# /spec progress

- **updated:** 2026-07-10T10:30Z   # real OS time, UTC
- **current_phase:** 3
- **current_step:** 闭环   # Phase 3 sealed and built; G11/G12 green
- **core_problem:** define the missing Gate 1.5 — a /build skill that constructs code from the authoritative SPEC.md without re-introducing drift (ephemeral plan; gate-closed)

## done
- 2026-07-10 — Phase 3 built: evidence revision+artifact binding, isolated yolo lifecycle, mutable Construction Ledger, explicit profiles, transactional role-manifest distribution; G11/G12 green; independent review found no remaining P0/P1
- 2026-06-30 — **subject established first** (define-the-noun-before-verb): a construction layer = Spec→Plan→Tasks→Implement; Spec Kit & Kiro PERSIST the middle layer (cited)
- 2026-06-30 — Phase 1 (`/spec`, Gate 1) **sealed by reference** to docs/DESIGN-NOTES.md (D-01…D-39) + .claude/skills/spec/
- 2026-06-30 — Phase 2 (`/build`, Gate 1.5) spec settled: G1 ✅ (research); G2 done-rule illustrated (logic-check) — behavioral proof of done-by-gate-reexecution lives in `eval/`
- 2026-06-30 — Decisions D1–D5 [auto] (authority/ephemeral-plan/done-by-gates/single-command/code-not-spec); D6 [human] autonomy = propose-then-apply (user "a")
- 2026-07-08 — **second-pass GLM-5.2 rigor hardening** (DESIGN-NOTES Round 39, D-69…D-73): shipped `probe.template.sh` + `coherence.template.sh` + instantiated dogfood G5–G9 coherence probes (D-69); backfilled R1–R5 Intent/Method so G6 goes green (D-73); G3 extended to command wrappers + fixed `commands/yolo.md`/`build.md` drift (D-72); independent-review L1/L2 split (D-71); review-capability negative control in `eval/cn-novel/tests/review-negative-control/` (D-70). All probes + selftests green.

## pending
- none blocking
- Q2 — exact ephemeral-plan home/format ⤳ resolved at build time: `.spec/plan/` gitignored scratch

## next_action
Phase 3 complete. Future changes open a superseding phase.

## build
<!-- owned by /build; /spec preserves this section verbatim when rewriting -->
- built: Phase 3 — 2026-07-10T10:30:23Z — R6–R10 implemented; G11/G12 green; Phase 2 remains built 2026-06-30
- remaining: none
- next: —
- conflict: none

# Freshness note: Spec Kit/Kiro facts captured 2026-06-30 from their docs; this is
# a fast-moving space — re-verify at build time. G2 illustrative logic-check green;
# behavioral done-by-gate proof lives in eval/ (real probes + red→green logs).
