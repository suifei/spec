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
targeted requirement's acceptance holds and the load-bearing gates are green
(re-run `.spec/probes/`). Show the diff + green gates before committing.

If reality contradicts `SPEC.md`, **stop and route me to `/spec`** — never silently
patch the spec. Default surface: propose-then-apply with checkpoints.

Input (optional): $ARGUMENTS
