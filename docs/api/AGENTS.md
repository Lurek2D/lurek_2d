# API Docs Contract

Covers work under `docs/api/`.

## Mission
- Own the generated API reference for Lua and Rust-facing docs.
- Keep published API docs synced with source docstrings and specs.

## Scope
- `docs/api/` generated API pages.
- Lua and Rust-facing reference output.

## Local map
- `lurek.md` and `rust.md` are generated outputs.
- `src/lua_api/` is the source edge.
- `docs/specs/` defines ownership and behavior.

## Rules
- Treat `docs/api/` as generated output.
- Do not hand-edit rendered pages when docstrings or spec inputs are the real fix.
- Regenerate API docs when `src/lua_api/<module>_api.rs` changes.
- Keep anchors and headings stable.
- If generator output shifts unexpectedly, fix the source docstring or generator and rerun the pipeline.

## Workflow
- Read the owning spec and source docstrings before editing the API surface.
- Regenerate with the normal docs pipeline after API-visible changes and verify the diff.

## References
- `src/lua_api/`
- `docs/specs/`
- `tools/gen_all_docs.py`
