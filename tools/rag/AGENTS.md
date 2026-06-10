# RAG Contract

Adds local rules for `tools/rag/`.

## Mission & Scope
- Own the repo search corpus, SQLite FTS5 index rules, and chunking parameters for RAG.
- Manage full-text queries, reading helpers, ranking, and source priority.
- Maintain indexes of specs, architecture notes, and code for developer tooling.

## Files
- `query.py`: Search and read script for natural-language keywords and chunk ids.
- `read.py`: Thin CLI for reading full chunks and adjacent context.
- `context.py`: Agent context bundle builder for task prompts.
- `eval.py`: Recall baseline runner for prompt-to-source tests.
- `build_index.py`: Script that indexes files into local SQLite FTS5.
- `rag.toml`: Configuration schema setting file filters, priority ranks, and chunk weights.
- `recall_baseline.json`: Prompt baseline that must return useful source hits.

## Rules
- Prioritize design specs and core system prompts over code examples and generated web pages.
- Use logic-based chunking such as class, function, or spec-section boundaries instead of raw byte slices.
- Keep the generated FTS database outside of version control; always treat it as local build-derived data.
- Rebuild the index after changing indexed sources or `tools/rag/rag.toml`.
- Prefer `context.py` or `query.py --include-content --neighbors 1` when the agent needs to read, not just locate, context.

## Workflow
- Rebuild the search corpus index by running `tools/python.cmd tools/rag/build_index.py`.
- Query the index to test rank ordering using `tools/python.cmd tools/rag/query.py "<terms>"`.
- Read full context using `tools/python.cmd tools/rag/read.py "<chunk-id>" --neighbors 1`.
- Validate recall with `tools/python.cmd tools/rag/eval.py`.

## References
- tools/rag/query.py
- tools/rag/read.py
- tools/rag/context.py
- tools/rag/eval.py
- tools/rag/build_index.py
- tools/rag/rag.toml

