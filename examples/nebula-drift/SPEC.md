# Nebula Drift — Specification

> **Version:** v3 · **Updated:** 2026-06-29
> **Closure:** Phase 1 ✅ sealed 2026-06-29 (gates green) · Phase 2 ⏳ open
> (netcode authority decided + transport probe-verified; build not yet started)
>
> Authoritative, highest-priority reference. Maintained by `/spec`. Gates are
> verified by probes in `.spec/`; pinned dependency facts live in
> `.spec/knowledge/`. All times are real OS time (UTC). A lower bound on verified
> truth, not a correctness proof.

## 1. Vision & Problem
**Core problem (found via the meta-question, not the surface ask):** the ask was
"build a 2D space shooter," but the real goal is **a snackable browser game that
goes from click to fun in ~10 seconds, feels juicy, and gives a reason to replay**
— no install, no account. Success = a stranger plays a round and immediately
starts a second one to beat their score.

## 2. Scope
**In scope (Phase 1)** — single-player top-down arena survival; ship movement +
shooting; waves of asteroids/enemies; a score that's always visible; a locally
persisted high score; runs in a desktop browser.

**Out of scope (explicitly)** — accounts/login (Phase 1); **native desktop build
(the "via Godot" assumption was refuted — see gate G0)**; mobile/touch controls
(Phase 1); online multiplayer (→ Phase 2).

## 3. Sources of Truth & Gates
Status ∈ {unverified, ✅ verified, ❌ failed, ⤳ deferred→Phase N, ◻ open}.

| Gate | Concern | Authoritative source | Invariant | Probe | Last run (UTC / where) | Status |
|------|---------|----------------------|-----------|-------|------------------------|--------|
| G0 | native build feasibility | — | — | `.spec/probes/G0-godot.sh` | 2026-06-29T18:18:32Z / vm | ❌ refuted → dropped |
| G1 | build toolchain | Node.js + npm | dev/build run on Node | `.spec/probes/G1-node-toolchain.sh` | 2026-06-29T18:18:14Z / vm | ✅ verified |
| G2 | dev server port | port 5173 | Vite dev binds 5173 | `.spec/probes/G2-devport.sh` | 2026-06-29T18:18:15Z / vm | ✅ verified |
| G3 | asset storage | `public/assets` | static assets live here | `.spec/probes/G3-assets.sh` | 2026-06-29T18:18:15Z / vm | ✅ verified |
| G4 | performance NFR | a perf harness (TBD) | 60 FPS @ 200 entities | (none yet) | — | ◻ open (can't probe until there's a prototype) |
| G5 | high-score store | `localStorage["nebula.scores"]` | only store scores here (Phase 1) | (browser; design invariant) | 2026-06-29 | ✅ asserted (WEAK, non-probed) → superseded by G6 |
| G6 | realtime transport (Phase 2) | server-authoritative sim over `ws` | server can bind, handshake (RFC6455) & round-trip a message | `.spec/probes/G6-ws-transport.sh` | 2026-06-29T18:33:08Z / vm | ✅ verified |

### Gate detail
#### G0 — native build (refuted)
- The human assumed a native desktop build via Godot. **Scout probed reality:**
  `godot NOT found on PATH` (evidence `.spec/evidence/G0-godot-…Z.log`). Decision
  pivoted to a **browser** build (PixiJS). *This is the scout-feeds-decision /
  no-fabrication path in action — a claimed truth was checked, not assumed.*
#### G1/G2/G3 — toolchain/port/assets
- Green with raw evidence (node v22.22.2; bind 5173 OK + neg-control errno 98;
  assets writable + neg-control). Each probe carries a **negative control**, so a
  green means something. Fresh **as of 2026-06-29T18:18Z** — re-run if the env
  changes.
#### G4 — performance (honestly open)
- "60 FPS @ 200 entities" is behavioral; we **cannot write a meaningful probe
  until a prototype exists**, so the gate stays **open** (not faked green). See Q1.
#### G6 — realtime transport (Phase 2, verified)
- Phase 2 needs a **trusted, shared** scoreboard, which forces a
  **server-authoritative** model (see Q2 / `.spec/knowledge/realtime-transport.md`).
  A dependency-free probe (Node built-ins, no `ws` package) brought up a WebSocket
  server, completed the RFC6455 handshake, and round-tripped a server-side echo;
  its **negative control** (dial an unused port) failed as required. Green **as of
  2026-06-29T18:33Z** (evidence `.spec/evidence/G6-ws-transport-…Z.log`).
  *Coverage limit:* proves reachability + round-trip on this platform, **not**
  latency under load or the production wire format — those become new gates once
  the authoritative loop exists.

