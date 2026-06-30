# /spec progress

- **updated:** 2026-06-30T00:48Z   # real OS time, UTC
- **current_phase:** 1
- **current_step:** 闭环   # Phase 1 loop + scope + safety sealed
- **core_problem:** build a trustworthy propose→evaluate→select→archive loop with an objective fitness gate + safe rollback — then choose which layer evolves — NOT "let an agent edit itself"

## done
- 2026-06-30 — **established the subject first** (define-the-noun-before-verb) from authoritative literature: self-evolving agent = objective-gated evolution loop over a chosen layer (surveys 2507.21046/2508.07407; DGM 2505.22954; ADAS 2408.08435)
- 2026-06-30 — Phase 1 **sealed**: G1 ✅ (research, the subject), G2 ✅ (probe, objective gate rejects regressions), G3 ✅ (research, auto-promote must be hardened)
- 2026-06-30 — Decision Log D1–D4 [auto]; **human forks decided**: D5 scope = prompts+memory+skills+workflow (no code/weights), D6 promotion = auto-promote (hardened with held-out+rollback+kill-switch per R6)

## pending
- Q3 — expand scope to self-code/weights ⤳ deferred→Phase 2 (needs fresh safety review)
- Q4 — concrete objective benchmark/domain ⤳ deferred→build (must resist gaming, use held-out)

## next_action
Phase 1 is sealed. Phase 2 (self-code/weight evolution) opens only when the human
brings it — and it must re-open the safety fork, since auto-promotion is likely
insufficient for self-modifying code.

# Freshness note: self-evolving agents are an active 2024–2025 research area;
# facts captured 2026-06-30 — re-verify state-of-the-art at build time. G2 probe
# green as-of 2026-06-30T00:48Z.
