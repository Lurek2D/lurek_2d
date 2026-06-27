---
name: convert-gemini-game
description: "Load this skill when converting Gemini Canvas, React, TSX, JavaScript, HTML canvas, or other web game prototypes into runnable Lurek2D Lua games under content/games. Use it when the user pastes or provides a web prototype and asks to port, map, redesign, or recreate it in Lurek while maximizing real lurek.* API usage."
---

# Convert Gemini Game

## Mission
- Convert Gemini, React, TSX, JavaScript, and HTML-canvas game prototypes into runnable Lurek2D Lua demos while maximizing real `lurek.*` API usage.

## When To Load
- Converting a Gemini Canvas or other web game prototype into a runnable Lurek2D Lua game under `content/games/`.
- Mapping React/canvas mechanics to Lurek APIs before implementing a port or redesign.

## When To Skip
- Normal Lua demo work that does not start from a web prototype.
- Engine internals, docs-only updates, or product code unrelated to a prototype conversion.

## Domain Knowledge
- Read root `AGENTS.md`, then target contracts such as `content/AGENTS.md` and `content/games/AGENTS.md`.
- Run RAG before broad reads: `tools/python.cmd tools/rag/query.py "content games demo conventions render input" --profile game --limit 10`.
- Prefer existing Lurek APIs and nearby demos over direct structural ports of React code.
- Save pasted or bulky source only under `work/{short-chat-name}/` if a scratch copy is needed.
- Keep gameplay state local to Lua tables/modules. Do not port React components, DOM state, CSS classes, Tailwind styling, or canvas boilerplate directly.
- Use this mandatory concept map before coding:
  - `React state/effects/game loop -> lurek.init, lurek.process(dt), lurek.draw, lurek.draw_ui`
  - `Canvas primitives -> lurek.render.setColor, rectangle, circle, line, polygon, print, LShape, mesh`
  - `Keyboard/mouse events -> lurek.input.bind, isActionDown, wasActionPressed, lurek.input.mouse.getPosition`
  - `Screen/window size -> lurek.window.getWidth, getHeight, getDimensions, lurek.resize`
  - `Camera/scrolling -> explicit camera offsets or lurek.camera`
  - `Particles/tweens/timers/audio/physics -> lurek.particle, lurek.tween, lurek.timer, lurek.audio, lurek.physics`
  - `Procedural math -> lurek.math helpers when they fit, otherwise small local math functions`

## Workflow
- Identify the prototype's game loop, state model, input, rendering primitives, UI/HUD, assets, timing, randomness, economy/combat/physics rules, and win/loss conditions.
- Write a short conversion brief before editing: source mechanics, target folder, chosen Lurek APIs, deliberate simplifications, and validation plan.
- Build a mandatory API map before writing code.
- Implement under the narrowest game folder, normally `content/games/<category>/<name>/main.lua`; create a new folder only when no existing demo owns the concept.
- Preserve the playable fantasy and core mechanics over exact visual parity.
- Maximize Lurek API usage, but avoid forced APIs that add no behavior or clarity.
- Scale all motion, production, cooldowns, fades, and simulation timers by `dt`.
- Bind named actions instead of scattering raw key strings through logic.
- Draw world content in `lurek.draw` and HUD/menu overlays in `lurek.draw_ui`.
- Keep UI text concise and in-game; do not add explanatory landing screens.
- For TOML UI in converted games, use `w`/`h` keys and validator-supported bitmap font sizes 8, 10, 12, 16, 20, 24, or 30.
- Use procedural shapes for Gemini canvas prototypes unless real assets are supplied or clearly needed.
- Add a small `README.md` only when nearby demos use one or the game needs catalog context.
- If a prototype feature has no current Lurek API, state the gap and build the simplest Lua-side equivalent without pretending an API exists.

## Success Criteria
- The converted demo preserves the prototype's core playable loop while feeling native to Lurek.
- A mandatory API map was produced before implementation and uses real `lurek.*` APIs wherever they match.
- The target artifact was created or modified in the narrowest owning `content/games/` location.
- Validation completes successfully, or remaining gaps are reported with exact commands and blockers.

## Stop Conditions
- The prototype source is missing or too incomplete to infer its mechanics safely.
- A requested feature depends on a nonexistent Lurek API and no reasonable Lua-side substitute fits the scope.
- Completing the port would require widening into engine work or overwriting unrelated user changes.

## Companion File Index
- Contracts: `AGENTS.md`, `content/AGENTS.md`, `content/games/AGENTS.md`, `tests/lua/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "content games demo conventions render input" --profile game --limit 10`, `tools/python.cmd tools/validate/validate_game.py <demo-dir>`, `python tools/dev/parallel_cargo.py run debug -- content/games/<category>/<name>/main.lua`, `tools/python.cmd tools/demos/smoke_sweep.py --kind game --only <name>`
- Owner profile: `content`

## Common RAG Queries
- Use when locating demo owners and matching APIs before porting:
  - `content games demo conventions render input`
  - `hex strategy camera render input`
  - `simulation logistics drones resource transport`
- Common areas to inspect after top hits:
  - `content/games/`
  - `content/examples/`
  - `docs/api/lurek.md`
  - `docs/specs/`

## References
- `contracts: AGENTS.md, content/AGENTS.md, content/games/AGENTS.md, tests/lua/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content games demo conventions render input" --profile game --limit 10, tools/python.cmd tools/validate/validate_game.py <demo-dir>, python tools/dev/parallel_cargo.py run debug -- content/games/<category>/<name>/main.lua, tools/python.cmd tools/demos/smoke_sweep.py --kind game --only <name>, tools/python.cmd tools/validate/cag_validate.py`
- `agent: content`
