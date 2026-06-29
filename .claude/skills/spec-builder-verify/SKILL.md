---
name: spec-builder-verify
description: >-
  Verify that a Spec-Builder change's implementation matches its artifacts —
  checks completeness (tasks + spec coverage), correctness (requirement/scenario
  coverage), and coherence (design adherence + pattern consistency), then emits a
  prioritized report. Use before archiving or when asked "does the code match the
  spec / is this done". Maps to /spec:verify.
---

# Spec-Builder: Verify

Verify that an implementation matches the change artifacts (specs, tasks, design).

Read `.claude/skills/spec-builder/references/conventions.md` first.

**Input**: Optionally a change name. If omitted, infer from context; if vague or
ambiguous you MUST prompt for selection.

## Steps

1. **If no change name provided, prompt for selection.** Run
   `python3 .claude/skills/spec-builder/references/scripts/spec_status.py --list`,
   mark changes with incomplete tasks as "(In Progress)", and use the
   **AskUserQuestion tool**. Don't auto-select.

2. **Load artifacts.** Read all artifacts present in the change folder
   (`proposal.md`, `specs/**/spec.md`, `design.md`, `tasks.md`) and
   `spec-builder/project.md`.

3. **Build a report across three dimensions**, each with CRITICAL / WARNING /
   SUGGESTION issues:

   **Completeness**
   - *Task completion*: parse `tasks.md` checkboxes. Each incomplete `- [ ]` →
     CRITICAL: "Complete task: <desc>" (or "Mark as done if already implemented").
   - *Spec coverage*: for each requirement (`### Requirement:`) in the delta specs,
     search the codebase for evidence of implementation. If unimplemented →
     CRITICAL: "Requirement not found: <name>".

   **Correctness**
   - *Requirement mapping*: for each requirement, find implementation evidence
     (note `file:line`). If it diverges from intent → WARNING + "Review
     <file>:<lines> against requirement X".
   - *Scenario coverage*: for each scenario (`#### Scenario:`), check the condition
     is handled and a test exists. If uncovered → WARNING + recommend a
     test/implementation.

   **Coherence**
   - *Design adherence*: if `design.md` exists, extract key Decisions and verify
     the implementation follows them. Contradiction → WARNING + recommendation. If
     no design.md, note "No design.md to verify against".
   - *Pattern consistency*: review new code against project patterns (naming,
     structure, style from `project.md`). Significant deviation → SUGGESTION.

4. **Emit the report:**

   ```
   ## Verification Report: <change-name>

   ### Summary
   | Dimension    | Status            |
   |--------------|-------------------|
   | Completeness | X/Y tasks, N reqs |
   | Correctness  | M/N reqs covered  |
   | Coherence    | Followed/Issues   |
   ```

   Then issues grouped by priority — **CRITICAL** (must fix before archive),
   **WARNING** (should fix), **SUGGESTION** (nice to fix) — each with a specific,
   actionable recommendation and `file:line` references where applicable.

   **Final assessment:**
   - CRITICAL present: "X critical issue(s) found. Fix before archiving."
   - Only warnings: "No critical issues. Y warning(s) to consider. Ready for
     archive (with noted improvements)."
   - All clear: "All checks passed. Ready for archive."

## Heuristics

- **Completeness**: objective items (checkboxes, requirements list).
- **Correctness**: keyword/path search + reasonable inference — don't require
  perfect certainty.
- **Coherence**: glaring inconsistencies only, don't nitpick style.
- **False positives**: when uncertain, prefer SUGGESTION over WARNING, WARNING
  over CRITICAL.
- **Actionability**: every issue gets a specific recommendation (with file/line
  where applicable). No vague "consider reviewing".

## Graceful degradation

- Only `tasks.md`: verify task completion, skip spec/design checks.
- tasks + specs: verify completeness and correctness, skip design.
- Full artifacts: verify all three dimensions.
- Always note which checks were skipped and why.

You can also run `spec_lint.py` to mechanically confirm spec format validity as
part of the report.
