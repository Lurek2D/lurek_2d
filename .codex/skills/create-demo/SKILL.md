---
name: create-demo
description: "Load this skill when creating or modifying finished playable Lua games or mini games under content/games, with assets, modular code, screenshots, validation, and smoke coverage. Skip it for API showcases, throwaway mechanic snippets, single-file examples, engine internals, or pure library modules."
---

# create-demo

## Mission
- Create or modify finished playable games and mini games that use real Lurek2D APIs, live under `content/games`, and remain validator-safe.

## Domain Knowledge
- Finished playable products live under `content/games/<name>/`; `content/examples/` owns API teaching and `tests/lua/evidence/` owns artifact demonstrations. There is no separate new-games content tree in this repository.
- A catalog-ready game combines a stable entry point, complete rules loop, reachable start/end states, controls, feedback, and folder-local assets; feature count alone does not turn an example into a game.
- `main.lua` should coordinate callbacks and game-local modules rather than accumulate state, rules, presentation, data, and automation in one file.
- `screen.png` is catalog evidence and must show representative active play; a splash screen, empty map, or first loading frame is not sufficient proof.
- The game audit classifies catalog readiness and smoke checks bootability, but only a core-loop playthrough proves progression, failure, and restart remain reachable.
- Game state benefits from an explicit authority graph: rules modules own simulation values, presentation modules read snapshots or queries, UI sends intents, and automation drives the same public action path as a player. Direct UI mutation of rule state makes replay and screenshot setup unreliable.
- Completion quality includes pacing and feedback, not merely reachability. Score/progression cadence, damage/resource signals, audio cues, and transition timing should make the rules understandable without reading source code.
- Automation used for capture should be deterministic, bounded, and game-local. It may seed or issue normal actions, but it must not introduce a second rules path that can reach states a player cannot.
- Asset budgets and loading behavior shape startup: repeated per-frame image/audio creation, absolute paths, oversized unreferenced assets, or missing fallback behavior can pass static validation yet fail packaging and smoke execution.

## Workflow
- Start with `audit_games.py` and neighboring `content/games/` projects to decide whether to evolve an owner or create a product. Define the core loop, controls, progression/failure/restart states, module boundaries, asset plan, and catalog scale first.
- Build a thin `main.lua` around local modules, then complete a playable vertical slice with real `lurek.*` systems. Add folder-local art/audio and TOML UI where they strengthen feedback, plus automation that can reach representative gameplay.
- Finish the product surface: remove dead-end menus and placeholders, verify a full play/restart cycle, write the local README with controls and scale, and capture `screen.png` only when the frame communicates the game loop.
- Run `validate_game.py`, a direct debug launch/screenshot, and the targeted smoke sweep; rerun the catalog audit and regenerate catalog data only after the project earns a `KEEP` classification.
- Define acceptance scenarios before expanding content: cold boot to menu or play, control discovery, one complete progression loop, failure, victory when applicable, pause/resume, restart, and deterministic automation to an informative capture frame.
- Review module boundaries after the first slice, moving mixed responsibilities out of `main.lua` and ensuring gameplay modules do not depend on draw order for correctness. Confirm callbacks delegate into the same state owner rather than keeping mirrored counters.
- Perform a feedback pass with audio muted and then visuals simplified: critical state changes should remain legible through more than one cue where practical, and HUD values should update from authoritative state without a one-frame or stale-cache discrepancy.
- Exercise the game at alternate window sizes and with fresh save/config state, checking layout clipping, camera assumptions, restart cleanup, accumulated callbacks/timers, and whether a second session behaves identically to the first.
- Audit every shipped asset and module from the entry point, remove unused or prototype-only files, verify forward-slash relative paths from the game folder, and confirm the direct binary launch works outside editor-specific configuration.
- Capture the final screenshot only after automation reaches stable active play; inspect it for readable state, representative threats/objectives, absence of debug overlays, and enough composition to distinguish the game in the generated catalog.

## References
- `contracts: content/AGENTS.md, content/games/AGENTS.md, tests/lua/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content games playable modules assets screenshot ui toml" --profile game --limit 10, tools/python.cmd tools/demos/audit_games.py, tools/python.cmd tools/validate/validate_game.py content/games/<name>, build/debug/lurek2d.exe content/games/<name> --screenshot=screen.png --screenshot-frames=180, tools/python.cmd tools/dev/parallel_cargo.py run debug -- content/games/<name>`
- `agent: content`
- RAG: Use when finding similar games or owning game content; `content games playable modules assets`; `main.lua game demo content games`; `layout sprite physics audio gameplay`; `screen.png automation gameplay capture`; `content/games/`; `content/layouts/`; `library/`; related `docs/` specs or examples
