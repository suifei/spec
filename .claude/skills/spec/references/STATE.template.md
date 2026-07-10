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
- built: <Phase N — date — requirements constructed, with dates — or "none" yet.
  NAME THE PHASE ("Phase N —") so `.spec/probes/G4-writeback-coherence.sh` can scope its
  write-back check to that phase's own SPEC.md block, not the whole file (a `built:` line
  with no phase falls back to an imprecise whole-file check).>
- remaining: <…>
- next: <…>
- run_id: <UTC + random suffix; immutable for one /yolo run>
- job_id: <scheduler id | inline>
- run_status: <active|done|blocked|stuck|ceiling|stopped>
- ceiling: <positive integer; default 20>
- tick_log: <.spec/evidence/yolo/<run_id>/ticks.log>
- ticks: <N — mirror of this run's tick_log only. Before a firing, if N >= ceiling,
  stop without appending/building; otherwise append and N becomes the new count.>
- artifact: <git:<commit> | sha256:<digest> covered by the final passing review>
- last_failure: <none | one line: what this tick failed on — the anchor that lets the
  NEXT fresh-context firing detect "2nd identical failure" and stop>
- no_progress_streak: <0..N — consecutive ticks with NO material progress (no gate
  red→green, no requirement closed); reset to 0 on material progress, else +1.
  ≥ 3 ⇒ stuck (cosmetic churn is a stall). The anchor that makes "no material
  progress = stop" enforceable across stateless firings.>
- conflict: <none | what contradicts what · evidence path · code state left behind>
