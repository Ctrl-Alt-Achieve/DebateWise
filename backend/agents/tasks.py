from crewai import Task

def get_debate_tasks(agents, topic, student_input=""):
    skeptic, overexplainer, questioner, arbiter = agents

    # The manager will dynamically decide which of these tasks to run based on the context.
    
    initial_explanation_task = Task(
        description=f"Provide a technical explanation of the topic: {topic}. Use bullet points, not paragraphs. Be dense but concise.",
        expected_output="A headline definition followed by 2-3 bullet points of technical detail. Under 80 words.",
        agent=overexplainer
    )

    challenge_concept_task = Task(
        description=f"Analyze the student's input: '{student_input}'. Identify the weakest assumption and challenge it directly. Use bullet points.",
        expected_output="A one-line thesis of what's wrong, followed by 2-3 bullet-point flaws. Under 80 words.",
        agent=skeptic
    )

    foundation_question_task = Task(
        description=f"Ask 1-2 confused, foundational questions about {topic} that reveal a genuine misconception.",
        expected_output="Exactly 1-2 short questions, no preamble. Under 40 words.",
        agent=questioner
    )

    adjudicate_task = Task(
        description=f"Review the entire debate about {topic}. Deliver a structured verdict: who was right, what errors were made, and the factual truth. Use the search tool to verify claims.",
        expected_output="Verdict (1 sentence), Errors Found (bullet list), The Truth (2-3 bullets). Under 100 words.",
        agent=arbiter
    )

    return [initial_explanation_task, challenge_concept_task, foundation_question_task, adjudicate_task]
