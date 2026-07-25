# RAG Contract

## Mission & Scope
- Own repo search corpus rules, the DuckDB index, chunking, ranking, and recall tests.
- Keep retrieval useful for agents before broad file reads.

## Files
- `query.py`: Keyword search and chunk lookup.
- `read.py`: Full chunk plus neighbor reader.
- `context.py`: Agent context bundle builder.
- `eval.py`: Recall baseline runner.
- `build_index.py`: Local DuckDB index builder.
- `rag.toml`: File filters, priorities, and chunk weights.
- `recall_baseline.json`: Expected prompt-to-source hits.

## Rules
- Rank specs and core guidance above examples and generated pages.
- Chunk by logic boundaries such as functions, classes, or spec sections.
- Keep generated index data out of version control.
- Rebuild the index after changing indexed sources or `rag.toml`.
- Use `context.py` or `query.py --include-content --neighbors 1` when agents need readable context.

## Workflow
- Run `tools/python.cmd tools/rag/build_index.py`.
- Test ranking with `tools/python.cmd tools/rag/query.py "<terms>"`.
- Read context with `tools/python.cmd tools/rag/read.py "<chunk-id>" --neighbors 1`.
- Run `tools/python.cmd tools/rag/eval.py`.
