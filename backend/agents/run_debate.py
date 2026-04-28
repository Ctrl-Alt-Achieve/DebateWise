#!/usr/bin/env python3
"""
Standalone script to run a debate crew for a given student input.
Called via subprocess.Popen from crew.py to ensure full process isolation
from Firebase's listener threads (avoids 'cannot schedule new futures after shutdown').
"""
import sys
import os

# Load environment variables
from dotenv import load_dotenv
load_dotenv()

# Map GOOGLE_API_KEY to GEMINI_API_KEY if needed
if os.environ.get("GOOGLE_API_KEY") and not os.environ.get("GEMINI_API_KEY"):
    os.environ["GEMINI_API_KEY"] = os.environ.get("GOOGLE_API_KEY")

def reset_crewai_event_bus():
    """
    Reset CrewAI's internal ThreadPoolExecutor to prevent
    'cannot schedule new futures after shutdown' errors.
    """
    try:
        print("[run_debate.py] Attempting to reset event bus...")
        from concurrent.futures import ThreadPoolExecutor
        print("[run_debate.py] ThreadPoolExecutor imported.")
        from crewai.events.event_bus import crewai_event_bus
        print("[run_debate.py] crewai_event_bus imported.")
        # Force a new executor
        crewai_event_bus._sync_executor = ThreadPoolExecutor(max_workers=1)
        print("[run_debate.py] CrewAI event bus executor reset successfully.")
    except Exception as e:
        print(f"[run_debate.py] Warning: Could not reset event bus: {e}")

def main():
    if len(sys.argv) < 2:
        print("[run_debate.py] ERROR: No student input provided.")
        sys.exit(1)
    
    student_input = sys.argv[1]
    print(f"\n[run_debate.py] Starting debate for: '{student_input}'")
    
    # Reset the event bus BEFORE importing crew (which imports crewai)
    reset_crewai_event_bus()
    
    try:
        print("[run_debate.py] Importing run_debate_crew from crew...")
        from crew import run_debate_crew
        print("[run_debate.py] run_debate_crew imported. Calling it...")
        run_debate_crew(student_input=student_input)
        print(f"\n[run_debate.py] Debate complete for: '{student_input[:50]}'")
    except Exception as e:
        print(f"[run_debate.py] ERROR: Debate failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
