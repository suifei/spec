# Web Claude Code — Specification

> **Version:** v1 · **Updated:** 2026-06-30
> **Closure:** Phase 1 ✅ sealed 2026-06-30 (architecture settled) · Phase 2 ⏳ open
>
> Authoritative, highest-priority reference. Maintained by `/spec`. Load-bearing
> gates are backed by evidence — a runnable probe where the truth is behavioral,
> a cited finding where it isn't. Pinned research lives in `.spec/knowledge/`.
> All times are real OS time (UTC). A lower bound on verified truth, not a proof.

## 1. Vision & Problem
**Core problem (the meta-question, not the surface ask):** the ask was "a Web
version of Claude Code," but the real goal is **to drive an autonomous coding
agent from a browser tab — no local install — while the agent still has real
hands: a filesystem, a shell, git, and the ability to run the project's
toolchain.** The whole design tension is that *a browser tab has no hands* — it
can't fork processes, run native binaries, or hold a real filesystem. Success =
a developer opens a URL, points the agent at a repo, walks away, comes back on a
different network, and the task is still running and resumable.

## 2. Scope & boundaries
**In scope (Phase 1)** — a thin **browser client** (editor + agent transcript);
a **remote sandboxed execution backend** that owns the fs/shell/git/toolchain;
a **credential proxy** so secrets never reach the browser; **server-side,
persistent execution sessions** that survive disconnect; the **agent loop**
(model ↔ tools) running server-side and **streamed** to the browser.

**Out of scope (explicitly) / boundaries** — native mobile app; offline mode;
real-time multi-user collaboration on one session (→ Phase 2); building the agent
model itself (we consume an LLM API).

