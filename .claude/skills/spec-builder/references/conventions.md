# Spec-Builder Conventions

This is the canonical reference for the Spec-Builder spec-driven development (SDD)
workflow as executed natively by Claude Code. Every `spec-builder-*` skill relies
on the rules below. Read this file once per session before creating or editing any
artifact.

## The core idea

Specs are the source of truth, not code. Before non-trivial work, you write down
*what should happen* and get alignment. Code is then written to match the agreed
spec. This keeps humans and AI agents aligned on intent.

There are two kinds of spec content:

1. **Specs** (`spec-builder/specs/`) — the *current, deployed truth*. What the
   system does **today**. Stable, long-lived knowledge.
2. **Changes** (`spec-builder/changes/`) — *proposed deltas*. What we want to
   change. A change is a folder of artifacts (proposal, spec deltas, design,
   tasks). When a change ships, its deltas are merged into the specs and the
   change is archived.

This separation is the whole game: you never edit `specs/` directly during
feature work — you propose a delta in a change, implement it, then merge + archive.

## Directory layout

```
spec-builder/
├── project.md                      # Project context & conventions (recommended)
├── specs/                          # CURRENT truth — what is built today
│   └── <capability>/
│       └── spec.md                 # Purpose + Requirements (with Scenarios)
└── changes/                        # PROPOSED work
    ├── <change-name>/              # one folder per change, kebab-case name
    │   ├── proposal.md             # WHY + WHAT (the contract)
    │   ├── design.md               # HOW (technical decisions) — optional
    │   ├── tasks.md                # implementation checklist (drives apply)
    │   └── specs/
    │       └── <capability>/
    │           └── spec.md         # DELTA spec (ADDED/MODIFIED/REMOVED/RENAMED)
    └── archive/
        └── YYYY-MM-DD-<change-name>/   # completed changes, moved here
```

- `<capability>` is a kebab-case noun for a slice of behavior (e.g. `user-auth`,
  `data-export`). One capability = one spec file. Capabilities are stable and
  long-lived; changes are transient.
- A change's `specs/<capability>/spec.md` is a **delta** — only the requirements
  that change, wrapped in delta operation headers.
- `spec-builder/specs/<capability>/spec.md` is the **full** spec — the merged
  result of all archived deltas.

## "Status" of a change (filesystem-derived)

There is no daemon. Status is derived from which files exist and the checkbox
state of `tasks.md`. **Prefer the helper script** (deterministic):

```bash
python3 .claude/skills/spec-builder/references/scripts/spec_status.py            # all changes
python3 .claude/skills/spec-builder/references/scripts/spec_status.py --change <name> --json
python3 .claude/skills/spec-builder/references/scripts/spec_status.py --list     # active change names
python3 .claude/skills/spec-builder/references/scripts/spec_status.py --capabilities
```

JSON fields: `artifacts.<id>.status` (done/ready/blocked/optional), `applyReady`,
`isComplete`, `tasks` (total/complete/pending), `deltaCapabilities`. The script
finds the `spec-builder/` root by walking up from the current directory.

Validate spec format anytime with:
```bash
python3 .claude/skills/spec-builder/references/scripts/spec_lint.py
```

Manual fallback (if Python is unavailable):

- **Active changes**: directories under `spec-builder/changes/` except `archive/`.
- **Artifact status** (schema order proposal → specs → design → tasks):
  `done` = file(s) exist & non-empty; `ready` = deps done but missing;
  `blocked` = a hard dependency missing. (`design` is optional — never blocks.)
- **Apply-ready**: `tasks.md` exists with at least one checkbox.
- **Task progress**: count `- [ ]` (pending) vs `- [x]` (done).

See `spec-driven-schema.md` for the artifact graph and per-artifact instructions.

## Spec format (fails silently if you get it wrong)

A **full spec** (`spec-builder/specs/<capability>/spec.md`):

```markdown
# <Capability Name> Specification

## Purpose
<1–3 sentences on what this capability is and why it exists.>

## Requirements

### Requirement: <Short Name>
The system SHALL <normative statement>.

#### Scenario: <Short Name>
- **WHEN** <condition / trigger>
- **THEN** <expected, observable outcome>
- **AND** <additional outcome, optional>
```

Hard rules (the common silent-failure modes):

- Requirement header is exactly `### Requirement: <name>` (3 hashes).
- Scenario header is exactly `#### Scenario: <name>` (**4 hashes**). Using 3
  hashes or a bullet list will fail silently.
