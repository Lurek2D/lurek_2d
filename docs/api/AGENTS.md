# API Docs Contract

This file adds local rules for work under `docs/api/`.

## Mission
- Own the generated API reference surface for Lua and Rust-facing documentation.
- Keep the published API docs synchronized with source docstrings and module specs.

## Local rules
- Treat `docs/api/` as generated output. Do not hand-edit the rendered pages when the source docstrings or spec inputs are the real fix.
- When `src/lua_api/<module>_api.rs` changes, regenerate the API reference rather than patching `lurek.md` or `rust.md` by hand.
- Keep generated API pages aligned with `docs/specs/<module>.md` for ownership, behavior, and error semantics.
- Preserve stable anchors and headings so links from docs, examples, and the website do not drift unnecessarily.
- If the generator output changes unexpectedly, fix the source docstring or generation script and rerun the docs pipeline.

## Workflow
- Read the owning spec and the source docstrings before changing anything that affects the API surface.
- Regenerate with the normal docs pipeline after API-visible changes and verify the output diff.

## References
- `src/lua_api/`
- `docs/specs/`
- `tools/gen_all_docs.py`
