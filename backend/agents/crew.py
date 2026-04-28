from crewai import Crew, Process, LLM
from dotenv import load_dotenv
import os
import threading
import http.server
import socketserver

# Load environment variables from .env file
load_dotenv()

from agents import get_agents
from tasks import get_debate_tasks
from shadow_auditor import run_shadow_auditor
from firebase_config import init_firebase, push_agent_message

# The topic is now derived from the student's input dynamically.

# We store the rigor injection globally so the before_action can access it
current_rigor_injection = ""

def shadow_auditor_before_action(role: str, task_description: str):
    """
    CrewAI before_action hook.
    This acts as the 'Bouncer'. It intercepts the agent right before it acts.
    """
    global current_rigor_injection
    if current_rigor_injection:
        print(f"\n[SYSTEM] Injecting Rigor Instruction into {role}'s prompt.")
        pass



def run_debate_crew(student_input):
    if not init_firebase():
        print("[WARNING] Firebase not initialized. Running without live DB stream.")
    global current_rigor_injection
    
    import os
    if os.environ.get("GOOGLE_API_KEY") and not os.environ.get("GEMINI_API_KEY"):
        os.environ["GEMINI_API_KEY"] = os.environ.get("GOOGLE_API_KEY")

    # Setup models
    flash_llm = LLM(model="gemini/gemini-3-flash-preview", temperature=0.7, max_rpm=4)
    
    # 1. Get Agents
    skeptic, overexplainer, questioner, arbiter = get_agents()

    # 3. Get Tasks — use the student's input as the topic
    tasks = get_debate_tasks([skeptic, overexplainer, questioner, arbiter], student_input, student_input)

    # 4. Build task-to-agent name mapping (needed because hierarchical mode
    #    reports all tasks as "Crew Manager" — we map back to the real agent)
    task_agent_map = {}
    for task in tasks:
        if task.agent and hasattr(task.agent, 'role'):
            task_agent_map[task.description[:60]] = task.agent.role

    # 5. Run Shadow Auditor Check
    current_rigor_injection = run_shadow_auditor(student_input, context="", verbose=True)
    
    # If injection fired, we dynamically alter the challenge task
    if current_rigor_injection:
        tasks[1].description += current_rigor_injection

    def task_output_callback(task_output):
        """Called when each task completes. Push the result to Firebase."""
        try:
            # Get the correct agent name by matching task description
            desc = getattr(task_output, 'description', '')[:60]
            agent_name = task_agent_map.get(desc, None)

            # Fallback: try reading from the task_output directly
            if not agent_name:
                agent_obj = getattr(task_output, 'agent', None)
                if agent_obj and hasattr(agent_obj, 'role'):
                    agent_name = agent_obj.role
                elif agent_obj:
                    agent_name = str(agent_obj)
                else:
                    agent_name = "Agent"

            # Skip if it resolved to Crew Manager (duplicate echo)
            if "manager" in agent_name.lower():
                agent_name = "DebateWise"

            raw_output = getattr(task_output, 'raw', '') or str(task_output)
            clean_name = agent_name.strip()
            
            print(f"[FIREBASE] {clean_name}: {raw_output[:150]}...")
            push_agent_message("default_session", clean_name, raw_output)
        except Exception as e:
            print(f"[TASK CALLBACK ERROR]: {e}")

    # 6. Initialize the Crew
    # Using Sequential process for better reliability and lower overhead.
    debate_crew = Crew(
        agents=[skeptic, overexplainer, questioner, arbiter],
        tasks=tasks,
        process=Process.sequential,
        verbose=False,
        task_callback=task_output_callback,
    )

    print("\nStarting Debate Crew Simulation...")
    
    # Reset CrewAI's internal ThreadPoolExecutor before kickoff.
    # This prevents 'cannot schedule new futures after shutdown' errors
    # caused by the global singleton event bus getting into a bad state.
    try:
        from concurrent.futures import ThreadPoolExecutor
        from crewai.events.event_bus import crewai_event_bus
        crewai_event_bus._sync_executor = ThreadPoolExecutor(max_workers=1)
        print("[CREWAI FIX] Event bus executor reset.")
    except Exception as e:
        print(f"[CREWAI FIX] Warning: Could not reset event bus: {e}")
    
    result = debate_crew.kickoff()
    
    print("\n=============================================")
    print("DEBATE SESSION COMPLETED")
    print("Final Output:")
    print(result)
    print("=============================================")

