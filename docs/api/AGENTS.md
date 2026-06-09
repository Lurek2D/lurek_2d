# API Docs Contract

Covers work under `docs/api/`.

## Mission & Scope
- Manage the generated Lua and Rust API reference documentation.
- Maintain consistency between source code binding annotations and final output formats.
- Prevent manual edit drift by keeping output documents strictly derived from engine source code.

## Files
- `lurek.md`: Compiled markdown reference sheet for the `lurek.*` namespace.
- `lurek.lua`: EmmyLua/LDoc type declarations used for IDE code completion.

## Rules
- All files in this directory are generated; never edit them directly.
- Modify the source doc comments under `src/lua_api/` when correcting spelling, signatures, or behavior notes.
- Verify that regenerations preserve anchor tags and do not break external reference links.

## Workflow
- Run `python tools/gen_all_docs.py` to rebuild output files after editing Lua binding definitions.

## References
- src/lua_api/
- docs/api/lurek.md
- tools/gen_all_docs.py
