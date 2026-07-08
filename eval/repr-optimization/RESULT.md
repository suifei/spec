# Representation optimization — which skill content compresses without losing fidelity?

**Goal:** find, empirically, which skill content is expressed more precisely / token-efficiently as a
diagram, text+arrows, or an invented terse notation — and where prose must stay. **Method** (mirrors the
repo's own discipline): a *mechanical* measure (size = token proxy) + an *independent judge* (a
clean-context reader uses ONLY the representation, then either answers fixed decision cases scored
against a hidden key, or generates output scored blind against a rubric). Value = fidelity ÷ size —
later refined to fidelity × robustness ÷ size.

## Round 1 — the "gate decision" doctrine (highly STRUCTURAL content)

Same doctrine (Intent/Acceptance/Method → Probed/OPEN/WEAK, proxy-vs-intent, independent review, probe-set
reconciliation) written four ways; four independent readers, blind, 8 decision cases each.

| Repr | chars | vs prose | fidelity (of 8) | value |
|------|------:|---------:|:---------------:|-------|
| A — prose (baseline) | 3495 | 100% | **8 / 8** | ref |
| B — Mermaid flowchart | 1917 | −45% | **8 / 8** | high |
| C — text + arrows | 1689 | −52% | **8 / 8** | **high** |
| D — invented terse DSL | 1127 | −68% | **8 / 8** | highest raw |

**Finding (round 1):** for *structural / decision-tree* content, all three compact forms preserved **full
fidelity** at a fraction of the size — a reader even parsed `∀(locked∧P)∃.sh` correctly. The "prose is
safest" instinct is **wrong for this class**: decision routing, field schemas, and pipelines compress hard
with no loss.

## Round 2 — the "questioning" doctrine (JUDGMENT-heavy routing)

Prediction going in: compression breaks where nuance lives. Same doctrine (derive-first / ask-only-genuine-
forks / surface-better-option / honesty / define-noun-before-verb / prior-knowledge calibration /
respect-urgency / low-cadence / question-must-move-spec) as prose (A) vs the terse DSL (D). 10 decision
cases built to *separate letter-following from understanding* — twin cases that flip on one nuance
(C1 don't-ask-derivable ↔ C2 ask-true-fork; C5 expert→counterfactual ↔ C6 novice→worked-example; C3's narrow
"surface-with-reason" path flanked by silent-switch and why-less-ask distractors).

| Repr | chars | vs prose | fidelity (of 10) |
|------|------:|---------:|:----------------:|
| A — prose | 3423 | 100% | **10 / 10** |
| D — terse DSL | 1545 | −55% | **10 / 10** |

**Finding (round 2):** prediction **refuted**. The DSL reader nailed every nuance discriminator. Multiple-
choice, though, tests *routing/recall* — which is exactly the compressible skill. It cannot see the real
judgment payload: the *tone* of a generated question. So → Round 3.

## Round 3 — TONE (GENERATIVE judgment; the hardest case for compression)

The style sub-doctrine (spark-interest/collaborative-not-controlling phrasing, carry-context, calibrate-to-
novice, low-cadence). Not multiple-choice: each reader had to **write the actual question** to a non-technical
founder given a scenario (ambiguous "make it fast" + an unmentioned CDN option). An independent judge scored
the outputs **blind** against a 5-point tone rubric, citing offending phrases. Three arms:

| Arm | representation | tone score (of 5) |
|-----|----------------|:-----------------:|
| A — prose style rules | full prose | **5 / 5** |
| D — DSL, exemplars kept inline (`"maybe relevant?"…`) | terse | **5 / 5** |
| D′ — DSL, **exemplars ablated** (only abstract descriptors) | terser | **5 / 5**-equiv |

**Finding (round 3):** even *generated tone* survived compression. D′ — given only `phrasing:
informational/collaborative ¬controlling` with **no example phrases** — still produced "My hunch… I'd lean
there", "Want me to fold that in?", and a plain CDN analogy. A strong model reconstructs the collaborative
register from the abstract descriptor alone.

## Converged conclusion — the "best expression"

Across structural, judgment-routing, and generative-tone content, **compact notation held full fidelity with
a strong-model reader every time.** The naive read — "smallest wins, convert everything to the −68% DSL" — is
still wrong, because raw fidelity-per-byte is not the whole objective. Judging on **value = fidelity ×
robustness ÷ size**:

1. **Structural content** (decision routing, field schemas, pipelines, state machines, coherence invariants,
   `done =` / `ask-gate` definitions): compress to **text + arrows/tables using a SMALL SHARED symbol set**
   (`→ ∧ ∨ ¬ ≻ ∀ ∃`). This is arm **C**, not **D**: ~50% token cut at full fidelity **with no per-file legend**.
   C beats D on *value* once robustness enters — D's −68% edge is bought with a bespoke legend that adds
   opacity, cross-file inconsistency, and drift-fragility to a long-lived, multi-author artifact.

2. **Judgment / tone content**: compresses too, but the marginal byte savings are smaller and the robustness
   cost higher. Keep it **tight prose with exemplars preserved verbatim**. Not because a strong reader needs
   the exemplars (round 3 proved it doesn't) but as **defense-in-depth**: exemplars anchor the register against
   spec drift, weaker future readers, and edits by other authors. Fidelity tests can't measure that — so don't
   trade it away for a few bytes.

3. **Avoid** dense bespoke DSL (D) in production skills. It wins every fidelity test and is the right tool for a
   *single high-volume structural block* where the legend amortizes — but as a house style it converts the
   savings back into legend-maintenance and ambiguity debt.

**Honest caveats.** One strong-model reader per cell (matches the real skill consumer, but n is small). Tests
measure *fidelity to a strong reader*, deliberately not *robustness under drift* — which is exactly why the
recommendation refuses to chase the smallest form. A generated-output rubric can't catch a subtle register
drift a human would feel over 100 invocations. The legend has a fixed cost, so compression only pays past a
content threshold.

**Net:** the highest-value optimization is to render the skills' **structural cores** in shared-symbol
text+arrows (arm C) — precise, ~half the tokens, no bespoke legend — and to leave the **motivating "why" and
tone exemplars** in prose. Maximal DSL is a scalpel for one big structural block, not a house style.
