---
topic: build tool / dev server
decision: Vite (chosen over Webpack)
status: decided
captured: 2026-06-29
sources: [knowledge — would web-verify exact version in a live run]
---

## Candidates compared
| Option | Maintenance | Notes |
|--------|-------------|-------|
| Vite | very active | instant HMR, ESM-native, zero-config TS, fast cold start |
| Webpack | active | powerful but heavier config, slower dev loop |

## Recommendation
**Vite** — best dev-loop feel for a small game; native ESM matches PixiJS v8.

## Decision (human)
Vite · 2026-06-29. Default dev port **5173** (probed bindable — see gate G2).

## Pinned knowledge (for execution)
- `npm create vite@latest` → vanilla-ts template.
- Static assets under `public/` (see gate G3); imported assets are hashed by Vite.
- Dev: `vite` (port 5173); build: `vite build` → `dist/`.
