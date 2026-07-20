---
name: create-rag-artifact
description: "Load this skill when creating or modifying RAG corpus configuration, indexing rules, retrieval ranking, or recall tests. Skip it for normal code search, one-off rg usage, or unrelated docs edits."
---

# create-rag-artifact

## Mission
- Create or modify RAG sources, ranking, and indexes so Codex retrieval finds canonical repo context.

## Domain Knowledge
- `tools/rag/rag.toml` controls inclusion, exclusions, source priorities, and chunk weights; `build_index.py` materializes those choices into the local untracked FTS5 database.
- Retrieval quality is a ranking contract, not an indexing-count goal: contracts/specs should outrank examples and generated pages for invariant queries, while content queries still need playable/game sources through the correct profile.
- Chunk boundaries preserve answerable units such as Markdown sections, functions, and classes. Oversized chunks dilute terms; undersized chunks separate a rule from its conditions and owning path.
- `recall_baseline.json` encodes prompt-to-source expectations and `eval.py` detects ranking regressions; a new corpus source is valuable only if representative queries retrieve it without displacing higher-authority owners.
- Query, read-with-neighbors, and context-bundle paths serve different consumers; changes must preserve chunk IDs/metadata needed to expand a search hit into coherent context.
- Governing-path metadata is part of retrieval authority: a result should carry the nearest applicable contract so an agent can distinguish project rules from illustrative content without a second broad search.
- Query normalization and AND/OR fallback affect precision differently for code symbols, paths, natural-language concepts, and hyphenated skill names; recall cases should cover each family rather than tuning only prose prompts.
- Exclusion rules protect both quality and index size by keeping build output, generated duplicates, vendor caches, logs, and temporary work from overwhelming source-owned guidance.

## Workflow
- Record baseline results for representative engine, game, CAG, and ambiguous queries, including rank, source kind, governing contract, chunk span, and whether neighbor expansion supplies the missing context.
- Change one retrieval dimension at a time—corpus selection, parser/chunk boundary, metadata, FTS query strategy, or rank weight—and add/adjust a recall case that captures the intended improvement without overfitting a single literal phrase.
- Rebuild the local index and inspect both target-query gains and authority inversions, especially generated pages outranking source docs, examples outranking specs, or broad CAG content masking the nearest skill/contract.
- Run `eval.py`, query/read/context smoke paths, and deterministic rebuild checks; keep the database untracked and document any remaining false-positive/recall trade-off in the changed configuration or baseline rationale.
- Inspect index statistics by source kind, profile, generated/vendor flags, and governing path after corpus changes; unexpected cardinality shifts often reveal a glob or parser error before recall failures become obvious.
- Test a near-miss query and an authority-conflict query alongside positive recall, verifying the change does not promote irrelevant token overlap or a lower-priority generated copy above its canonical source.

## References
- `contracts: .codex/AGENTS.md, tools/AGENTS.md, tools/rag/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "RAG rag.toml build_index query" --profile engine --limit 10, tools/python.cmd tools/rag/build_index.py, tools/python.cmd tools/rag/query.py "create-module skill" --profile all --limit 10, tools/python.cmd tools/rag/query.py "Codex AGENTS skills agents" --profile engine --limit 10`
- `agent: cag_architect`
- RAG: Start with: `RAG rag.toml build_index query`, `RAG read chunk neighbors full content`, `RAG stats chunks by kind source priorities`; Focus areas first: `.codex/`, `tools/rag/`, `tools/mcp/`, `tests/python/`, root `AGENTS.md`; For ranking issues, append the target source kind or path such as `skills`, `agents`, `pages`, `specs`, `tests`, `tools/rag`
