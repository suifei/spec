---
name: spec-builder-apply
description: >-
  Implement the tasks of a Spec-Builder change — read the artifacts, work through
  tasks.md, write the code, and tick checkboxes as you go. Use when the user says
  "implement / apply / build the change" or "do the tasks". Maps to /spec:apply.
---

# Spec-Builder: Apply

Implement tasks from a change.

Read `.claude/skills/spec-builder/references/conventions.md` first for the layout
and status rules.

**Input**: Optionally a change name. If omitted, infer from conversation context;
if vague or ambiguous you MUST prompt for available changes.

## Steps

1. **Select the change.**
   - If a name is provided, use it. Otherwise infer from conversation, or
     auto-select if only one active change exists.
   - If ambiguous, run
     `python3 .claude/skills/spec-builder/references/scripts/spec_status.py --list`
     and use the **AskUserQuestion tool** to let the user select.
   - Announce: "Using change: <name>" and how to override (`/spec:apply <other>`).

2. **Understand the change.** Confirm `tasks.md` exists (apply requires it). If
   missing, the change isn't apply-ready → suggest `/spec:propose <name>` to fill
   in the remaining artifacts, then stop.

3. **Read context files.** Read every artifact present in the change folder:
   `proposal.md`, all `specs/**/spec.md` (the requirements you're implementing),
   `design.md` (the approach), `tasks.md`, plus `spec-builder/project.md` for
   project conventions.

4. **Show current progress.** Run
   `python3 .claude/skills/spec-builder/references/scripts/spec_status.py --change "<name>" --json`
   (or parse `tasks.md` checkboxes). Display "N/M tasks complete" and remaining
   tasks. If all tasks are already done → congratulate and suggest `/spec:verify`
   then `/spec:archive`.

5. **Implement tasks (loop until done or blocked).** For each pending task:
   - Announce which task you're working on.
   - Make the code changes. Follow `project.md` conventions and the design. Keep
     changes minimal and scoped to the task.
   - Mark the task complete in `tasks.md`: `- [ ]` → `- [x]` (immediately).
   - Continue to the next task.

   **Pause if:** a task is unclear → ask; implementation reveals a design/spec
   issue → suggest updating the artifact (the workflow is fluid, not phase-locked);
   an error/blocker occurs → report and wait; the user interrupts.

6. **On completion or pause, show status** — tasks completed this session, overall
   N/M; if all done, suggest verify/archive; if paused, explain why.

## Output during implementation

```
## Implementing: <change-name>

Working on task 3/7: <task description>
…implementation…
✓ Task complete
```

## Output on completion

```
## Implementation Complete
**Change:** <change-name>
**Progress:** 7/7 tasks complete ✓

All tasks complete! Run /spec:verify to check, then /spec:archive.
```

## Output on pause

```
## Implementation Paused
**Change:** <change-name>
**Progress:** 4/7 tasks complete

### Issue Encountered
<description>

**Options:**
1. <option 1>
2. <option 2>
3. Other approach

What would you like to do?
```

## Guardrails

- Keep going through tasks until done or blocked.
- Always read context files (artifacts + project.md) before starting.
- If a task is ambiguous, pause and ask — don't guess.
- If implementation reveals issues, pause and suggest artifact updates.
- Keep code changes minimal and scoped to each task.
- Update the task checkbox immediately after completing each task.
- Pause on errors, blockers, or unclear requirements.
