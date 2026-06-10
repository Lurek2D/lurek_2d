---
name: create-module
description: "Load this skill when creating or modifying Rust engine modules in src with Lua API, specs, examples, and tests. Skip it for small docs-only updates, pure Lua content, or VS Code extension work."
---
# create-module

## Mission
- Create or modify Rust engine modules while keeping public Lua API, specs, examples, and tests aligned.

## When To Load
- Creating or modifying Rust engine modules in src with Lua API, specs, examples, and tests.

## When To Skip
- Small docs-only updates, pure Lua content, or VS Code extension work.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect existing `src/<module>/`, `src/lua_api/`, specs, examples, and tests before deciding create vs modify.
- Create a new top-level module only when no current module owns the behavior.
- Keep `src/lua_api/` registration-only and implement logic in the domain module.
- Update specs, generated API docs, Lua tests, and examples when public behavior changes.
- Run docs generation, cargo tests, clippy, and CAG validation.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- The target artifact was created or modified in the narrowest owning location.
- Existing content was preserved and updated when it already owned the behavior.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `src/AGENTS.md`, `src/lua_api/AGENTS.md`, `docs/architecture/AGENTS.md`, `docs/specs/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "Rust engine module lua_api docs specs" --profile engine --limit 10`, `tools/python.cmd tools/gen_all_docs.py`, `cargo test`, `cargo clippy -- -D warnings`, `tools/python.cmd tools/validate/cag_validate.py`
- Owner profile: `developer`

## Common RAG Queries
- Start with: `Rust engine module lua_api docs specs`, `engine feature src lua_api specs tests`, `input module spec keyboard mouse gamepad touch`
- Focus areas first: `src/`, `src/lua_api/`, `docs/specs/`, `docs/modules/`, `tests/`
- If the task is module-specific, append the module name or public API path such as `render`, `input`, `lurek.render`, `lurek.input`

## References
- `contracts: src/AGENTS.md, src/lua_api/AGENTS.md, docs/architecture/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Rust engine module lua_api docs specs" --profile engine --limit 10, tools/python.cmd tools/gen_all_docs.py, cargo test, cargo clippy -- -D warnings, tools/python.cmd tools/validate/cag_validate.py`
- `agent: developer`
