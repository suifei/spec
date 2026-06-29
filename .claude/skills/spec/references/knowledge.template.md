<!--
.spec/knowledge/<topic>.md — one persisted reconnaissance finding. The scout
writes this so the same exploration isn't repeated next time, and so downstream
execution can read pinned facts without re-fetching from the web. Committed.
Default is REUSE; refresh only on request or when the spec changes this item.
Superseded entries are kept (set status: superseded), not deleted.
-->

---
topic: <e.g. rust async runtime>
decision: <chosen item + one-line reason, e.g. "tokio 1.40 (chosen over async-std)">
status: <explored | decided | superseded>
captured: <YYYY-MM-DD>
sources: [<url>, <url>]
---

## Candidates compared
| Option | Stable | Latest | Maintenance | Notes |
|--------|--------|--------|-------------|-------|
| <tokio> | <1.40> | <1.40> | <very active> | <de-facto standard> |
| <async-std> | <1.13> | <1.13> | <low> | <fewer integrations> |

## Recommendation
<which, and why>

## Decision (human)
<chosen · pinned version · date>

## Pinned knowledge (for execution)
<key APIs, gotchas, minimal usage, version-specific notes, doc links — enough that
downstream code can be written without re-searching the web>
