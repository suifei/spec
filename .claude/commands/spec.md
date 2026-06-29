---
description: Brainstorm to a feasible spec, with the AI as your scout. Creates/updates SPEC.md (Gate 1). Resumable.
argument-hint: "[an idea, a PRD, a repo/path to read, or nothing to resume]"
---

Invoke the `spec` skill.

First **rehydrate** from `.spec/STATE.md` (+ `SPEC.md`, `.spec/knowledge/`) and tell
me where things stand. Then **scout first** (read what I point at, check the
knowledge cache, search your knowledge, search the web only when needed, probe for
evidence — delegate heavy reads to a sub-agent and keep only the summary), present
your findings, ask me only what needs me (aim at the core problem, low burden),
help me decide, verify gates with real probes, and persist everything (SPEC.md +
.spec/) — doing one safe-to-stop chunk and updating `.spec/STATE.md`.

I only brainstorm and decide; you do the heavy lifting.

Input (optional): $ARGUMENTS
