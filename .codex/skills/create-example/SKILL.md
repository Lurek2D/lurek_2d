---
name: create-example
description: "Load this skill when creating or modifying API examples under content/examples for a specific public lurek API. Skip it for full demos, snippets, engine implementation, or non-public internals."
---
# create-example

## Mission
- Create or modify concise runnable API examples that cover real public behavior.
- Keep `content/examples/` at 100% public API coverage with one owner block per API.

## When To Load
- Creating or modifying API examples under content/examples for a specific public lurek API.

## When To Skip
- Full demos, snippets, engine implementation, or non-public internals.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect existing examples and current API signatures before writing.
- Modify an existing module example file when it already owns the API; create a new file only for a new module owner.
- Keep one API = one exact `--@api:` marker = one immediately following runnable `do ... end` block.
- Keep the block self-contained, runnable, free of TODO stubs, and at least 5 relevant non-comment code lines.
- Do not add comments, setup, helpers, callbacks, tables, or reusable logic between a marker and `do`, or at top level outside marker-owned blocks.
- Show one concrete usage pattern with short context; do not turn the block into an exhaustive test.
- Keep the full module file runnable in Lurek without errors.
- Run example coverage before and after the change.
- Regenerate or validate docs only when example metadata changes.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- The target artifact was created or modified in the narrowest owning location.
- Existing content was preserved and updated when it already owned the behavior.
- The example layer keeps 100% coverage with no TODO stubs or thin placeholder blocks.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `content/AGENTS.md`, `content/examples/AGENTS.md`, `docs/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "content examples API coverage" --profile game --limit 10`, `tools/python.cmd tools/audit/example_coverage.py --module <module>`, `tools/python.cmd tools/validate/validate_example_coverage.py`
- Owner profile: `content`

## Common RAG Queries
- Start with: `content examples API coverage`, `example coverage content examples API`, `keyboard input lua API examples tests`
- Focus areas first: `content/examples/`, `docs/`, `tests/lua/`, `content/snippets/`
- Append the API or module name such as `input`, `render`, `tilemap`, `math` when narrowing

## References
- `contracts: content/AGENTS.md, content/examples/AGENTS.md, docs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content examples API coverage" --profile game --limit 10, tools/python.cmd tools/audit/example_coverage.py --module <module>, tools/python.cmd tools/validate/validate_example_coverage.py`
- `agent: content`
