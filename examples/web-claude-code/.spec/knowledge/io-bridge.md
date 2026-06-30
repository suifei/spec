---
topic: the mechanism — take over the CLI's I/O and relay it to the browser over WS
decision: server owns the `claude` process; bridge its I/O (PTY for TUI, or stream-json for structured) to the browser over WebSocket; xterm.js for the terminal view
status: decided
captured: 2026-06-30
sources:
  - https://tsl0922.github.io/ttyd/          # share a terminal over the web (PTY + WS)
  - https://github.com/butlerx/wetty          # terminal in browser over ws
  - https://xtermjs.org/                       # browser terminal emulator
  - https://code.claude.com/docs/en/headless   # claude -p --output-format stream-json
---

## The mechanism (downstream of "what Claude Code is")
Given Claude Code is a CLI whose surface is terminal I/O, web-ification = **relay
that I/O**. This is a solved pattern (ttyd / wetty / gotty): a server holds the
process, a WebSocket carries its I/O both ways, a browser terminal renders it.

```
browser (xterm.js)  <—WebSocket—>  server bridge  <—stdio/PTY—>  claude CLI (unchanged)
       keystrokes  ───────────────────────────────────────────▶  stdin
       rendered output ◀───────────────────────────────────────  stdout/stderr
```

## Two faithful I/O surfaces
| Surface | What you relay | UX | Notes |
|---------|----------------|----|-------|
| **Interactive PTY** | the full TUI byte stream | looks exactly like the CLI | needs a real pseudo-terminal (e.g. `node-pty`); the TUI detects a non-TTY and degrades, so a PTY is required for full fidelity |
| **Headless `stream-json`** | `claude -p --output-format stream-json` NDJSON | a custom web UI you build | no PTY needed; structured events; you design the rendering |

## Candidates compared — transport
| Option | Duplex | Reconnect to same session | Verdict |
|--------|--------|---------------------------|---------|
| **WebSocket** | yes | yes (re-attach by session id) | **Chosen** — the established terminal-over-web transport (ttyd/wetty) |
| SSE | server→client only | needs a second input channel | half-duplex |
| WebTransport | yes | yes | support still uneven; revisit, verify at build date |

## Recommendation
Server owns the `claude` process and bridges its I/O to the browser over a
WebSocket; render with xterm.js for the PTY path. Whether to ship the PTY terminal
mirror or a custom stream-json UI is a product/UX fork → human (D5/Q1).

## Decision
I/O-bridge over WebSocket · 2026-06-30 · **[auto]** (mechanism follows from the
subject; the PTY-vs-stream-json UX is escalated, not decided here).

## Pinned knowledge (for execution)
- Full interactive TUI fidelity needs a **PTY** (native, e.g. `node-pty`) — plain
  pipes work for headless/`stream-json` but the TUI degrades without a TTY. (This
  is a build-time gate, noted; not probeable dependency-free here.)
- The `claude` process is server-side and addressable by session id; the socket is
  just a viewport that can drop and re-attach.
