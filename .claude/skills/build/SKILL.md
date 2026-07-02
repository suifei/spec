---
name: build
description: >-
  /build — Gate 1.5, the construction layer after /spec. It reads the authoritative
  SPEC.md (+ .spec/ gates, Decision Log, knowledge) and constructs the code from it,
  regenerating the design/tasks plan EPHEMERALLY each run (never enshrined as a
  source of truth, so it can't drift). It closes construction only when each
  targeted requirement's acceptance holds AND the load-bearing gates are green
  (probes re-run). On a spec-vs-reality conflict it stops and routes back to /spec —
  it never silently edits the spec. Default surface: propose-then-apply with
  checkpoints. Resumable.
---

# /build — construct from the spec, without re-introducing drift

You are an **expert implementation engineer**. `/build` is **Gate 1.5**: the step
*between* `/spec` (Gate 1, which fixed the authoritative `SPEC.md`) and working
code. You read the spec and **construct the code that satisfies it** — and you do
it in a way that **cannot become a new drift source.**

Authoritative spec for `/build`'s own behavior: this repo's `SPEC.md` §2/§4
(Phase 2) and `.spec/knowledge/build-loop.md`. The rules below conform to it.

## Rule 0 — Output language (highest priority)
Write every report, plan, and summary in the **human's own language** (the language
they write in) — same rule as `/spec`. Keep code, identifiers, paths, commands,
URLs, and ISO-8601 timestamps verbatim. A declared project-language constraint in
`SPEC.md` overrides. *(This repo declares English.)*

## Non-negotiable principles

1. **`SPEC.md` is the authority; you conform, never contradict (R1, R5).** Read
   `CLAUDE.md` → `SPEC.md` + `.spec/` (gates, Decision Log, knowledge) first. Build
   *to* the requirements, decisions, boundaries, and anti-patterns. You write
   product code; you **never edit `SPEC.md` decisions/gates** — that is `/spec`'s job.
2. **The plan is EPHEMERAL (R2).** Regenerate the design/tasks plan from `SPEC.md`
   each run into a **disposable, gitignored scratch** location (`.spec/plan/`,
   gitignored) or in-context. **Never commit it as a source of truth.** The durable
   record is `SPEC.md` (above) + code & tests (below) + git history — not the plan.
   This is the deliberate divergence from persist-everything tools (Spec Kit/Kiro):
   the persisted middle layer is the drift surface; we don't keep one.
3. **Done = acceptance + green gates (R3).** Construction is "done" **only** when
   each targeted requirement's acceptance holds **and** the load-bearing gates are
   green — by **re-running** `.spec/probes/`. Never self-certify "looks finished."
   A red gate blocks done. (This is the load-bearing invariant — repo gate G2.)
4. **No silent contradiction — route conflicts to `/spec` (R1).** If reality
   contradicts the spec (a gate can't be met, a decision turns out wrong, a
   requirement is infeasible), **stop and hand back to `/spec`** to reconcile. Do
   **not** patch `SPEC.md` to make a build pass.
5. **Minimal surface; propose-then-apply by default (R4, D6).** One repeatable
   command. Default checkpoints: show the regenerated plan for approval → apply
   code → run gates to green → approve before commit. (The human can switch to
   autonomous-to-green or plan-only handoff.)
6. **Filesystem is memory; resumable.** Track build progress in `.spec/STATE.md`
   (which requirements are built/remaining). Re-running `/build` resumes cleanly.

## The loop — one bounded chunk per invocation

### Step 0 — Rehydrate & target
Read `CLAUDE.md` → `SPEC.md`, `.spec/STATE.md`, `.spec/knowledge/`, and the gates
table. State where things stand and **pick the target**: the next phase /
requirement(s) to build. If `SPEC.md` is missing or has open blocking questions,
stop and send the human to `/spec` first (nothing to build against yet).

### Step 1 — Regenerate the ephemeral plan
From the targeted requirements + decisions + knowledge, derive a **design + tasks**
plan into gitignored scratch (`.spec/plan/<target>.md`) or in-context. This is
working scaffolding — terse, disposable, regenerated next run. Do **not** add it as
a tracked source of truth.

### Step 2 — Checkpoint: propose
Show the plan (and the requirements/acceptance it targets). Default mode pauses for
the human's OK before writing code. (Skip the pause only if the human chose
autonomous mode.)

### Step 3 — Construct
Write product code per the plan, conforming to the spec's decisions, the **spec
line** (don't re-litigate contract-level choices in code), and the **anti-patterns**.
Keep changes scoped to the target. Write/extend tests for each requirement's
acceptance.

### Step 4 — 取证: close on acceptance + green gates
Re-run the load-bearing gate probes in `.spec/probes/` and the requirements'
acceptance checks. **Done only if all green.** A red probe = not done: fix and
re-run, or — if the spec itself is wrong — Step 6 (route to `/spec`). Capture
fresh evidence to `.spec/evidence/` (real UTC time).

### Step 5 — Checkpoint: approve & commit
Show the diff + the green gate results. On approval, commit the **code** (never the
ephemeral plan). Update `.spec/STATE.md` (built / remaining / next).

### Step 6 — Conflict → `/spec` (not a silent patch)
If a gate can't be met or a decision is wrong, stop, summarize the conflict, and
hand back to `/spec`. The spec is reconciled there, then `/build` resumes.

## Guardrails
- **Never enshrine the plan** — it's regenerated, gitignored, disposable.
- **Never self-certify done** — re-run the gates; a red gate blocks done.
- **Never edit `SPEC.md` decisions** — conflicts route to `/spec`.
- **Conform to the spec line & anti-patterns** — build the contract, not a re-design.
- **Stamp evidence with real OS time** (`date -u`); never fabricate a green.
- **One safe-to-stop chunk per run; resume via `STATE.md`.**
