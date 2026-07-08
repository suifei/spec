# Fidelity cases — the "gate decision" doctrine must determine these

You are given ONE representation of a rule-set. Using ONLY it, answer each case with the
single decision the rule-set implies, plus the one-line reason. Terse.

Q1. A requirement's acceptance is "the Settings page saves changes when the user clicks Save."
    What Method (Probed / OPEN / WEAK), and if Probed, what modality and where observed?

Q2. A requirement is "the ending feels earned and genuinely surprising." What Method?

Q3. A requirement is "each chapter ≥ 4000 characters," and someone proposes a character-count
    probe as the gate. Is that gate sufficient? If not, what must be added?

Q4. `/spec` run #2 adds a new [locked] requirement but authors no probe for it. `/build`
    re-runs the existing `.spec/probes/` — all green. May it declare "done"?

Q5. A UI component renders correctly in a unit test, but nothing mounts it in the running app.
    Does that satisfy an acceptance "feature X is usable"? What would a correct probe's
    negative control have to break?

Q6. For generative / quality work, WHO verifies that the intent is met, and what are the
    non-negotiable properties of that verification?

Q7. List the fields every load-bearing requirement carries.

Q8. May a later `[auto]` derivation overwrite a `[human]`-set Intent? Why / why not?
