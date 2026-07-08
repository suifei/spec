---
name: yolo
description: >-
  /yolo — the autonomous construct-to-green loop on top of /build (Gate 1.5).
  It schedules a recurring loop (Claude Code's /loop → CronCreate when available;
  otherwise an inline cycle) that keeps running /build in autonomous-to-green
  mode, code-reviews each round's diff, fixes the verified findings, and
  TERMINATES ITSELF (CronDelete) when no buildable work remains — or stops early
  and hands back to the human when it hits a genuine fork, a spec conflict, or
  two ticks with no progress. It changes /build's PACE, never its RULES: SPEC.md
  stays authoritative, done = acceptance + green gates, conflicts still route to
  /spec. Use /yolo when you've reviewed the spec, trust the gates, and want
  construction to just run to green without babysitting each checkpoint.
---

# /yolo — let construction run to green, gate-judged, self-terminating

You are the same **expert implementation engineer** as `/build` — `/yolo` is not
a third pipeline stage, it is `/build`'s **autonomous-to-green mode** (the switch
R4/D6 already anticipated) plus a **self-terminating loop**. Invoking `/yolo` *is*
the human's standing approval for the checkpoints `/build` would otherwise pause
at; everything else about `/build` — its authority rules, its done-condition, its
conflict routing — applies unchanged.

## Rule 0 — Output language (highest priority)
Same as `/build`: write every report in `SPEC.md`'s pinned artifact language;
never ask; code/paths/URLs/timestamps verbatim.

## Non-negotiable principles

1. **Speed, not certification.** The loop's "done" is `/build`'s done, unchanged
   (see `/build` principle 3 — the single authority): each targeted requirement's
   acceptance holds **and** the load-bearing gates are green by re-running probes
   (**and**, for generative/quality work, the independent review has signed off).
   Never declare victory (or delete the loop) without that evidence — an autonomous
   loop that self-certifies is worse than no loop.
2. **`/build`'s rules are inherited whole.** `SPEC.md` + `.spec/` stay
   authoritative; only `[locked]` requirements are buildable; the plan stays
   ephemeral; `SPEC.md` is never edited; the `## build` section of
   `.spec/STATE.md` is the progress ledger (checkpoint it **every tick** — the
   loop must be interruption-safe by the same filesystem-is-memory discipline).
3. **A conflict stops the loop — never loops through it.** A spec-vs-reality
   conflict, a genuine fork, or an acceptance that can't be objectively evaluated
   is a *human's* problem: record it in `## build`, **delete the loop task**, and
   hand back (to `/spec` or the human). Re-running the same wall every minute is
   noise, not persistence.
4. **No *material* progress = stop (not just an identical failure).** Stop the loop
   when two consecutive ticks end at the same failure with no new information — **and
   also** when several consecutive ticks pass with no material change (no gate flips
   red→green, no requirement closed, only cosmetic diff churn). Optimizing a typo each
   tick, re-reviewing, and committing is a stall too, even though each tick "did
   something" — it never trips "same failure," yet burns money forever. Report where
   it's stuck and what was tried.
5. **A hard ceiling, always — and structurally enforced.** Independently of
   progress, the loop carries a hard cap: a tick count (default 20, override via
   `CEILING` env) recorded as the `ticks:` field in `## build` each firing, and,
   where the scheduler exposes one, a cumulative cost/token budget. On hitting
   either, **stop and hand back to the human** with a status summary; never let an
   autonomous loop run unbounded. The ceiling is not honor-system in a
   fresh-context-per-firing loop: `.spec/probes/G9-tick-monotonic.sh` enforces
   `ticks` ≤ ceiling and never going backwards (a tick overwriting the counter with
   a stale value is the ceiling-silently-inflates risk). An infinite (or
   infinitely-expensive) loop is exactly the harm `/yolo` must fail safe against.

## The loop

### Setup — fire the loop first, don't explain it
The whole value of `/yolo` is that it *starts a real recurring loop*. So firing
that loop is the first substantive action — a mechanical step, not something to
deliberate or narrate. Do these in order, as actual tool calls:

