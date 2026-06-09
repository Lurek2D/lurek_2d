# Lurek2D Repository Contract

This file is the always-loaded repository contract for Codex work in `lurek_2D`.

## Project identity
- Lurek2D is a Rust runtime for Lua game scripts.
- Target desktop only. No mobile. No WASM.
- Target 2D only. No 3D features.
- LuaJIT is the primary runtime. Lua 5.4 is fallback only.
- The public Lua surface is `lurek.*` and no other global namespace.

## CAG system
- In this repo, CAG means the active Codex guidance layer for the current task.
- The CAG set is:
- the root `AGENTS.md` plus any deeper `AGENTS.md` files on the path to the edited folder
- `.codex/config.toml` for feature toggles and role registration
- `.codex/agents/*.toml` for runtime role profiles
- `.codex/skills/*` for background procedural knowledge
- `.codex/task-skills/*` for explicit user-invoked workflows
- `.github/agents`, `.github/skills`, `.github/prompts`, and `.github/copilot-instructions.md` are migration-era reference only unless the current `.codex/` layer is missing something important.

## Repository layout
- `src/` contains Rust runtime and engine code.
- `src/lua_api/` contains Lua bindings and API docstrings only.
- `tests/` contains Lua and Rust tests.
- `docs/` contains specs, guides, and architecture docs.
- `docs/api/` contains generated API reference output.
- `content/` contains games, demos, and content-side examples.
- `library/` contains reusable Lua modules.
- `tools/` contains scripts, validation, packaging, and CI helpers.
- `extension/` contains the VS Code extension.
- `pages/` contains generated static-site output.
- `tests/rust/` contains Rust-side integration, unit, golden, and stress tests.
- `work/` contains temporary repros, reports, notes, and disposable artifacts.
- `.codex/` contains Codex-local agents, skills, task-skills, and migration notes.

## Global invariants
- Do not put `#[cfg(test)]` blocks in `src/`.
- Keep `mod.rs` files limited to exports and module-level docs.
- Keep business logic in `src/`; keep `src/lua_api/` thin.
- Do not edit `docs/api/lurek.lua` directly. Update `src/lua_api/` and regenerate.
- Do not silence warnings in `.vscode/settings.json`.
- Do not add `---@diagnostic disable` to Lua files to hide API issues.
- Prefer `any` in Rust bindings instead of unsafe Lua-side type casts.
- Keep public API changes synchronized with specs, examples, and coverage.

## Work rules
- Use `work/` for repro scripts, temporary plans, audit reports, and scratch artifacts.
- Keep `work/` disposable. Do not treat it as product source.
- Prefer the smallest artifact that proves the issue or captures the decision.
- Leave a command trail for validation when behavior changes.

## Rag rules
- Mandatory search step: before any broad filesystem search, or before reading many files to locate repository content or source-of-truth information, query `python tools/rag/query.py "<keywords>" --profile all|game|engine` first.
- If RAG does not answer the question, then fall back to targeted filesystem search.
- Rebuild the index with `python tools/rag/build_index.py` after changing indexed sources or `tools/rag/rag.toml`.

## Git discipline
- Keep scope narrow and tied to the requested task.
- Do not revert unrelated user changes.
- Prefer additive, reviewable edits over broad rewrites.
- When behavior changes, leave validation proof through commands, tests, or generated artifacts.

## Sync rules
- Rust module contract changes must update matching `docs/specs/<module>.md`.
- Lua API changes must update specs and regenerated API docs.
- Public API changes must update relevant examples, content, and library modules.
- New modules must add their spec entry and index updates.
- Setup and workflow changes must update contributor-facing docs.

## Quality gates
- Run `cargo test`.
- Run `cargo clippy -- -D warnings`.
- Run `python tools/validate/cag_validate.py`.
- Run `python tools/audit/cag_link_check.py --strict`.

## Discovery
- Start with nested `AGENTS.md` files in the folder you touch.
- Use `.codex/agents/` for role runtime profiles.
- Use `.codex/skills/` for background procedural skills.
- Use `.codex/task-skills/` for user-invoked workflows.
- Use `.codex/howto.md` as the project-specific Codex setup note distilled from the official OpenAI docs.
- Treat `docs/architecture/developer-ecosystem.md` as the canonical CAG doctrine; `docs/architecture/cag-system.md` is only a compatibility pointer.
- Treat `.github/` as legacy reference during the migration period.
