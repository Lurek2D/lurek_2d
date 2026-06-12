---
name: create-demo
description: "Load this skill when creating or modifying runnable Lua demo games under content/games with validation and smoke coverage. Skip it for single-file examples, engine internals, or pure library modules."
---
# create-demo

## Mission
- Create or modify runnable demo games that exercise real Lurek2D APIs and remain validator-safe.

## When To Load
- Creating or modifying runnable Lua demo games under content/games with validation and smoke coverage.

## When To Skip
- Single-file examples, engine internals, or pure library modules.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect the target demo folder and nearby demos before deciding create vs modify.
- Create a new `content/games/<name>/` only when no matching demo exists; otherwise modify the existing demo.
- Keep `main.lua`, config, assets, and README aligned with current demo conventions.
- Use real `lurek.*` calls and avoid placeholder gameplay.
- Run game validation and smoke tests for the changed demo.
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
- Contracts: `content/AGENTS.md`, `content/games/AGENTS.md`, `tests/lua_reorg/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "content games demo conventions" --profile game --limit 10`, `tools/python.cmd tools/validate/validate_game.py <demo-dir>`, `cargo test --test demo_smoke_tests`
- Owner profile: `content`

## Common RAG Queries
- Use when finding similar demos or owning game content:
  - `content games demo conventions`
  - `main.lua game demo content`
  - `layout sprite physics audio demo`
- Common areas to inspect after top hits:
  - `content/games/`
  - `content/layouts/`
  - `library/`
  - related `docs/` specs or examples

## References
- `contracts: content/AGENTS.md, content/games/AGENTS.md, tests/lua_reorg/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content games demo conventions" --profile game --limit 10, tools/python.cmd tools/validate/validate_game.py <demo-dir>, cargo test --test demo_smoke_tests`
- `agent: content`
