# /spec progress

- **updated:** 2026-07-08T20:05Z   # real OS time, UTC
- **current_phase:** 2
- **current_step:** 闭环   # Phase 2 spec sealed; construction built + recorded (matches SPEC.md ledger)
- **core_problem:** define the missing Gate 1.5 — a /build skill that constructs code from the authoritative SPEC.md without re-introducing drift (ephemeral plan; gate-closed)

## done
- 2026-06-30 — **subject established first** (define-the-noun-before-verb): a construction layer = Spec→Plan→Tasks→Implement; Spec Kit & Kiro PERSIST the middle layer (cited)
- 2026-06-30 — Phase 1 (`/spec`, Gate 1) **sealed by reference** to docs/DESIGN-NOTES.md (D-01…D-39) + .claude/skills/spec/
- 2026-06-30 — Phase 2 (`/build`, Gate 1.5) spec settled: G1 ✅ (research); G2 done-rule illustrated (logic-check) — behavioral proof of done-by-gate-reexecution lives in `eval/`
- 2026-06-30 — Decisions D1–D5 [auto] (authority/ephemeral-plan/done-by-gates/single-command/code-not-spec); D6 [human] autonomy = propose-then-apply (user "a")
- 2026-07-08 — **second-pass GLM-5.2 rigor hardening** (DESIGN-NOTES Round 39, D-69…D-73): shipped `probe.template.sh` + `coherence.template.sh` + instantiated dogfood G5–G9 coherence probes (D-69); backfilled R1–R5 Intent/Method so G6 goes green (D-73); G3 extended to command wrappers + fixed `commands/yolo.md`/`build.md` drift (D-72); independent-review L1/L2 split (D-71); review-capability negative control in `eval/cn-novel/tests/review-negative-control/` (D-70). All probes + selftests green.

## pending
- (none blocking — Phase 2 built and recorded)
- Q2 — exact ephemeral-plan home/format ⤳ resolved at build time: `.spec/plan/` gitignored scratch

## next_action
Phase 2 sealed; rigor hardening (G5–G9) complete 2026-07-08. Future work opens a new superseding phase per the usual closure flow.

## build
<!-- owned by /build; /spec preserves this section verbatim when rewriting -->
- built: Phase 2 — 2026-06-30 — `/build` skill (`.claude/skills/build/SKILL.md` + `.claude/commands/build.md`) per R1–R5; G2 illustrative logic-check green; behavioral proof in `eval/`
- remaining: none
- next: —
- conflict: none

# Freshness note: Spec Kit/Kiro facts captured 2026-06-30 from their docs; this is
# a fast-moving space — re-verify at build time. G2 illustrative logic-check green;
# behavioral done-by-gate proof lives in eval/ (real probes + red→green logs).