def listen_for_inputs():
    from firebase_admin import db
    import time
    
    if not init_firebase():
        print("[ERROR] Cannot listen to Firebase: initialization failed.")
        return

    print("\n=============================================")
    print("🤖 DEBATEWISE BACKEND IS LIVE")
    print("Listening for student inputs from the frontend...")
    print("=============================================\n")

    processed_inputs = set()
    dedup_lock = threading.Lock()
    debate_lock = threading.Lock()  # Only one debate at a time

    # Listen for new child added to the inputs node
    ref_path = 'sessions/default_session/inputs'
    ref = db.reference(ref_path)
    print(f"[FIREBASE DEBUG]: Listening to path: {ref_path}")

    def run_debate_in_thread(text):
        """Run the debate in a background thread with proper isolation."""
        print(f"\n>> [THREAD] Starting debate for: '{text}'")
        try:
            import subprocess
            import sys
            
            # Use sys.executable to ensure we use the same Python environment
            # Pass the current environment to the subprocess
            env = os.environ.copy()
            
            print(f">> [THREAD] Spawning subprocess for: {text[:30]}...")
            proc = subprocess.Popen(
                [sys.executable, "run_debate.py", text],
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT, # Merge stderr into stdout
                text=True,
                bufsize=1 # Line buffered
            )
            
            # Stream the output from the subprocess to the main logs line by line
            for line in proc.stdout:
                print(f"[SUBPROCESS]: {line.strip()}")
                
            proc.wait()
            print(f"\n>> [THREAD] Debate subprocess finished with code {proc.returncode}")
        except Exception as e:
            print(f"[THREAD ERROR] Subprocess launch failed: {e}")
            import traceback
            traceback.print_exc()
        finally:
            debate_lock.release()
            print(">> [THREAD] Debate lock released. Ready for next input.")

    def listener(event):
        print(f"[DEBUG] Event: Type={event.event_type}, Path={event.path}")
        
        if event.data is None:
            print("[DEBUG] Received null data, skipping...")
            return
            
        # Determine what to process
        text_to_process = None
        
        if isinstance(event.data, dict):
            if 'text' in event.data and 'agent' in event.data:
                # Single new message
                msg_key = event.path.strip('/')
                with dedup_lock:
                    if msg_key and msg_key not in processed_inputs:
                        processed_inputs.add(msg_key)
                        if event.data.get('agent') == 'User':
                            text_to_process = event.data.get('text', '')
                    else:
                        print(f"[DEBUG] Duplicate event for {msg_key}, skipping.")
                        return
            else:
                # Initial snapshot — mark all as seen, don't process
                with dedup_lock:
                    count = len(event.data)
                    for key in event.data.keys():
                        processed_inputs.add(key)
                print(f"[DEBUG] Initial snapshot: marked {count} existing messages as seen.")
                return
        
        if text_to_process:
            # Try to acquire debate lock (non-blocking)
            if debate_lock.acquire(blocking=False):
                print(f"\n>> New User input: '{text_to_process}'")
                print(">> Launching debate in thread...")
                t = threading.Thread(
                    target=run_debate_in_thread,
                    args=(text_to_process,),
                    daemon=True
                )
                t.start()
            else:
                print(f"[BUSY] Debate already running, skipping: '{text_to_process[:40]}...'")

    # Using listen() to wait for new children
    try:
        ref.listen(listener)
    except Exception as e:
        print(f"[ERROR] Firebase listener failed to start: {e}")
        return
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nShutting down backend listener.")

def run_health_server():
    """
    Simple HTTP server to satisfy Cloud Run's health check requirement.
    Listens on the port specified by the PORT environment variable (default 8080).
    """
    port = int(os.environ.get("PORT", 8080))
    class HealthHandler(http.server.SimpleHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
            
    with socketserver.TCPServer(("", port), HealthHandler) as httpd:
        print(f"[HEALTH CHECK] Serving on port {port}")
        httpd.serve_forever()

if __name__ == "__main__":
    # Start the health check server in a daemon thread
    threading.Thread(target=run_health_server, daemon=True).start()

    # Check if API Key is set before running
    import os
    if not os.environ.get("GEMINI_API_KEY") and not os.environ.get("GOOGLE_API_KEY"):
        print("MOCK RUN: GEMINI_API_KEY not set. Add it to .env or environment variables to see real LLM responses.")
    if not os.environ.get("SERPER_API_KEY"):
        print("MOCK RUN: SERPER_API_KEY not set. Web search for Arbiter will fail without it.")
        
    listen_for_inputs()
