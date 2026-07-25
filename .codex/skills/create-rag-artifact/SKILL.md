---
name: create-rag-artifact
description: "Load this skill when creating or modifying RAG corpus configuration, indexing rules, retrieval ranking, or recall tests. Skip it for normal code search, one-off rg usage, or unrelated docs edits."
---

# create-rag-artifact

## Mission
- Create or modify RAG sources, ranking, and indexes so Codex retrieval finds canonical repo context.

## Domain Knowledge
- RAG source rules live in `tools/rag/rag.toml`.
- `build_index.py` builds the local DuckDB index.
- The local index is not a source file.
- `query.py` runs keyword and ranked retrieval.
- `read.py` returns a chunk with neighbors.
- `context.py` builds an agent context bundle.
- `tools/mcp/lurek_mcp_server.py` exposes repository RAG as MCP tools.
- `rag_context_bundle` retrieves full, deduplicated chunks for a task prompt.
- `rag_read` reads one chunk and optional neighbors.
- `rag_stats` reports index counts and largest indexed paths.
- `rag_eval` runs the recall baseline through MCP.
- `rag_rebuild_index` rebuilds the full index or selected repo-relative targets.
- Repository MCP tools are preferred over direct CLI calls when the same operation is available.
- `recall_baseline.json` stores query-to-source expectations.
- `eval.py` checks recall expectations.
- Engine, game, and all profiles have different source needs.
- Contracts and specs have higher authority than examples and generated pages.
- Generated copies must not outrank their source owners.
- Markdown sections, functions, and classes are chunk boundaries.
- Each chunk stores source kind and generated or vendor flags.
- Governing-path metadata points to the nearest contract.
- Build output, vendor caches, logs, and temporary work are excluded.
- Code symbols, paths, natural language, and hyphenated skill names need recall cases.
- `rag.toml` limits chunks to 1800 characters, keeps chunks of at least 120 characters, and skips files above 2,000,000 bytes.
- Indexed extensions are explicitly allowlisted; binary assets are not chunked.
- Title matches use a higher BM25 weight than path or body matches.
- `recall_baseline.json` is test input and is intentionally excluded from its own index.
- Query ranking demotes generated and vendor chunks before applying source priority.
- Context bundles run separate searches for API use, module use, navigation, tools, and related sources.
- Governing contracts are added to a context bundle even when the first lexical results are implementation files.

## Workflow
1. Read `.codex/AGENTS.md` and `tools/rag/AGENTS.md`.
2. Use `rag_context_bundle` to record current target and neighboring results.
3. Record rank, source kind, path, chunk, and governing contract.
4. Classify the change as corpus, chunking, metadata, query, or ranking.
5. Change one retrieval dimension.
6. Add or update a recall case for the intended behavior.
7. Use `rag_rebuild_index` to rebuild the full index or changed targets.
8. Run the target query in the correct profile.
9. Run a near-miss query.
10. Run an authority-conflict query.
11. Check that source owners outrank generated copies.
12. Test `rag_read` and `rag_context_bundle`.
13. Use `rag_eval` to run the recall suite.
14. Use `rag_stats` to check source kinds, flags, and largest paths.
15. Confirm the CLI equivalents through `query.py`, `read.py`, and `context.py`.
16. Rebuild again and check deterministic results.
17. Keep the generated database untracked.

## References
- `contracts: .codex/AGENTS.md, tools/AGENTS.md, tools/rag/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "RAG rag.toml build_index query" --profile engine --limit 10, tools/python.cmd tools/rag/build_index.py, tools/python.cmd tools/rag/query.py "create-module skill" --profile all --limit 10, tools/python.cmd tools/rag/query.py "Codex AGENTS skills agents" --profile engine --limit 10`
- `agent: cag_architect`
- RAG: `AGENTS skill workflow MCP tool RAG`; inspect `tools/mcp/lurek_mcp_server.py`, `tools/rag/`, the target source kind, its governing contract, and relevant `tests/python/` coverage.
