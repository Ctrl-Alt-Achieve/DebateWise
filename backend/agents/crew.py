from crewai import Crew, Process, LLM
from dotenv import load_dotenv

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

def firebase_step_callback(output):
    """
    CrewAI step_callback hook.
    This acts as the 'Live Reporter'.
    Receives either an AgentFinish or AgentAction object from CrewAI.
    """
    try:
        text = ""
        agent_name = "Agent"

        # Try to get the clean output text
        if hasattr(output, 'result'):
            text = str(output.result)
        elif hasattr(output, 'output'):
            text = str(output.output)
        elif hasattr(output, 'return_values') and isinstance(output.return_values, dict):
            text = output.return_values.get('output', str(output))
        elif hasattr(output, 'log'):
            text = output.log
        else:
            text = str(output)

        # Try to get the agent name
        if hasattr(output, 'agent') and output.agent:
            agent_name = str(output.agent)
        
        # Skip empty or very short outputs
        if not text or len(text.strip()) < 5:
            return

        print(f"\n--- [FIREBASE STREAM] ---")
        print(f"Agent: {agent_name}")
        print(f"Pushing to UI: {text[:150]}...")
        print("------------------------------\n")

        push_agent_message("default_session", agent_name, text)

    except Exception as e:
        print(f"\n[FIREBASE STREAM ERROR]: Could not parse step output — {e}")

def run_debate_crew(student_input):
    if not init_firebase():
        print("[WARNING] Firebase not initialized. Running without live DB stream.")
    global current_rigor_injection
    
    import os
    if os.environ.get("GOOGLE_API_KEY") and not os.environ.get("GEMINI_API_KEY"):
        os.environ["GEMINI_API_KEY"] = os.environ.get("GOOGLE_API_KEY")

    # Setup models
    flash_llm = LLM(model="gemini/gemini-3-flash-preview", temperature=0.7)
    
    # 1. Get Agents
    skeptic, overexplainer, questioner, arbiter = get_agents()

    # 3. Get Tasks — use the student's input as the topic
    tasks = get_debate_tasks([skeptic, overexplainer, questioner, arbiter], student_input, student_input)

    # 4. Run Shadow Auditor Check
    # In a real app this runs asynchronously when the student hits 'Send'
    current_rigor_injection = run_shadow_auditor(student_input, context="", verbose=True)
    
    # If injection fired, we dynamically alter the challenge task
    if current_rigor_injection:
        tasks[1].description += current_rigor_injection # the challenge task

    def task_output_callback(task_output):
        """Called when each task completes. Push the result to Firebase."""
        try:
            # Extract agent name — try multiple paths since CrewAI stores it differently
            agent_name = "Agent"
            agent_obj = getattr(task_output, 'agent', None)
            if agent_obj:
                # agent_obj might be a string or an Agent object with a .role
                if hasattr(agent_obj, 'role'):
                    agent_name = agent_obj.role
                else:
                    agent_name = str(agent_obj)
            
            # Also try the 'name' attribute on the TaskOutput
            if agent_name == "Agent":
                agent_name = getattr(task_output, 'name', 'Agent')

            raw_output = getattr(task_output, 'raw', '') or str(task_output)
            
            # Clean up agent name — remove "The " prefix for cleaner display
            clean_name = str(agent_name).strip()
            
            print(f"\n--- [TASK COMPLETE -> FIREBASE] ---")
            print(f"Agent: {clean_name}")
            print(f"Output: {raw_output[:200]}...")
            print("-----------------------------------\n")
            
            push_agent_message("default_session", clean_name, raw_output)
        except Exception as e:
            print(f"[TASK CALLBACK ERROR]: {e}")

    # 5. Initialize the Crew
    # We use Hierarchical Process which automatically creates the Manager Agent out of the LLM.
    debate_crew = Crew(
        agents=[skeptic, overexplainer, questioner, arbiter],
        tasks=tasks,
        process=Process.hierarchical,
        manager_llm=flash_llm,
        verbose=False,
        task_callback=task_output_callback,
    )

    print("\nStarting Debate Crew Simulation...")
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

    def listener(event):
        print(f"[DEBUG] Firebase Event Received! Type: {event.event_type}, Path: {event.path}")
        print(f"[DEBUG] Raw Data: {event.data}")
        
        if event.data is None:
            return
            
        # If event.data is a dict, it might be the initial snapshot or a new push
        # We iterate through all items to find ones we haven't processed yet
        items_to_process = []
        if isinstance(event.data, dict):
            # Check if it's a single message (if path is deep) or a collection
            if 'text' in event.data and 'agent' in event.data:
                items_to_process = [event.data]
            else:
                # It's a collection of messages indexed by random keys
                for key, val in event.data.items():
                    if key not in processed_inputs:
                        items_to_process.append(val)
                        processed_inputs.add(key)
        
        for item in items_to_process:
            text = item.get('text', '')
            agent = item.get('agent', '')
            
            if agent == 'User' and text:
                print(f"\n>> Received new User input: '{text}'")
                print(">> Kicking off Debate Crew...")
                try:
                    run_debate_crew(student_input=text)
                    print("\n>> Ready for next input...")
                except Exception as e:
                    print(f"[ERROR] Debate run failed: {e}")

    # Listen for new child added to the inputs node
    ref = db.reference('sessions/default_session/inputs')
    # Using listen() to wait for new children
    try:
        ref.delete()
    except Exception as e:
        print(f"[WARNING] Could not clear old inputs (maybe database is empty or URL is incorrect): {e}")
    
    # We can't easily listen to just 'child_added' in Python Firebase Admin exactly like JS,
    # but listen() triggers on any changes. To make it only trigger on new items,
    # we can process event and keep track of processed keys if we wanted to.
    # However, since we clear it, any new data added will trigger this.
    ref.listen(listener)
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nShutting down backend listener.")

if __name__ == "__main__":
    # Check if API Key is set before running
    import os
    if not os.environ.get("GEMINI_API_KEY") and not os.environ.get("GOOGLE_API_KEY"):
        print("MOCK RUN: GEMINI_API_KEY not set. Add it to .env or environment variables to see real LLM responses.")
    if not os.environ.get("SERPER_API_KEY"):
        print("MOCK RUN: SERPER_API_KEY not set. Web search for Arbiter will fail without it.")
        
    listen_for_inputs()
