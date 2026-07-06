---
description: Autonomous construct-to-green loop over /build. Schedules itself, reviews itself, deletes itself when done.
argument-hint: "[phase/requirements to target, or nothing = everything buildable]"
---

Invoke the `yolo` skill.

This is `/build`'s autonomous-to-green mode plus a self-terminating loop: my
invoking it **is** the standing approval for the checkpoints `/build` would
normally pause at.

The whole point of `/yolo` is to **start a real recurring loop**, so that is the
first substantive move — mechanical, not narrated. Rehydrate like `/build`
(SPEC.md, `## build`, gates, worktree); stop before scheduling only if there's
no spec, open blocking questions, no buildable `[locked]` work, or a loop is
already live (one loop at a time). Otherwise **fire the loop**: invoke the
`loop` skill with args `1m <fixed prompt>` (or call `CronCreate` with cron
`*/1 * * * *` and that prompt). The prompt is fixed and self-contained — each
firing is a fresh, stateless turn, so it carries the whole tick contract:

> `/build` — continue autonomously to green; do NOT pause at propose/commit
> checkpoints. Each firing: rehydrate from `## build`; if buildable `[locked]`
> work remains, drive `/build` to green (plan → construct → re-run gates +
> acceptance) and commit on green; code-review the diff (`/code-review` if
> present) and fix verified findings; checkpoint `## build` with real UTC time;
> then end the turn. When no buildable work remains — or on a spec conflict /
> genuine fork / two firings with the same failure — delete this loop
> (`CronList` → `CronDelete`) and write the final report.

Record the job id in `## build`, then **end the turn** — a session-only cron
fires only when the REPL is idle, so the loop can't advance until you stop; do
not hand-crank a tick yourself. Only if neither the `loop` skill nor
`CronCreate` exists here, run that same tick cycle inline, back-to-back, never
stopping after one tick.

Terminate the loop yourself (CronDelete) the moment any of these holds: all
buildable `[locked]` work is done with green evidence · a spec conflict / genuine
fork / unevaluable acceptance needs a human (record it, hand back to `/spec`) ·
two ticks with the same failure and no new information (honest stuck-report) ·
I say stop. Never leave an orphaned loop running, and never declare done without
gate-judged evidence — speed is the point, self-certification is the failure.

Artifact language: read `SPEC.md`'s pinned "Artifact language" and use it — never
ask.

Input (optional): $ARGUMENTS
