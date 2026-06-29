<!--
Fixed structure for SPEC.md (repo root). /spec rewrites this file as a whole.
Keep every section. Requirements are numbered and verifiable. Gates are
probe-verified: a gate is only "verified" when its probe script ran and passed,
with raw evidence. A phase is construction-ready only when all its gates are green.
-->

# <Project Name> — Specification

> **Version:** v<N>  ·  **Last updated:** <YYYY-MM-DD>
> **Closure:** <Phase 1: ✅ ready (3/3 gates) · Phase 2: ⏳ 2 gates deferred>
>
> Authoritative specification and highest-priority reference. Maintained by `/spec`.
> Gates below are verified by real probe scripts (`.spec/probes/`), not assertions.

## 1. Vision & Problem

<Why this project exists, for whom, and what success looks like. 1–3 paragraphs.>

## 2. Scope

**In scope**
- <what this project will do>

**Out of scope (explicitly not doing)**
- <deliberate exclusions>

## 3. Sources of Truth & Gates

One authority per concern; each proven by a probe. Status ∈
{unverified, ✅ verified, ❌ failed, ⤳ deferred→Phase N}.

| Gate | Concern | Authoritative source | Invariant | Probe | Last run (when / where) | Status |
|------|---------|----------------------|-----------|-------|-------------------------|--------|
| G1 | <e.g. storage> | <`./data/app.db`> | <writes only via this path> | `.spec/probes/G1_storage.sh` | <2026-06-29 / devbox> | ✅ verified |

### Gate detail

#### G1 — <short title>
- **Concern:** <…>   **Authoritative source:** <…>   **Invariant:** <…>
- **Probe:** `.spec/probes/G1_storage.sh`
- **Evidence (raw, from `.spec/evidence/…`):**
  ```
  resolved path: /abs/.../data/app.db
  write+read: OK (1 row round-tripped)
  free space: 12G
  ```
- **Status:** ✅ verified — ran 2026-06-29T09:00 on devbox (`uname`: Linux …)
- **Phase:** Phase 1

<!-- Attestation gates (cannot be scripted, e.g. "legal approved"): mark clearly. -->
<!-- #### G9 — Legal sign-off   **Type:** attestation (WEAK, non-probed)
     **Source:** <name/email + date>   **Status:** attested (not probe-verified) -->

## 4. Requirements

Numbered, verifiable. Use SHALL/MUST. Tag each `[locked]` (backed by a green probe)
or `[provisional→Phase N]` (a future phase will confirm or overturn it).

- **R1.** `[locked]` The system SHALL <…>.  *Acceptance:* <observable check / Given–When–Then>
- **R2.** `[provisional→Phase 2]` The system SHALL <…>.  *Unlocked by:* <trigger>

## 5. Phases

Execution plan, **cut along the probe line**. The near phase is detailed; far phases
stay coarse (goal + trigger) until unlocked — do not over-detail them, that's
fabrication. A phase may be **built** only when its entry gates are ✅; it is **done**
only when its exit probes are ✅.

Dependency flow:  `Phase 1 ──unlocks──▶ Phase 2 ──unlocks──▶ Phase 3`

### Phase 1 — <name>   ·   status: <blocked|ready|in-progress|done>   ·   resolution: detailed
- **Depends on:** — (none)
- **Goal:** <what this phase delivers>
- **Entry gates (must be ✅ to start):** G1, G2
- **Exit = probes that go green:** <e.g. `.spec/probes/G4.sh` becomes runnable and passes>
- **Unlocks:** Phase 2 gates (G4, G5)
- **Owner:** <who builds it>

### Phase 2 — <name>   ·   status: blocked   ·   resolution: coarse (unlocked by Phase 1)
- **Depends on:** Phase 1 (its API / output)
- **Goal:** <coarse goal — do NOT over-detail until unlocked>
- **Deferred gates:** G4 ⤳ deferred→Phase 2 (trigger: Phase 1 ships API; re-probe `.spec/probes/G4.sh`; owner: <who>)
- **Open questions to resolve when unlocked:** Q3, Q4

## 6. Architecture & Key Decisions

<Components, boundaries, data flow. Diagrams welcome. Explain the "why".>

### Decision Log
Append-only; record reversals explicitly.

| Date | Decision | Rationale (why this over alternatives; cite probe evidence) |
|------|----------|-------------------------------------------------------------|
| <YYYY-MM-DD> | <chose SQLite over Postgres> | <single-node scale; G1 probe: write OK, 12G free> |

## 7. Open Questions

Closure gate. Each item is being driven to a decision or explicitly deferred. The
spec is "Closed" for a phase only when that phase's gates are green and no blocking
question remains.

| # | Question | Status (open / deferred) | Owner / trigger | Notes |
|---|----------|--------------------------|-----------------|-------|
| Q1 | <question> | open | <who/when resolves it> | <context> |

## 8. Glossary

| Term | Meaning |
|------|---------|
| <term> | <definition> |
