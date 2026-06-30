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
- **current_step:** <探真(研究) | 呈现 | 提问 | 决策 | 取证 | 写入 | 闭环>
  # 探真 = investigate/research (Step 1); 取证 = gather a load-bearing gate's evidence (Step 5)
- **core_problem:** <one line — the core problem as understood so far>

## done
- <phase 1 sealed (gate G1 verified; assumption refuted & redirected)>
- <decided tokio 1.40 over async-std [auto] — see Decision Log / .spec/knowledge/rust-async.md>

## pending
- <Q3: a genuine fork awaiting the human (value/priority/risk)>
- <gate G4 unverified (probe not yet run)>
- <research needed: …>

## next_action
<the single next thing to do>