> **Spec-line note:** the human also asked for "a purple-gradient HUD with the
> score top-right." That's **below the spec line** (visual detail) — left to
> execution. The spec only fixes the *capability*: **R4 — the score is always
> visible during play.** No pixels in the spec.

## 4. Requirements
Tag `[locked]` (probe/decision-backed) or `[provisional→Phase N]`.
- **R1.** `[locked]` The game SHALL let the player move the ship in 2D with keyboard. *Acceptance:* ship responds to input each frame.
- **R2.** `[locked]` The game SHALL let the player fire projectiles that destroy hazards. *Acceptance:* projectile↔hazard collision removes both, awards score.
- **R3.** `[locked]` The game SHALL spawn escalating waves of hazards until the player dies. *Acceptance:* spawn rate increases over time; death ends the round.
- **R4.** `[locked]` The current score SHALL be visible at all times during play. *Acceptance:* score element present every frame (placement is execution's call).
- **R5.** `[superseded→Phase 2]` ~~The high score SHALL persist locally between sessions (`localStorage`).~~ **Superseded 2026-06-29** by **R7** — Phase 2's server-authoritative model makes the server the source of truth for scores; a local-only store can't back a trusted, shared scoreboard.
- **R7.** `[locked]` In multiplayer, the **server** SHALL be authoritative for simulation outcomes and scores; clients send inputs and receive snapshots, and SHALL NOT be trusted to report their own score. *Acceptance:* a client-submitted score that disagrees with the server's computed result is rejected. *Backed by:* Q2 decision + gate G6.
- **R6.** `[provisional]` The game SHALL hold 60 FPS with ≥200 active entities on a mid-range laptop. *Unlocked by:* G4 (needs a prototype to probe).

## 5. Dependencies (chosen tech — details in `.spec/knowledge/`)
| Concern | Chosen (pinned) | Considered | Why | Knowledge |
|---------|-----------------|------------|-----|-----------|
| Render framework | **PixiJS 8.18.1** (latest 8.19.0, as of 2026-06-29) | Phaser 3.8x, vanilla Canvas | sprite-batch perf, light, active | `.spec/knowledge/render-framework.md` |
| Build tool / dev server | **Vite** | Webpack | fast HMR, ESM-native | `.spec/knowledge/build-tool.md` |
| Netcode authority | **server-authoritative sim** | lockstep/P2P, client-authoritative | only a trusted central authority can back shared scores | `.spec/knowledge/realtime-transport.md` |
| Realtime transport | **ws** (custom binary tick) | Socket.IO, WebTransport | own the wire format; fits an authoritative tick loop; probe-verified (G6) | `.spec/knowledge/realtime-transport.md` |

## 6. Phases (ledger — emergent from closure)

### Phase 1 — single-player core loop · status: **sealed 2026-06-29**
- **Goal:** prove the 10-seconds-to-fun core loop in the browser, with a local
  high score.
- **Gates:** G1 ✅, G2 ✅, G3 ✅ (G0 refuted & dropped; G4 open → tracked as Q1).
- **Key decisions:** browser (not native), PixiJS 8.18.1, Vite, scores in
  localStorage (provisional).
- **Supersedes:** none.

### Phase 2 — online multiplayer arena · status: **open, decisions locked** (depends on Phase 1)
- **Goal:** real-time multiplayer arena with trusted, shared scores.
- **Decided 2026-06-29:** **server-authoritative simulation** (Q2) transported
  over **`ws`** with a custom binary tick protocol. The transport gate that was
  previously *deferred* is now a real, **green gate G6** (probe-verified).
- **Supersedes:** **Phase 1 decision "high score in localStorage" (R5)** → the
  server is authoritative for scores (clients can't be trusted). Recorded per the
  append-only rule; R5 marked superseded, **R7** added and locked.
- **Still open before build:** server-side score store (DB choice), latency/load
  gate under the real wire format, and reconnection — intentionally left coarse
  until the authoritative loop is being built.

## 7. Open Questions (the closure gate)
| # | Question | Status | Owner/trigger | Notes |
|---|----------|--------|---------------|-------|
| Q1 | Does the core loop hold 60 FPS @ 200 entities? | open | resolve with a PixiJS spike, then write G4 probe | blocks R6 only, not Phase 1 seal |
| Q2 | Netcode authority model (lockstep vs server-authoritative)? | **decided 2026-06-29** | — | **server-authoritative** (trusted shared scores); transport = `ws`, probe-verified (G6) |
| Q3 | Monetization / accounts? | deferred | post-Phase 2 | out of current scope |

## 8. Glossary
| Term | Meaning |
|------|---------|
| Arena | bounded play area where waves spawn |
| Hazard | asteroid or enemy that ends the round on contact |
| Juicy | high-feedback game feel (screenshake, particles, sfx) |
| Tick | fixed-timestep simulation step (kept separate from render) |
