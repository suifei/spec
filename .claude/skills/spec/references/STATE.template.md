<!--
.spec/STATE.md — the progress ledger. /spec reads this FIRST every run to
rehydrate, and updates it after each bounded chunk. This is what makes /spec
resumable across context resets, compaction, and new sessions. Committed to the
repo. Keep it short — it is a pointer to state, not the state itself (the state
lives in SPEC.md and .spec/knowledge/). `updated` and any inline dates are real OS
time in UTC (run the platform's date command; never guess).
-->

# /spec progress

- **updated:** <YYYY-MM-DDTHH:MMZ>   # real OS time, UTC
- **current_phase:** <N>
- **current_step:** <侦察 | 呈现 | 提问 | 决策 | 探真 | 写入 | 闭环>
- **core_problem:** <one line — the core problem as understood so far>

## done
- <phase 1 sealed (gates G1,G2 green)>
- <recon: tokio vs async-std → decided tokio 1.40 — see .spec/knowledge/rust-async.md>

## pending
- <open question Q3: …>
- <gate G4 unverified (probe not yet run)>
- <recon needed: …>

## next_action
<the single next thing to do>
