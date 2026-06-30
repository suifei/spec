# /spec progress

- **updated:** 2026-06-30T00:34Z   # real OS time, UTC
- **current_phase:** 1
- **current_step:** 闭环   # Phase 1 subject + approach sealed
- **core_problem:** put the EXISTING Claude Code CLI in a browser by taking over its terminal I/O and relaying it over WebSocket — not by rebuilding the agent

## done
- 2026-06-30 — **established the subject first** (define-the-noun-before-the-verb): Claude Code is an agentic CLI (terminal, Unix-composable, headless stream-json, Agent SDK) — official docs
- 2026-06-30 — core realization: "to web" = take over the CLI's I/O (PTY or stream-json) and relay over WS; browser is a view (ttyd/wetty precedent)
- 2026-06-30 — Phase 1 **sealed**: G1 ✅ (research, the subject), G2 ✅ (probe, stdio takeover+relay), G3 ✅ (research, creds server-side); G4 ⤳ deferred→build (PTY)
- 2026-06-30 — Decision Log D1–D4 [auto]; D5 (UX mechanism) & D6 (isolation/cost) escalated to human (Q1/Q2)
- 2026-06-30 — **superseded v1's framing** ("build an agent backend") — it designed before identifying the subject

## pending
- Q1 (D5) — **genuine fork for the human**: full PTY terminal-mirror vs custom stream-json web UI (product/UX)
- Q2 (D6) — isolation depth + compute cost ⤳ deferred→Phase 2 (risk/business)
- G4 — PTY fidelity gate, resolvable only at build time (node-pty)

## next_action
Get the human's call on Q1 (terminal-mirror vs stream-json UI), which shapes the
Phase 2 build. No further research unblocks it — it's a UX direction only they own.

# Freshness note: Claude Code CLI facts (headless/stream-json/SDK) captured
# 2026-06-30 from official docs; flags evolve — re-verify at build time. G2 probe
# green as-of 2026-06-30T00:34Z.