**Anti-patterns (deliberately don't do)** — the traps, not just the boundaries:
- **Shipping the LLM/API key to the browser.** It's the obvious shortcut and it
  leaks the credential to every tab; keys stay server-side (see G2).
- **Emulating the full toolchain in the browser to avoid a backend.** A browser
  Node-in-WASM runtime (WebContainers) can't run native git/compilers/native
  addons (see G1); pretending it can produces a demo that breaks on real repos.
- **Binding the agent's execution lifetime to the websocket/tab.** Long tasks
  would die on a flaky connection or a closed laptop (see G3).
- **Reimplementing the agent loop client-side calling the model directly.** It
  leaks keys, has no durable session, and has no real tools — it's a chatbot, not
  Claude Code.

## 3. Gates (load-bearing sources of truth)
Only **load-bearing** gates appear here — a truth a real architectural decision
*hinges* on (load-bearing ∧ uncertain ∧ consequential-if-wrong). Evidence is a
runnable probe where the truth is behavioral, a **cited research finding** where
it isn't. **Commonsense facts are deliberately *not* gated** — "a browser can
open a WebSocket," "a port is free," "node is installed" change no decision and
are not a coding focus. Status ∈ {unverified, ✅ verified, ❌ refuted, ⤳ deferred→Phase N}.

| Gate | Decision it gates | Authoritative source | Invariant | Evidence | Last checked (UTC/where) | Status |
|------|-------------------|----------------------|-----------|----------|--------------------------|--------|
| G1 | execution locus: browser vs remote | WebContainers/WASM platform limits | the agent's native toolchain (git, compilers, native addons) can't run in-browser ⇒ execution is remote | research (cited) | 2026-06-30 / web | ✅ verified (research) |
| G2 | where credentials live | Claude-Code-on-web token-proxy model | API/LLM + repo tokens never reach the browser; a backend proxy issues scoped creds | research (cited) | 2026-06-30 / web | ✅ verified (research) |
| G3 | session lifetime model | runnable probe | an execution session survives client disconnect/reconnect (work continues) | `.spec/probes/G3-session-persistence.sh` | 2026-06-30T00:16Z / vm | ✅ verified (probe) |

### Gate detail
#### G1 — execution must be remote (research refutes "all-in-browser")
- **Decision it gates:** the single biggest fork — run the agent's tools in the
  browser, or on a remote backend. If the browser *could* host the toolchain, the
  whole product would be client-only.
- **Finding:** WebContainers run Node **in-WASM** in the browser but **cannot run
  native binaries / native addons** (loaded with `--no-addons` by default) unless
  they're WASM-compiled. Real coding agents need native `git`, compilers, and
  language toolchains — so **tool execution must run in a remote sandboxed
  environment**, exactly as Claude Code on the web does (repo cloned into an
  Anthropic-managed VM/ephemeral container). *This is the scout refuting the naive
  assumption by research — the same role G0 (Godot) played in the other example,
  but settled with knowledge, not a script.*
- **Sources:** webcontainers.io / StackBlitz docs (native-addon limits);
  Anthropic "Claude Code on the web" / sandboxing docs. See
  `.spec/knowledge/execution-model.md`.
- **Status:** ✅ verified (research) — 2026-06-30. *Not a runnable probe: the truth
  is a platform capability, not a behavior on this box. Backed by named sources,
  not faked green.*

#### G2 — credentials never reach the browser (research)
- **Decision it gates:** trust boundary. A browser-held key is exfiltratable by
  any script in the tab; this dictates a backend proxy.
- **Finding:** the proven model (Claude Code on the web) keeps the repo token
  **outside** the sandbox in a separate proxy that issues **scoped** credentials,
  and a network proxy enforces an allowlist. Web Claude Code adopts the same: the
  browser talks only to our backend; the backend holds the LLM key and brokers
  scoped, short-lived repo creds.
- **Sources:** Anthropic Claude Code sandboxing / on-the-web docs. See
  `.spec/knowledge/credential-boundary.md`.
- **Status:** ✅ verified (research) — 2026-06-30.

#### G3 — sessions survive disconnect (runnable probe)
- **Decision it gates:** session lifetime. If a session died with its websocket,
  long agent tasks couldn't run from a flaky browser — forcing a totally different
  (client-driven) design. This truth is **behavioral**, so it earns a real probe.
- **Probe:** `.spec/probes/G3-session-persistence.sh` starts a detached server-side
  worker, reads its progress, simulates a client **disconnect**, waits, then
  **reconnects** and asserts the work **advanced while disconnected**. Negative
  control: a connection-bound worker is killed on disconnect and must show **no**
  progress — proving the probe discriminates (it can go red).
- **Evidence (raw):** `persistent: counter 5 → 18 across a disconnect · ephemeral
  neg-control: 4 → 4 (no progress)` — `.spec/evidence/G3-…Z.log`.
- **Status:** ✅ verified (probe) — 2026-06-30T00:16Z, vm.

## 4. Requirements
Tag `[locked]` (evidence-backed) or `[provisional→Phase N]`.
- **R1.** `[locked]` Tool execution (fs, shell, git, toolchain) SHALL run in a remote sandboxed environment, never in the browser. *Acceptance:* G1.
- **R2.** `[locked]` Credentials (LLM key, repo tokens) SHALL never be delivered to the browser; a backend proxy SHALL hold them and issue scoped, short-lived creds. *Acceptance:* G2; no secret in any client bundle.
- **R3.** `[locked]` An execution session SHALL survive client disconnect/reconnect with in-flight work continuing. *Acceptance:* G3 probe (work advances across a disconnect).
- **R4.** `[locked]` The agent loop (model output + tool calls/results) SHALL stream incrementally to the browser. *Acceptance:* the client renders partial output before a step completes.
- **R5.** `[provisional→Phase 2]` Multiple users SHALL observe/drive one live session. *Unlocked by:* Phase 2 (collaboration).

## 5. Dependencies (chosen approach — details in `.spec/knowledge/`)
Kept at *approach* altitude (no fabricated version pins; sources dated).

| Concern | Chosen | Considered | Why | Knowledge |
|---------|--------|------------|-----|-----------|
| Execution backend | **remote ephemeral sandbox (container/microVM, gVisor-class isolation)** | WebContainers (in-browser), raw long-lived VM | native toolchain support + per-task isolation (G1) | `.spec/knowledge/execution-model.md` |
| Credential handling | **backend proxy, scoped tokens** | key in client, long-lived PAT | trust boundary (G2) | `.spec/knowledge/credential-boundary.md` |
| Client↔backend transport | **WebSocket (streaming) + resumable session id** | SSE, WebTransport | duplex streaming + reconnect to same session (G3) | `.spec/knowledge/execution-model.md` |

## 6. Decision Log (key reasoning path → conclusion)
`[auto]` = the scout settled it from evidence; `[human]` = a genuine fork escalated.

| # | Decision | Reasoning (why, over alternatives) | Evidence | By | Date |
|---|----------|------------------------------------|----------|----|------|
| D1 | Architecture = thin browser client + **remote sandboxed execution backend** | browser can't host native git/compilers/addons (WebContainers `--no-addons`); all-in-browser breaks on real repos | G1 | [auto] | 2026-06-30 |
| D2 | **Backend credential proxy**; browser never holds keys; scoped short-lived repo creds | a tab-held key is exfiltratable; mirrors the proven Claude-Code-on-web token proxy | G2 | [auto] | 2026-06-30 |
| D3 | **Server-side persistent sessions**, resumable by id; browser is a view | long agent tasks must outlive a flaky tab; probe shows work continues across disconnect | G3 | [auto] | 2026-06-30 |
| D4 | Stream the agent loop server→browser incrementally over WebSocket | agent steps are long; users need partial output; reconnect rejoins the same session | reasoning + G3 | [auto] | 2026-06-30 |
| D5 | **Isolation depth + compute-cost ceiling** for multi-tenant execution | gVisor-class strong isolation vs lighter; idle-timeout; who pays for compute — a **risk/business call evidence can't settle** | — | **[human]** (Q1) | open |

## 7. Phases (ledger — emergent from closure)

### Phase 1 — architecture · status: **sealed 2026-06-30**
- **Goal:** settle *where the agent's hands live* and the trust/lifetime model, so
  construction can begin without re-litigating the foundation.
- **Gates:** G1 ✅ (research), G2 ✅ (research), G3 ✅ (probe).
- **Key decisions:** D1–D4 (see Decision Log). D5 escalated to the human (Q1).
- **Supersedes:** none.

### Phase 2 — collaboration & scale · status: **open** (depends on Phase 1)
- **Goal:** multiple users on one live session; the multi-tenant isolation/cost
  model (D5/Q1) resolved into concrete limits.
- **Deferred gate:** *shared-session consistency* ⤳ deferred→Phase 2.
- (Kept coarse on purpose until unlocked.)

## 8. Open Questions (genuine forks — the human's to own)
| # | Question | Status | Owner/trigger | Notes |
|---|----------|--------|---------------|-------|
| Q1 | Isolation depth & compute-cost ceiling for multi-tenant execution? | open | human (D5) | gVisor-class vs lighter; idle-timeout; cost owner — risk/business, not derivable |
| Q2 | Real-time multi-user collaboration on one session? | deferred→Phase 2 | when Phase 2 opens | drives shared-session design |

## 9. Glossary
| Term | Meaning |
|------|---------|
| Session | a server-side execution context (fs + processes) addressable by id, outliving any one connection |
| Sandbox | the isolated environment (container/microVM) a session runs in |
| Agent loop | the model ↔ tools cycle (model emits tool calls, backend runs them, results fed back) |
| Credential proxy | backend component that holds secrets and issues scoped, short-lived creds; never exposes them to the browser |
