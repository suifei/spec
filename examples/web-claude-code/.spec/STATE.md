# /spec progress

- **updated:** 2026-06-30T00:16Z   # real OS time, UTC
- **current_phase:** 1
- **current_step:** 闭环   # Phase 1 architecture sealed
- **core_problem:** drive an autonomous coding agent from a browser tab while it still has real hands (fs/shell/git/toolchain) — the tab has none, so where do the hands live?

## done
- 2026-06-30 — investigation (= research): WebContainers can't run native git/toolchains; Claude-Code-on-web uses isolated ephemeral containers + an out-of-sandbox credential proxy
- 2026-06-30 — Phase 1 **sealed**: G1 ✅ (research, refutes all-in-browser), G2 ✅ (research, credential boundary), G3 ✅ (probe, session survives disconnect)
- 2026-06-30 — Decision Log D1–D4 [auto] registered; D5 (isolation/cost) escalated to human as Q1

## pending
- Q1 (D5) — **genuine fork for the human**: multi-tenant isolation depth + compute-cost ceiling (risk/business, not derivable)
- Q2 — real-time collaboration ⤳ deferred→Phase 2

## next_action
Get the human's call on Q1 (isolation depth + who pays for idle compute), which
opens Phase 2 (collaboration & scale). No further investigation unblocks it — it's
a value/risk decision only they can make.

# Freshness note: platform facts (WebContainers limits, Claude-Code-on-web model)
# captured 2026-06-30 and are architecture-stable; re-verify exact runtime/isolation
# versions at build time. G3 probe green as-of 2026-06-30T00:16Z.
