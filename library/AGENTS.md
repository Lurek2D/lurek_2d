# Library Contract

Covers work under `library/`.

## Mission & Scope
- Own reusable, pure Lua gameplay systems (e.g., inventory management, quest tracking, card battling, narrative loops).
- Provide encapsulated packages that can be easily loaded and integrated into any Lurek2D game.
- Maintain comprehensive documentation, usage examples, and tests for each library package.

## Files
- `README.md`: Consolidated guide mapping each library subdirectory to its design goal.
- `*/init.lua`: Canonical entrypoint module for a package (e.g., `inventory/init.lua`).
- `*/example.lua`: Minimal runnable example illustrating standard integration.

## Rules
- Library modules must be written in pure Lua and remain agnostic of specific game assets or hardcoded textures.
- Never write stateful global variables inside libraries; return module tables containing constructors or local states.
- If a package API interface changes, immediately update the matching `example.lua` and rebuild documentation.
- All library modules must run correctly under both LuaJIT and Lua 5.4.
- Do not silence warnings in `.vscode/settings.json` or hide Lua API issues with `---@diagnostic disable`.

## Workflow
- Run and test library updates against their corresponding unit test files under `tests/lua/`.
- Rebuild markdown documentation blocks using `python tools/docs/gen_lib_docs.py`.

## References
- content/examples/
- tests/lua/
- tools/docs/gen_lib_docs.py
