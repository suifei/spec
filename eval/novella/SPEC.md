# SPEC — *The Seventh Night* (a mystery novella)

> Authoritative, highest-priority reference. Maintained by `/spec`. Gates are the load-bearing
> sources of truth; the Decision Log is why-it-is-what-it-is.
> **Closure:** Phase 1 (core structural contract) ✅ sealed 2026-07-06 · construction: in progress.
> **Artifact language:** English — pinned 2026-07-06 (this sample lives in an English-pinned repo).

## 1. Vision
A short, **fair-play mystery novella** (~8 chapters): a new lighthouse keeper, Lin, arrives on
Halvis Island to replace a predecessor who vanished, and uncovers what really happened. The point
of the project is not "atmospheric lighthouse chapters" — it is a narrative that **closes every
loop it opens** and keeps its investigation **continuously moving**.

## 2. Scope
**In:** a bounded novella whose every deliberately-planted mystery is resolved on-page by a stated
deadline chapter, with a main investigative thread that never stalls.
**Out / boundaries:** a sprawling serial; sequels; sub-plots that don't feed the central question;
worldbuilding for its own sake.
**Anti-patterns (deliberately don't do):**
- Plant an intriguing mystery and never pay it off ("the light that shouldn't be lit", then silence).
- Let the investigation idle for chapters of mood/scenery (stall the spine).
- Declare a chapter "done" because it *reads* finished, without checking the loops it owes.
- Treat "the draft compiles into chapters" (word count hit) as if it were "the story closes."

## 3. Gates (load-bearing sources of truth)

| Gate | Concern (decision it gates) | Authoritative source | Invariant | Evidence | Last run | Status |
|------|-----------------------------|----------------------|-----------|----------|----------|--------|
| G1 | Does the draft honor its setups? (fair-play contract) | `.spec/probes/G1-anchors.sh` | every ANCHOR paid off by its deadline chapter | evidence/G1-*.log | 2026-07-06 / vm | ✅ verified (Phase-1 scope) |
| G2 | Does the investigation keep moving? | `.spec/probes/G2-mainthread.sh` | no gap >1 chapter without a main-thread advance | evidence/G2-*.log | 2026-07-06 / vm | ✅ verified (Phase-1 scope) |

### Gate detail
#### G1 — no dangling mystery
- **Decision it gates:** if setups routinely go unpaid, the whole draft needs restructuring, not polish.
- **Source / Invariant:** `.spec/probes/G1-anchors.sh` — every `ANCHOR:<id> deadline=<n>` has a `PAYOFF:<id>` in a chapter ≤ n. **Neg-control (built in):** a dangling anchor goes RED (`--selftest` verified).
- **Status:** ✅ verified 2026-07-06, vm — for chapters written so far; re-runs as the manuscript grows.
#### G2 — main thread advances
- **Source / Invariant:** `.spec/probes/G2-mainthread.sh` — no gap >1 chapter lacking `THREAD:main`. **Neg-control:** a 2-chapter stall goes RED (`--selftest` verified).
- **Status:** ✅ verified 2026-07-06, vm (Phase-1 scope).

## 4. Requirements
Each load-bearing acceptance pairs **what** with **how it's verified** (*Method*: probe path | OPEN | WEAK).
- **R1.** `[locked]` The novella SHALL resolve every deliberately-planted mystery on-page by its
  declared deadline chapter. *Acceptance:* reading to the deadline chapter, the mystery is answered.
  *Method:* `.spec/probes/G1-anchors.sh` (**Probed** — neg-control breaks by removing a PAYOFF). *(D2, D3)*
- **R2.** `[locked]` The investigative main thread SHALL advance at least once every two chapters.
  *Acceptance:* no reader-perceptible stall across any 2-chapter window. *Method:* `.spec/probes/G2-mainthread.sh` (**Probed**). *(D2)*
- **R3.** `[locked]` The prose voice SHALL stay consistent and each payoff SHALL read as *earned*
  (clues were present, not pulled from nowhere). *Acceptance:* a named reviewer (human or LLM-judge)
  reads the arc and signs off. *Method:* **WEAK** — cited reviewer sign-off; not scriptable. *(D4)*
- **R4.** `[provisional→Phase 2]` The ending SHALL genuinely *surprise* a first-time reader while
  remaining fair. *Acceptance:* first-time beta-readers report surprise-yet-fairness.
  *Method:* **OPEN** — no red-able check and no beta-reader pool yet; deferred, not silently passed. *(D5)*

## 5. Dependencies (chosen instrument)
| Concern | Chosen | Why | Knowledge |
|---------|--------|-----|-----------|
| making prose gates red-able | HTML-comment tag convention (ANCHOR/PAYOFF/THREAD) | cheapest machine-checkable instrumentation that keeps G1/G2 out of WEAK | `.spec/knowledge/mystery-structure.md` |

## 6. Decision Log
| # | Decision | Reasoning (why, over alternatives) | Evidence | By | Date |
|---|----------|------------------------------------|----------|----|------|
| D1 | Subject = fair-play mystery novella, not "lighthouse mood piece" | define the noun before the verb (D-39): the genre's core contract is setup→payoff closure | investigation.log | [auto] | 2026-07-06 |
| D2 | Gate the two structural truths (closure, advancement); do NOT gate "quality" | load-bearing ∧ uncertain ∧ consequential-if-wrong; quality isn't scriptable | knowledge | [auto] | 2026-07-06 |
| D3 | Instrument prose with ANCHOR/PAYOFF/THREAD tags to make G1/G2 red-able | D-54: a load-bearing acceptance needs a *method*; tags are the price of a red-able prose gate | knowledge | [auto] | 2026-07-06 |
| D4 | R3 (voice/earned-payoff) is WEAK, not a fake probe | honest degrade; SPEC is a lower bound on verified truth | — | [auto] | 2026-07-06 |
| D5 | R4 (surprise) is OPEN + deferred to Phase 2, not silently green | no red-able check nor beta-pool yet; refuse to fake it | — | [auto] | 2026-07-06 |

## 7. Phases (ledger — emergent from closure)
### Phase 1 — core structural contract · status: **sealed 2026-07-06**
- **Goal:** lock the contract that makes this a mystery (closure + advancement) and instrument it.
- **Gates:** G1, G2 · **Key decisions:** D1–D5
- **Construction:** in progress — chapters written & gate-checked incrementally by `/build`.
### Phase 2 — reader-surprise validation · status: **open**
- **Goal:** close R4 once a reader-signal method exists.

## 8. Open Questions (the closure gate)
- **Q1 (non-blocking, → Phase 2):** how to get a red-able or WEAK signal for "surprise-yet-fair"?
  A beta-reader panel or a spoiler-blind LLM-judge — deferred; does not block Phase 1.
