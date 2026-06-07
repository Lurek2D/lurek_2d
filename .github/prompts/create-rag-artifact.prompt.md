---
name: create-rag-artifact
description: Create or update how RAG system works, new feature or something, reindex it.
---

# GOAL
- Configure Retrieval-Augmented Generation rules, specify new indexing targets, and regenerate the corpus.

# INPUTS REQUIRED
- New docs-general source or structural change
- Relevance weighting rules
= User must define what needs to be indexed or how retrieval should change
- Agent must collect RAG tooling configuration

# STEPS TO DO
1. Load skills: retrieval-architecture, cag-workflow.
2. Edit the RAG JSON or Python config files under `tools/rag/` to ingest new sources or adjust vector chunk sizes.
3. Execute the local indexing tool (e.g., `python tools/rag/reindex.py`). If the tool fails (exit code >0), fix the configuration syntax.
4. Run test queries against the new index to verify that >95% of expected chunks are accurately recalled.

# OUTPUTS PROVIDED
- Updated RAG configuration files
- Newly generated RAG index/corpus database

# SUCCESS CRITERIA
- `python tools/rag/reindex.py` exits with code 0 (0 indexing failures).
- Query recall tests return >= 95% accuracy.

# ANIT PATTERNS
- Indexing massive binary files or unhelpful raw logs.
- Over-chunking documents so context is lost.

# REFERENCES
- skills: retrieval-architecture, cag-workflow
- tools: RAG indexing scripts inside `tools/rag/`
- agent: CAG-Architect
