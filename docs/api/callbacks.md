# Callback Hooks

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Binding: Global engine callback registration (no dedicated `src/lua_api/<module>_api.rs` spec target)
- Namespace: `lurek.<callback>` (global callbacks)
- Callback surface: `0` engine callbacks
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

This spec documents global `lurek.*` lifecycle/input/render callbacks exposed by the engine runtime. It is generated from `build/docs-data/lua_api.json` (`engine_callbacks`) with `logs/data/lua_api_data.json` compatibility fallback so callback contracts stay in sync with Rust+Lua API extraction without hardcoded lists.

Scope boundary: this file owns only callback inventory and ownership context. Detailed callback signatures/parameters belong to generated API references (`docs/api/lurek.md`, `docs/api/lurek.lua`).

## Callback Inventory

*No callbacks found in `logs/data/lua_api_data.json`.*

## Callback Details

*No callback details available.*

## Sources

- [Spec callbacks](https://github.com/Lurek2D/lurek_2d/blob/main/docs/specs/callbacks.md)
- [Generated API (Markdown)](lurek.md)
