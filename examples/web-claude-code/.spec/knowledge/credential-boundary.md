---
topic: where credentials / auth / permissions live once the CLI is web-relayed
decision: the `claude` CLI runs server-side with its own auth + permission model; the browser is only a relayed view — no secrets reach it
status: decided
captured: 2026-06-30
sources:
  - https://code.claude.com/docs/en/overview            # CLI asks permission before edits/commands
  - https://www.anthropic.com/engineering/claude-code-sandboxing
---

## The real question (follows from the subject)
Since web-ification **relays the CLI's I/O** rather than rebuilding it, the
credential question is simple: the real `claude` process runs **server-side**,
where the repo, its auth (Pro/Max/Console or API key), and its **permission
prompts** already live. So **what crosses to the browser?** Only relayed terminal
I/O — never a secret.

## Candidates compared
| Option | Exfiltration risk | Verdict |
|--------|-------------------|---------|
| Browser calls the model directly with a key (rebuild the agent client-side) | **High** — key readable by any tab script; also re-implements what the CLI already is | Rejected (anti-pattern) |
| `claude` CLI runs server-side; **browser only relays I/O** | Low | **Chosen** — secrets stay on the server with the process; the browser is a viewport |

## Recommendation
Run `claude` on the server (where repo + creds live); bridge only its I/O to the
browser. The CLI's **own permission model is preserved** — its approve/deny
prompts are relayed to the user in the browser, not reinvented. A network allowlist
limits what a session can reach.

## Decision
CLI server-side; browser is a relayed view; no secret crosses · 2026-06-30 ·
**[auto]**.

## Pinned knowledge (for execution)
- No secret ever appears in a client bundle or a browser-visible payload (a secret
  scan belongs in CI — a commonsense check, **not a gate**).
- Preserve, don't reinvent, the CLI's permission prompts — relay them.
- Multi-tenant isolation depth + who pays for idle compute is a **business/risk
  fork → human (Q2/D6)**, not decided here.
