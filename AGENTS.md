# Repository Contract

Covers work across the whole repository.

## Mission & Scope
- Lurek2D is a desktop-only 2D Rust runtime for Lua game scripts.
- LuaJIT is primary; Lua 5.4 is fallback.
- Public Lua surface is `lurek.*`.
- This file applies to the repo root and all child paths. Deeper `AGENTS.md` files override it for their subtree. `.codex/` holds local CAG config, roles, skills, and task skills. `.github/` is migration-era reference only unless `.codex/` is missing the needed rule.

## Files
- `src/` is engine code; `src/lua_api/` is the binding edge.
- `docs/specs/` is the per-module contract layer.
- `content/`, `library/`, `tests/`, `tools/`, `extension/`, `pages/`, and `ideas/` are the main work areas.
- `work/` is disposable scratch.

## Rules
- Use the nearest nested `AGENTS.md` first.
- Keep `src/lua_api/` thin; keep business logic in `src/`.
- Do not edit generated docs directly.
- Do not add `#[cfg(test)]` to `src/`.
- Do not silence warnings in `.vscode/settings.json` or hide Lua API issues with `---@diagnostic disable`.
- Keep public API changes synced with specs, examples, and coverage.
- Before broad filesystem search or many-file reads, run `python tools/rag/query.py "<keywords>" --profile all|game|engine`.
- Rebuild the index after changing indexed sources or `tools/rag/rag.toml`.
- Run `cargo test`, `cargo clippy -- -D warnings`, `python tools/validate/cag_validate.py`, and `python tools/audit/cag_link_check.py --strict` when behavior or contracts change.
- Keep scope narrow and do not revert unrelated user changes.

## Workflow
- Read the nearest source or spec before editing.
- Use `work/` for disposable repros and notes.
- Leave validation proof when behavior changes.

## References
- `docs/architecture/developer-ecosystem.md`
- `docs/specs/`
- `.codex/config.toml`
- `.codex/agents/`
- `.codex/skills/`
- `.codex/task-skills/`
- `.codex/howto.md`
- `work/`
