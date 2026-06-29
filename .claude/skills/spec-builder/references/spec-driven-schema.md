# Spec-Driven Schema

The default Spec-Builder workflow: **proposal → specs → design → tasks → apply**.
It defines the artifacts of a change, their dependency order, and the exact
instructions/rules for creating each. The lifecycle skills use this as the
"instructions" source for each artifact.

```
name: spec-driven
artifact graph (requires):
  proposal : []                      → proposal.md
  specs    : [proposal]              → specs/<capability>/spec.md  (one per capability)
  design   : [proposal]              → design.md     (conditional — see below)
  tasks    : [specs, design]         → tasks.md
apply:
  requires: [tasks]
  tracks:   tasks.md
```

Build order: **proposal → specs → design → tasks**. `tasks` requires both `specs`
and `design`, so create `design` (or consciously skip it — see its rule) before
`tasks`.

Each artifact lists: the **template** (`templates/<file>` for structure), the
**instruction** (what to write), and **requires** (read these first).

---

## Artifact: proposal  →  `proposal.md`

**Template:** `templates/proposal.md` · **Requires:** (none)

> Create the proposal document that establishes WHY this change is needed.
>
> Sections:
> - **Why**: 1–2 sentences on the problem or opportunity. What problem does this solve? Why now?
> - **What Changes**: Bullet list of changes. Be specific about new capabilities, modifications, or removals. Mark breaking changes with **BREAKING**.
> - **Capabilities**: Identify which specs will be created or modified:
>   - **New Capabilities**: capabilities being introduced. Each becomes a new `specs/<name>/spec.md`. Use kebab-case names (e.g., `user-auth`, `data-export`).
>   - **Modified Capabilities**: existing capabilities whose REQUIREMENTS are changing. Only include if spec-level behavior changes (not just implementation). Each needs a delta spec file. Check `spec-builder/specs/` for existing spec names. Leave empty if no requirement changes.
> - **Impact**: Affected code, APIs, dependencies, or systems.
>
> IMPORTANT: The Capabilities section is the contract between the proposal and
> specs phases. Research existing specs before filling it in. Each capability
> listed here needs a corresponding spec file.
>
> Keep it concise (1–2 pages). Focus on the "why" not the "how" — implementation
> details belong in design.md. This is the foundation — specs, design, and tasks
> all build on it.

---

## Artifact: specs  →  `specs/**/*.md`  (one file per capability)

**Template:** `templates/delta-spec.md` · **Requires:** proposal

> Create specification files that define WHAT the system should do.
>
> Create one spec file per capability listed in the proposal's Capabilities section.
> - New capabilities: use the exact kebab-case name from the proposal (`specs/<capability>/spec.md`).
> - Modified capabilities: use the existing spec folder name from `spec-builder/specs/<capability>/` when creating the delta at `specs/<capability>/spec.md`.
>
> Delta operations (use `##` headers):
> - **ADDED Requirements**: New capabilities
> - **MODIFIED Requirements**: Changed behavior — include the full updated content
> - **REMOVED Requirements**: Deprecated features — MUST include **Reason** and **Migration**
> - **RENAMED Requirements**: Name changes only — use FROM:/TO: format
>
> Format requirements:
> - Each requirement: `### Requirement: <name>` followed by description
> - Use SHALL/MUST for normative requirements (avoid should/may)
> - Each scenario: `#### Scenario: <name>` with WHEN/THEN format
> - **CRITICAL**: Scenarios MUST use exactly 4 hashtags (`####`). Using 3 hashtags or bullets will fail silently.
> - Every requirement MUST have at least one scenario.
>
> MODIFIED requirements workflow:
> 1. Locate the existing requirement in `spec-builder/specs/<capability>/spec.md`
> 2. Copy the ENTIRE requirement block (from `### Requirement:` through all scenarios)
> 3. Paste under `## MODIFIED Requirements` and edit to reflect new behavior
> 4. Ensure header text matches exactly (whitespace-insensitive)
>
> Common pitfall: Using MODIFIED with partial content can lose detail. If adding
> new concerns without changing existing behavior, use ADDED instead.
>
> Specs should be testable — each scenario is a potential test case.

Example:

```markdown
## ADDED Requirements

### Requirement: User can export data
The system SHALL allow users to export their data in CSV format.

#### Scenario: Successful export
- **WHEN** user clicks "Export" button
- **THEN** system downloads a CSV file with all user data

## REMOVED Requirements

### Requirement: Legacy export
**Reason**: Replaced by new export system
**Migration**: Use new export endpoint at /api/v2/export
```

---

## Artifact: design  →  `design.md`

**Template:** `templates/design.md` · **Requires:** proposal

> Create the design document that explains HOW to implement the change.
>
> When to include design.md (create only if any apply):
> - Cross-cutting change (multiple services/modules) or new architectural pattern
> - New external dependency or significant data model changes
> - Security, performance, or migration complexity
> - Ambiguity that benefits from technical decisions before coding
>
> Sections:
> - **Context**: Background, current state, constraints, stakeholders
> - **Goals / Non-Goals**: What this design achieves and explicitly excludes
> - **Decisions**: Key technical choices with rationale (why X over Y?). Include alternatives considered.
> - **Risks / Trade-offs**: Known limitations. Format: [Risk] → Mitigation
> - **Migration Plan**: Steps to deploy, rollback strategy (if applicable)
> - **Open Questions**: Outstanding decisions or unknowns
>
> Focus on architecture and approach, not line-by-line implementation. Reference
> the proposal for motivation and specs for requirements.

If the change is simple enough that none of the "when to include" triggers apply,
**skip design.md** and note it (so `tasks` becomes ready).

---

## Artifact: tasks  →  `tasks.md`

**Template:** `templates/tasks.md` · **Requires:** specs, design

> Create the task list that breaks down the implementation work.
>
> **IMPORTANT: Follow the template exactly.** The apply phase parses checkbox
> format to track progress. Tasks not using `- [ ]` won't be tracked.
>
> Guidelines:
> - Group related tasks under `##` numbered headings
> - Each task MUST be a checkbox: `- [ ] X.Y Task description`
> - Tasks should be small enough to complete in one session
> - Order tasks by dependency (what must be done first?)
>
> Reference specs for what to build, design for how. Each task should be
> verifiable — you know when it's done.

Example:

```markdown
## 1. Setup

- [ ] 1.1 Create new module structure
- [ ] 1.2 Add dependencies to package.json

## 2. Core Implementation

- [ ] 2.1 Implement data export function
- [ ] 2.2 Add CSV formatting utilities
```

---

## apply

> requires: [tasks] · tracks: tasks.md
>
> Read context files, work through pending tasks, mark complete as you go.
> Pause if you hit blockers or need clarification.
