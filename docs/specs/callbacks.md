# callbacks

## TL;DR

Global `lurek.*` callbacks are documented here as a dedicated generated spec, independent from thin-wrapper module specs.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/app/`
- Binding: Global engine callback registration (no dedicated `src/lua_api/<module>_api.rs` spec target)
- Namespace: `lurek.<callback>` (global callbacks)
- Callback surface: `0` engine callbacks
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

Documents global `lurek.*` engine callbacks. Read it as the inventory for lifecycle, input, and render hooks.

## Imports

- Global callback contracts are sourced from `logs/data/lua_api_data.json` (`engine_callbacks`).

## Files

### callback contracts

- Generated from engine callback metadata extracted during Lua API data generation.

## Lua API Ref

- No callback metadata available in `logs/data/lua_api_data.json`.
### API Details

- Full signatures and parameter contracts are intentionally kept in generated API docs:
  - `docs/api/lurek.md`
  - `docs/api/lurek.lua`
