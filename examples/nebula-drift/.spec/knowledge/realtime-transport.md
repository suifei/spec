---
topic: realtime transport + netcode authority for online multiplayer (Phase 2)
decision: server-authoritative simulation over ws (Node WebSocket), custom binary tick protocol
status: decided
captured: 2026-06-29
sources: [knowledge; transport feasibility probe-verified — see gate G6]
---

## The real question (meta-question, not the surface ask)
The surface ask was "pick a transport (ws vs Socket.IO vs WebTransport)." But the
transport is downstream of one decision that actually matters for *this* game:
**who owns the truth — the clients or the server?** The core problem says scores
must be **trusted and shared** (the reason Phase 2 exists at all). That forces the
authority model first; the transport falls out of it.

## Netcode authority — candidates compared
| Model | Trust | Fit for a public arena with shared scores |
|-------|-------|-------------------------------------------|
| **Lockstep / deterministic P2P** | clients agree on inputs; no central truth | great for small-N RTS; **wrong here** — no trusted authority, every client can lie about score, cheating is trivial, NAT/P2P pain |
| **Client-authoritative + server relay** | clients assert state, server forwards | lowest server cost; **rejected** — a public scoreboard means clients *will* forge scores |
| **Server-authoritative simulation** | server runs the sim, clients send inputs, server emits snapshots | **chosen** — the server is the single source of truth for hits, deaths, and scores; clients can't forge results; matches "trusted, shared scores" |

## Transport — candidates compared (downstream of the model above)
| Option | Notes |
|--------|-------|
| **ws** | minimal, fast, we own the wire format; a custom binary tick protocol fits a fixed-timestep authoritative loop; **chosen** |
| Socket.IO | rooms/reconnect built-in, but heavier and imposes its own framing we don't need under an authoritative tick model |
| WebTransport | UDP-like, lowest latency; **re-evaluate later** — browser/host support still uneven (re-verify *as of the build date*; this entry is 2026-06-29) |

## Recommendation
**Server-authoritative simulation transported over `ws`** with a custom binary
tick protocol (client→server: inputs; server→client: authoritative snapshots).
Scores are computed and stored server-side. Revisit WebTransport for latency once
the authoritative loop is stable and support is verified at that date.

## Decision (human)
Server-authoritative over `ws` · 2026-06-29. The localStorage high score from
Phase 1 (R5) is **superseded**: the server is now the authority for scores.

## Probe-verified feasibility (gate G6)
A dependency-free probe (`.spec/probes/G6-ws-transport.sh`, Node built-ins only,
no `ws` package) brought up a WebSocket server, completed the RFC6455 handshake,
and round-tripped a server-authoritative echo; its **negative control** (dialing
an unused port) failed as required.
- Evidence: `.spec/evidence/G6-ws-transport-*.log` — handshake 101, `ping →
  echo:ping`, neg-control refused, exit 0, as of 2026-06-29T18:33Z.
- Coverage limit: this proves *transport reachability + round-trip on this
  platform*, not latency under load or the production framing — those become real
  gates once the authoritative loop exists.

## Pinned knowledge (for execution)
- Server owns the sim: clients send inputs only; server emits snapshots; score is
  computed and persisted server-side (never trusted from a client).
- A custom binary tick frame over `ws` is enough; no Socket.IO dependency.
- Node 22 ships a global `WebSocket` *client*; a server needs the `ws` package
  (not installed in the probe env — the probe hand-rolled the handshake to stay
  dependency-free). Add `ws` as a real dependency when building Phase 2.
