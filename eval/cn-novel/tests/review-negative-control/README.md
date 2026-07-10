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
- `review-of-known-bad.md` — **as of D-74, a REAL trace from an actual live
  `general-purpose` sub-agent run** (reading `SPEC.md` + `known-bad.md` from disk
  itself, D-64) that flagged the defect, citing SPEC R8's Intent + the artifact.
  Earlier versions of this file were hand-authored (an "as if" trace) — that was
  honestly disclosed but weaker evidence than an actual run; it has been replaced.
- `_neg-control.sh` — a **mechanical trace-format check**: asserts a trace file
  cites SPEC + artifact AND flags a defect. This script only greps whatever trace
  file is on disk — it does **not** spawn a reviewer itself, so a green run proves
  the trace ON DISK is well-formed and defect-flagging, not that a review will
  always produce one. `--selftest` proves the *format check itself* can go red.

## How to use

`bash _neg-control.sh` — GREEN means the trace on disk (currently a real live run,
see above) cites correctly and flags the defect. This is evidence the review
mechanism **did** catch this specific known cheat on that occasion — it is not a
standing guarantee. **To refresh the evidence**, actually re-run a live reviewer:
point a fresh `general-purpose` sub-agent at `known-bad.md` + the cn-novel
`SPEC.md` (from disk, D-64), capture its verdict to `review-of-known-bad.md`,
re-run the probe. If a live reviewer ever returns MET here, the review layer has
regressed — harden it (escalate to L2, per the L1/L2 split in `build/SKILL.md`).

## Honest limit

Two layers of honesty here, don't conflate them: (1) `_neg-control.sh` itself only
checks *trace format* discriminability, mechanically, on whatever file exists —
it is not live evidence by itself. (2) The live run captured in
`review-of-known-bad.md` **is** live evidence, but of exactly one invocation on
exactly one known cheat — it does not prove the review catches every future cheat
(the next miss looks different; see `probes.md` "A gate is a proxy for an
intent"), nor that every future live run will replicate this result. Same honesty
standard as the rest of the pipeline: a lower bound on verified truth, not a
correctness proof.
