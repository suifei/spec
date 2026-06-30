# CLAUDE.md

Guidance for AI agents working in this repository.

<!-- BEGIN SPEC-AUTHORITY (managed by /spec) -->
## Specification authority
`SPEC.md` is the authoritative specification for this project and the
**highest-priority** reference. Before planning or implementing anything, read
`SPEC.md` and conform to it — especially its **Gates** (the load-bearing sources
of truth) and its **Decision Log**. A phase may not be built until its load-bearing
gates are probe-verified (green) in `SPEC.md`. If reality and `SPEC.md` disagree,
treat `SPEC.md` as intent and run `/spec` to reconcile. Do not silently contradict
it.
<!-- END SPEC-AUTHORITY -->

## About this repository

This repo provides the **`/spec`** command — **Gate 1** of an AI-assisted
development process. It is one repeatable command (like `/init`, but for the
living spec) in which the AI plays an **expert requirements-elicitation analyst**:
it takes the user's vague idea, **clarifies it through investigation** (reads what
you point at, mines the project's data, searches its knowledge and the web —
preferring top-tier authoritative sources — reasons it through; investigation *is*
research), **organizes and reflects the idea back**, **offers better views**, and
**reports what is closed-loop (ready) vs not yet thought through**. It is **honest
— including saying no**: it refuses the research-proven-infeasible with the real
reason rather than spec a known-wrong wish. In effect it stands in for a bench of
roles at once — market/requirements research, brainstorming,
feasibility/requirements analysis, technical architecture, design review. It then standardizes the result — key content, boundaries, and
anti-patterns — into one authoritative, *feasible* `SPEC.md`. It resolves
everything it can itself and **registers the reasoning** (Decision Log), asking the
human only about genuine forks or a better option it found. **Load-bearing** gates
are backed by real, runnable **probes** (`.spec/probes/`) — commonsense facts (a
free port, a writable dir) are never gates. Findings persist (`.spec/knowledge/`)
so they aren't re-explored, and progress is externalized to `.spec/STATE.md`, so
`/spec` is **resumable** across context resets.

Implemented as a Claude Code skill in `.claude/skills/spec/` with a slash-command
wrapper in `.claude/commands/spec.md`. The full design rationale (discussion rounds
+ a consolidated decision log) is in `docs/DESIGN-NOTES.md`.

The repo also provides **`/build`** — **Gate 1.5**, the construction layer that
*reads* `SPEC.md` and writes the code from it, keeping the design/tasks plan
**ephemeral** (regenerated each run, never enshrined) so it can't drift, and closing
construction only when each requirement's acceptance holds and the load-bearing
gates are green. (`.claude/skills/build/` + `.claude/commands/build.md`.) Gate 2
(skill extraction) remains Claude Code's built-in skill-builder and is out of scope.

Run `/spec` to create/update/reconcile the spec; run `/build` to construct from it.

> This repo **dogfoods itself**: its own `SPEC.md` + `.spec/` (produced by a real
> `/spec` run) specify the `/spec → /build` pipeline — Phase 1 (`/spec`) sealed,
> Phase 2 (`/build`) built. In a *fresh* project, `SPEC.md` and `.spec/` don't exist
> until you run `/spec` for the first time.
