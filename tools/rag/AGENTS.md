# RAG Contract

This file adds local rules for work under `tools/rag/`.

## Mission
- Own retrieval corpus shape, indexing rules, source priority, and freshness handling for the repository RAG system.

## Local rules
- Query first when canonical repository context should come from indexed sources rather than ad hoc browsing.
- Keep source priority aligned with repository authority: binding constraints, CAG layer, module specs, architecture docs, contributor docs, then examples and generated outputs.
- Prefer ownership-sized chunks over arbitrary byte slicing. Whole contracts, spec sections, and docstring units are better retrieval boundaries than fixed-size fragments.
- Generated outputs should rank below their editable sources. Retrieval should steer edits back to the file that actually governs the contract.
- Freshness rules must account for source-generated relationships such as Lua API bindings driving generated docs or specs.
- Retrieval evaluation should test contract questions, workflow questions, ownership questions, and stale-content traps instead of only keyword matches.
- Treat the index database as derived data. Change configuration or source files, then rebuild.

## Workflow
- Inspect `rag.toml` and the current source set before changing corpus coverage, chunking, or ranking behavior.
- Rebuild the index after source or config changes, then verify with representative queries that the canonical source wins.

## References
- `tools/rag/query.py`
- `tools/rag/build_index.py`
- `tools/rag/rag.toml`
- `docs/specs/`
- `docs/architecture/`
