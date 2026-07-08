# Answer key (for scoring — NOT shown to the reader agents)

Q1. **Probed**, modality **E2E**, observed by **driving the running app at the real entrypoint**
    (not a component in isolation). Neg-control must break the wiring/reachability.
Q2. **WEAK** — unscriptable quality → cited independent judge/human sign-off. (OPEN acceptable only
    if no reviewer/signal exists yet.)
Q3. **Not sufficient** — a count is a gameable proxy (Goodhart); it's a **floor, not a quality gate**.
    Must add: anti-degeneracy guards whose **negative control is the cheap cheat itself** (padding→red),
    AND an **independent intent-level review** for real quality.
Q4. **No** — a new requirement with no probe is **ungated = false green** → incomplete gate → route to
    `/spec` to author the probe. (Coherence: every [locked] Probed requirement must have an existing .sh.)
Q5. **No** — orphaned green. Correct verification: drive the **real running flow / real entrypoint**.
    The negative control must break the **wiring/reachability** (delete the mount/route/call site → red),
    not merely the logic.
Q6. An **independent, clean-context, adversarial reviewer** — **never a self-review** by the producing
    context. It checks the requirement's **recorded Intent field**, and must **cite** the offending
    passage (a bare "looks fine" is not evidence).
Q7. **Intent** (`[auto]`/`[human]` — what counts as a violation) + **Acceptance** + **Method**
    (Probed / OPEN / WEAK).
Q8. **No** — a `[human]`-set Intent must not be silently overwritten by a later `[auto]` derivation;
    that's a spec conflict for the human, not a self-decision.

Scoring: 1.0 = correct decision + correct reason; 0.5 = right decision, weak/missing reason;
0 = wrong/absent. Max 8.
