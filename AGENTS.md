# Repository Contract

- Lurek2D is a 1-Rust-binary runtime for Lua game scripts.
- The stack is Rust 1.78+, LuaJIT with mlua 0.9, wgpu 22, winit 0.30, rapier2d 0.32, rodio 0.17, and fontdue 0.9.
- This is AI-first project, coding is agent, human is review.

## Mission & Scope
- Keep repo-wide agent guidance short, clear, and aligned with the codebase and docs.
- Define the default workflow and validation baseline unless a deeper `AGENTS.md` adds subtree rules.
- Point to canonical sources instead of repeating policy in nested files.

## Notes
- Use Codex skills when they help.
- Use RAG before broad search or many-file reads: `tools/rag/query.py "<keywords>" --profile all|game|engine`. Start from top hits, then expand only if needed.
- Use CAG context every time: read root `AGENTS.md`, then nested `AGENTS.md` files on the target path, then relevant skills, agents, and local `.codex/` guidance.
- Use MCP tools and repo CLI first when they fit. Prefer tool workflows over ad hoc scripts.
- Prefer Python scripts run from the terminal and inspect their output before falling back to shell-specific commands.
- Prefer `python path/to/script.py` over PowerShell one-liners for search, parsing, reporting, and automation work when both are viable.
- Treat PowerShell or command prompt as thin launchers for tools; avoid embedding non-trivial workflow logic in shell commands when a short Python script is clearer.
- Keep tool output short. Use flags that limit output.
- Cap captured output at 1000 lines.
- Do not read huge files.
- Test and compile before done.
- Ask questions if instructions are unclear.
- Write simple English. Use short pragmatic bullets.
- This file applies to the repo root and all child paths.
- Deeper `AGENTS.md` files add subtree rules.
- `.codex/` holds local CAG config, roles, skills, and task skills.
- Put temp notes, repros, exports, and scratch files under `work/{short-chat-name}/`.

## Files
- `src/` Rust engine source.
- `docs/` docs, specs, API.
- `content/` Lua content and examples.
- `library/` pure Lua extensions.
- `tests/` test framework.
- `tools/` MCP tools and CLI scripts.
- `extension/` VS Code extension.
- `pages/` GitHub Pages site.
- `ideas/` sandbox and roadmap.
- `work/` temp work files.

## Rules
- Keep public API changes synced with specs, examples, and coverage.
- Keep scope narrow and do not revert unrelated user changes.
- Leave validation proof when behavior changes.
- Run `cargo test`, `cargo clippy -- -D warnings`, `tools/python.cmd tools/validate/cag_validate.py`, and `tools/python.cmd tools/audit/cag_link_check.py --strict` when behavior or contracts change.

## Workflow
- Load instructions in this order: root `AGENTS.md`, then nested `AGENTS.md` files along the target path, then task-relevant skills/agents/CAG files.
- Start discovery with RAG, then read only the nearest source, spec, or docstrings needed for the task.
- Read the nearest source or spec before editing; prefer source docstrings over broad file loading, and for terminal automation prefer adding or running a small Python script and reading its results instead of composing complex PowerShell pipelines.
- Use `work/{short-chat-name}/` for repros, notes, generated files, and temp artifacts.

