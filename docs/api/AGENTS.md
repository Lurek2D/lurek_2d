# API Docs Contract

## Mission & Scope
- Own generated Lua and Rust API reference docs.
- Keep final docs derived from source binding annotations.

## Files
- `lurek.md`: Markdown reference for `lurek.*`.
- `lurek.lua`: EmmyLua/LDoc declarations for IDEs.

## Rules
- Files here are generated; never edit them by hand.
- Fix spelling, signatures, and behavior notes in `src/lua_api/`.
- Keep generated anchors and external links stable.

## Workflow
- Run `python tools/gen_all_docs.py` after editing binding definitions.
