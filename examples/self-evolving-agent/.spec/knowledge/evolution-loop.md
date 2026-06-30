---
topic: the mechanism — a trustworthy propose→evaluate→select→archive loop
decision: an objective evaluation gate (rejects regressions) + an archive + sandboxed/rollback-able application of the change
status: decided
captured: 2026-06-30
sources:
  - https://arxiv.org/abs/2505.22954     # DGM: empirical validation gate + archive + sandbox
  - https://arxiv.org/abs/2408.08435     # ADAS: search space / search algorithm / evaluation function
  - https://arxiv.org/abs/2507.21046     # survey: when/how to evolve
---

## The loop (downstream of "what it is")
```
        ┌───────────────────────────────────────────────┐
        ▼                                                 │
  propose change ──▶ apply in SANDBOX ──▶ EVALUATE vs ──▶ SELECT ──▶ ARCHIVE
  (to a chosen        (rollback-able)     objective       keep iff    (keep variants;
   component)                             signal          better      sample for next)
```

## The three non-negotiable parts (and their failure if missing)
| Part | Why load-bearing | Failure if absent |
|------|------------------|-------------------|
| **Objective evaluation gate** | decides what "better" means from outside the agent | self-grading ⇒ Goodhart / reward-hacking / drift |
| **Archive (open-ended search)** | retains good ancestors; samples to escape local optima | pure hill-climb ⇒ stuck / brittle (DGM & ADAS both archive) |
| **Sandbox + rollback** | a self-modification can break the agent | unsafe self-edit ⇒ unrecoverable corruption |

## The single most important invariant
**Evolution is gated by an objective signal that can REJECT a regression** — never
the agent's own self-assessment. This is the behavioral truth worth a probe
(gate G2): with the gate, a worse variant is rejected; remove the gate and a
regression is admitted.

## Recommendation
Build the loop first (gate + archive + sandbox/rollback), proven on a measurable
task, before widening the *layer* that evolves. The empirical-validation gate is
what separates real self-improvement (DGM: SWE-bench 20%→50%) from drift.

## Decision
Objective-gated loop + archive + sandbox/rollback · 2026-06-30 · **[auto]** (the
shared invariant across DGM/ADAS/surveys; not a human fork).

## Pinned knowledge (for execution)
- "Better" must be an **external** signal (benchmark/environment), versioned, and
  resistant to gaming; re-evaluate held-out to catch overfitting to the metric.
- Keep the **last-known-good** always restorable; apply changes behind a sandbox.
- Which *layer* evolves (prompt→…→code/weights) is the human's scope/safety fork.
