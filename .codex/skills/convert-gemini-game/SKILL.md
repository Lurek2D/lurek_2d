---
name: convert-gemini-game
description: "Load this skill when converting Gemini Canvas, React, TSX, JavaScript, HTML canvas, or other web game prototypes into runnable Lurek2D Lua games under lurek_2d_content/games. Skip it for engine internals, docs-only edits, or tasks that do not start from an existing web prototype."
---

# convert-gemini-game

## Mission
- Convert Gemini, React, TSX, JavaScript, and HTML-canvas prototypes into complete runnable Lurek2D Lua games while maximizing real `lurek.*` API usage.

## Domain Knowledge
- The source prototype is the behavior reference.
- The target is a Lua game under `lurek_2d_content/games/`.
- React components become Lua modules or state tables.
- React state becomes explicit authoritative Lua state.
- Browser repaint maps to Lurek init, update, draw, and UI callbacks.
- `requestAnimationFrame` does not define target timing.
- Timed behavior uses `dt`, `lurek.timer`, or `lurek.tween`.
- World rendering belongs in `lurek.draw`.
- HUD rendering belongs in `lurek.draw_ui`.
- Camera transforms apply once to world rendering and hit tests.
- Browser input handlers become named `lurek.input` actions.
- Pressed actions and held actions are separate.
- Draw callbacks do not change simulation state.
- Persistent resources are created outside per-frame callbacks.
- Randomized systems need an owned seed.
- The port preserves controls, rules, progress, loss, win, and restart.
- Browser-only layout and CSS are not target runtime contracts.
- DOM controls map to retained `lurek.ui` widgets or `lurek.draw_ui`, not to world draw code.
- Browser audio objects map to owned `lurek.audio` sources with explicit stop and release behavior.
- `localStorage` progress maps to versioned `lurek.save` data, not process globals.
- URL and bundler asset imports become forward-slash paths relative to the game folder.
- React effect cleanup becomes explicit callback removal, resource release, or scene teardown.
- Frame-count constants from the prototype become seconds or rates before they are multiplied by `dt`.

## Workflow
1. Read the source prototype and list its visible behaviors.
2. Record controls, state, timing, rules, assets, and completion states.
3. Separate world rendering from HUD rendering.
4. Map browser input to semantic Lurek actions.
5. Map browser timers and effects to `dt`, timer, or tween behavior.
6. Verify every target API in generated Lua API docs.
7. Read the closest Lurek games and API examples.
8. Create one target game folder.
9. Port one complete vertical slice.
10. Add deterministic seed ownership when the source uses randomness.
11. Add physics, audio, particles, assets, and menus after the loop works.
12. Compare initial, first-action, progress, loss, win, and restart states.
13. Test normal `dt` and one large catch-up step.
14. Record intentional simplifications and engine gaps.
15. Run `validate_game.py`.
16. Launch the exact game entry point.
17. Run the targeted game smoke sweep.

## References
- `contracts: AGENTS.md, content/AGENTS.md, lurek_2d_content/AGENTS.md, lurek_2d_content/games/AGENTS.md, tests/lua/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "web prototype Lurek game conversion" --profile game --limit 10, tools/python.cmd tools/validate/validate_game.py lurek_2d_content/games/<name>, tools/python.cmd tools/demos/smoke_sweep.py --kind game --only <name>`
- `agent: content`
- RAG: `web prototype game conversion input dt draw_ui`; inspect the target game, neighboring `lurek_2d_content/games/`, and examples for mapped APIs.
