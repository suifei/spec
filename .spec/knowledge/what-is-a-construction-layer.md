---
topic: WHAT a "construction layer" (spec→code) is — established before designing /build
decision: it is the Spec→Plan→Tasks→Implement bridge; we adopt it but keep the Plan/Tasks EPHEMERAL (deliberate divergence from the persist-everything norm)
status: decided
captured: 2026-06-30
sources:
  - https://github.com/github/spec-kit          # Spec Kit: constitution + /specify /plan /tasks /implement, each a committed artifact
  - https://kiro.dev/docs/specs/                 # Kiro: requirements.md / design.md / tasks.md in .kiro/specs/, version-controlled
  - https://kiro.dev/                            # Kiro: agentic engineering, steering files
---

## Why this file exists (define the noun before the verb)
Before designing `/build`, establish what a "construction layer" *is* from the
field's leading tools — not from a guess.

## What it is (from the leaders)
The construction layer is the bridge from an authoritative spec to code, and the
state of practice is a **staged pipeline**:
- **GitHub Spec Kit**: a `constitution` (project non-negotiables) plus
  **/specify → /plan → /tasks → /implement**; each stage emits a **persisted,
  committed markdown artifact**.
- **AWS Kiro**: a spec = **`requirements.md` → `design.md` → `tasks.md`** in
  `.kiro/specs/`, **version-controlled**, plus `steering/` files for durable
  project context. Implementation runs tasks against that design.

**Key observation:** both leaders **persist and version the middle layer**
(plan/design/tasks) as the source of truth for construction.

## Our deliberate divergence (and its honest tradeoff)
This project's authority is already `SPEC.md` (≈ Spec Kit's constitution + spec) +
`.spec/` (gates, Decision Log, knowledge). The user's call (option A): keep the
**Plan/Tasks EPHEMERAL** — regenerated from `SPEC.md` each run, **never enshrined**
as a committed source of truth.
- **Why diverge:** a persisted, prose-heavy middle layer is the dominant **drift**
  surface; if it's the source of truth it rots against the code. Keeping only two
  durable ends — `SPEC.md` (thin, probe-backed) above and **code+tests** below —
  removes that surface.
- **Honest cost:** you lose Spec Kit/Kiro's persisted, reviewable task audit trail.
  Mitigation: durable record = `SPEC.md` Decision Log + git history + tests; the
  plan is disposable scaffolding, resumable within a build but not authoritative.

## The essence (what /build therefore is)
`/build` (Gate 1.5) = **read the authoritative `SPEC.md` → regenerate an ephemeral
Plan/Tasks → construct code → close when each requirement's acceptance holds and
the load-bearing gates are green (probes re-run)**. It never edits `SPEC.md`
decisions; on a spec-vs-reality conflict it **stops and routes back to `/spec`**
(no silent contradiction). Mechanism details: `build-loop.md`.

## Pinned knowledge (for execution)
- Authoritative input: `SPEC.md` + `.spec/` (gates, Decision Log, knowledge).
- Plan/Tasks: ephemeral; regenerate; do not commit as a source of truth.
- Done-condition: requirement acceptance + green gates (re-run probes = drift check).
- Captured 2026-06-30; Spec Kit/Kiro evolve fast — re-verify at build time.