- **Every requirement MUST have at least one scenario.**
- Use **SHALL** / **MUST** for normative requirements (avoid "should" / "may").
- Each scenario reads like a testable case (WHEN / THEN) — a candidate test.
- Requirement names are unique within a spec and stable (matched by text,
  whitespace-insensitive, when merging).

## Delta spec format (inside a change)

A **delta spec** records only what changes, under `##` operation headers:

```markdown
## ADDED Requirements

### Requirement: User can export data
The system SHALL allow users to export their data in CSV format.

#### Scenario: Successful export
- **WHEN** user clicks "Export"
- **THEN** the system downloads a CSV file containing all user data

## MODIFIED Requirements

### Requirement: Existing Feature
The system SHALL <full, updated requirement text>.

#### Scenario: New scenario being added
- **WHEN** ...
- **THEN** ...

## REMOVED Requirements

### Requirement: Legacy export
**Reason**: Replaced by the new export system.
**Migration**: Use the new export endpoint at /api/v2/export.

## RENAMED Requirements

- FROM: `### Requirement: Old Name`
- TO: `### Requirement: New Name`
```

Delta operation rules:

- **ADDED** — brand-new requirements. Full requirement + scenarios.
- **MODIFIED** — changed behavior. When **authoring**, prefer including the
  complete updated requirement block. The merge step (below) also accepts a
  *partial* MODIFIED (e.g. just a new scenario) and preserves untouched content.
  - If you're only *adding* a new concern without changing existing behavior, use
    ADDED, not MODIFIED.
- **REMOVED** — deprecated requirements. MUST include `**Reason**` and
  `**Migration**`.
- **RENAMED** — name-only changes. Use the `FROM:` / `TO:` format.

## Merging deltas into specs (done at archive time)

Archiving merges a change's delta specs into the living specs. This is
**agent-driven** intelligent merging — read the delta and the main spec, then edit
the main spec. For each capability delta:

1. Read the delta at `spec-builder/changes/<name>/specs/<capability>/spec.md`.
2. Read the main spec at `spec-builder/specs/<capability>/spec.md` (may not exist).
3. Apply each operation:
   - **ADDED**: if the requirement is absent → add it; if present → update to match
     (treat as implicit MODIFIED).
   - **MODIFIED**: find the requirement and apply the changes — add new scenarios,
     edit existing ones, or change the description. **Preserve scenarios/content
     not mentioned in the delta.**
   - **REMOVED**: delete the entire requirement block from the main spec.
   - **RENAMED**: rename the FROM requirement to TO.
4. If the capability's main spec doesn't exist yet, create it from
   `templates/spec.md`: add a Purpose (brief/TBD ok) and the ADDED requirements.

Key principle: the delta represents **intent**, not a wholesale replacement. Use
judgment; the merge should be idempotent (running twice yields the same result).

## The lifecycle (4 commands + optional verify)

```
explore ──▶ propose ──▶ apply ──▶ [verify] ──▶ archive
            (auto-init,                          (merge deltas
             resumable)                           into specs, then move)
```

| Stage | Skill | Slash command | What it does |
|-------|-------|---------------|--------------|
| Explore | `spec-builder-explore` | `/spec:explore` | Thinking partner; reads code, weighs options. **Never implements.** |
| Propose | `spec-builder-propose` | `/spec:propose` | Scaffold workspace if needed, then create a change and its artifacts (all at once, or continue a partial one). |
| Apply | `spec-builder-apply` | `/spec:apply` | Implement the tasks; tick checkboxes as you go. |
| Verify | `spec-builder-verify` | `/spec:verify` | (Optional) Check implementation vs artifacts before archiving. |
| Archive | `spec-builder-archive` | `/spec:archive` | Merge delta specs into the living specs, then move the change to `archive/`. |

The workflow is **fluid, not rigid**: update any artifact anytime, no hard phase
gates. `propose` is resumable — re-running it on an existing change fills in the
missing artifacts. Prefer momentum on low-stakes calls; pause and ask when a
choice is the user's to make.

## Working principles (apply across all skills)

- **Don't guess; ask when it matters.** Use AskUserQuestion when change selection
  is ambiguous or context is critically unclear. Prefer reasonable decisions to
  keep momentum on low-stakes choices.
- **Read dependencies before writing.** Read upstream artifacts (and relevant
  specs/code) before creating a new one.
- **Templates are structure; instructions/rules are constraints.** Fill in a
  template's sections. Never copy *instruction* or context text into the output.
- **Verify each file after writing** before moving on.
- **Keep proposals concise** (1–2 pages). The "how" goes in design.md; the "why"
  in proposal.md.
- **Specs are testable.** Write scenarios you could hand to QA.
