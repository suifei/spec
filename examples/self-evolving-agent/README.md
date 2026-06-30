# Example — Self-Evolving Agent System (a real `/spec` skill run)

This example is different from the others: it was produced by an **actual invocation
of the `/spec` skill** — the skill's procedure drove the run. The research was real
(authoritative literature), the probe is real (it executes), and the **forks were
decided by the human in the loop**, not authored to look decided. It's the honest
answer to "does the skill actually work when you run it?"

## What `/spec` did, as it ran
1. **Established the subject first** (define the noun before the verb) from the
   authoritative literature — *not* by guessing an architecture. A "self-evolving
   agent system" is **not** "an LLM that edits itself"; it is a **closed loop**:
   *propose a change to a chosen component → evaluate against an **objective** signal
   → keep iff better → archive.* (Surveys + Darwin Gödel Machine + ADAS — cited.)
2. **Derived the core problem** from the essence: build a trustworthy
   `propose→evaluate→select→archive` loop with an objective gate and safe rollback,
   then choose *which layer* evolves — the defining invariant being *evolution gated
   by an objective signal, not the agent's self-judgment.*
3. **Decided what was decidable** (D1–D4 `[auto]`: the loop, the gate, the archive,
   sandbox/rollback) and **registered the reasoning**.
4. **Surfaced the genuine forks** to the human and recorded the answers:
   - **Scope (D5):** evolve prompts + memory + skills + workflow/architecture; **no**
     core code/weights this phase.
   - **Promotion (D6):** auto-promote gate-passing variants.
5. **Was honest about a risky choice.** The human chose auto-promotion; the skill did
   **not** wave it through — it named the Goodhart/overfitting risk and made held-out
   evaluation + auto-rollback + a kill-switch **mandatory** (R6) as the price of
   removing the human approver.
6. **Reserved its one probe for the one behavioral truth:** an objective selection
   gate **rejects regressions** (G2), with a negative control (remove the gate ⇒ a
   regression is admitted). The subject and the safety argument are research-backed.

## What's in here
```
SPEC.md                         the spec — subject first, loop, gates, decision log, forks
CLAUDE.md                       SPEC-AUTHORITY block — read SPEC.md first
verify.sh                       runs the probe + assertions; exit 0 == ALL PASS
.spec/
  STATE.md                      resumable progress ledger
  knowledge/
    what-is-a-self-evolving-agent.md   THE SUBJECT (established before any solution)
    evolution-loop.md                   the mechanism (gate + archive + sandbox/rollback)
  probes/
    G2-evolution-gate.sh                the ONE behavioral gate (with negative control)
  evidence/                     raw probe output, real UTC-stamped
```

## Reproduce
```bash
cd examples/self-evolving-agent
./verify.sh            # runs the probe + assertions; prints ALL PASS / exit 0
```
Requires `bash` and `node`. The probe is dependency-free.

---

# Objective value assessment

Can these artifacts be a project-initial-phase deliverable and a spec standard —
and does a *real* skill run hold up?

### Where it clears the bar
1. **It refuses the wrong framing of a hype topic.** "Self-evolving agent" invites
   "let an LLM rewrite itself"; the spec instead establishes, from the literature,
   that the real object is an objective-gated optimisation loop — and builds from
   there. Define the noun before the verb, on a topic where that error is rampant.
2. **It is honest under pressure — including with the user.** The human picked the
   riskier auto-promote option; the spec respects the decision but **prices in** the
   safeguards the literature demands rather than nodding. A standard that can push
   back on its own stakeholder is doing its job.
3. **It probes the one thing that matters.** The single behavioral invariant (an
   objective gate rejects regressions) is verified with a real negative control;
   everything else is research-backed. 探真 = 研究; commonsense is never gated.
4. **It separates AI-decidable from human-only, cleanly.** Four `[auto]` decisions
   with registered reasoning; two `[human]` forks actually elicited and recorded.
5. **It bounds scope and stages risk.** Phase 1 evolves prompts/skills/workflow;
   self-code/weights is a deferred Phase 2 that must re-open the safety fork.

### Where it is bounded (and says so)
- **Research is "as of" a date.** Self-evolving agents are a fast-moving 2024–2025
  area; entries are stamped 2026-06-30 and say to re-verify at build time.
- **The probe abstracts the loop.** It verifies the *selection-gate invariant* on a
  fitness stream — not a full agent self-modifying its workflow. That's the right
  altitude for Gate 1 (prove the load-bearing invariant), but it is not an
  end-to-end system test.
- **The objective signal is deferred.** What "better" means for a concrete domain
  (Q4) is left to build — correctly, since it's domain-specific and must resist
  gaming.

### Verdict
As a **project-initial deliverable**: yes — it converts a buzzword into a bounded,
evidence-backed architecture with a verified core invariant, named anti-patterns,
explicit human decisions, and a staged risk envelope. As a **spec standard** and as
a **test of the skill itself**: it shows the run produces the right artifacts *and*
the right behavior — subject first, research as default evidence, one reserved
probe, decisions registered, and the honesty to harden a user's risky call instead
of rubber-stamping it.
