<!--
Fixed structure for SPEC.md (repo root). /spec rewrites this file as a whole.
Keep every section. If a section is genuinely empty, write "None yet" rather than
deleting it. Requirements are numbered and verifiable. Scenario-style acceptance
("Given/When/Then") is encouraged where it sharpens a requirement.
-->

# <Project Name> — Specification

> **Version:** v<N>  ·  **Last updated:** <YYYY-MM-DD>  ·  **Status:** <Draft | ✅ Closed | ⏳ Open questions remain>
>
> This is the authoritative specification for this project and the highest-priority
> reference for any work. Generated and maintained by `/spec`.

## 1. Vision & Problem

<Why this project exists. The problem it solves, for whom, and what success looks
like. 1–3 short paragraphs.>

## 2. Scope

**In scope**
- <what this project will do>

**Out of scope (explicitly not doing)**
- <boundaries — the things people might assume but that are deliberately excluded>

## 3. Sources of Truth & Gates

The single authority for each key concern. Nothing else may contradict these.

| Concern | Authoritative source | Gate / contract | Invariant (never violate) |
|---------|----------------------|-----------------|---------------------------|
| <e.g. Data model> | <e.g. `db/schema.sql`> | <e.g. migrations only> | <e.g. no model edits outside migrations> |

## 4. Requirements

Numbered, verifiable statements of what must be true. Use SHALL/MUST for binding
requirements.

- **R1.** The system SHALL <…>.
  - *Acceptance:* <observable check / Given–When–Then>
- **R2.** …

## 5. Architecture & Key Decisions

<High-level approach: components, boundaries, data flow. Diagrams welcome. Explain
the "why", not line-by-line implementation.>

### Decision Log
Append-only. Record reversals explicitly rather than deleting.

| Date | Decision | Rationale (why this over alternatives) |
|------|----------|----------------------------------------|
| <YYYY-MM-DD> | <what was decided> | <why; what was rejected> |

## 6. Open Questions

The closure gate. Each item is either being driven to a decision or explicitly
deferred. **The spec is "Closed" only when this list has no blocking items.**

| # | Question | Status (open / deferred) | Owner / trigger | Notes |
|---|----------|--------------------------|-----------------|-------|
| Q1 | <question> | open | <who/when resolves it> | <context> |

## 7. Glossary

| Term | Meaning |
|------|---------|
| <term> | <definition> |
