# SIMULATION — "change request updates SPEC.md, but the probes don't" (F-N4)

**The user's scenario:** `/spec` #1 → `/build` proceeds, all green → a **change request** arrives →
`/spec` #2 updates `SPEC.md`. **But does the probe set update?** Probes were called "固化" (committed).
If a new/changed requirement gets no new/updated probe, `/build` re-runs a **stale gate set** and goes
green against a spec it no longer matches. This file records the real run on `eval/cn-novel/`.

## Verdict: the hole is REAL.

Auditing the skill: `/spec` Step 6 lists "`.spec/probes`" among things to update, but the only *elaborated*
instruction about probes on a re-run is "refresh that gate's Last-run/Status" (evidence timestamps). It
never names the three change-time dangers, and Step 7's "sealed = read-only" framing risks an executor
treating the probe **set** as frozen:
1. **new** requirement → no probe → **ungated** (false green);
2. **changed** acceptance → **stale** probe still tests the old behavior (false green);
3. **superseded** requirement → **lingering** probe gates a dead requirement.

## The run (evidence: `.spec/evidence/sim-*.log`, `final-green-*.log`)

Baseline: ch01–02 consistent; `G-canon` GREEN; `coherence` GREEN (R1 gated, R2/R3 deferred).

**[A] change request adds R7 (`星力` conservation) to `SPEC.md`, naive re-run authors no probe:**
```
### G-canon (the stale set /build re-runs):   RESULT: GREEN   <- /build would declare "done"
### coherence (spec <-> probe):               RESULT: RED — gate set OUT OF SYNC
    RED  locked req -> G-conservation.sh MISSING, not deferred — requirement is UNGATED
```
Then a chapter (ch03, an earlier draft) that **violated** R7 (星力 +500 凭空 / upgrade with no deduction)
passed the stale set (`G-canon` GREEN) — the 数值崩坏 slipped straight through, exactly as feared.

**[B] the fix — author R7's probe (`G-conservation.sh`):**
```
### G-conservation (manuscript):  RED ch3: 陆沉 升级 cost=200 无等额扣减 — R7 violated   <- now CAUGHT
### coherence:                    RESULT: GREEN — R7 now gated
```
(ch03 was then rewritten to a conserving version; the final committed sample is G-canon + G-conservation
+ coherence all GREEN — see `final-green-*.log`.)

## The fix shipped to the skills (F-N4)

Two parts, mirroring the D-54 philosophy ("outlaw the illegal state, don't rely on the executor
remembering"):

1. **Probe-lifecycle under change is now explicit** (`/spec` Step 6, `/build` Step 4): on every re-run,
   reconcile the probe **set** to the *current* locked requirements — **new → author, changed → replace
   the stale probe, superseded → retire**. "Sealed/固化" freezes the *record of what was decided*, not the
   gate set's duty to match the current spec.
2. **A coherence invariant**: every `[locked]` requirement with a Probed method must have an existing
   probe; no orphan probe may reference a superseded requirement. `/build` treats a locked requirement
   whose Method-probe is missing/stale as an **incomplete gate → route to `/spec`**, never a silent green.
   `_coherence.sh` here is a reference implementation of that check.

This was the highest-severity finding of the whole eval series: it protects the pipeline's core anti-drift
promise (D-14) — without it, the drift detector itself silently drifts.
