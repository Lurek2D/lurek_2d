---
name: create-demo
description: "Load this skill when creating or modifying finished playable Lua mini games or game-like apps under content/newgames, with assets, modular code, screenshots, validation, and smoke coverage. Skip it for API showcases, throwaway mechanic snippets, single-file examples, engine internals, or pure library modules."
---
# create-demo

## Mission
- Create or modify finished playable mini games and game-like apps that use real Lurek2D APIs, live under `content/newgames`, and remain validator-safe.

## When To Load
- Creating or modifying playable Lua mini games or apps under `content/newgames` with modular code, local assets, screenshots, validation, and smoke coverage.

## When To Skip
- API showcases, throwaway mechanic snippets, single-file examples, engine internals, or pure library modules.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect `content/newgames/<name>/` first; use `content/games/` only as reference material when no newgames owner exists.
- Create a new project from `content/newgames/_template/` only when no matching newgames project exists; otherwise modify the existing owner.
- Keep `main.lua` as a thin bootstrap and put gameplay, rendering, input, UI, audio, data, and scenario logic in Lua modules.
- Include local assets under the game folder, including PNG art and audio where the design has feedback or music.
- Write an English `README.md` that explains the game design, controls, structure, APIs used, and how to play.
- Use TOML layout files for menus, HUDs, tool panels, and app UI; update widgets through `lurek.ui`.
- Use real `lurek.*` APIs whenever they exist; do not write local stand-ins for engine systems such as input, audio, particles, tilemaps, physics, UI, automation, dataframe, or province rendering.
- Capture `screen.png` from active gameplay, not a menu; if a menu blocks gameplay, add or use automation so the renderer reaches the right frame before capture.
- Run game validation and a direct engine screenshot smoke for the changed project.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- The target artifact was created or modified in the narrowest owning location.
- Existing content was preserved and updated when it already owned the behavior.
- The result is a playable mini game or app, not a Lurek API showcase.
- The project has `main.lua`, multiple Lua modules, local assets, an English `README.md`, TOML UI when UI exists, and a gameplay `screen.png`.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `content/AGENTS.md`, `content/newgames/AGENTS.md`, `content/games/AGENTS.md`, `tests/lua/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "content newgames playable game modules assets screenshot ui toml" --profile game --limit 10`, `tools/python.cmd tools/validate/validate_game.py content/newgames/<name>`, `build/debug/lurek2d.exe content/newgames/<name> --screenshot=screen.png --screenshot-frames=180`, `python tools/dev/parallel_cargo.py run debug -- content/newgames/<name>`
- Owner profile: `content`

## Common RAG Queries
- Use when finding similar demos or owning game content:
  - `content newgames playable game modules assets`
  - `main.lua game demo content newgames`
  - `layout sprite physics audio gameplay`
  - `screen.png automation gameplay capture`
- Common areas to inspect after top hits:
  - `content/newgames/`
  - `content/games/`
  - `content/layouts/`
  - `library/`
  - related `docs/` specs or examples

## References
- `contracts: content/AGENTS.md, content/newgames/AGENTS.md, content/games/AGENTS.md, tests/lua/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content newgames playable game modules assets screenshot ui toml" --profile game --limit 10, tools/python.cmd tools/validate/validate_game.py content/newgames/<name>, build/debug/lurek2d.exe content/newgames/<name> --screenshot=screen.png --screenshot-frames=180, python tools/dev/parallel_cargo.py run debug -- content/newgames/<name>`
- `agent: content`
