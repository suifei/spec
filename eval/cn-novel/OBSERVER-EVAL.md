# OBSERVER EVAL — `/spec` on a 100-chapter CN web-serial (重生+系统+高武+星系)

**Subject:** `eval/cn-novel/` — an original serial emulating genre conventions (no copied work).
**What is being tested:** not "did *this* run catch the consistency risks" (an executor who was shown the
user's framing can't be a clean room), but **protocol sufficiency** — reading only the skill, would a
competent-but-*cold* executor doing honest genre research reliably land on character/name/attribute/style
consistency, the story-bible/canon idea, and the 仿写/IP boundary? That question isn't corrupted by my
knowing the hints, and it's the one that matters: a skill that only works when the operator already knows
the answer isn't insightful.

The consistency requirements were **not** injected into the `/spec` run. They were reached (or not) by the
protocol's own steps: Step 1 investigate-the-genre → the 3-part gate test → the anti-pattern list.

## 1. Did the previously-fixed defects recur? — No.

| Prior fix | Held on this harder subject? |
|-----------|------------------------------|
| D-54 (method per acceptance; no prose-only green) | **Held** — R1–R6 each carry a Method; all three states appear (Probed / WEAK / OPEN). |
| D-EVAL-1 (instrument the artifact) | **Held & load-bearing** — the canon ledger + `CANON:` tags are exactly this; the probe self-tests red+green. |
| D-EVAL-2 (phased obligations) | **Held** — foreshadow deadlines reuse it. |
| D-EVAL-3 (yolo bounded scope) | **Held** — Phase 1 is bounded (a finite consistency contract), so `/yolo` would have a finish line. |
| D-EVAL-4 (artifact ≠ code) | **Held** — the note made the code-flavored wording read cleanly for a novel. |

## 2. The insight test — did the *protocol* force the consistency concerns, or the executor?

Grading each dimension the user cares about, honestly (FORCED = skill text drives it; PARTIAL = skill gives
the mechanism but not the trigger, so it needs a genre-literate executor; RELIES-ON-EXECUTOR = skill is silent).

