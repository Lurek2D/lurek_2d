# API Docs Contract

Adds local rules for `docs/api/`.

## Mission & Scope
- Manage generated Lua and Rust API reference docs.
- Keep source binding annotations and final output aligned.
- Prevent drift by keeping output derived from engine source.

## Files
- `lurek.md`: Compiled Markdown reference for the `lurek.*` namespace.
- `lurek.lua`: EmmyLua/LDoc type declarations used for IDE code completion.

## Rules
- All files in this directory are generated; never edit them directly.
- Modify the source doc comments under `src/lua_api/` when correcting spelling, signatures, or behavior notes.
- Verify that regenerations keep anchor tags and external links intact.

## Workflow
- Run `python tools/gen_all_docs.py` to rebuild output files after editing Lua binding definitions.

## References
- src/lua_api/
- docs/api/lurek.md
- tools/gen_all_docs.py
