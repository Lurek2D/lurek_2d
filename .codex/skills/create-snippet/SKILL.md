---
name: create-snippet
description: "Load this skill when creating or modifying Lua snippets and generated VS Code snippet output. Skip it for full examples, docs pages, or extension features unrelated to snippets."
---
# create-snippet

## Mission
- Create or modify snippets that reflect idiomatic public API usage and generated editor output.

## When To Load
- Creating or modifying Lua snippets and generated VS Code snippet output.

## When To Skip
- Full examples, docs pages, or extension features unrelated to snippets.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect existing snippets, current API docs, and generated extension output before editing.
- Modify an existing snippet when it owns the use case; create only for uncovered high-value API usage.
- Follow snippet template marker order and naming conventions.
- Regenerate VS Code snippets when inventory changes.
- Validate snippets and rerun coverage.
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
- Contracts: `content/snippets/AGENTS.md`, `docs/AGENTS.md`, `extension/vscode/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "content snippets API usage" --profile game --limit 10`, `tools/python.cmd tools/audit/snippet_coverage.py`, `tools/python.cmd tools/snippets/gen_vscode_snippets.py`, `tools/python.cmd tools/validate/validate_snippets.py`
- Owner profile: `doc_writer`

## Common RAG Queries
- Use when locating snippet sources and generated output:
  - `content snippets API usage`
  - `snippets json generated extension`
  - `template placeholder trigger description`
- Common areas to inspect after top hits:
  - `extension/`
  - snippet source files in `tools/` or `docs/`
  - generated snippet output
  - user-facing examples

## References
- `contracts: content/snippets/AGENTS.md, docs/AGENTS.md, extension/vscode/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content snippets API usage" --profile game --limit 10, tools/python.cmd tools/audit/snippet_coverage.py, tools/python.cmd tools/snippets/gen_vscode_snippets.py, tools/python.cmd tools/validate/validate_snippets.py`
- `agent: doc_writer`