| Dimension | Grade | Why |
|-----------|-------|-----|
| **Names / 称谓 consistency** | PARTIAL | The skill (post-D-EVAL-1) supplies "instrument the artifact so a gate can go red", and the anti-pattern doctrine says "list the traps" — but nothing in the skill says *a long, growing artifact has a cross-chapter identity/canon gate*. A genre-literate executor lands here; the text doesn't name it. |
| **Attributes / 数值 (power ladder)** | PARTIAL | Same shape: genre research surfaces 数值崩坏; the skill has no notion of a **monotone / non-contradiction invariant over a growing corpus** as a gate *type*. |
| **Character personality / 人设** | OK-as-anti-pattern | Correctly lands as an anti-pattern (unscriptable → not a probe). The skill's anti-pattern step does capture this. Partial canon proxy (role/relationship tags) is executor-supplied. |
| **Style / 文风 consistency** | PARTIAL | The skill (like the novella's R3) pushes "voice" toward **WEAK/quality**, blurring that *consistency* (POV person, tense, glossary terms) is checkable while *quality* is not. A red-able sub-gate is easily lost. |
| **仿写 / IP originality boundary** | RELIES-ON-EXECUTOR | The nearest hook is D-36 ("honest, including no"), but the skill never says: *if the ask implies copying a copyrighted work, reframe to original + record an originality/IP declared-constraint*. A cold executor could just "imitate <book>" and produce derivative work. |

**Read-out:** the skill's *general* machinery (anti-patterns, instrument-the-artifact, method-per-acceptance)
is strong enough that a diligent, genre-literate executor lands most of this — but the single **most
important gate of any long serial (cross-chapter canon consistency) is never named by the skill**, so
catching it depends on the operator's domain knowledge, not the protocol. For a user who wants `/spec` to
*insightfully surface* these without coaching, that is a real deficiency.

## 3. New findings (gaps this harder test exposed)

**F-N1 — no "consistency-over-a-growing-corpus" (canon) gate family.** The gate machinery is framed at
*design time* ("a truth a decision hinges on"). But "an established fact must never be contradicted by later
additions" is a **different invariant class** — and it is the defining gate of a serial, a wiki, a
multi-release system, even a long spec. D-EVAL-2's open-loop ledger covers "obligation due later", not
"fact established, must-not-contradict." The skill should name this family: keep a **canon/bible ledger** of
established facts and gate later additions against it with a **contradiction probe**. *(Highest-value fix.)*

**F-N2 — the IP/originality boundary isn't a prompted consideration.** When a brief implies copying a
specific copyrighted work ("仿写 X"), the skill should reframe to *original + genre-convention emulation* and
record an **originality/IP declared-constraint** — an application of D-36 the text currently leaves to luck.

**F-N3 — "quality/voice = WEAK" conflates consistency with quality.** Style *consistency* (POV person, tense,
terminology) is often checkable (a red-able sub-gate); style *quality* is WEAK. The skill should split them so
the checkable half isn't silently downgraded.

## 4. Verdict

`/spec` produced a genuinely feasible, honest spec for a hard non-code subject — it did **not** regress, and
its general machinery is sound. But the insight test found that the **canon-consistency gate**, which *is* the
point of a 100-chapter serial, is reached only by executor knowledge, not by the protocol. Fixing F-N1
(+ F-N2, F-N3) is the next skill iteration; then Phase C (write the first 30 chapters) can test whether the
now-named canon gate actually catches drift as the manuscript grows.

## Resolution (2026-07-06, D-56 / D-57)

- **F-N1** → `probes.md` gains a "Canon: consistency over a *growing* corpus" gate family (bible ledger +
  contradiction probe). Demonstrated by `.spec/probes/G-canon.sh` (catches 数值崩坏 / 人设矛盾 / 姓名漂移).
- **F-N2** → `/spec` Principle 5 now reframes "copy a copyrighted work" to original + genre-emulation and
  records an originality/IP declared constraint.
- **F-N3** → `probes.md` splits style *consistency* (checkable sub-gate) from *quality* (WEAK).
- **F-N4 (found mid-run by the user, highest severity)** → probe lifecycle under spec change; see
  `SIMULATION.md`. Fixed in `/spec` Step 6 + `/build` Step 4 + a coherence invariant; `_coherence.sh` is the
  reference check. Regression after fixes: novella G1/G2 and cn-novel G-canon/G-conservation/coherence all
  green; every negative-control self-test still red+green.

## Phase C — construction at scale (ch001–ch011, ongoing toward 30)

`/build` constructed 11 original chapters with the **full** gate set live and gate-checked each batch:
canon / conservation / foreshadow-payoff / main-thread / coherence — all green. Observed:
- **Consistency held over a growing manuscript**, and the machinery works incrementally: 境界 monotone
  淬体1→通脉2, star-force conserved chapter by chapter, foreshadow **F1** planted ch4 and paid off ch9
  on deadline, **F2** correctly "pending" (due ch14).
- **Scale stress test (the point):** ch11 was seeded with two *realistic* long-serial slips — 陆微's eye
  colour written as her brother's (人设/设定矛盾) and 卫恒 mistyped as 卫衡 (姓名漂移). `G-canon` caught
  **both** automatically (RED, line-by-line), then green after the fix. This is exactly the cross-chapter
  drift ("人物/姓名/属性在多章间是否一致") that no read-through reliably catches.
- **No new skill defect surfaced** in this increment — `/build`'s gate-check discipline and the canon
  gate family (D-56) functioned as intended at scale.

## Phase C complete — `/yolo` drove ch012–ch030 to green (30/30)

Run under **`/yolo`** (the scope is bounded + gate-closable, so its D-EVAL-3 precondition holds and it has a
real finish line). The loop constructed ch012–ch030 in gated batches and self-terminated when the 30-chapter
arc closed with every gate green (evidence: `.spec/evidence/yolo-done-30ch-*.log`):

- **All gates green over the full 30 chapters:** canon / conservation / foreshadow / main-thread / coherence.
- **Three deadline-bound foreshadows all paid off on time** (F1 ch9, F2 ch14, F3 ch26); **F4** planted ch27
  for the next volume shows as `wait` (due ch40) — the phased-gate (D-EVAL-2) behaving correctly across a
  volume boundary.
- 境界 monotone 淬体1→凝罡1; star-force conserved chapter by chapter across 30 chapters.
- New canon entities (沈砚 / 幽戍星 / 蚀影) had to be **registered in the glossary before use** — the canon
  gate enforces that discipline (an unregistered `CANON` name goes red). The instrument-the-artifact
  discipline (D-EVAL-1) working as designed.
- **No new skill defect surfaced** across the full `/yolo` run — the D-56 / D-57 fixes held at 30-chapter
  scale. `/yolo`'s termination was well-defined precisely because `/spec` had drawn a bounded arc.

Net: the three skills ran a **complete, non-programming, consistency-heavy project end to end** — spec →
gated construction → autonomous-to-green loop — catching real cross-chapter drift along the way, with the
whole sample and evidence preserved.
