<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/callbacks.md or source docstrings instead. -->

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

This spec documents global `lurek.*` lifecycle/input/render callbacks exposed by the engine runtime. It is generated from `build/docs-data/lua_api.json` (`engine_callbacks`) with `logs/data/lua_api_data.json` compatibility fallback so callback contracts stay in sync with Rust+Lua API extraction without hardcoded lists.

Scope boundary: this file owns only callback inventory and ownership context. Detailed callback signatures/parameters belong to generated API references (`docs/api/lurek.md`, `docs/api/lurek.lua`).

## Imports

- Global callback contracts are sourced from generated Lua API data (`engine_callbacks`).

## Files

### callback contracts

- Generated from engine callback metadata extracted during Lua API data generation.

## Lua API Ref

- No callback metadata available in generated Lua API data.
### API Details

- Full signatures and parameter contracts are intentionally kept in generated API docs:
  - `docs/api/lurek.md`
  - `docs/api/lurek.lua`
