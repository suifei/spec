---
topic: 2D browser render framework for Nebula Drift
decision: PixiJS 8.18.1 (chosen over Phaser and vanilla Canvas)
status: decided
captured: 2026-06-29
sources:
  - https://pixijs.com/versions
  - https://www.npmjs.com/package/pixi.js?activeTab=versions
  - https://github.com/pixijs/pixijs/releases
---

## Candidates compared (as of 2026-06-29, web-verified)
| Option | Stable | Latest | Maintenance | Notes |
|--------|--------|--------|-------------|-------|
| PixiJS | 8.18.1 | 8.19.0 | very active (monthly releases) | WebGL/WebGPU renderer; lightweight; great for custom sprite-heavy games |
| Phaser | 3.8x | 3.8x | active | full game framework (physics/scenes); heavier, more opinionated |
| vanilla Canvas | n/a | n/a | n/a | zero deps but we'd reinvent batching/scene graph |

## Recommendation
**PixiJS** — fastest sprite batching for a 200-entity arena, far lighter than
Phaser when we want our own ECS/loop, and actively maintained. Vanilla Canvas
rejected: perf work we shouldn't redo.

## Decision (human)
PixiJS, **pinned 8.18.1** (current stable) · 2026-06-29. (Latest 8.19.0 noted;
pin stable, re-evaluate the bump in a later phase.)

## Pinned knowledge (for execution)
- Install: `npm i pixi.js@8.18.1`
- v8 API: `import { Application, Container, Sprite } from 'pixi.js'`; `await app.init({ ... })` (v8 init is async — different from v7).
- Renderer auto-selects WebGPU→WebGL; for max compat pass `preference: 'webgl'`.
- Ticker (`app.ticker.add`) drives the game loop; keep our fixed-timestep sim separate from render for determinism (matters for Phase 2 netcode).
- Gotcha: v8 dropped the old `PIXI.*` global namespace — use ES imports + bundler (Vite).
