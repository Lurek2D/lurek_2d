# RAG Contract

Covers work under `tools/rag/`.

## Mission & Scope
- Own the repository's search corpus, vector indexing rules, and chunking parameters for retrieval-augmented generation.
- Manage similarity queries, search weighting, and source prioritization algorithms.
- Maintain indices of documentation specs, architecture notes, and codebases to feed developer tooling.

## Files
- `query.py`: Search execution script parsing natural language keywords and queries.
- `build_index.py`: Script indexing files and computing text embeddings.
- `rag.toml`: Configuration schema setting file filters, priority ranks, and chunk weights.

## Rules
- Prioritize design specs and core system prompts over code examples and generated web pages.
- Enforce logic-based file chunking (e.g., class, function, or spec section boundaries) rather than static byte-based slicing.
- Keep the generated vector database outside of version control; always treat it as local build-derived data.
- Automatically trigger index rebuilds when structural specification changes are introduced.

## Workflow
- Rebuild the search corpus index by running `python tools/rag/build_index.py`.
- Query the index to test rank ordering using `python tools/rag/query.py "<terms>"`.

## References
- tools/rag/query.py
- tools/rag/build_index.py
- tools/rag/rag.toml
