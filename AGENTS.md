# Repository Contract

- Lurek2D is a 1-Rust-binary runtime for Lua game scripts.
- The stack is Rust 1.78+, LuaJIT with mlua 0.9, wgpu 22, winit 0.30, rapier2d 0.32, rodio 0.17, and fontdue 0.9.
- This is AI-first project, coding is agent, human is review.

## Mission & Scope
- Keep repository-wide agent guidance concise, actionable, and consistent with the current codebase and docs.
- Define the default workflow and validation expectations that apply unless a deeper `AGENTS.md` adds subtree-specific rules.
- Point agents to canonical sources instead of duplicating large blocks of policy text across nested files.

## Notes
- Use Codex skills when they help.
- Use RAG before broad search or many-file reads. Query `tools/rag/query.py "<keywords>" --profile all|game|engine`, start from the top hits, then expand only if needed.
- Use CAG context every time: read root `AGENTS.md` first, then every nested `AGENTS.md` on the path to the target folder; also load relevant skills, agents, and local `.codex/` guidance before editing.
- Use MCP tools and repo CLI tools first when they fit the task; prefer tool-driven workflows over manual scanning or ad hoc scripts.
- Keep tool output short. Prefer commands and flags that limit output size in the current shell.
- When running scripts or commands that can print a lot, always cap captured output to at most 1000 lines before bringing it into context.
- Do not read huge files.
- Test and compile before done.
- Ask questions if instructions are unclear.
- Write simple English, bullet points, pragmatic.
- This file applies to the repo root and all child paths.
- Deeper nested `AGENTS.md` files enhance content for their subtree on the path.
- `.codex/` holds local CAG config, roles, skills, and task skills.
- Put every temporary task note, repro, export, or scratch file under `work/{short-chat-name}/`.

## Files
- `src/` rust source code engine.
- `docs/` docs, specs, api.
- `content/` lua based content, examples.
- `library/` pure lua extension to lurek.
- `tests/` tests framework.
- `tools/` mcp tools, cli scripts.
- `extension/` ms vs code extension.
- `pages/` github pages wiki.
- `ideas/` sandbox for ideas, roadmap.
- `work/` current work, temp files.

## Rules
- Keep public API changes synced with specs, examples, and coverage.
- Keep scope narrow and do not revert unrelated user changes.
- Leave validation proof when behavior changes.
- Run `cargo test`, `cargo clippy -- -D warnings`, `python tools/validate/cag_validate.py`, and `python tools/audit/cag_link_check.py --strict` when behavior or contracts change.

## Workflow
- Load instructions in this order: root `AGENTS.md`, then nested `AGENTS.md` files along the target path, then task-relevant skills/agents/CAG files.
- Start discovery with RAG, then read only the nearest source, spec, or docstrings needed for the task.
- Read the nearest source or spec before editing; prefer source docstrings over broad file loading.
- Use `work/{short-chat-name}/` for disposable repros, notes, generated files, and temporary task artifacts.
