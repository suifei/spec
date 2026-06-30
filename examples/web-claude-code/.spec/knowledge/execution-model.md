---
topic: where the agent's tools execute (browser vs remote) + client↔backend transport
decision: remote ephemeral sandbox (container/microVM) + WebSocket streaming with resumable session id
status: decided
captured: 2026-06-30
sources:
  - https://webcontainers.io/guides/troubleshooting        # native addons disabled (--no-addons)
  - https://blog.stackblitz.com/posts/introducing-webcontainers/  # Node-in-WASM in the browser
  - https://www.anthropic.com/engineering/claude-code-sandboxing # cloud sandbox model
  - https://code.claude.com/docs/en/sandbox-environments
---

## The real question (meta, not surface)
Surface ask: "pick a transport / runtime." Real question: **can a browser host the
agent's tools at all?** Everything downstream (transport, session model, security)
depends on the answer. So investigate *that* first.

## Candidates compared — execution locus
| Option | Can run native git/compilers/addons? | Verdict |
|--------|--------------------------------------|---------|
| **All in-browser (WebContainers / Node-in-WASM)** | **No** — WebContainers run Node compiled to WASM but disable native addons (`--no-addons` by default) and can't run native binaries unless WASM-compiled | **Rejected** — real repos need native git + toolchains; this breaks on contact |
| Raw long-lived VM per user | Yes | workable but no per-task isolation, costly when idle |
| **Remote ephemeral sandbox (container/microVM), per task** | Yes | **Chosen** — native toolchain + strong per-task isolation; matches the proven Claude-Code-on-web model (repo cloned into an Anthropic-managed VM/ephemeral container, discarded after the task) |

## Candidates compared — transport
| Option | Duplex | Reconnect to same session | Notes |
|--------|--------|---------------------------|-------|
| **WebSocket + resumable session id** | yes | yes (rejoin by id) | **Chosen** — streams agent output + carries tool I/O; client reconnects to the live session |
| SSE | server→client only | needs a second channel for input | half-duplex |
| WebTransport | yes, lower latency | yes | support still uneven — revisit later, verify support *as of that date* |

## Recommendation
Remote ephemeral sandbox for execution; WebSocket streaming keyed by a resumable
session id so a dropped tab rejoins the same running session.

## Decision
Remote ephemeral sandbox + WebSocket/resumable-session · 2026-06-30 · **[auto]**
(settled from the WebContainers limitation + the proven cloud-sandbox model; no
human fork here).

## Pinned knowledge (for execution)
- WebContainers ≠ a real environment: no native addons/binaries unless WASM. Do not
  design around running native git/compilers in the browser.
- Session is server-side and addressable by id; the browser is a thin view that can
  disconnect and rejoin (see gate G3 probe).
- Keep version pinning to build time — this entry is approach-level; verify exact
  runtime/isolation versions when construction starts (facts captured 2026-06-30).
