# Library Contract

## Mission & Scope
- Own reusable pure Lua gameplay packages.
- Keep packages portable across games, LuaJIT, and Lua 5.4.

## Files
- `README.md`: Package index and design goals.
- `*/init.lua`: Package entry point.
- `*/example.lua`: Minimal runnable example.
- `tests/lua/library/test_<name>_library.lua`: Canonical package test owner.

## Rules
- Keep modules pure Lua and game-asset agnostic.
- Return module tables with constructors or local state; do not create globals.
- `init.lua` must end with a return statement and include LDoc-style `-- @...` or `--- @...` annotations.
- Update matching `example.lua` and docs when a package API changes.
- Support both LuaJIT and Lua 5.4.
- Do not hide warnings with `.vscode/settings.json` or `---@diagnostic disable`.

## Workflow
- Run matching Lua tests under `tests/lua/`.
- Rebuild docs with `python tools/docs/gen_lib_docs.py`.