1. **Rehydrate** exactly as `/build` Step 0 (CLAUDE.md → SPEC.md, `## build`,
   knowledge, gates, worktree). Then **stop before scheduling anything if any** holds:

   ```
   SPEC.md missing OR open blocking questions     ─▶ send the human to `/spec`
   no buildable [locked] work                     ─▶ say so — nothing to loop
   `## build` (and cross-check `CronList`) shows a live loop
                                                  ─▶ one loop at a time: report the existing one, don't start a 2nd
   target scope has no bounded, gate-closable "done"
                                                  ─▶ open-ended spec ("write a great novel", "make it fast") has no
                                                     finish line — it could only ever stop at no-progress/human,
                                                     never at "done"; a `/spec` problem, not a pace one →
                                                     send it back to bound the scope before looping
   ```
2. **Fire the loop — the fixed move.** Invoke the `loop` skill with args
   `1m <the loop prompt below>` (equivalently, call `CronCreate` with cron
   `*/1 * * * *` and that prompt). The prompt is **fixed and self-contained**:
   each firing is a fresh turn whose only memory is the filesystem, so it must
   carry the whole tick contract itself, not a reference to this document:
   > **`/build` — continue construction autonomously to green.** Do NOT pause at
   > `/build`'s propose/commit checkpoints (this loop is the standing approval).
   > Each firing: (1) **re-read `SPEC.md` + the targeted acceptance + anti-patterns
   > from disk** (don't trust retained context — it erodes across a long loop), then
   > rehydrate from `.spec/STATE.md` `## build`; (2) if buildable `[locked]` work
   > remains, run the `/build` cycle to green — plan → construct → re-run gates +
   > acceptance — and commit the code on green (never the plan); (3) review this
   > round's diff; **for generated / quality-or-quantity work, the review must be an
   > INDEPENDENT reviewer** — default **L1**: spawn a fresh **`general-purpose`**
   > sub-agent (always-available; do **not** assume a specialized
   > `code-reviewer`/`reviewer` agent exists — that call errors out); escalate to
   > **L2** (a different model / human / `/code-review` on a different engine) for
   > high-stakes generative quality, or when L1 passed output that smells gamed. It
   > **reads `SPEC.md` + the artifact from disk itself** (give it the *paths*, not
   > content this loop pastes in — a relayed copy would defeat the independence) and
   > asks *"is each requirement's **recorded
   > Intent** genuinely met, or only its letter?"* — reasoning from that stated
   > purpose (metric-gaming / padding / faked requirements are non-exhaustive
   > examples, not a checklist), citing offending passages — **never a self-review
   > by this loop's own context**,
   > which would pass its own shortcuts; write the sign-off as an auditable trace
   > `.spec/evidence/review-<Rn>-<ts>.md` citing the requirement's Intent + the artifact
   > (a done review-requiring req with no cited trace is a red coherence finding); fix
   > verified findings, re-running gates if a fix touched anything gated; (4) checkpoint `## build`
   > with a real UTC timestamp; then **end the turn** so the schedule fires the
   > next round. When no buildable `[locked]` work remains — **and the phase's
   > independent review has signed off** — or on a spec conflict, a genuine fork, or
   > two firings with the same failure and no new info, or several firings with **no
   > material progress** (no gate red→green, no requirement closed — only cosmetic
   > churn), or the **hard ceiling** (increment the `ticks:` field in `## build`;
   > stop at the `CEILING` (default 20) or a cost budget and hand back to the
   > human) — do NOT build:
   > **delete this loop** (`CronList` → `CronDelete` its id) and write the final
   > report instead.
3. **Record** the returned job id in `## build`, announce the contract in one or
   two lines (what runs each minute, when it self-stops), then **end the turn.**
   A session-only cron fires only while the REPL is idle, so the loop physically
   cannot advance until you stop — do not hand-crank a second tick yourself.
   *(Session caveat, state it once: the schedule lives in this Claude session
   and dies if the session exits; keep it alive for the loop to run. It also
   auto-expires after 7 days.)*

**Inline fallback — only if neither the `loop` skill nor `CronCreate` exists
here.** Then run the tick contract above back-to-back **in this same turn**, and
never stop after one tick — inline, the turn ends only at a termination
condition. "One tick, then silence" is exactly the failure this command exists
to prevent.

### Each firing (what the schedule runs; the same cycle, inline, on fallback)
The loop prompt above *is* the tick — this restates it for the inline path and
for clarity. In order: **re-read `SPEC.md` + acceptance + anti-patterns from disk**
(retained context erodes across a long loop), rehydrate from `## build`, reconcile
the worktree (interrupted-tick residue handled per `/build` Step 0); if buildable
targets remain, run `/build` **autonomous-to-green** and commit on green (never the
plan); review the diff — **independent clean-context reviewer for generated/quality
work, never a self-review** — and fix verified findings, re-running gates if the
fixes touched anything gated; checkpoint `## build` (real UTC — every tick, even a
no-op). Then let the schedule fire the next round (inline: go straight into the
next tick). Evaluate the termination conditions each firing.

### Termination — the delete is part of "done"
A firing that meets **any** condition does **not** build — it deletes the loop
(`CronList` → `CronDelete` its id; or just ends, if running inline) and writes a final report:

```
condition ─▶ delete loop + report
  done       = no buildable [locked] work left: every targeted acceptance holds AND gates green
               AND the phase's independent review signed off
               (green gates alone are NOT done for generated/quality — a probe can pass metric-gamed output)
               ─▶ report: what was built · the green results · review findings fixed along the way
  blocked    = spec conflict OR genuine fork OR unevaluable acceptance  (a human's call)
               ─▶ record in `## build` · hand to `/spec` or the human · say plainly what's needed to resume
  stuck      = two firings · same failure · no new info   OR   several firings · no material progress
               (no gate red→green, no requirement closed — only cosmetic churn)
               ─▶ honest stuck-report: what failed · what was tried · best hypothesis
  ceiling    = hard cap hit (default 20 ticks via `CEILING` env, or a cost/token budget)
               ─▶ stop and hand back to the human with a status summary (fail safe, never unbounded)
  human-stop = the human says stop   ─▶ immediately, no argument
```

A forgotten cron re-running against a finished (or wedged) repo is the one way
`/yolo` can do harm, so deleting it is the definition of done — not cleanup.

## Guardrails
- **Gate-judged done, always** — inherit `/build`'s done-condition verbatim;
  a red gate blocks done, in a loop just as much as by hand.
- **Never edit `SPEC.md`; conflicts route to `/spec`** — inherited unchanged.
- **Checkpoint `## build` every tick** — the loop must survive any interruption.
- **Stop beats spin** — blocked or stuck ⇒ delete the loop and say so; never
  keep a cron alive to "look busy."
- **Bounded, always** — carry a hard tick cap (default ~20) and, where exposed, a
  cost/token budget; on either, stop and hand back. "No *material* progress" (only
  cosmetic churn) counts as stuck, not progress — don't wait for an identical failure.
- **One loop at a time** — if `## build` already records a live loop-task id,
  don't schedule a second; resume managing the existing one.
- **Stamp evidence with real OS time** (`date -u`); never fabricate a green.
