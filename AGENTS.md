# Repository Contract

- Lurek2D is one Rust binary that runs Lua game scripts.
- Stack: Rust 1.78+, LuaJIT/mlua 0.9, wgpu 22, winit 0.30, rapier2d 0.32, rodio 0.17, fontdue 0.9.
- AI writes code; human reviews.

## Mission & Scope
- This file applies to the whole repo unless a deeper `AGENTS.md` adds local rules.
- Keep guidance short. Put durable rules in the nearest owning contract.
- Use `.codex/` for local CAG config, roles, and skills.

## Files
- `src/`: Rust engine and Lua bindings.
- `content/`: Lua examples, demos, layouts, snippets.
- `library/`: Pure Lua packages.
- `tests/`: Lua, Rust, smoke, golden, and evidence tests.
- `docs/`, `pages/`: Source docs and generated site.
- `tools/`: Repo scripts, generators, validators.
- `extension/`: VS Code extension.
- `work/`: Temporary notes, repros, and evidence.

## Rules
- Read root `AGENTS.md`, then nested contracts on the target path, then relevant skills/agents.
- CAG is active guidance: `AGENTS.md` contracts, `.codex/agents/`, `.codex/skills/`, and task skills.
- RAG is first-pass discovery: use `tools/rag/query.py "<keywords>" --profile all|game|engine` before broad reads.
- MCP/repo CLI comes before ad hoc scripts when a matching tool exists.
- Prefer `python path/to/script.py` for parsing, reporting, and automation.
- Keep output short; cap captured output at 1000 lines.
- Do not read huge files unless needed.
- Keep scope narrow and never revert unrelated user changes.
- Ask if instructions are unclear.
- Write simple English and short bullets.
- NEVER write any temp files outside of `work/` folder. NEVER !!

## Workflow
- Keep public API changes synced with specs, examples, and coverage.
- Leave proof when behavior changes.
- For behavior or contract changes, run as relevant: `cargo test`, `cargo clippy -- -D warnings`, `tools/python.cmd tools/validate/cag_validate.py`, `tools/python.cmd tools/audit/cag_link_check.py --strict`.
- Put scratch artifacts under `work/{short-chat-name}/`.
