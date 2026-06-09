---
name: create-rag-artifact
description: "Create or update the RAG corpus, change retrieval sources or ranking, rebuild the index, and verify recall."
---
# create-rag-artifact

## Goal
- Configure Retrieval-Augmented Generation rules, specify new indexing targets, and regenerate the corpus.

## Required inputs
- New docs-general source or structural change
- Relevance weighting rules
- User must define what needs to be indexed or how retrieval should change
- Agent must collect RAG tooling configuration

## Profile hint
- `manager`

## Read these contracts
- `.codex/AGENTS.md`
- `tools/AGENTS.md`

## Read these contracts
- `.codex/AGENTS.md`
- `tools/AGENTS.md`
- `tools/rag/AGENTS.md`

## Steps
- Read the listed contracts before changing corpus coverage, ranking, or chunking.
- Inspect `tools/rag/rag.toml` and the current corpus before changing any source list or chunk sizing.
- Edit `tools/rag/rag.toml` or the indexing scripts under `tools/rag/` to ingest new sources, adjust chunk size, or tune BM25 weighting.
- Execute the local indexing tool: `python tools/rag/build_index.py` or `python tools/rag/build_index.py <targets...>` for a narrower rebuild. If the tool fails (exit code >0), fix the configuration or script logic.
- Run test queries with `python tools/rag/query.py "<query>" --profile all|game|engine --limit 10` against the rebuilt index and verify that the top results include the canonical source.
- If retrieval quality is still weak, iterate on chunking or source priority and rebuild again.

## Outputs
- Updated RAG configuration files
- Newly generated RAG index/corpus database

## Success criteria
- [ ] `python tools/rag/build_index.py` exits with code 0 (0 indexing failures).
- [ ] Query recall tests return >= 95% accuracy and surface the canonical source first.

## Stop conditions
- Indexing massive binary files or unhelpful raw logs.
- Over-chunking documents so context is lost.

## References
- `contracts: .codex/AGENTS.md, tools/AGENTS.md, tools/rag/AGENTS.md`
- `tools: RAG indexing scripts inside tools/rag/`
- `agent: CAG-Architect`


