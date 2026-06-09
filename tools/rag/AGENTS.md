# RAG Contract

Covers work under `tools/rag/`.

## Mission
- Own retrieval corpus shape, indexing rules, source priority, and freshness handling for the repository RAG system.

## Scope
- `tools/rag/` retrieval and indexing code.

## Local map
- `query.py` is the query entry point.
- `build_index.py` rebuilds the index.
- `rag.toml` defines corpus and ranking config.
- `docs/specs/` and `docs/architecture/` are the main source groups.

## Rules
- Query first when canonical repository context should come from indexed sources.
- Keep source priority aligned with repository authority: binding constraints, CAG layer, module specs, architecture docs, contributor docs, then examples and generated outputs.
- Prefer ownership-sized chunks over arbitrary byte slicing.
- Generated outputs should rank below editable sources.
- Freshness rules must account for source-generated relationships such as Lua API bindings driving generated docs or specs.
- Retrieval evaluation should test contract, workflow, ownership, and stale-content traps.
- Treat the index database as derived data.

## Workflow
- Inspect `rag.toml` and the current source set before changing corpus coverage, chunking, or ranking behavior.
- Rebuild the index after source or config changes, then verify with representative queries that the canonical source wins.

## References
- `tools/rag/query.py`
- `tools/rag/build_index.py`
- `tools/rag/rag.toml`
- `docs/specs/`
- `docs/architecture/`
