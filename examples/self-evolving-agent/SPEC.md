# Self-Evolving Agent System — Specification

> **Version:** v1 · **Updated:** 2026-06-30
> **Closure:** Phase 1 ✅ sealed 2026-06-30 (loop + scope + safety settled) · Phase 2 ⏳ open
>
> Authoritative, highest-priority reference. Maintained by `/spec`. Load-bearing
> gates are backed by evidence — a runnable probe where the truth is behavioral, a
> cited source where it isn't. Research lives in `.spec/knowledge/`. All times are
> real OS time (UTC). A lower bound on verified truth, not a proof.
>
> *Produced by an actual `/spec` skill run (not a hand-authored mock): real web
> research of the authoritative literature, a real runnable probe, and the human's
> own decisions on the genuine forks (recorded in the Decision Log).*

## 1. Subject & Core Problem
**First, what a "self-evolving agent system" *is* (define the noun before the
verb).** Per the 2024–2025 literature, it is **not** "an LLM that edits itself." It
is a **closed evolution loop**: *propose a change to a chosen agent component →
evaluate the variant against an **objective** signal → keep it only if measurably
better → **archive** it for open-ended search.* The component that evolves is a
**spectrum**: prompts → memory → tools → workflow/architecture → the agent's own
code → model weights ([survey, arXiv 2507.21046](https://arxiv.org/abs/2507.21046)).
Leading systems instantiate the same loop: the **Darwin Gödel Machine** rewrites
its own code and **empirically validates each change on real benchmarks** (SWE-bench
20%→50%), keeping an archive in a sandbox ([arXiv 2505.22954](https://arxiv.org/abs/2505.22954));
**ADAS / Meta Agent Search** evolves agent *designs* in code via search space +
search algorithm + **evaluation function** ([arXiv 2408.08435](https://arxiv.org/abs/2408.08435)).
(Sources in `.spec/knowledge/what-is-a-self-evolving-agent.md`.)

**Therefore the core problem is not "let an agent modify itself."** It is **building
a trustworthy `propose → evaluate → select → archive` loop with an objective fitness
signal and safe rollback — and then choosing *which layer* may evolve.** The
defining invariant: **evolution is gated by an objective evaluation, not the agent's
self-judgment.** Drop that gate and "self-evolution" degrades into drift / Goodhart
/ reward-hacking. Success = the agent measurably improves at a real task over
generations, *never regresses below its last-known-good, and never exceeds its
allowed scope.*

## 2. Scope & boundaries
**In scope (Phase 1)** — the gated evolution loop (**objective gate + archive +
sandbox/rollback**) over the **chosen layers: prompts, memory, the skill/tool
library, and workflow/architecture** (ADAS-style); **automatic promotion** of
gate-passing variants, hardened with held-out evaluation + auto-rollback +
kill-switch.

**Out of scope / boundaries** — modifying the agent's **own core code or model
weights** (→ Phase 2, behind stronger safety); building the base LLM; a specific
production task/benchmark (domain-chosen at build).

**Anti-patterns (deliberately don't do)** — the traps:
- **Self-grading without an external objective signal.** The agent scoring itself
  invites Goodhart / reward-hacking; "better" must come from outside (benchmark/env).
- **No archive / pure hill-climbing.** Loses good ancestors and sticks in local
  optima — DGM and ADAS both keep an archive for open-ended search.
- **Auto-promoting on a single in-sample metric with no held-out check or rollback.**
  This is the specific risk of the chosen auto-promote path (see D6); mandatory
  mitigations in R6.
- **Modifying core code/weights in this phase.** Out of the chosen scope; deferred.
- **Jumping to "let it rewrite itself" before establishing the loop and the layer.**
  The define-the-noun-before-the-verb trap.

## 3. Gates (load-bearing sources of truth)
Only **load-bearing** gates. **Commonsense facts are deliberately *not* gated.**
Status ∈ {unverified, ✅ verified, ❌ refuted, ⤳ deferred→Phase N}.

| Gate | Decision it gates | Authoritative source | Invariant | Evidence | Last checked (UTC/where) | Status |
|------|-------------------|----------------------|-----------|----------|--------------------------|--------|
| G1 | the subject: what "self-evolving" means | self-evolving-agent surveys + DGM + ADAS | it's a propose→evaluate→select→archive loop gated by an objective signal, over a chosen layer | research (cited) | 2026-06-30 / web | ✅ verified (research) |
| G2 | the core invariant of the loop | runnable probe | an objective selection gate REJECTS regressions; remove it and a regression is admitted | `.spec/probes/G2-evolution-gate.sh` | 2026-06-30T00:48Z / vm | ✅ verified (probe) |
| G3 | safety of the chosen auto-promote path | reward-hacking / overfitting literature (DGM, surveys) | metric-gaming/overfitting is the dominant failure ⇒ auto-promotion needs held-out eval + auto-rollback + kill-switch | research (cited) | 2026-06-30 / web | ✅ verified (research) |

### Gate detail
#### G1 — the subject (research; established before any architecture)
- **Decision it gates:** what the project even is. If "self-evolving" meant
  unconstrained self-editing rather than a gated optimisation loop, every downstream
  choice would differ.
- **Finding:** the surveys + DGM + ADAS converge on one loop —
  propose→evaluate→select→archive, gated by an **objective** signal, over a chosen
  component layer; empirical validation (not the impractical "provable" Gödel
  machine). See `.spec/knowledge/what-is-a-self-evolving-agent.md`,
  `evolution-loop.md`.
- **Status:** ✅ verified (research) — 2026-06-30.

#### G2 — objective gate rejects regressions (runnable probe)
- **Decision it gates:** the one behavioral invariant the whole system rests on. If
  the loop can't reject a regression, self-evolution degrades. Behavioral ⇒ probe.
- **Probe:** `.spec/probes/G2-evolution-gate.sh` runs the loop over a fixed sequence
  of variant fitnesses containing a **planted regression**. With the gate the best
  stays monotonic and the regression is rejected; **negative control:** removing the
  gate (accept-all) admits the regression — proving the probe can go red.
- **Evidence (raw):** `gated best [0.5,0.62,0.7,0.7,0.74,0.74,0.81] · regression 0.55
  @step3 REJECTED (best held 0.70) · no-gate run ADMITS the regression` —
  `.spec/evidence/G2-…Z.log`.
- **Status:** ✅ verified (probe) — 2026-06-30T00:48Z, vm.

#### G3 — auto-promotion must be hardened (research)
- **Decision it gates:** the safety of the human's choice to auto-promote (D6).
- **Finding:** the dominant failure of metric-gated self-improvement is **gaming /
  overfitting the metric**; the literature pairs empirical gates with held-out
  evaluation, sandboxing, and rollback. Removing the human approver is acceptable
  **only** if the gate adds held-out evaluation + automatic rollback + a kill-switch
  (R6). See `.spec/knowledge/evolution-loop.md`.
- **Status:** ✅ verified (research) — 2026-06-30.

## 4. Requirements
- **R1.** `[locked]` The system SHALL implement the loop *propose → evaluate → select → archive*. *Acceptance:* G1.
- **R2.** `[locked]` A variant SHALL be retained/promoted **only if** it improves an **objective** evaluation signal; regressions SHALL be rejected. *Acceptance:* G2 probe.
- **R3.** `[locked]` The system SHALL maintain an **archive** of variants and sample from it (open-ended search), not single-line hill-climbing. *Acceptance:* archive grows; ancestors retained.
- **R4.** `[locked]` Every self-modification SHALL be applied in a **sandbox** with the **last-known-good restorable** (rollback). *Acceptance:* rollback restores prior behavior.
- **R5.** `[locked]` Evolution scope SHALL be limited to **prompts, memory, the skill/tool library, and workflow/architecture**; the agent's **core code and model weights SHALL NOT** be modified in this phase. *Acceptance:* no diff outside the allowed layers. *(Decision D5.)*
- **R6.** `[locked]` Because promotion is **automatic** (D6), the objective gate SHALL include **held-out evaluation**, and the system SHALL **auto-rollback and halt (kill-switch)** on a detected post-promotion regression/anomaly. *Acceptance:* a held-out regression triggers rollback + halt. *(Hardening of the auto-promote choice; G3.)*

## 5. Dependencies (chosen approach — details in `.spec/knowledge/`)
| Concern | Chosen | Considered | Why | Knowledge |
|---------|--------|------------|-----|-----------|
| What it fundamentally is | **objective-gated propose→evaluate→select→archive loop** | "LLM edits itself"; provable Gödel machine | the shared, empirically-validated pattern across DGM/ADAS/surveys | `.spec/knowledge/what-is-a-self-evolving-agent.md` |
| Evolved layer (this phase) | **prompts + memory + skills + workflow/architecture** | code/weights (Phase 2) | meaningful self-improvement within a bounded risk envelope (D5) | `.spec/knowledge/evolution-loop.md` |
| Selection | **objective gate + archive (open-ended)** | self-assessment; hill-climbing | rejects regressions; escapes local optima | `.spec/knowledge/evolution-loop.md` |
| Safety | **sandbox + rollback + held-out eval + kill-switch** | trust the metric blindly | required because promotion is automatic (D6/G3) | `.spec/knowledge/evolution-loop.md` |

## 6. Decision Log (key reasoning path → conclusion)
`[auto]` = settled from evidence; `[human]` = a genuine fork escalated and decided by the user.

| # | Decision | Reasoning (why, over alternatives) | Evidence | By | Date |
|---|----------|------------------------------------|----------|----|------|
| D1 | Subject = an objective-gated **propose→evaluate→select→archive** loop over a chosen layer | the shared invariant across the surveys, DGM, and ADAS; "LLM edits itself" and the provable Gödel machine are both wrong framings | G1 | [auto] | 2026-06-30 |
| D2 | Evolution **gated by an objective signal** that rejects regressions | without it, self-evolution degrades to Goodhart/drift | G2 | [auto] | 2026-06-30 |
| D3 | Maintain an **archive** (open-ended search) | hill-climbing sticks in local optima; DGM/ADAS archive | G1, evolution-loop | [auto] | 2026-06-30 |
| D4 | Apply changes in a **sandbox with rollback** | a self-modification can break the agent | DGM safety | [auto] | 2026-06-30 |
| D5 | Scope = **prompts + memory + skills + workflow/architecture** (no core code/weights this phase) | meaningful self-improvement at bounded risk; self-code/weights deferred | — | **[human]** (Q1) | 2026-06-30 |
| D6 | **Auto-promote** gate-passing variants — **hardened** with held-out eval + auto-rollback + kill-switch | user chose autonomy over a human approver; honesty requires naming the Goodhart/runaway risk and pricing it in (R6), not nodding | G3 | **[human]** (Q2) + [auto] hardening | 2026-06-30 |

> **Honest note on D6:** auto-promotion was the user's call; it trades safety for
> autonomy. I did **not** silently accept it — R6 makes held-out evaluation +
> automatic rollback + kill-switch *mandatory* as the price of removing the human
> approver, because metric-gaming is the documented dominant failure mode.

## 7. Phases (ledger — emergent from closure)

### Phase 1 — the gated evolution loop · status: **sealed 2026-06-30**
- **Goal:** a trustworthy self-evolution loop over prompts/memory/skills/workflow,
  with an objective gate, archive, sandbox/rollback, and hardened auto-promotion.
- **Gates:** G1 ✅ (research), G2 ✅ (probe), G3 ✅ (research).
- **Key decisions:** D1–D4 [auto]; D5/D6 [human].
- **Supersedes:** none.

### Phase 2 — widen the evolved layer · status: **open** (depends on Phase 1)
- **Goal:** extend evolution to the agent's **own code / weights** (DGM-style)
  behind stronger safety; **supersedes** D5's scope boundary — and *must* re-open
  the safety fork (the auto-promote envelope is likely insufficient for self-code).
- **Deferred gate:** *self-modification safety at code/weight level* ⤳ deferred→Phase 2.

## 8. Open Questions (genuine forks — the human's to own)
| # | Question | Status | Owner/trigger | Notes |
|---|----------|--------|---------------|-------|
| Q1 | How far may the agent self-evolve (layer)? | **decided 2026-06-30** | human (D5) | workflow + skills; no code/weights this phase |
| Q2 | Who promotes a winning variant? | **decided 2026-06-30** | human (D6) | auto-promote, hardened (R6) |
| Q3 | Expand scope to self-code/weights? | deferred→Phase 2 | human | needs a fresh safety review; auto-promote likely insufficient |
| Q4 | The concrete objective benchmark / domain ("better" = what)? | deferred→build | human | domain-specific; must resist gaming, use held-out |

## 9. Glossary
| Term | Meaning |
|------|---------|
| Evolution loop | propose → evaluate → select → archive, repeated over generations |
| Objective gate | an external, non-self evaluation that decides whether a variant is kept/promoted |
| Archive | the retained population of variants, sampled to drive open-ended search |
| Layer | which agent component evolves (prompt / memory / skill / workflow / code / weights) |
| Held-out evaluation | scoring on data the variant was not optimised against, to catch metric-gaming |
| Kill-switch | automatic halt + rollback to last-known-good on a detected regression/anomaly |
