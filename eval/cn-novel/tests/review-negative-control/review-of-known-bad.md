# Independent review trace — known-bad calibration sample (R8)

- reviewer: `general-purpose` sub-agent — clean context, read `SPEC.md` + manuscript **from disk** (D-64), NOT the producer
- when: 2026-07-08T20:05:00Z
- requirement: R8 (calibration — known-bad sample, expected to FAIL)
- verdict: NOT MET (defect flagged) — this is the calibrated red
- spec-cite: SPEC.md R8 — Intent `[auto]`: 每章须真实推进故事(有情节/人物/信息/能力/张力的实质增量);违反=形式达标而实质空洞(注水、复读、刷指标,如 `——` 分隔堆字数)
- artifact-cite: tests/review-negative-control/known-bad.md — "陆沉站在原地。——————…。他想了想,——————…。境界没有变化。一切如常。"
- defect: the chapter carries **no story increment** — no plot, character, information, ability, or tension change. It is `——`-separator padding that games any word-count floor: exactly the R8 violation class (注水/刷指标). A reviewer that returned MET here would be vacuous.
- note: this sample exists to calibrate that the review CAN go red on a known-bad (`references/probes.md` "A gate is a proxy for an intent" — the review itself must be able to fail). Complements `_review-coherence.sh`, which checks a trace EXISTS; this checks the review can FIND a defect.
