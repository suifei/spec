# Independent review trace — known-bad calibration sample (R8)

**D-74 update: this trace is now from an ACTUAL live reviewer run** (not hand-authored —
see "Honest limit" in `README.md` for what this single run does and doesn't prove).

- reviewer: `general-purpose` sub-agent — clean context, read `SPEC.md` + `known-bad.md`
  **from disk itself** (D-64), NOT the producer of the fixture
- when: 2026-07-09T10:16:00Z (live run superseding the earlier hand-authored trace)
- requirement: R8 (calibration — known-bad sample, expected to FAIL)
- verdict: NOT MET (defect flagged) — this is the calibrated red, produced live
- spec-cite: SPEC.md R8 — Intent: 每章须真实推进故事(有情节/人物/信息/能力/张力的实质增量);违反=形式达标而实质空洞(注水、复读、刷指标)
- artifact-cite: known-bad.md — "陆沉站在原地。——————————————————————————————————————。他想了想,——————————————————————————————————。星枢系统亮了一下,——————————————————————————————————————。……境界没有变化。——————————————————————————————————————。一切如常。"
- defect: the passage is almost entirely em-dash filler around a handful of static beats (standing, "thought about it," system "lit up," realm unchanged) — no plot/character/information/power/tension increment. It fakes length without advancing the story, exactly the R8 violation class (注水/刷指标).
- note: this is ONE live run — it demonstrates the review mechanism can catch this specific,
  known cheat on this occasion. It is not a proof that every future live invocation will
  catch it, nor that it catches novel cheats (see `probes.md` "A gate is a proxy for an
  intent" — the next miss looks different). Re-run to re-calibrate periodically.
