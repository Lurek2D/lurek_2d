---
name: convert-gemini-game
description: "Load this skill when converting Gemini Canvas, React, TSX, JavaScript, HTML canvas, or other web game prototypes into runnable Lurek2D Lua games under content/games. Skip it for engine internals, docs-only edits, or tasks that do not start from an existing web prototype."
---

# Convert Gemini Game

## Mission
- Convert Gemini, React, TSX, JavaScript, and HTML-canvas game prototypes into runnable Lurek2D Lua demos while maximizing real `lurek.*` API usage.

## Domain Knowledge
- A web prototype is a behavioral specification, not a source-language template: component trees collapse into Lua state modules, hooks become explicit transitions, and browser repaint becomes Lurek's `init`/`process(dt)`/`draw`/`draw_ui` lifecycle.
- Coordinate translation is explicit: canvas world drawing belongs in `lurek.draw`, HUD in `lurek.draw_ui`, resize assumptions behind `lurek.window`, and camera transforms must not be applied twice to input hit tests.
- Browser key/pointer handlers become named `lurek.input` actions plus mouse queries, with edge-triggered actions separated from held movement to avoid frame-dependent toggles.
- React effects, `requestAnimationFrame`, intervals, and CSS transitions encode timing semantics that map to `dt`, `lurek.timer`, or `lurek.tween`; browser scheduling and fixed 60 Hz assumptions do not survive the port.
- Physics, particles, audio, camera, and UI should use engine owners when their behavior matters; local math is for prototype-specific rules, not a shadow implementation of an existing subsystem.
- Individual calls are best verified in `content/examples/` and generated API docs, while neighboring `content/games/` projects teach composition, asset loading, boot flow, and completeness.
- Preserve the feedback loop—player action, visible response, state consequence, and win/loss progression—even when DOM layout, CSS ornament, and React abstractions disappear.
- Treat browser layout as evidence of visual intent rather than a geometry contract. Flex/grid panels usually map to TOML UI or explicit HUD groups, while absolutely positioned canvas labels often belong in world-space rendering; choose according to how the element should react to camera movement and resize.
- Separate simulation state from presentation caches during translation. React often derives display data during render, but Lurek draw callbacks should not advance timers, mutate economy/combat state, or create persistent engine resources because multiple draws or screenshot paths would then change gameplay.
- Reconcile JavaScript numeric assumptions with LuaJIT behavior: array indices, truthiness, missing table keys, integer-like coordinates, modulo on negatives, and floating-point comparisons can change edge behavior even when the formulas look identical.
- Preserve deterministic setup when the prototype uses `Math.random`, randomized spawning, or procedural maps. Make seed ownership explicit so smoke captures and bug reproduction do not depend on an unrepeatable first frame.
- Translate asset semantics, not import syntax: browser URLs and bundler imports become forward-slash game-relative paths, image dimensions must match the engine draw call, and audio/image creation should occur at initialization rather than inside per-frame callbacks.

## Workflow
- Decompose the source into a brief naming authoritative state, update cadence, action bindings, world/UI passes, assets, random seeds, collision/economy rules, and completion states; map every browser-only mechanism to a verified Lurek replacement or explicit Lua fallback.
- Locate the closest `content/games/` owner and per-API examples before coding. Choose a new directory only when no project owns the playable concept, and keep bulky source/comparison notes under `work/<short-chat-name>/`.
- Port one vertical slice first: initialize local/module state, bind semantic actions, update continuous quantities from `dt`, render correct passes, and preserve action-to-feedback timing; add physics, audio, particles, assets, and menus after the loop boots cleanly.
- Compare rules and transitions rather than pixels, document simplifications and API gaps, then run `validate_game.py`, launch the exact entry point, and use the targeted smoke sweep to catch unknown callbacks, asset paths, and lifecycle failures.
- Build a source-to-target state table before implementation: list every React state variable or JavaScript singleton, its writer, update phase, persistence lifetime, and Lua owner. Identify values that are merely derived for rendering so they are not ported as competing authoritative state.
- Audit all input paths after the vertical slice: verify simultaneous directions, key repeat, pointer coordinates under camera/resize, focus loss, pause/menu transitions, and one-shot actions. Replace source event ordering assumptions with explicit action precedence where simultaneous events affect rules.
- Compare the source and port at several fixed checkpoints—initial state, first meaningful action, mid-progression, loss, victory, and restart—recording semantic differences in counters, positions, cooldowns, and available actions rather than relying only on a final screenshot.
- Exercise at least two frame-step patterns when timing matters: normal interactive `dt` and a larger catch-up step. Clamp or subdivide only where the target engine/API requires it, and confirm timers, spawning, collisions, tweens, and economy production do not skip terminal states.
- Finish by checking the complete folder as a distributable game: no web framework remnants, remote asset dependencies, browser terminology in controls, orphan source files, or hidden development-only startup steps; ensure README and screenshot describe the Lurek result rather than the original prototype.

## References
- `contracts: AGENTS.md, content/AGENTS.md, content/games/AGENTS.md, tests/lua/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content games demo conventions render input" --profile game --limit 10, tools/python.cmd tools/validate/validate_game.py <demo-dir>, python tools/dev/parallel_cargo.py run debug -- content/games/<category>/<name>/main.lua, tools/python.cmd tools/demos/smoke_sweep.py --kind game --only <name>, tools/python.cmd tools/validate/cag_validate.py`
- `agent: content`
- RAG: Use when locating demo owners and matching APIs before porting; `content games demo conventions render input`; `hex strategy camera render input`; `simulation logistics drones resource transport`; `content/games/`; `content/examples/`; `docs/api/lurek.md`; `docs/specs/`
