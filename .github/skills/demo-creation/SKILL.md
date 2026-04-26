---
name: demo-creation
description: "Load this skill when creating one or more new demo projects in content/games/. Use when: scaffolding a demo from a genre or feature description; generating conf.lua + main.lua + README.md + screen.png; registering a new demo in content/games/README.md; using library/ modules alongside lurek.* API; creating batches of demos from a list of genres or specific needs. Skip it for content/examples/ single-file scripts (use examples-management skill), test writing, or engine Rust code."
---
# demo-creation

## Mission

Own the content/games/<name>/ folder scaffold, 4-file bundle, library integration, registration, and batch creation workflow.

## When To Load

- Generating a new content/games/<name>/ project from scratch
- Scaffolding multiple demos in one pass (batch creation)
- A demo uses library/ modules alongside lurek.*
- Registering a newly created demo in content/games/README.md

## When To Skip

- content/examples/ single-file scripts → use examples-management skill
- Engine Rust code → use rust-coding + lua-rust-bridge skills
- Test writing → use testing-rust skill

## Domain Knowledge

**Required 4-file bundle — every demo must produce exactly:**

| File | Purpose |
|------|---------|
| conf.toml | Window config: title, resolution, module flags |
| main.lua | Game entry point with canonical section order |
| README.md | 5-section doc: Overview, Controls, Features, API, Notes |
| screen.png | Auto-generated via tools/demos/gen_demo_screenshots.py |

Optional: assets/ folder (sprites, sounds, tilemaps). Never scaffold save/ — auto-created at runtime.

**Demo naming:** lowercase_underscore (tower_defense, bullet_hell). No spaces, hyphens, or version numbers. Check existing folders first.

**conf.toml resolutions:** 800x600 (default for most), 960x540 (16:9 platformers), 800x640 (message logs), 1024x768 (strategy/maps). Add module flags (physics=true, audio=true) only when actually needed.

**main.lua canonical section order (never rearrange):** (1) state locals, (2) helpers, (3) lurek.load (init), (4) lurek.update (process), (5) lurek.draw (draw), (6) lurek.keypressed.

**Mandatory invariants:** all state in module-level locals — no globals except callbacks; lurek.window.setTitle() first in load; lurek.render.setBackgroundColor() in load; movement multiplied by dt; escape → lurek.event.quit() always; all 4 callbacks defined even if empty; no print() — use lurek.render.print() for on-screen text.

**Library integration:** only dialog, item, and inventory are "Full" status and safe to depend on. Other library/ modules may be stubs — check library/README.md status before using.

**README.md template:** 5 sections in order: Overview (1-2 sentences), Controls (table), Features Used (bullet list of lurek.* modules), API Highlights (key functions), Notes (gotchas, limitations).

**Registration:** add table row + detail block in content/games/README.md. Generate screenshot: tools/demos/gen_demo_screenshots.py.

**Smoke testing:** every demo must include an escape→quit path. For CI: if lurek.runtime.getArgs()["--smoke"] then lurek.event.quit() end.

**Genre-to-API mapping:** platformer→physics+input+animation; puzzle→tilemap+input; shooter→physics+particle+audio; RPG→dialog+inventory+save+tilemap; strategy→tilemap+ai+minimap.

## Companion File Index

None — all guidance is inline.

## References

- content/games/ — existing demos (reference for patterns)
- content/games/README.md — demo registry
- tools/demos/ — screenshot generation and smoke testing scripts
- library/ — Lunasome pure-Lua game libraries
