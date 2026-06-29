---
name: spec
description: >-
  Create or update the project's single authoritative specification, SPEC.md, by
  brainstorming with the user until every open question is closed and every source
  of truth is pinned down. Like /init, but for the living spec: re-running it
  reconciles SPEC.md with current project progress, absorbs any new input or
  change the user brings, drives the discussion to closure, records decisions, and
  rewrites the complete spec. Use for /spec, or whenever the user wants to define,
  refine, reconcile, or lock down what the project should be.
---

# /spec — the project's living specification

`/spec` is a single, repeatable command. It is a **thinking partner that converges
on truth and writes it down.** Its only output is one authoritative document,
`SPEC.md`, plus a pointer to it from `CLAUDE.md`.

**Scope boundary (important):** `/spec` does **not** implement code and is **not**
coupled to any execution skill. It only produces the specification. Downstream work
reads `CLAUDE.md` → `SPEC.md` and treats `SPEC.md` as the highest-priority
reference. Keep those concerns separate.

The fixed document is **`SPEC.md` at the repository root.** Always read it, always
overwrite it as a whole (it is the single source — never fragment it).

## The job, in one line

Brainstorm with the user → drive **every blocking question to closure (闭环)** →
explicitly pin **every source of truth and gate (真实源/门)** → write the complete
`SPEC.md` → make sure `CLAUDE.md` declares `SPEC.md` as the supreme reference.

## What "source of truth / gate" means (真实源/门)

For each important concern, exactly **one** place is authoritative; everything else
defers to it. A *gate* is the boundary/contract/invariant that truth must pass
through. Examples:

- "The Postgres schema is the source of truth for the data model; the ORM models
  are generated from it."
- "The OpenAPI file is the gate for the HTTP contract; clients and server both
  conform to it."
- "Pricing lives only in `config/pricing.yaml`; no hard-coded prices anywhere."

A spec is not closed until each key concern has a single named authority and no two
places silently claim the same truth.

## Procedure (run this every time)

### 1. Load the current state
- Read `SPEC.md` if it exists, and `CLAUDE.md` if it exists.
- Scan the project to understand actual progress: README, package/manifest files,
  directory structure, entry points, tests, config. Form a concise mental model of
  "what this project currently is."
- Briefly reflect back your understanding so the user can correct it early.

### 2. Reconcile drift (on re-runs)
- Compare what the code/project shows against what `SPEC.md` claims.
- List concrete discrepancies (spec says X, code does Y; spec missing a thing the
  code clearly has; a source-of-truth that's been violated). Each discrepancy
  becomes an item to resolve in step 4.

### 3. Ingest the user's input
- Treat any argument/free-form content the user passed to `/spec` as material to
  integrate: a new requirement, a correction, a pasted doc, a change of direction —
  anything. Fold it into the open items.

### 4. Brainstorm to closure (the core loop)
This is where the value is. Be a real thinking partner, not a form-filler.
- Surface the open questions, ambiguities, undefined sources of truth, unstated
  scope boundaries, risky assumptions, and the drift items from step 2.
- For each, **propose options and a recommendation**, challenge assumptions, and
  name trade-offs and risks. Use ASCII diagrams when they clarify.
- Ask the user using the **AskUserQuestion tool**, batching related questions
  (recommended option first). Keep looping — ask, integrate answers, surface the
  next layer of questions that the answers expose.
- **Closure gate (闭环):** do not finish while any *blocking* question is
  unresolved. An item leaves the open list only when it is **decided** or
  **explicitly deferred** (with a reason and, ideally, an owner/trigger). Be honest
  about what's still open; never paper over ambiguity to seem done.
- Drive especially hard on the **Sources of Truth & Gates** — every key concern
  must end with a single named authority.

### 5. Record explicit decisions
- For each resolved item, capture the decision, the rationale (why this over the
  alternatives), and the date in the Decision Log. Decisions are durable; don't
  silently overwrite history — append, and note reversals explicitly.

### 6. Write the complete `SPEC.md`
- Overwrite `SPEC.md` in full using the structure in
  `references/SPEC.template.md`. Bump the version and update the timestamp in the
  meta block. The document must be self-contained and readable on its own.

### 7. Wire up `CLAUDE.md`
- Ensure `CLAUDE.md` contains the managed authority block (create `CLAUDE.md` if
  missing). Replace the block between the markers each run; leave the rest of
  `CLAUDE.md` untouched:

  ```markdown
  <!-- BEGIN SPEC-AUTHORITY (managed by /spec) -->
  ## Specification authority
  `SPEC.md` is the authoritative specification for this project and the
  **highest-priority** reference. Before planning or implementing anything, read
  `SPEC.md` and conform to it — especially its "Sources of Truth & Gates" section.
  If reality and `SPEC.md` disagree, treat `SPEC.md` as intent and surface the
  drift (or run `/spec` to reconcile). Do not silently contradict it.
  <!-- END SPEC-AUTHORITY -->
  ```

### 8. Report
- Summarize what changed in `SPEC.md` this run, which decisions were recorded, and
  what (if anything) was **deferred** and why. End with the spec's current
  closure status: "✅ Closed — no blocking open questions" or "⏳ N blocking
  question(s) remain — run `/spec` again to continue."

## Guardrails

- **One document, always whole.** `SPEC.md` at the repo root is the single source;
  rewrite it entirely, don't scatter spec content elsewhere.
- **Closure is the bar.** Don't end the loop with unacknowledged blocking
  ambiguity. Deferral is allowed but must be explicit and recorded.
- **Pin every source of truth.** No concern should have two competing authorities.
- **Don't implement.** `/spec` only specifies. Execution is decoupled and reads
  `SPEC.md` via `CLAUDE.md`.
- **Idempotent.** With no new input and no drift, a re-run yields the same content
  (only the timestamp may change).
- **Prefer decisions over endless questions.** Recommend a default and move; reserve
  AskUserQuestion for things that genuinely need the user.
- **Honesty over completeness theater.** If something is unknown, it belongs in
  Open Questions, not invented into a requirement.
