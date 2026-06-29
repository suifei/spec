# Spec-Builder

**Spec-driven development (SDD) for Claude Code** — a lightweight, file-based
workflow where specs are the source of truth. Before non-trivial work you write a
**change** (a proposal + spec deltas + design + tasks), implement against it, then
merge the deltas into the living **specs** and archive the change.

It runs entirely on the filesystem with Claude Code's built-in tools — **no
external CLI or package required.**

## The idea

```
spec-builder/
├── project.md            # project context & conventions
├── specs/                # CURRENT truth — what is built today
│   └── <capability>/spec.md
└── changes/              # PROPOSED work
    ├── <change-name>/
    │   ├── proposal.md   # WHY + WHAT (the contract)
    │   ├── design.md     # HOW (optional)
    │   ├── tasks.md      # implementation checklist
    │   └── specs/<capability>/spec.md   # delta (ADDED/MODIFIED/REMOVED/RENAMED)
    └── archive/YYYY-MM-DD-<change-name>/
```

You never edit `specs/` directly during feature work — you propose a delta in a
change, implement it, then merge + archive.

## The lifecycle — 4 commands (+ optional verify)

```
explore ──▶ propose ──▶ apply ──▶ [verify] ──▶ archive
```

| Command | Skill | What it does |
|---------|-------|--------------|
| `/spec:explore` | `spec-builder-explore` | Thinking partner; reads code, weighs options. **Never implements.** |
| `/spec:propose` | `spec-builder-propose` | Scaffold workspace if needed, then create a change and its artifacts. **Resumable** — re-run to fill in missing artifacts. |
| `/spec:apply` | `spec-builder-apply` | Implement the tasks; tick checkboxes as you go. |
| `/spec:verify` | `spec-builder-verify` | *(Optional)* Check implementation vs artifacts before archiving. |
| `/spec:archive` | `spec-builder-archive` | **Merge** the change's delta specs into the living specs, then move it to `archive/`. |

`propose` absorbs workspace setup and step-by-step continuation; `archive` absorbs
the spec merge. So the surface is just four commands plus an optional `verify`.

The workflow is **fluid, not rigid**: update any artifact anytime, no hard phase
gates.

## Usage

In Claude Code, either:

- **Type a slash command**: `/spec:propose add user authentication`
- **Just describe intent**: "let's plan a change to add CSV export" — the matching
  `spec-builder-*` skill triggers automatically from its description.

Start with `/spec:propose` (it scaffolds `spec-builder/` on first run), or
`/spec:explore` to think first.

### Deterministic status & lint (no dependencies)

```bash
# status of all changes (artifact statuses, applyReady, isComplete, N/M tasks)
python3 .claude/skills/spec-builder/references/scripts/spec_status.py
python3 .claude/skills/spec-builder/references/scripts/spec_status.py --change <name> --json

# validate the strict spec format (fails non-zero on errors)
python3 .claude/skills/spec-builder/references/scripts/spec_lint.py
```

## Spec format (strict — fails silently if wrong)

```markdown
### Requirement: User can export data
The system SHALL allow users to export their data in CSV format.

#### Scenario: Successful export
- **WHEN** user clicks "Export"
- **THEN** the system downloads a CSV file with all user data
```

- `### Requirement:` (3 hashes), `#### Scenario:` (**exactly 4 hashes**).
- Every requirement needs **≥ 1 scenario**. Use **SHALL/MUST**.
- In a change, specs are **deltas** under `## ADDED/MODIFIED/REMOVED/RENAMED
  Requirements`. The archive merge applies them to the living specs, preserving
  content a `MODIFIED` delta doesn't mention.

See `.claude/skills/spec-builder/references/conventions.md` for the complete rules.

## Worked example

[`examples/slugify/`](examples/slugify/) is the end-state of two full lifecycle
runs on a tiny library — including a **partial `MODIFIED`** delta merged into an
existing spec (the original scenarios are preserved, the new one folded in). It
ships with working code, tests, and the archived changes; run the status/lint
scripts and the tests against it to see the workflow's output.

## Layout

```
.claude/
├── skills/
│   ├── spec-builder/                 # umbrella: methodology, setup, router
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── conventions.md        # layout, spec/delta format, merge rules
│   │       ├── spec-driven-schema.md # artifact graph + per-artifact instructions
│   │       ├── templates/            # proposal, design, tasks, delta-spec, spec
│   │       └── scripts/              # spec_status.py, spec_lint.py (no deps)
│   ├── spec-builder-explore/SKILL.md
│   ├── spec-builder-propose/SKILL.md
│   ├── spec-builder-apply/SKILL.md
│   ├── spec-builder-verify/SKILL.md
│   └── spec-builder-archive/SKILL.md
├── commands/spec/                    # /spec:* slash-command wrappers
│   ├── explore.md  propose.md  apply.md  verify.md  archive.md
└── examples/slugify/                 # worked end-to-end example
```
