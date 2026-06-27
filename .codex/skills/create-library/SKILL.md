---
name: create-library
description: "Load this skill when creating or modifying pure Lua library modules under library with tests and docs. Skip it for engine Rust modules, content demos, or one-off snippets."
---
# create-library

## Mission
- Create or modify pure Lua library modules that are reusable, documented, and covered.

## When To Load
- Creating or modifying pure Lua library modules under library with tests and docs.

## When To Skip
- Engine Rust modules, content demos, or one-off snippets.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect the target `library/<name>/` and existing library conventions first.
- Modify an existing library when it owns the requested API; new libraries need `library/<name>/init.lua`, `library/<name>/example.lua`, and `tests/lua/library/test_<name>_library.lua`.
- Keep the public Lua interface small, documented with LDoc-style `-- @...` or `--- @...` annotations, and returned from `init.lua` without raw global writes.
- Add or update Lua tests and examples that exercise real behavior.
- Run library validation and coverage before finishing.
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
- Contracts: `library/AGENTS.md`, `tests/lua/AGENTS.md`, `content/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "library Lua module conventions" --profile game --limit 10`, `tools/python.cmd tools/audit/library_coverage.py`, `tools/python.cmd tools/validate/validate_library.py --library <name>`
- Owner profile: `content`

## Common RAG Queries
- Use when finding existing Lua helper modules and tests:
  - `library Lua module conventions`
  - `require library module pattern`
  - `tests lua helper assert fixture`
- Common areas to inspect after top hits:
  - `library/`
  - `tests/lua/`
  - `content/examples/`
  - `docs/` API references

## References
- `contracts: library/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "library Lua module conventions" --profile game --limit 10, tools/python.cmd tools/audit/library_coverage.py, tools/python.cmd tools/validate/validate_library.py --library <name>`
- `agent: content`
