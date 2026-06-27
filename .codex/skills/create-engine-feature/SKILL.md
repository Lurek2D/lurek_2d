---
name: create-engine-feature
description: "Load this skill when creating or modifying Rust engine features that may touch modules, Lua API, specs, examples, and tests end to end. Skip it for docs-only reviews, content-only demos, or VS Code extension work."
---
# create-engine-feature

## Mission
- Deliver engine feature changes end to end while keeping public Lua contracts, specs, examples, and tests in sync.

## When To Load
- Creating or modifying Rust engine features that may touch modules, Lua API, specs, examples, and tests end to end.

## When To Skip
- Docs-only reviews, content-only demos, or VS Code extension work.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect the existing module, spec, Lua API wrapper, examples, and tests before choosing create vs modify.
- Use `create-module` only when a new top-level module is needed; otherwise update the existing owner module.
- Change Lua API, specs, examples, and tests only when public behavior changes, using tool-enforced example and Lua test marker formats.
- For public API changes, regenerate Lua API data before writing example `--@api:` blocks or unit-test `-- @covers` markers.
- Keep `src/lua_api/` thin and put business logic in the Rust domain module.
- Run cargo, docs generation, and CAG validation appropriate to the changed surface.
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
- Contracts: `src/AGENTS.md`, `src/lua_api/AGENTS.md`, `tests/AGENTS.md`, `content/examples/AGENTS.md`, `docs/specs/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "engine feature src lua_api specs tests" --profile engine --limit 10`, `cargo test`, `cargo clippy -- -D warnings`, `tools/python.cmd tools/gen_all_docs.py`, `tools/python.cmd tools/validate/cag_validate.py`
- Owner profile: `developer`

## Common RAG Queries
- Start with: `engine feature src lua_api specs tests`, `Rust engine module lua_api docs specs`, `review audits quality performance specs tests`
- Focus areas first: `src/`, `src/lua_api/`, `tests/`, `content/examples/`, `docs/specs/`
- For a behavior change, append the feature or module name before broad reads

## References
- `contracts: src/AGENTS.md, src/lua_api/AGENTS.md, tests/AGENTS.md, content/examples/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "engine feature src lua_api specs tests" --profile engine --limit 10, cargo test, cargo clippy -- -D warnings, tools/python.cmd tools/gen_all_docs.py, tools/python.cmd tools/validate/cag_validate.py`
- `agent: developer`
