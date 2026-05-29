# lua_api

## Summary
Binding layer that registers and documents the public lurek.* Lua API surface.

## General Info
Files in src/lua_api expose Rust features to Lua and define source doc comments used to generate docs/api/lurek.lua and related API artifacts.

## Files
- src/lua_api/

## Types
- Lua wrapper userdata types (for example: LImage, LWorld, LPathGrid, LFov).

## Functions
- Module registration functions that attach namespaces and constructors to lurek.*.

## Lua API Reference
- Source of truth lives in src/lua_api/*_api.rs doc comments.
- Generated output: docs/api/lurek.lua and docs/api/lurek.md.

## Notes
- Keep business logic in src/<module>/ and keep src/lua_api focused on binding and type conversion.
- Do not hand-edit generated API files under docs/api/.

## References
- docs/specs/README.md
- src/lua_api/
- tools/docs/gen_lua_api_data.py
- tools/docs/gen_luadoc.py
- tools/docs/gen_extension_api.py
