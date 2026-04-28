import os
from crewai import Agent, Task, Crew, LLM

def test_crewai():
    print("Testing CrewAI import and initialization...")
    try:
        # Initialize a minimal agent
        llm = LLM(model="gemini/gemini-1.5-flash", temperature=0.7)
        agent = Agent(
            role="Tester",
            goal="Test if CrewAI is working",
            backstory="A test agent",
            llm=llm,
            verbose=True
        )
        print("Agent initialized successfully.")
        
        # Initialize a minimal task
        task = Task(
            description="Say 'CrewAI is working!'",
            expected_output="A confirmation message.",
            agent=agent
        )
        print("Task initialized successfully.")
        
        # Initialize a crew
        crew = Crew(
            agents=[agent],
            tasks=[task],
            verbose=True
        )
        print("Crew initialized successfully.")
        
        # Test event bus
        from crewai.events.event_bus import crewai_event_bus
        print(f"Event bus executor: {crewai_event_bus._sync_executor}")
        
        return True
    except Exception as e:
        print(f"CrewAI test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    test_crewai()
