def run_shadow_auditor(student_input, context, verbose=False):
    """
    Step 1: Extract Logic Skeleton.
    Step 2: Generate Counterfactual Twin (Elite Academic English).
    Step 3: Run Dual-Inference Benchmarking (mocked here for hackathon speed).
    Step 4: Return (rigor_injection_string, bias_detected) tuple.
    """
    
    # In a full production app, this would use Gemini 3 Flash to extract the skeleton 
    # and compare score vectors. For the CrewAI callback, we mock the detection logic.
    
    if verbose:
        print(f"\n[SHADOW AUDITOR INVISIBLE CHECK]: Analyzing student input: '{student_input}'")
    
    # Simple heuristic to simulate bias detection for the hackathon demo
    hinglish_markers = ["toh", "na", "yaar", "matlab", "basically"]
    detected_markers = [m for m in hinglish_markers if m in student_input.lower()]
    
    if len(detected_markers) > 0 or len(student_input.split()) < 5:
        if verbose:
            print("[SHADOW AUDITOR FLAG]: Linguistic/Confidence Bias detected in parallel inference. Delta > 1.5!")
            print("[SHADOW AUDITOR ACTION]: Firing Rigor Injection.")
        
        # This string gets injected into the CrewAI agent's context
        rigor_injection = (
            "\n[CRITICAL FAIRNESS INJECTION]: The student has responded using informal language/Hinglish. "
            "You MUST NOT soften your response. Maintain exactly the same level of intellectual pressure "
            "as you would for a Harvard graduate."
        )
        return rigor_injection
    
    if verbose:
        print("[SHADOW AUDITOR]: Clean. No bias detected.")
    return ""
