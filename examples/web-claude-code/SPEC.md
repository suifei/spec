# Web Claude Code — Specification

> **Version:** v2 · **Updated:** 2026-06-30
> **Closure:** Phase 1 ✅ sealed 2026-06-30 (subject + approach settled) · Phase 2 ⏳ open
>
> Authoritative, highest-priority reference. Maintained by `/spec`. Load-bearing
> gates are backed by evidence — a runnable probe where the truth is behavioral, a
> cited official source where it isn't. Research lives in `.spec/knowledge/`. All
> times are real OS time (UTC). A lower bound on verified truth, not a proof.

## 1. Subject & Core Problem
**First, what Claude Code *is* (define the noun before the verb).** Per the official
docs, Claude Code is an **agentic coding CLI** that runs **in the terminal**
(also IDE/desktop/browser): it reads the codebase, edits files, runs commands, and
**asks permission** first — and it is **Unix-composable** (pipe into it, run in CI,
chain it). It exposes **headless mode** (`claude -p --output-format stream-json`,
newline-delimited JSON streaming) and an **Agent SDK**. The agent loop, the real
tools, the permission model, and MCP **already live inside the CLI**. (Sources in
`.spec/knowledge/what-is-claude-code.md`.)

**Therefore the core problem is not "build an agent for the web."** Because the
subject is *a CLI whose essence is terminal I/O*, **"a web version" = take over the
`claude` process's I/O (interactive PTY, or headless `stream-json`) and relay it to
the browser over a WebSocket** — the real Claude Code runs unchanged on the server;
the browser is a terminal/view. Success = a developer opens a URL and drives the
*same* Claude Code, with its own permission prompts, from the browser.

> This v2 corrects v1, which jumped to "build an agent backend + sandbox" **without
> first establishing what Claude Code is** — the define-the-noun-before-the-verb
> failure. The whole architecture below follows from the subject, not from a
> guessed solution.

