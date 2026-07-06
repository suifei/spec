---
description: Autonomous construct-to-green loop over /build. Schedules itself, reviews itself, deletes itself when done.
argument-hint: "[phase/requirements to target, or nothing = everything buildable]"
---

Invoke the `yolo` skill.

This is `/build`'s autonomous-to-green mode plus a self-terminating loop: my
invoking it **is** the standing approval for the checkpoints `/build` would
normally pause at. Rehydrate like `/build` (SPEC.md, `## build` section, gates,
worktree), state the target set, then schedule the loop — prefer the native
scheduler (`/loop` → CronCreate, recording the task id in `## build`); if none
exists here, run the same tick cycle inline.

Each tick: run `/build` to green (plan → construct → re-run gates + acceptance),
code-review the diff and fix verified findings, commit, checkpoint `## build`
with real UTC time.

Terminate the loop yourself (CronDelete) the moment any of these holds: all
buildable `[locked]` work is done with green evidence · a spec conflict / genuine
fork / unevaluable acceptance needs a human (record it, hand back to `/spec`) ·
two ticks with the same failure and no new information (honest stuck-report) ·
I say stop. Never leave an orphaned loop running, and never declare done without
gate-judged evidence — speed is the point, self-certification is the failure.

Artifact language: read `SPEC.md`'s pinned "Artifact language" and use it — never
ask.

Input (optional): $ARGUMENTS
