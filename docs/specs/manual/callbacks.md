# callbacks manual spec overlay

## TL;DR

Global `lurek.*` callbacks are documented here as a dedicated generated spec, independent from thin-wrapper module specs.

## Summary

This spec documents global `lurek.*` lifecycle/input/render callbacks exposed by the engine runtime. It is generated from `logs/data/lua_api_data.json` (`engine_callbacks`) so callback contracts stay in sync with Rust+Lua API extraction without hardcoded lists.

Scope boundary: this file owns only callback inventory and ownership context. Detailed callback signatures/parameters belong to generated API references (`docs/api/lurek.md`, `docs/api/lurek.lua`).

## Notes

- Intentionally empty.

## Architecture Links

- Intentionally empty.
