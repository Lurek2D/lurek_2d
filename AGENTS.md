# Repository Contract

- Lurek2D is one Rust binary that runs Lua game scripts.
- Stack: Rust 1.78+, LuaJIT/mlua 0.9, wgpu 22, winit 0.30, rapier2d 0.32, rodio 0.17, fontdue 0.9.

## Mission & Scope
- This file applies to the whole repo unless a deeper `AGENTS.md` adds local rules.
- Keep guidance short. Put durable rules in the nearest owning contract.
- Use `.codex/` for local CAG config, roles, and skills.

## Files
- `src/`: Rust engine and Lua bindings.
- `content/`: Lua examples, demos, layouts, snippets.
- `library/`: Pure Lua packages.
- `tests/`: Lua, Rust, smoke, golden, and evidence tests.
- `docs/`: Source docs for the engine.
- `tools/`: Repo scripts, generators, validators.
- `lurek_2d_extension/`: Separate repository for the VS Code extension; do not create or edit a root-level `extension/` directory.
- `lurek_2d_pages/`: Separate repository for generated documentation pages; do not create or edit a root-level `pages/` directory.
- `work/`: Temporary notes, repros, and evidence.

## Rules
- Read root `AGENTS.md`, then nested contracts on the target path, then relevant skills/agents.
- CAG is active guidance: `AGENTS.md` contracts, `.codex/agents/`, `.codex/skills/`, and task skills.
- Use only registered agent profiles from `.codex/agents/`; do not invent role names in contracts or skills.
- RAG is first-pass discovery: use `tools/rag/query.py "<keywords>" --profile all|game|engine` before broad reads.
- MCP/repo CLI comes before ad hoc scripts when a matching tool exists.
- Prefer `tools/python.cmd path/to/script.py` for parsing, reporting, and automation on Windows.
- When a repo tool enforces a marker, path, registry, or file-shape contract, treat that parser as source of truth and keep the nearest `AGENTS.md` plus task skills synced.
- Keep captured output under 1000 lines.
- Keep scope narrow and never revert unrelated user changes.
- Write temporary files only under `work/`.

## Workflow
- Keep public API changes synced with specs, examples, and coverage.
- Leave proof when behavior changes.
- For behavior or contract changes, run as relevant: `cargo test`, `cargo clippy -- -D warnings`, `tools/python.cmd tools/validate/cag_validate.py`, `tools/python.cmd tools/audit/cag_link_check.py --strict`.
- Put scratch artifacts under `work/{short-chat-name}/`.