## 2. Scope & boundaries
**In scope (Phase 1)** — a **server bridge** that owns the `claude` CLI process and
relays its I/O; a **browser client** (terminal via xterm.js, or a structured UI on
`stream-json`); **WebSocket** transport with resumable sessions; **server-side
credentials/permissions** (the CLI's own model, relayed not reinvented).

**Out of scope / boundaries** — building the agent/model (we adopt the existing
CLI); native mobile app; offline mode; real-time multi-user collaboration on one
session (→ Phase 2).

**Anti-patterns (deliberately don't do)** — the traps:
- **Designing the web architecture before establishing what Claude Code is.** Define
  the noun (a CLI with a takeover-able I/O surface) before the verb — the exact
  mistake v1 made.
- **Rebuilding the agent loop / tools / permission model.** Claude Code already *is*
  the agent; web-ification only relays its I/O.
- **Shipping the API key / auth to the browser.** The CLI (with its creds) stays
  server-side; the browser only sees relayed I/O.
- **Tying the `claude` process lifetime to the websocket/tab.** The session is the
  server-side process; the socket is a viewport that can drop and re-attach.

## 3. Gates (load-bearing sources of truth)
Only **load-bearing** gates (load-bearing ∧ uncertain ∧ consequential-if-wrong).
**Commonsense facts are deliberately *not* gated** ("a browser can open a
WebSocket," "a port is free"). Status ∈ {unverified, ✅ verified, ❌ refuted, ⤳ deferred→Phase N}.

| Gate | Decision it gates | Authoritative source | Invariant | Evidence | Last checked (UTC/where) | Status |
|------|-------------------|----------------------|-----------|----------|--------------------------|--------|
| G1 | the subject itself: what "to web" even means | Claude Code official docs | Claude Code is a CLI with a takeover-able I/O surface ⇒ web-ify = relay I/O, not rebuild | research (cited) | 2026-06-30 / web | ✅ verified (research) |
| G2 | the mechanism the approach rests on | runnable probe + ttyd/wetty precedent | a CLI process's stdio can be taken over and relayed bidirectionally | `.spec/probes/G2-stdio-takeover.sh` | 2026-06-30T00:34Z / vm | ✅ verified (probe) |
| G3 | trust boundary | Claude Code permission/auth model | the CLI runs server-side with its own auth+permissions; no secret crosses to the browser | research (cited) | 2026-06-30 / web | ✅ verified (research) |
| G4 | full TUI fidelity | needs a PTY (`node-pty`, native) | interactive TUI requires a real pseudo-terminal | (build-time; not probeable dependency-free) | — | ⤳ deferred→build (noted) |

### Gate detail
#### G1 — the subject (research; this is the gate v1 skipped)
- **Decision it gates:** literally what the project is. If Claude Code weren't a CLI
  whose I/O can be relayed, "a web version" would mean something entirely different.
- **Finding:** official docs establish Claude Code as an agentic **CLI** (terminal,
  Unix-composable, headless `stream-json`, Agent SDK) that already contains the
  agent loop/tools/permissions. So **"to web" = take over its I/O and forward it**,
  not rebuild it. *This is the define-the-noun-before-the-verb gate — get it wrong
  and every downstream decision is wrong.*
- **Sources:** code.claude.com/docs (overview, headless, cli-reference);
  anthropic.com/claude-code. See `.spec/knowledge/what-is-claude-code.md`.
- **Status:** ✅ verified (research) — 2026-06-30.

#### G2 — stdio takeover + relay (runnable probe)
- **Decision it gates:** the mechanism. The bridge works only if a child CLI's I/O
  can be taken over and relayed both ways. This is **behavioral**, so it earns a
  probe.
- **Probe:** `.spec/probes/G2-stdio-takeover.sh` spawns a stand-in CLI, takes over
  its stdin+stdout, sends input, and reads its output back. Negative control: the
  same child with stdout **not** taken over (inherited) yields nothing — proving the
  probe can go red ("no takeover ⇒ the browser sees nothing").
- **Evidence (raw):** `sent "ping","hello-web" → relayed "recv:ping\nrecv:hello-web"
  · neg-control: stdout not taken over → nothing captured` — `.spec/evidence/G2-…Z.log`.
- **Precedent:** ttyd / wetty do exactly this at scale (node-pty + WS + xterm.js).
- **Status:** ✅ verified (probe) — 2026-06-30T00:34Z, vm.

#### G3 — credentials/permissions stay server-side (research)
- **Decision it gates:** trust boundary. Because the CLI runs server-side, secrets
  and the permission model stay there; the browser only relays I/O.
- **Finding:** Claude Code asks permission before edits/commands and authenticates
  server-side; web-ification **preserves and relays** that model rather than
  shipping a key to the tab. See `.spec/knowledge/credential-boundary.md`.
- **Status:** ✅ verified (research) — 2026-06-30.

#### G4 — full TUI fidelity needs a PTY (deferred to build)
- A plain-pipe relay covers headless/`stream-json`; the **interactive TUI** detects
  a non-TTY and degrades, so full fidelity needs a real PTY (`node-pty`, native) —
  **not probeable dependency-free here**, so it's tracked as a build-time gate, not
  faked green. (Honest open item.)

## 4. Requirements
- **R1.** `[locked]` The web layer SHALL relay the existing `claude` CLI's I/O and SHALL NOT reimplement its agent loop, tools, or permission model. *Acceptance:* G1.
- **R2.** `[locked]` The server SHALL own the `claude` process and bridge its I/O to the browser over a WebSocket (PTY for the interactive TUI; `stream-json` for a structured UI). *Acceptance:* G2 (+ precedent).
- **R3.** `[locked]` Credentials/auth SHALL stay server-side; no secret SHALL reach the browser; the CLI's permission prompts SHALL be relayed, not reinvented. *Acceptance:* G3.
- **R4.** `[locked]` A session SHALL be the server-side `claude` process, addressable by id, surviving socket disconnect/reconnect. *Acceptance:* re-attach to a live session by id.
- **R5.** `[provisional→build]` Full interactive TUI fidelity SHALL be delivered via a PTY. *Unlocked by:* G4 (PTY at build time).

## 5. Dependencies (chosen approach — details in `.spec/knowledge/`)
| Concern | Chosen | Considered | Why | Knowledge |
|---------|--------|------------|-----|-----------|
| What we build on | **the existing `claude` CLI (adopt, don't rebuild)** | reimplement the agent via SDK from scratch | the CLI *is* the agent; relay its I/O | `.spec/knowledge/what-is-claude-code.md` |
| I/O surface | **PTY (TUI) or `-p --output-format stream-json`** | scrape interactive output | official, faithful surfaces | `.spec/knowledge/io-bridge.md` |
| Transport + view | **WebSocket + xterm.js** | SSE, WebTransport | proven terminal-over-web stack (ttyd/wetty) | `.spec/knowledge/io-bridge.md` |
| Credentials | **server-side; relayed permissions** | key in browser | trust boundary (G3) | `.spec/knowledge/credential-boundary.md` |

## 6. Decision Log (key reasoning path → conclusion)
`[auto]` = settled from evidence; `[human]` = a genuine fork escalated.

| # | Decision | Reasoning (why, over alternatives) | Evidence | By | Date |
|---|----------|------------------------------------|----------|----|------|
| D1 | Web-ify = **adopt the existing CLI and relay its I/O**, not rebuild the agent | the subject is a CLI whose essence is terminal I/O; rebuilding duplicates what already exists (and v1's error was skipping this) | G1 | [auto] | 2026-06-30 |
| D2 | Server owns `claude`; **bridge its I/O to the browser over WebSocket** (xterm.js for the PTY path) | proven terminal-over-web pattern; matches the CLI's I/O surface | G2, io-bridge | [auto] | 2026-06-30 |
| D3 | CLI runs **server-side**; creds + permission prompts stay there; browser is a view | a tab can't safely hold secrets; preserve, don't reinvent, the CLI's model | G3 | [auto] | 2026-06-30 |
| D4 | A session **is** the server-side process, addressable by id; socket can drop & re-attach | long agent tasks must outlive a flaky tab | reasoning + G2 | [auto] | 2026-06-30 |
| D5 | **Full PTY terminal-mirror vs custom `stream-json` web UI** | exact-CLI fidelity vs a nicer purpose-built UX — a **product/UX direction call** evidence can't settle | io-bridge | **[human]** (Q1) | open |
| D6 | Multi-tenant **isolation depth + compute-cost ceiling** | gVisor-class vs lighter; idle-timeout; who pays — a **risk/business call** | — | **[human]** (Q2) | open |

## 7. Phases (ledger — emergent from closure)

### Phase 1 — subject + approach · status: **sealed 2026-06-30**
- **Goal:** establish *what Claude Code is* and *what "to web" means*, then settle
  the bridge approach — so construction starts from the right foundation.
- **Gates:** G1 ✅ (research), G2 ✅ (probe), G3 ✅ (research); G4 ⤳ deferred→build.
- **Key decisions:** D1–D4 [auto]; D5/D6 escalated to the human (Q1/Q2).
- **Supersedes:** **v1's framing** ("build an agent backend") — replaced by
  "adopt the CLI and relay its I/O," because v1 designed before identifying the
  subject. Recorded per the append-only rule.

### Phase 2 — fidelity, collaboration & scale · status: **open**
- **Goal:** the chosen UX (D5) built out; PTY fidelity (G4); multi-user sessions;
  the isolation/cost model (D6) resolved into concrete limits.

## 8. Open Questions (genuine forks — the human's to own)
| # | Question | Status | Owner/trigger | Notes |
|---|----------|--------|---------------|-------|
| Q1 | Full PTY terminal-mirror, or a custom `stream-json` web UI? | open | human (D5) | product/UX direction — fidelity vs bespoke UX |
| Q2 | Multi-tenant isolation depth & compute-cost ceiling? | deferred→Phase 2 | human (D6) | risk/business, not derivable |

## 9. Glossary
| Term | Meaning |
|------|---------|
| I/O takeover | a parent process capturing a child CLI's stdin/stdout (via pipe or PTY) to relay it |
| PTY | pseudo-terminal; needed for a full interactive TUI to behave as if on a real terminal |
| Bridge | the server component that owns the `claude` process and relays its I/O over WebSocket |
| stream-json | `claude -p --output-format stream-json` — newline-delimited JSON for structured streaming |
| Session | the server-side `claude` process, addressable by id, outliving any one connection |
