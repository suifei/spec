# Example: `slugify` — a full Spec-Builder run

This is the **end-state** of running the Spec-Builder lifecycle twice on a tiny
Python library. It exists to show what the artifacts and workspace look like after
real use, and to let the helper scripts run against a known-good workspace.

## What it demonstrates

Two changes were taken through `propose → apply → archive`:

1. **`add-slugify`** — introduced the `slugify` capability (ADDED requirement +
   3 scenarios), implemented `slugify(text)`, and merged the delta to create
   `spec-builder/specs/slugify/spec.md`.
2. **`slugify-options`** — added a `sep` parameter (ADDED requirement) and a new
   underscore scenario via a **partial `MODIFIED`** delta. The archive merge folded
   the new scenario into the existing requirement **while preserving the 3 original
   scenarios** — the key proof that delta merging keeps untouched content.

Both changes now live under `spec-builder/changes/archive/`. The living spec
(`spec-builder/specs/slugify/spec.md`) is the merged result: 2 requirements, with
"Slugify text" carrying 4 scenarios.

## Layout

```
examples/slugify/
├── src/textutils.py          # the implemented code (final, with `sep`)
├── tests/test_slugify.py     # 5 tests, one per scenario
└── spec-builder/
    ├── project.md
    ├── specs/slugify/spec.md           # living spec (merged result)
    └── changes/archive/
        ├── 2026-06-29-add-slugify/     # change 1 (ADDED)
        └── 2026-06-29-slugify-options/ # change 2 (partial MODIFIED + ADDED)
```

The `slugify-options` delta is intentionally left as a **partial** MODIFIED block
(only the new scenario + reworded description) so you can compare it against the
merged living spec and see the merge behavior.

## Try the tooling against it

From this directory:

```bash
# status — no active changes, capability "slugify" present
python3 ../../.claude/skills/spec-builder/references/scripts/spec_status.py

# format lint — living spec + both archived deltas are all valid
python3 ../../.claude/skills/spec-builder/references/scripts/spec_lint.py

# the implemented code passes its tests
python3 tests/test_slugify.py
```
