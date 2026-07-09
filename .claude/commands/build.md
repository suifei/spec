---
description: Construct code from the authoritative SPEC.md (Gate 1.5). Ephemeral plan, gate-closed, resumable.
argument-hint: "[which phase/requirement to build, or nothing to continue from STATE.md]"
---

Invoke the `build` skill.

First **rehydrate** from `CLAUDE.md` → `SPEC.md` + `.spec/` (gates, Decision Log,
knowledge, `STATE.md`) and tell me where construction stands. Then pick the target,
**regenerate an ephemeral design/tasks plan** (disposable, gitignored — never a
committed source of truth), show it for approval, **construct** the code conforming
to the spec's decisions/anti-patterns/spec-line, and **close only when** each
targeted requirement's acceptance holds, the load-bearing gates are green
(re-run `.spec/probes/`), and — for generated/quality work — an independent
review has signed off (the done-condition; see `build/SKILL.md` principle 3).
Show the diff + green gates before committing.

If reality contradicts `SPEC.md`, **stop and route me to `/spec`** — never silently
patch the spec. Default surface: propose-then-apply with checkpoints.

Write your reports/plan/summaries in `SPEC.md`'s pinned **Artifact language** —
`/build` never asks about language itself, it only reads the pin (code/paths/URLs/
timestamps stay verbatim).

Input (optional): $ARGUMENTS
