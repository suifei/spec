---
name: spec-builder
description: >-
  Spec-driven development (SDD) for this repo. Use when the user wants to plan a
  feature/change before coding, write or update specs/requirements, create a
  change proposal, or set up the spec-builder/ workspace. This is the entry point
  and router; it explains the methodology, sets up the workspace, and hands off
  to the lifecycle skills (explore, propose, apply, verify, archive).
---

# Spec-Builder — Spec-Driven Development for Claude Code

Spec-Builder is a lightweight, file-based spec-driven development workflow. Specs
are the source of truth: before non-trivial work you write down *what should
happen* as a **change** (proposal + spec deltas + design + tasks), implement
against it, then merge the deltas into the living **specs** and archive the change.

It runs entirely on the filesystem with Claude Code's own tools — **no external
CLI or package required.** Status, instructions, and templates are all embedded in
this skill's references.

## First: load the conventions

Before creating or editing any artifact, read these two files (once per session):

- `references/conventions.md` — directory layout, spec & delta format, how to
  derive status, and how deltas merge into specs. **The format rules are strict
  and fail silently if violated** (e.g. scenarios need exactly `####`).
- `references/spec-driven-schema.md` — the artifact graph and exact per-artifact
  instructions/rules (proposal → specs → design → tasks → apply).

Templates: `references/templates/` (`proposal.md`, `design.md`, `tasks.md`,
`delta-spec.md` for change deltas, `spec.md` for full/main specs).
Scripts: `references/scripts/` (`spec_status.py`, `spec_lint.py`).

## The lifecycle and which skill to use

```
explore ──▶ propose ──▶ apply ──▶ [verify] ──▶ archive
```

| Intent | Use |
|--------|-----|
| "Help me think through X" / weigh options, no code yet | `spec-builder-explore` (`/spec:explore`) |
| "Propose/plan a change for X" (create artifacts; resumable) | `spec-builder-propose` (`/spec:propose`) |
| "Implement it" / do the tasks | `spec-builder-apply` (`/spec:apply`) |
| "Check the implementation matches the spec" | `spec-builder-verify` (`/spec:verify`) |
| "It's done — merge specs and archive it" | `spec-builder-archive` (`/spec:archive`) |

`propose` also handles **setup** (it scaffolds the workspace if missing) and
**continuation** (re-running it on an existing change fills in missing artifacts).
`archive` also handles the **spec merge** (it merges the change's delta specs into
`spec-builder/specs/` before moving the change). So the user-facing surface is just
four commands plus an optional `verify`.

When the user's intent clearly matches a row above, invoke that skill. If they're
just getting started or unsure, stay here and orient them.

The workflow is **fluid, not rigid** — update any artifact anytime; no hard phase
gates. Prefer momentum on low-stakes calls; pause and ask when a choice is the
user's to make.

## Setting up the workspace

`propose`/`explore` will scaffold automatically, but to set up explicitly:

1. Create the structure:
   ```bash
   mkdir -p spec-builder/specs spec-builder/changes/archive
   ```
2. Create `spec-builder/project.md` capturing project context (used by every later
   artifact). Research the repo first (README, manifests, structure), then fill in:

   ```markdown
   # Project Context

   ## Purpose
   <What this project is and who it's for.>

   ## Tech Stack
   <Languages, frameworks, key dependencies, runtime.>

   ## Conventions
   <Code style, directory layout, naming, testing approach an agent should follow.>

   ## Domain Glossary
   <Project-specific terms and their meanings.>
   ```

3. (Optional) If the codebase already has substantial behavior worth capturing,
   offer to seed `spec-builder/specs/<capability>/spec.md` files documenting what
   exists today, using `references/templates/spec.md`. Don't force it.

4. Tell the user it's ready; suggest `/spec:explore` (to think) or `/spec:propose`.

## Status at a glance

```bash
python3 .claude/skills/spec-builder/references/scripts/spec_status.py          # human summary
python3 .claude/skills/spec-builder/references/scripts/spec_status.py --json   # machine-readable
python3 .claude/skills/spec-builder/references/scripts/spec_lint.py            # validate spec format
```

The status script reports, per change: artifact statuses
(done/ready/blocked/optional), `applyReady`, `isComplete`, task progress (N/M), and
delta capabilities; plus capabilities under `spec-builder/specs/`. See
`references/conventions.md` for the underlying rules and the manual fallback.

## Guardrails

- Read upstream artifacts (and relevant specs/code) before writing a new one.
- Templates give structure; instructions/rules are constraints for *you* — never
  copy instruction or context text into an output file.
- Verify each file exists after writing before moving on.
- Don't edit `spec-builder/specs/` directly during feature work — propose a delta
  in a change, then merge + archive.
