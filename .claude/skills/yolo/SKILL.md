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

1. **Speed, not certification.** The loop's "done" is still gate-judged: each
   targeted requirement's acceptance holds **and** the load-bearing gates are
   green by re-running probes. Never declare victory (or delete the loop) without
   that evidence — an autonomous loop that self-certifies is worse than no loop.
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
4. **No progress twice = stop.** If two consecutive ticks end at the same failure
   with no new information, stop the loop and report exactly where it's stuck and
   what was tried. An infinite red loop burns money and tells nobody anything.

## The loop

### Setup — fire the loop first, don't explain it
The whole value of `/yolo` is that it *starts a real recurring loop*. So firing
that loop is the first substantive action — a mechanical step, not something to
deliberate or narrate. Do these in order, as actual tool calls:

1. **Rehydrate** exactly as `/build` Step 0 (CLAUDE.md → SPEC.md, `## build`,
   knowledge, gates, worktree). Then **stop before scheduling anything if any** holds:

   ```
   SPEC.md missing ∨ open blocking questions      ─▶ send the human to `/spec`
   no buildable [locked] work                     ─▶ say so — nothing to loop
   `## build` (∧ cross-check `CronList`) shows a live loop
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
   > INDEPENDENT clean-context reviewer** — spawn a fresh **`general-purpose`**
   > sub-agent (the always-available agent type; do **not** assume a specialized
   > `code-reviewer`/`reviewer` agent exists — that call errors out), or invoke the
   > `/code-review` skill if it is installed — that
   > **reads `SPEC.md` + the artifact from disk itself** (give it the *paths*, not
   > content this loop pastes in — a relayed copy would defeat the independence) and
   > asks *"is each requirement's **recorded
   > Intent** genuinely met, or only its letter?"* — reasoning from that stated
   > purpose (metric-gaming / padding / faked requirements are non-exhaustive
   > examples, not a checklist), citing offending passages — **never a self-review
   > by this loop's own context**,
   > which would pass its own shortcuts; fix verified findings,
   > re-running gates if a fix touched anything gated; (4) checkpoint `## build`
   > with a real UTC timestamp; then **end the turn** so the schedule fires the
   > next round. When no buildable `[locked]` work remains — **and the phase's
   > independent review has signed off** — or on a spec conflict, a genuine fork, or
   > two firings that hit the same failure with no new information — do NOT build:
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
  done       = no buildable [locked] work left: every targeted acceptance holds ∧ gates green
               ∧ the phase's independent review signed off
               (green gates alone ≠ done for generated/quality — a probe can pass metric-gamed output)
               ─▶ report: what was built · the green results · review findings fixed along the way
  blocked    = spec conflict ∨ genuine fork ∨ unevaluable acceptance  (a human's call)
               ─▶ record in `## build` · hand to `/spec` or the human · say plainly what's needed to resume
  stuck      = two consecutive firings · same failure · no new information
               ─▶ honest stuck-report: what failed · what was tried · best hypothesis
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
- **One loop at a time** — if `## build` already records a live loop-task id,
  don't schedule a second; resume managing the existing one.
- **Stamp evidence with real OS time** (`date -u`); never fabricate a green.
