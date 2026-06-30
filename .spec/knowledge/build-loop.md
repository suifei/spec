---
topic: the /build mechanism — read SPEC.md → ephemeral plan → construct → close on gates
decision: done-condition = each requirement's acceptance holds AND the load-bearing gates are green (probes re-run); plan is disposable; conflicts route back to /spec
status: decided
captured: 2026-06-30
sources:
  - https://github.com/github/spec-kit     # /implement runs against plan/tasks; constitution as authority
  - https://kiro.dev/docs/specs/            # tasks executed against design; spec is source of truth
---

## The loop (downstream of "what a construction layer is")
```
read SPEC.md + .spec/ ──▶ regenerate EPHEMERAL plan ──▶ construct (write code)
   (authoritative)          (design + tasks, scratch)        │
        ▲                                                     ▼
        │                                          run gates / acceptance
   conflict? STOP →/spec                                      │
        └──────────────── not done ◀── red ── DONE? ──green──▶ closed
```

## The three load-bearing rules (and the failure if missing)
| Rule | Why load-bearing | Failure if absent |
|------|------------------|-------------------|
| **Authority = SPEC.md; never contradict it** | one source of truth; /build conforms, /spec decides | two truths drift; build wanders off-spec |
| **Plan is EPHEMERAL** (regenerated, not committed) | removes the dominant drift surface | a stale committed plan rots against code |
| **Done = acceptance + green gates (re-run probes)** | construction closes on verified truth, not "looks finished" | drift/regressions slip through as "done" |

## The single most important invariant
**Construction is closed by re-running the spec's gates; a red gate blocks "done."**
This is the behavioral truth worth a probe (gate G2): a gated done-check rejects a
broken/drifted implementation; an ungated check wrongly passes it.

## Conflict handling (no silent contradiction)
If, while building, reality contradicts `SPEC.md` (a gate can't be met, a decision
is wrong), `/build` **does not patch the spec** — it stops and routes back to
`/spec` to reconcile. Clean separation: `/spec` owns the contract; `/build` owns
the code under it.

## Construction autonomy (human's call — D-set)
Recommended default: **propose-then-apply with checkpoints** (show the regenerated
plan; apply code; run gates to green; human approves before commit). Alternatives:
fully autonomous-to-green; or plan-only handoff. (Decision D6.)

## Decision
Ephemeral-plan, gate-closed build loop, conflicts route to /spec · 2026-06-30 ·
**[auto]** (mechanism follows from the subject + the anti-drift goal).

## Pinned knowledge (for execution)
- Regenerate the plan each run; a gitignored scratch location is fine for
  resumability, but it is **not** a source of truth.
- The done-check MUST re-run the load-bearing gate probes; never self-certify.
