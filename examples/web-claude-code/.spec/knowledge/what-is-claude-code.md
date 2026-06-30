---
topic: WHAT Claude Code is (the subject — established before any solution)
decision: Claude Code is an agentic coding CLI with a takeover-able I/O surface; "to web" = relay that I/O, not rebuild the agent
status: decided
captured: 2026-06-30
sources:
  - https://code.claude.com/docs/en/overview              # agentic CLI, terminal/IDE/desktop/browser
  - https://www.anthropic.com/claude-code                  # Unix-composable; pipe/CI/chain
  - https://code.claude.com/docs/en/headless               # claude -p / --output-format stream-json
  - https://code.claude.com/docs/en/cli-reference
---

## Why this file exists (the lesson)
The first version of this spec skipped straight to "build an agent backend +
sandbox." That was the **define-the-noun-before-the-verb** failure: it designed a
*how* before establishing *what Claude Code is*. So, first, the subject — from the
official docs, not assumption.

## What Claude Code actually is
- An **agentic coding tool** that **runs in your terminal** (also IDE, desktop,
  browser). It reads the codebase, plans, edits files, runs commands, runs tests,
  and iterates — and asks **permission** before modifying files / running commands.
- It is a **CLI that follows the Unix philosophy**: composable — *pipe* into it,
  run it in CI, chain it with other tools. Its surface is **standard I/O on a
  terminal.**
- It has a **headless mode**: `claude -p` (`--print`) runs non-interactively;
  `--output-format stream-json` emits **newline-delimited JSON for real-time
  streaming**. There is also an **Agent SDK** to drive it programmatically.
- The **agent loop, the real tools, the permission model, MCP** already live
  *inside* the CLI. None of that needs rebuilding.

## The consequence for "a web version"
Because the subject is **a CLI whose essence is terminal I/O**, "to web" is
fundamentally an **I/O-takeover/forwarding** problem, **not** an agent-rebuild:
> take over the `claude` process's I/O (interactive PTY, or headless
> `stream-json`) and relay it to the browser over a WebSocket; the browser is a
> terminal/view, the real Claude Code runs unchanged on the server.

This is the single insight the first draft missed. Everything else (transport,
sessions, credentials) follows from it. Mechanism details: `io-bridge.md`.

## Pinned knowledge (for execution)
- Don't reimplement the agent/tools/permissions — you'd be rebuilding what the CLI
  already is. Web-ification adopts the binary and relays its I/O.
- Two faithful I/O surfaces to relay: interactive **PTY** (full TUI) or headless
  **`-p --output-format stream-json`** (structured). The choice is a UX fork (D5).
- Captured 2026-06-30; CLI flags/SDK evolve — re-verify exact flags at build time.
