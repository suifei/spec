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

## Round 4 — pseudocode & math, and the SECOND axis: human editability

Round 1–3 judged one axis: can a strong model *read* it. But a skill is a long-lived Markdown file a
human maintains — so the missing axis is **can a human safely EDIT it**. Two more representations of the
gate-decision doctrine (same 8 cases): **E — pseudocode** (familiar `match/case/def/return`), **F — math**
(set/logic notation). Both scored **8/8 fidelity**. Then an **edit-task probe**: give each compact form
(C, D, E, F) the *same* realistic spec change (add a `data-migration` acceptance kind; flip quality's
sign-off from OR→AND) and watch how the edit lands.

| Repr | chars | vs prose | fidelity | edit landed | human-editability (PR-review lens) |
|------|------:|---------:|:--------:|:-----------:|------------------------------------|
| A — prose | 3495 | 100% | 8/8 | — | universal, but verbose; semantics diffuse across sentences |
| E — pseudocode | 2981 | −15% | **8/8** | ✓ | **best** — universal programming constructs, no legend, new rule = new `case`, reviewable by any coder |
| B — mermaid | 1917 | −45% | 8/8 | — | render-dependent; graph edits are fiddly in raw text |
| C — arrows | 1689 | −52% | 8/8 | ✓ | **strong** — no bespoke legend (common symbols), rows self-describe, add-a-row is obvious |
| F — math | 1785 | −49% | **8/8** | ✓ | precise but **risky** — a one-glyph `∨→∧` flip is invisible in a diff; excludes non-math maintainers |
| D — dsl | 1127 | −68% | 8/8 | ✓ | **worst** — correct only if you've learned the legend; opaque in PR review |

**Finding (round 4):** fidelity and human-editability are **different axes, and they rank the compact forms
oppositely.** All four compact edits were *applied* correctly by a strong model (each self-rated 2/5
difficulty), but the *reviewability* diverges hard:
- **Pseudocode (E)** is the most human-friendly representation of all — it borrows constructs every
  contributor already knows, needs no legend, and adding a rule is adding a `case`. Its costs: it
  compresses the least (−15%), and it tends to **push real semantics into comments** (the OR→AND change
  landed in a comment, not the `return WEAK` structure) — readable, but not structurally enforced.
- **Math (F)** is compact and unambiguous *to someone fluent in it*, but its virtues are liabilities for a
  general open-source repo: a semantic flip is a single invisible glyph, and it gates contribution on
  comfort with `∈ ↦ ⇔ ∄ ∨/∧`. Good for a formal-methods audience, wrong for a broad contributor base.
- **DSL (D)** confirms round-1's caveat operationally: unreadable to anyone who hasn't internalised the
  legend — exactly the maintainability failure the human flagged.

The deeper structural point: **C-arrows and E-pseudocode are the same skeleton at two verbosities.** A
pseudocode `match/case → return Probed(...)` *is* an arrow row `kind ─▶ method` with keywords added back.
So the real design dial is "how many familiar keywords to keep": strip them all → arrows (−52%, still
legend-free); keep them → pseudocode (−15%, maximally familiar). Both stay human-editable because neither
invents symbols. Math and DSL win more compression by trading exactly that away.

## Converged conclusion — the "best expression"

Across structural, judgment-routing, and generative-tone content, **compact notation held full fidelity with
a strong-model reader every time** (all six representations, every round). The naive read — "smallest wins,
convert everything to the −68% DSL" — is still wrong, because fidelity is only one of two axes. The second,
which round 4 isolates, is **human editability** (can a contributor edit it and can a reviewer catch a wrong
edit in a diff). The two axes rank the compact forms *oppositely*: DSL wins fidelity-per-byte and loses
editability; pseudocode is the reverse. So judge on **value = fidelity × human-editability ÷ size**:

1. **Structural content** (decision routing, field schemas, pipelines, state machines, coherence invariants,
   `done =` / `ask-gate` definitions): compress to **legend-free, familiar notation** — arrows/tables (arm C)
   or light pseudocode (arm E), which are the same skeleton at two verbosities. Pick by audience: **arrows**
   when byte-cost dominates (−52%, still no legend), **pseudocode** when contributor-familiarity dominates
   (−15%, `match/case` every coder reads cold). **Reject arm D (bespoke DSL)** despite its −68%: its edge is
   bought with a legend that makes the file opaque to review — a maintainability failure, not a win. **Reject
   arm F (math)** for a general repo: precise, but a semantic flip is a single invisible glyph (`∨→∧`) and it
   gates contribution on logic-notation fluency; reserve it for a formal-methods audience.

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

**Net:** the highest-value optimization is to render the skills' **structural cores** in a **legend-free
familiar notation** — arrows/tables (arm C) when tokens dominate, light pseudocode (arm E) when contributor-
familiarity dominates — and to leave the **motivating "why" and tone exemplars** in prose. The winner is
whichever of {arrows, pseudocode} the audience reads coldest, because both max out the product of fidelity ×
editability. Bespoke DSL (D, most compact) and math (F, most precise) each sacrifice the editability axis and
are scalpels for a narrow audience, not a house style.
