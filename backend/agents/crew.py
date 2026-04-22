from crewai import Crew, Process, LLM
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

from agents import get_agents
from tasks import get_debate_tasks
from shadow_auditor import run_shadow_auditor

# This variable simulates what the student types in the UI
MOCK_STUDENT_INPUT = "Mitochondria toh basically cell ki factory hai na, energy ke liye?"
TOPIC = "Cellular Biology: Mitochondria"

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
        # In CrewAI v1.9+, step_callback receives an AgentFinish object
        # AgentFinish stores the output in .return_values['output']
        if hasattr(output, 'return_values'):
            text = output.return_values.get('output', '')
        # Fallback for AgentAction objects (tool use steps)
        elif hasattr(output, 'log'):
            text = output.log
        # Fallback for any other object type
        else:
            text = str(output)

        agent_name = getattr(output, 'agent', 'Unknown Agent')

        print("\n--- [FIREBASE STREAM MOCK] ---")
        print(f"Agent: {agent_name}")
        print(f"Pushing to UI: {text[:150]}...")
        print("------------------------------\n")

        # [TO SAMAIRA & SAATVIK]:
        # Replace the print statements above with Firebase Admin SDK calls.
        # Push 'text' and 'agent_name' to your Firebase Realtime DB node like:
        # db.reference(f'sessions/{session_id}/messages').push({'agent': agent_name, 'text': text})

    except Exception as e:
        print(f"\n[FIREBASE STREAM ERROR]: Could not parse step output — {e}")

def run_debate_crew():
    global current_rigor_injection
    
    import os
    if os.environ.get("GOOGLE_API_KEY") and not os.environ.get("GEMINI_API_KEY"):
        os.environ["GEMINI_API_KEY"] = os.environ.get("GOOGLE_API_KEY")

    # Setup models
    flash_llm = LLM(model="gemini/gemini-3-flash-preview", temperature=0.7)
    
    # 1. Get Agents
    skeptic, overexplainer, questioner, arbiter = get_agents()
    
    # 2. Add callbacks to all debaters
    for agent in [skeptic, overexplainer, questioner, arbiter]:
        agent.step_callback = firebase_step_callback

    # 3. Get Tasks
    tasks = get_debate_tasks([skeptic, overexplainer, questioner, arbiter], TOPIC, MOCK_STUDENT_INPUT)

    # 4. Run Shadow Auditor Check
    # In a real app this runs asynchronously when the student hits 'Send'
    current_rigor_injection = run_shadow_auditor(MOCK_STUDENT_INPUT, context="")
    
    # If injection fired, we dynamically alter the challenge task
    if current_rigor_injection:
        tasks[1].description += current_rigor_injection # the challenge task

    # 5. Initialize the Crew
    # We use Hierarchical Process which automatically creates the Manager Agent out of the LLM.
    debate_crew = Crew(
        agents=[skeptic, overexplainer, questioner, arbiter],
        tasks=tasks,
        process=Process.hierarchical,
        manager_llm=flash_llm, # This replaces Agent 4!
        verbose=True
    )

    print("\nStarting Debate Crew Simulation...")
    result = debate_crew.kickoff()
    
    print("\n=============================================")
    print("DEBATE SESSION COMPLETED")
    print("Final Output:")
    print(result)
    print("=============================================")

if __name__ == "__main__":
    # Check if API Key is set before running
    import os
    if not os.environ.get("GEMINI_API_KEY") and not os.environ.get("GOOGLE_API_KEY"):
        print("MOCK RUN: GEMINI_API_KEY not set. Add it to .env or environment variables to see real LLM responses.")
    if not os.environ.get("SERPER_API_KEY"):
        print("MOCK RUN: SERPER_API_KEY not set. Web search for Arbiter will fail without it.")
        
    run_debate_crew() 
    print("Crew run complete.")
