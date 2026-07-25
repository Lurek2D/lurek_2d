# API Docs Contract

## Mission & Scope
- Own generated Lua and Rust API reference docs.
- Keep final docs derived from source binding annotations.

## Files
- `lurek.md`, `lurek.lua`: Lua API reference and IDE declarations.
- `rust.md`: Rust API reference.
- `callbacks.md`, `lureksome.*`: Callback and pure Lua library references.

## Rules
- Files here are generated; never edit them by hand.
- Fix spelling, signatures, and behavior notes in `src/lua_api/`.
- Keep generated anchors and external links stable.

## Workflow
- Run `tools/python.cmd tools/gen_all_docs.py` after editing binding definitions.
