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
- **active_phases:** <[N]>   # usually one; a LIST when phases overlap — e.g. [2, 3] while
  # Phase 2 is still building and Phase 3 is superseding an earlier phase's item. Sealed
  # phases are NOT listed (they're read-only, done). Supersession is a small DAG, not a
  # single cursor: record it per-phase in SPEC.md (`Supersedes:`), and list every phase
  # still in flight here. (`current_phase: <N>` — the older single-value form — is fine
  # when exactly one phase is active.)
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

## build
<!-- owned by /build; /spec preserves this section verbatim when rewriting -->
- built: <requirements/phases constructed, with dates — or none yet>
- remaining: <…>
- next: <…>
- ticks: <N — present only while /yolo has a live loop: the monotonic tick counter,
  incremented each firing, ≤ the ceiling (default 20, override via `CEILING` env).
  The **tick-ceiling** closure probe (see `SKILL.md` "The closure probe kit")
  enforces it stays ≤ ceiling and never goes backwards (a fresh-context tick
  overwriting a stale count is the ceiling-silently-inflates risk). Absent when no
  loop is active.>
- conflict: <none | what contradicts what · evidence path · code state left behind>
