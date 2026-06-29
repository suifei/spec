---
name: spec-builder-propose
description: >-
  Create or continue a Spec-Builder change and generate its artifacts (proposal →
  spec deltas → design → tasks) so it's ready to implement. Scaffolds the
  spec-builder/ workspace automatically if missing, and resumes a partial change
  by filling in only the missing artifacts. Use when the user wants to
  propose/plan a feature or fix before coding, or continue an existing change.
  Maps to /spec:propose.
---

# Spec-Builder: Propose

Create a new change (or continue an existing one) and generate its artifacts:
- `proposal.md` (what & why)
- `specs/<capability>/spec.md` (delta specs — what the system should do)
- `design.md` (how — when warranted)
- `tasks.md` (implementation steps)

When ready to implement, use `/spec:apply`.

## Prerequisites

Read `.claude/skills/spec-builder/references/conventions.md` and
`.claude/skills/spec-builder/references/spec-driven-schema.md` first — they define
the directory layout, artifact graph, exact per-artifact instructions/rules, and
the strict spec format. Templates are in
`.claude/skills/spec-builder/references/templates/`.

**If there's no `spec-builder/` directory yet, scaffold it first:**
```bash
mkdir -p spec-builder/specs spec-builder/changes/archive
```
and create `spec-builder/project.md` from the repo context (see the `spec-builder`
skill's "Setting up the workspace"). Then continue.

**Input**: a change name (kebab-case) OR a description of what to build OR the name
of an existing change to continue.

## Steps

1. **Determine the change.**
   - If input names an existing change under `spec-builder/changes/` → **continue
     it** (skip to step 4 to fill in missing artifacts).
   - If input is a new name or a description → derive a kebab-case name (e.g.,
     "add user authentication" → `add-user-auth`) and create it:
     ```bash
     mkdir -p "spec-builder/changes/<name>"
     ```
   - If no input was provided, use the **AskUserQuestion tool** (open-ended):
     > "What change do you want to work on? Describe what you want to build or fix."
     Do NOT proceed without understanding what the user wants.

2. **Check current status** (so continuation builds only what's missing):
   `python3 .claude/skills/spec-builder/references/scripts/spec_status.py --change "<name>" --json`

3. **Decide scope of this run.** By default, generate **all** artifacts needed for
   implementation (proposal → specs → design/skip → tasks). If the user asked to
   go step-by-step, build only the next `ready` artifact and stop. Use the
   **TodoWrite tool** to track progress.

4. **Create artifacts in dependency order**, skipping any already `done`. For each:

   a. **Read its instruction** from `references/spec-driven-schema.md` and its
      **template** from `references/templates/`. Read completed dependency
      artifacts (and relevant existing `spec-builder/specs/` + code) for context.

   b. **Write the artifact** using the template as structure and the instruction +
      `spec-builder/project.md` as constraints. Apply constraints — do **NOT** copy
      instruction/context text into the file.

   c. **proposal.md** → Why, What Changes, Capabilities (New + Modified), Impact.
      The Capabilities section is the contract: each capability listed gets a spec
      file. Research `spec-builder/specs/` first.

   d. **specs/<capability>/spec.md** → one delta spec per capability. New
      capability → its kebab-case name. Modified capability → reuse the existing
      folder name from `spec-builder/specs/`. Use the delta format
      (ADDED/MODIFIED/REMOVED/RENAMED). **Scenarios use exactly `####`. Every
      requirement needs ≥1 scenario. Use SHALL/MUST.**

   e. **design.md** → create only if the change is cross-cutting, adds a
      dependency, touches data model/security/performance/migration, or has
      ambiguity worth resolving first. Otherwise **skip it** and note that design
      was not needed.

   f. **tasks.md** → checkbox tasks grouped under `##` headings, `- [ ] X.Y ...`,
      ordered by dependency. The apply phase parses these checkboxes.

   g. Show brief progress after each: "Created <artifact>".

   If an artifact needs user input (unclear context), use **AskUserQuestion**, then
   continue. Prefer reasonable decisions to keep momentum on low-stakes choices.

5. **Validate and show status.**
   ```bash
   python3 .claude/skills/spec-builder/references/scripts/spec_lint.py
   python3 .claude/skills/spec-builder/references/scripts/spec_status.py --change "<name>"
   ```

## Output

After completing the run, summarize:
- Change name and location (`spec-builder/changes/<name>/`)
- Artifacts created (or already present) with brief descriptions
- "All artifacts created! Ready for implementation." (or "Created <artifact>; run
  `/spec:propose <name>` again to continue.")
- "Run `/spec:apply` to start implementing."

## Guardrails

- Scaffold the workspace if it doesn't exist; never assume paths.
- Continuation is safe: skip artifacts that are already `done`, never overwrite
  without reason.
- Always read dependency artifacts before creating a new one.
- If context is critically unclear, ask — but prefer reasonable decisions to keep
  momentum.
- Verify each artifact file exists (and lint passes) before finishing.
- Instructions/context are constraints for YOU, not content for the file.
