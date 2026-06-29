# CLAUDE.md

Guidance for AI agents working in this repository.

<!-- BEGIN SPEC-AUTHORITY (managed by /spec) -->
## Specification authority
`SPEC.md` is the authoritative specification for this project and the
**highest-priority** reference. Before planning or implementing anything, read
`SPEC.md` and conform to it — especially its "Sources of Truth & Gates" section.
If reality and `SPEC.md` disagree, treat `SPEC.md` as intent and surface the drift
(or run `/spec` to reconcile). Do not silently contradict it.
<!-- END SPEC-AUTHORITY -->

## About this repository

This repo provides the **`/spec`** command: a single, repeatable command that
brainstorms with you to closure and maintains one authoritative specification
document (`SPEC.md`). It is implemented as a Claude Code skill in
`.claude/skills/spec/` with a slash-command wrapper in `.claude/commands/spec.md`.

Run `/spec` to create or update `SPEC.md`. Execution and any other skills are
intentionally decoupled from `/spec`; they simply read this file and `SPEC.md`.

> Note: `SPEC.md` does not exist until you run `/spec` for the first time. Until
> then, the authority block above points at a document that `/spec` will generate.
