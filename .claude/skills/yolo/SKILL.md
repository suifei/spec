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

### Setup (first invocation)
1. Rehydrate exactly as `/build` Step 0 (CLAUDE.md → SPEC.md, `## build` section,
   knowledge, gates, worktree). If `SPEC.md` is missing or has open blocking
   questions, stop — nothing to run a loop against; send the human to `/spec`.
   **Re-entry check:** if `## build` already records a live loop-task id, this
   invocation *is* a scheduled tick firing — skip the rest of Setup and go
   straight to "Each tick".
2. State the target set (every buildable `[locked]` requirement, or what the
   human scoped in the arguments) and announce the loop contract: what will run,
   when it will stop by itself.
3. **Schedule the loop — with real tool calls, not narration:**
   - **Find the scheduler before concluding it's absent.** Check the
     available-skills list for the `loop` skill and the tool list for the Cron
     tools (`CronCreate` / `CronDelete` / `CronList`). In Claude Code these
     tools are often **deferred**: only their names appear, and calling them
     fails until their schemas are loaded with `ToolSearch`
     (`select:CronCreate,CronDelete,CronList`). **Deferred ≠ unavailable** —
     never fall back inline just because a tool needs loading first.
   - **Preferred path:** invoke the `loop` skill via the Skill tool with an
     interval around one minute and a prompt that **re-invokes this command
     verbatim** — e.g. args: `1m /yolo <the same arguments this run received>`.
     Each firing then re-enters `/yolo`, which recognizes the live loop id
     (step 1's re-entry check) and runs exactly one tick. Calling `CronCreate`
     directly with that interval and prompt is equivalent.
   - Record the returned task id in the `## build` section (so a resumed
     session can find and manage it).
   - Then run **tick #1 immediately** in this session and end the turn — the
     scheduler drives every subsequent tick. One driver at a time: never also
     keep cycling inline while a cron is live.
   - **Inline fallback — only if both the `loop` skill and the Cron tools are
     genuinely absent:** run the same tick cycle back-to-back **in this same
     turn**, and do **not** end the turn after one tick. Inline, the turn ends
     only when a termination condition below holds. "One tick, then silence"
     is precisely the failure this command exists to prevent.

### Each tick
1. Rehydrate from `## build`; reconcile the worktree (interrupted-tick residue is
   handled exactly as `/build` Step 0 prescribes).
2. If buildable targets remain: run the `/build` cycle **autonomous-to-green**
   (plan → construct → re-run gates + acceptance), skipping the propose/commit
   pauses — `/yolo`'s invocation is the standing approval. Commit the code on
   green, exactly as `/build` Step 5 (never the plan).
3. **Code-review the tick's diff** — when a `code-review` skill is in the
   available-skills list, actually invoke it via the Skill tool (don't just
   mention it); else run a self-review pass at the same bar: hunt real defects,
   verify before acting. Fix the verified findings; re-run gates if the fixes
   touched anything gated; commit.
4. Update `## build` (built / remaining / next / loop-task id) with a real UTC
   timestamp — every tick, even a no-op one.
5. **Close the tick:** evaluate the termination conditions below. If one holds,
   terminate (delete the loop, final report). Otherwise: with a live cron, end
   the turn — the next firing continues; running inline, go straight into the
   next tick without ending the turn.

### Termination (the part that makes /yolo trustworthy)
Delete the loop task (CronDelete with the recorded id — load its schema via
`ToolSearch` first if it's deferred; or simply end, if running inline) and
write a final report when **any** of these holds:
- **Done:** no buildable `[locked]` work remains — every targeted requirement's
  acceptance holds and gates are green (evidence captured). Report what was
  built, the green results, and the review findings fixed along the way.
- **Blocked on a human:** spec conflict / genuine fork / unevaluable acceptance —
  recorded in `## build`, loop deleted, handed to `/spec` or the human. Say
  plainly what's needed to resume.
- **Stuck:** two consecutive ticks, same failure, no new information — loop
  deleted, honest stuck-report (what failed, what was tried, best hypothesis).
- **The human says stop** — immediately, no argument.

Never leave an orphaned loop running after any of these; a forgotten cron
re-running against a finished (or wedged) repo is the one way `/yolo` can do
harm, so the delete is part of the definition of done.

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
