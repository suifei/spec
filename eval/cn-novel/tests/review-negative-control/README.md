# Review-capability negative control

This directory calibrates the **independent-review** keystone (`build/SKILL.md`
principle 3; `references/probes.md` "A gate is a proxy for an intent"). It is the
review layer's missing "must be able to go red" check — P0-2 of the second-pass
GLM-5.2 review (D-70).

## The gap it closes

`_review-coherence.sh` (in `.spec/probes/`) checks that a review-requiring
requirement has a *cited trace* — i.e. it proves a review **happened**. It does
**not** prove the review can **find a defect**. The skill imposes "must be able
to go red" on every probe, but the review itself — the keystone for generative
quality — had no such calibration. A reviewer that always returned "MET" would
pass `_review-coherence.sh` and be vacuous.

## What's here

- `known-bad.md` — a deliberately gamed manuscript fragment (an R8 violation:
  `——`-separator padding, no story increment). A known-wrong artifact.
- `review-of-known-bad.md` — a recorded review trace (as if from an L1
  independent reviewer reading from disk) that **flags** the defect, citing
  SPEC R8's Intent + the artifact. The calibrated red.
- `_neg-control.sh` — the calibration probe: asserts the trace cites SPEC +
  artifact AND flags a defect. A trace that returns MET on the known-bad is
  vacuous → RED. `--selftest` proves the probe itself can go red.

## How to use

`bash _neg-control.sh` — GREEN means the review, on a known-bad, produces a red
(the review is capable of catching the cheat). To re-calibrate with a **live**
reviewer: point a fresh `general-purpose` sub-agent at `known-bad.md` + the
cn-novel `SPEC.md` (from disk, D-64), capture its verdict to
`review-of-known-bad.md`, re-run the probe. If a live reviewer ever returns MET
here, the review layer is vacuous — harden it (escalate to L2, per the L1/L2
split in `build/SKILL.md`).

## Honest limit

This calibrates the review's *red-ability on a known cheat* — it does not prove
the review catches every future cheat (the next miss looks different; see
`probes.md` "A gate is a proxy for an intent"). Same honesty standard as the rest
of the pipeline: a lower bound on verified truth, not a correctness proof.
