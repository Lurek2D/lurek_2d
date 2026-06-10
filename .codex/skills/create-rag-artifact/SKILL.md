---
name: create-rag-artifact
description: "Load this skill when creating or modifying RAG corpus configuration, indexing rules, retrieval ranking, or recall tests. Skip it for normal code search, one-off rg usage, or unrelated docs edits."
---
# create-rag-artifact

## Mission
- Create or modify RAG sources, ranking, and indexes so Codex retrieval finds canonical repo context.

## When To Load
- Creating or modifying RAG corpus configuration, indexing rules, retrieval ranking, or recall tests.

## When To Skip
- Normal code search, one-off rg usage, or unrelated docs edits.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect `tools/rag/rag.toml`, `build_index.py`, `query.py`, and current recall before changing configuration.
- Modify existing source lists, chunking, or ranking before adding new indexing logic.
- Rebuild the index after source or ranking changes.
- Run recall queries for `.codex/skills`, `.codex/AGENTS.md`, and active `.codex/agents/*.toml`.
- Treat `tools/rag/rag_index.db` as generated local data.
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
- Contracts: `.codex/AGENTS.md`, `tools/AGENTS.md`, `tools/rag/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "RAG rag.toml build_index query" --profile engine --limit 10`, `tools/python.cmd tools/rag/build_index.py`, `tools/python.cmd tools/rag/query.py "create-module skill" --profile all --limit 10`, `tools/python.cmd tools/rag/query.py "Codex AGENTS skills agents" --profile engine --limit 10`
- Owner profile: `cag_architect`

## Common RAG Queries
- Start with: `RAG rag.toml build_index query`, `RAG read chunk neighbors full content`, `RAG stats chunks by kind source priorities`
- Focus areas first: `.codex/`, `tools/rag/`, `tools/mcp/`, `tests/python/`, root `AGENTS.md`
- For ranking issues, append the target source kind or path such as `skills`, `agents`, `pages`, `specs`, `tests`, `tools/rag`

## References
- `contracts: .codex/AGENTS.md, tools/AGENTS.md, tools/rag/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "RAG rag.toml build_index query" --profile engine --limit 10, tools/python.cmd tools/rag/build_index.py, tools/python.cmd tools/rag/query.py "create-module skill" --profile all --limit 10, tools/python.cmd tools/rag/query.py "Codex AGENTS skills agents" --profile engine --limit 10`
- `agent: cag_architect`
