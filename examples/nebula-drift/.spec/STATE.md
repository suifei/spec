# /spec progress

- **updated:** 2026-06-29T18:33Z   # real OS time, UTC
- **current_phase:** 2
- **current_step:** 持久化   # Phase 2 netcode decided + transport gate verified
- **core_problem:** snackable, instantly-playable, replayable browser arena shooter (Phase 2: add trusted online multiplayer)

## done
- 2026-06-29 — Phase 1 **sealed**: browser build (native/Godot refuted, G0 ❌), PixiJS 8.18.1, Vite; gates G1/G2/G3 ✅ (evidence in .spec/evidence/)
- 2026-06-29 — recon persisted: render-framework, build-tool, realtime-transport (.spec/knowledge/)
- 2026-06-29 — Phase 2 opened; R5 (localStorage scores) marked to be superseded by server-authoritative scores
- 2026-06-29T18:33Z — **Q2 decided**: server-authoritative simulation over `ws` (lockstep/P2P & client-authoritative rejected — can't back trusted shared scores)
- 2026-06-29T18:33Z — **gate G6 ✅ verified**: dependency-free WS probe (RFC6455 handshake + round-trip + neg-control), evidence `.spec/evidence/G6-ws-transport-*.log`
- 2026-06-29 — R5 marked **superseded**; **R7** added & locked (server is authority for scores); realtime-transport.md → status `decided`

## pending
- Q1 — G4 perf gate **open**: needs a PixiJS spike before a real probe can be written (blocks R6 only)
- Phase 2 build-time gates still open: server-side score store (DB), latency/load under the real wire format, reconnection

## next_action
Run a PixiJS spike to make G4 probe-able (resolve Q1). For Phase 2 build: pick the
server-side score store, then write a latency/load gate against the real binary
tick protocol (G6 only proves reachability, not throughput).

# Freshness note: dependency facts captured 2026-06-29; gate greens as-of
# 2026-06-29T18:33Z. PixiJS "latest 8.19.0" and WebTransport support both age fast
# — re-verify before the Phase-2 build.
