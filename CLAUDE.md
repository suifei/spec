# CLAUDE.md

Guidance for AI agents working in this repository.

<!-- BEGIN SPEC-AUTHORITY (managed by /spec) -->
## Specification authority
`SPEC.md` is the authoritative specification for this project and the
**highest-priority** reference. Before planning or implementing anything, read
`SPEC.md` and conform to it — especially its "Sources of Truth & Gates" section. A
phase may not be built until its gates are probe-verified (green) in `SPEC.md`. If
reality and `SPEC.md` disagree, treat `SPEC.md` as intent and run `/spec` to
reconcile. Do not silently contradict it.
<!-- END SPEC-AUTHORITY -->

## About this repository

This repo provides the **`/spec`** command — **Gate 1** of an AI-assisted
development process. It is one repeatable command (like `/init`, but for the
living spec) that acts as a **reconnaissance scout**: it investigates first
(reads what you point at, checks its knowledge cache, searches the web when
needed, probes reality), brainstorms with you to find the core problem and reach
closure, and maintains one authoritative, *feasible* `SPEC.md`. It doesn't take
answers on faith — sources of truth / gates are backed by real, runnable
**probes** (`.spec/probes/`), and findings are persisted so they aren't
re-explored (`.spec/knowledge/`). Progress is externalized to `.spec/STATE.md`,
so `/spec` is **resumable** across context resets — the human only brainstorms
and decides; the AI does the heavy lifting.

Implemented as a Claude Code skill in `.claude/skills/spec/` with a slash-command
wrapper in `.claude/commands/spec.md`. The full design rationale (9 discussion
rounds + a consolidated decision log) is in `docs/DESIGN-NOTES.md`.

Run `/spec` to create, update, reconcile, or resume `SPEC.md`. Execution and Gate
2 (skill extraction — Claude Code's built-in skill-builder) are intentionally
decoupled; they just read this file and `SPEC.md` (and `.spec/knowledge/` for
pinned facts).

> Note: `SPEC.md` and `.spec/` do not exist until you run `/spec` for the first
> time. Until then, the authority block above points at documents `/spec` will
> generate.
