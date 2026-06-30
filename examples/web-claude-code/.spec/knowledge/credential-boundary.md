---
topic: where credentials live (LLM key, repo tokens) for a browser-driven agent
decision: backend credential proxy; browser never holds secrets; scoped short-lived creds
status: decided
captured: 2026-06-30
sources:
  - https://www.anthropic.com/engineering/claude-code-sandboxing  # token proxy outside the sandbox, scoped creds, network allowlist
  - https://code.claude.com/docs/en/sandbox-environments
---

## The real question
A browser tab is a hostile place to keep a secret: any script (or a successful
prompt injection) can read it. So **can the browser ever hold the LLM/API key or a
repo token?** No — and that decides the whole trust boundary.

## Candidates compared
| Option | Exfiltration risk | Verdict |
|--------|-------------------|---------|
| Key shipped to the browser (client calls model directly) | **High** — readable by any tab script; one of the spec's anti-patterns | Rejected |
| Long-lived PAT held server-side | Medium — broad blast radius if leaked | Rejected |
| **Backend proxy holds secrets; issues scoped, short-lived creds; network allowlist** | Low | **Chosen** — mirrors Claude Code on the web: repo token kept *outside* the sandbox in a separate proxy that issues scoped credentials |

## Recommendation
The browser talks only to our backend. The backend holds the LLM key and brokers
scoped, short-lived repo credentials to the sandbox; a network proxy enforces an
allowlist so a compromised session can't phone home.

## Decision
Backend credential proxy + scoped creds · 2026-06-30 · **[auto]** (standard trust
boundary; settled from the proven model, no human fork).

## Pinned knowledge (for execution)
- No secret ever appears in a client bundle or a browser-visible response. (A build
  check / secret scan belongs in CI — that's a commonsense check, **not a gate**.)
- Scoped + short-lived > long-lived PAT; keep the token's blast radius minimal.
- The depth of multi-tenant isolation (gVisor-class vs lighter) and who pays for
  idle compute is a **business/risk fork → escalated to the human (Q1/D5)**, not
  decided here.
