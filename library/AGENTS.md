# Library Contract

Adds local rules for `library/`.

## Mission & Scope
- Own reusable pure Lua gameplay systems.
- Provide encapsulated packages that can be loaded into any Lurek2D game.
- Maintain docs, examples, and tests for each package.

## Files
- `README.md`: Guide mapping each library folder to its design goal.
- `*/init.lua`: Main entrypoint for a package such as `inventory/init.lua`.
- `*/example.lua`: Minimal runnable integration example.

## Rules
- Library modules must be written in pure Lua and remain agnostic of specific game assets or hardcoded textures.
- Never write stateful globals inside libraries; return module tables with constructors or local state.
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
