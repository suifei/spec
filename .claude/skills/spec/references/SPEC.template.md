<!--
Fixed structure for SPEC.md (repo root). /spec rewrites this file as a whole.
Keep every section (write "None yet" if empty). Stay at contract-surface altitude
(behavior, contracts, sources-of-truth/gates, NFRs, declared constraints) — never
implementation detail. Phases are a ledger: emergent, append-only, sealed phases
are read-only.
-->

# <Project Name> — Specification

> **Version:** v<N> · **Updated:** <YYYY-MM-DD>
> **Closure:** <Phase 1 ✅ sealed (gates green) · Phase 2 ⏳ open>
>
> Authoritative, highest-priority reference. Maintained by `/spec`. Gates are
> verified by probes in `.spec/`; pinned dependency/research facts live in
> `.spec/knowledge/`. A lower bound on verified truth, not a correctness proof.

## 1. Vision & Problem
<The core problem (not surface symptoms), for whom, what success looks like.>

## 2. Scope
**In scope** — <what this project will do>
**Out of scope (explicitly not doing)** — <deliberate exclusions>

## 3. Sources of Truth & Gates
One authority per concern; each proven by a probe. Status ∈ {unverified, ✅ verified, ❌ failed, ⤳ deferred→Phase N}.

| Gate | Concern | Authoritative source | Invariant | Probe | Last run (when/where) | Status |
|------|---------|----------------------|-----------|-------|-----------------------|--------|
| G1 | <e.g. storage> | <`./data` / SQLite 3.45> | <writes only via this path> | `.spec/probes/G1.sh` | <2026-06-29 / devbox> | ✅ verified |

### Gate detail (one block per gate)
#### G1 — <title>
- **Source / Invariant:** <…>  · **Probe:** `.spec/probes/G1.sh`
- **Evidence (raw):** `resolved /abs/data · free 12G · write+read OK`
- **Status:** ✅ verified — 2026-06-29, devbox
- (Attestation gates that can't be scripted — e.g. "legal approved" — mark **WEAK (non-probed)** with a named source.)

## 4. Requirements
Numbered, verifiable. Use SHALL/MUST. Tag `[locked]` (probe-backed) or `[provisional→Phase N]`.
- **R1.** `[locked]` The system SHALL <…>. *Acceptance:* <observable check / probe>
- **R2.** `[provisional→Phase 2]` The system SHALL <…>. *Unlocked by:* <trigger>

## 5. Dependencies (chosen tech)
Decisions only; details/pinned docs in `.spec/knowledge/<lib>.md`.

| Concern | Chosen (pinned) | Considered | Why | Knowledge |
|---------|-----------------|------------|-----|-----------|
| <async runtime> | <tokio 1.40> | <async-std 1.13> | <maintenance, ecosystem> | `.spec/knowledge/rust-async.md` |

## 6. Phases (ledger — emergent from closure)
A phase is **sealed** when all its decisions are confirmed and its gates are
green (or explicitly deferred) with no blocking open question. Sealed = read-only.

### Phase 1 — <name> · status: <open|sealed YYYY-MM-DD>
- **Goal:** <what this closure establishes>
- **Gates:** G1, G2  · **Key decisions:** <…>
- **Supersedes:** <none | "阶段K 的第X条 — 因 …">

## 7. Open Questions (the closure gate)
| # | Question | Status (open/deferred) | Owner/trigger | Notes |
|---|----------|------------------------|---------------|-------|
| Q1 | <…> | open | <who/when> | <context> |

## 8. Glossary
| Term | Meaning |
|------|---------|
| <term> | <definition> |
