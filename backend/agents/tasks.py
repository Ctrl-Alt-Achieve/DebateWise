from crewai import Task

def get_debate_tasks(agents, topic, student_input=""):
    skeptic, overexplainer, questioner, arbiter = agents

    # The manager will dynamically decide which of these tasks to run based on the context.
    
    initial_explanation_task = Task(
        description=f"Provide an initial, overly-complex explanation of the topic: {topic}. Make sure to include dense technical jargon.",
        expected_output="A 3-4 sentence highly technical explanation.",
        agent=overexplainer
    )

    challenge_concept_task = Task(
        description=f"Analyze the previous statements or the student's input: '{student_input}'. Poke holes in the logic and challenge the assumptions.",
        expected_output="A sharp 3-4 sentence challenge highlighting a specific edge case or flaw.",
        agent=skeptic
    )

    foundation_question_task = Task(
        description=f"Ask a confused, foundational question about what was just discussed regarding {topic}.",
        expected_output="A 2-3 sentence basic question, slightly misremembering something.",
        agent=questioner
    )

    adjudicate_task = Task(
        description=f"Review the entire debate so far. Resolve the main dispute, fact-check the claims using the search tool, and declare what is objectively true regarding {topic}.",
        expected_output="A clear verdict, correcting errors and providing the final truth.",
        agent=arbiter
    )

    return [initial_explanation_task, challenge_concept_task, foundation_question_task, adjudicate_task]
