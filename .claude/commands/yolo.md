---
description: Autonomous construct-to-green loop over /build. Schedules itself, obtains independent review where required, and deletes itself when done.
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
`*/1 * * * *` and that prompt). The **authoritative fixed, self-contained tick prompt** lives in `yolo/SKILL.md`
("Fire the loop") — each firing is a fresh, stateless turn, so the prompt carries
the whole tick contract itself (re-read `SPEC.md` + acceptance + anti-patterns
from disk → `/build` to green → **independent review for generated/quality work**
→ checkpoint `## build` → end turn; self-terminate on done / conflict /
no-material-progress / hard ceiling). This wrapper does **not** restate that
prompt — read it from `yolo/SKILL.md` so the two cannot drift apart.

Record the job id in `## build`, then **end the turn** — a session-only cron
fires only when the REPL is idle, so the loop can't advance until you stop; do
not hand-crank a tick yourself. Only if neither the `loop` skill nor
`CronCreate` exists here, run that same tick cycle inline, back-to-back, never
stopping after one tick.

Terminate the loop yourself (CronDelete) the moment any of these holds: all
buildable `[locked]` work is done — acceptance holds **and** green gates **and**
(for generated/quality work) the independent review signed off · a spec conflict /
genuine fork / unevaluable acceptance needs a human (record it, hand back to
`/spec`) · two ticks with the same failure, or several ticks with no material
progress (no gate red→green, no requirement closed — only cosmetic churn) · the
hard ceiling (~20 ticks, or a cost/token budget) · I say stop. Never leave an
orphaned loop running, and never declare done without gate-judged evidence —
speed is the point, self-certification is the failure.

Artifact language: read `SPEC.md`'s pinned "Artifact language" and use it — never
ask.

Input (optional): $ARGUMENTS
