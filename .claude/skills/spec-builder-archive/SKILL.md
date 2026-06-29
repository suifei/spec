---
name: spec-builder-archive
description: >-
  Archive a completed Spec-Builder change — verify artifacts/tasks are done, merge
  its delta specs into the living specs (spec-builder/specs/), then move it to
  spec-builder/changes/archive/YYYY-MM-DD-<name>/. Use when a change is implemented
  and the user wants to close it out. Maps to /spec:archive.
---

# Spec-Builder: Archive

Archive a completed change: merge its delta specs into the source of truth, then
move it out of the active set. (Archiving includes the spec merge — there is no
separate sync step.)

Read `.claude/skills/spec-builder/references/conventions.md` first — especially
the **"Merging deltas into specs"** section, which defines the merge rules used in
step 4.

**Input**: Optionally a change name. If omitted, infer from context; if vague or
ambiguous you MUST prompt for selection.

## Steps

1. **If no change name provided, prompt for selection.** Run
   `python3 .claude/skills/spec-builder/references/scripts/spec_status.py --list`
   and use the **AskUserQuestion tool**. **Do NOT guess or auto-select.**

2. **Check artifact completion.** Run
   `python3 .claude/skills/spec-builder/references/scripts/spec_status.py --change "<name>" --json`
   and read `isComplete` / `tasks` / artifact statuses. If any required artifact is
   missing/incomplete → display a warning listing them and use **AskUserQuestion**
   to confirm proceeding. Proceed if confirmed.

3. **Check task completion.** From the status JSON, if `tasks.pending > 0` → warn
   with the count and confirm via **AskUserQuestion** before proceeding. If no
   `tasks.md`, proceed without a task warning.

4. **Merge delta specs into the living specs.** Find delta specs at
   `spec-builder/changes/<name>/specs/<capability>/spec.md`. If none, skip to
   step 5. Otherwise, for each capability, apply the **agent-driven merge** per the
   conventions' "Merging deltas into specs" rules:
   - Read the delta and the main spec at `spec-builder/specs/<capability>/spec.md`.
   - Apply ADDED / MODIFIED (partial-merge, preserving untouched scenarios) /
     REMOVED / RENAMED operations.
   - Create the main spec from `templates/spec.md` if the capability is new.
   - Before merging, show a brief summary of what will change and (unless the user
     already asked to archive) confirm. The merge should be idempotent.
   - After merging, run `spec_lint.py` to confirm the updated specs are valid.

5. **Perform the archive.**
   ```bash
   mkdir -p "spec-builder/changes/archive"
   ```
   Target name uses the current date: `YYYY-MM-DD-<change-name>`.
   - If the target already exists → stop with an error; suggest a different date or
     renaming the existing archive.
   - Otherwise move the change:
     ```bash
     mv "spec-builder/changes/<name>" "spec-builder/changes/archive/YYYY-MM-DD-<name>"
     ```

6. **Display the summary.**

   ```
   ## Archive Complete
   **Change:** <change-name>
   **Archived to:** spec-builder/changes/archive/YYYY-MM-DD-<name>/
   **Specs:** ✓ Merged into living specs   (or "No delta specs")

   All artifacts complete. All tasks complete.
   ```

## Guardrails

- Always prompt for change selection if not provided.
- Use the status script for completion checks.
- Don't block archive on warnings — just inform and confirm.
- Always run the merge before moving when delta specs exist; show what changed.
- Preserve scenarios/content not mentioned in a MODIFIED delta.
- Show a clear summary of what happened.
