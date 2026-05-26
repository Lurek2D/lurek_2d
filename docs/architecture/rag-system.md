# Lurek2D RAG Architecture

## TL;DR

- Lurek2D utilizes a fully local, zero-external-dependency Retrieval-Augmented Generation (RAG) system built entirely around Python and SQLite's FTS5 extension.

 This system provides exceptionally fast, token-efficient knowledge retrieval for both human developers and AI agents.

## Core Components

1. **`rag_index.db`**: An SQLite database located at `tools/rag/rag_index.db`. It contains an FTS5 virtual table called `documents`.
2. **`rag.toml`**: The central configuration file at `tools/rag/rag.toml`, defining chunk limits, search weights, and target paths.
3. **`build_index.py`**: The indexer. It traverses targeted directories, chunks source code/markdown, and importantly, reads `logs/data/lua_api_data.json` to inject highly structured API definitions.
4. **`query.py`**: The search engine. It uses the BM25 algorithm to execute queries against the index.

## Profiles

The RAG system implements semantic profiles to prevent noisy search results. When querying, you can specify a profile to constrain the results:
* **Game**: Restricts search to `content/`, `library/`, `docs/`, and structured `API` definitions. Ideal for learning how to use Lurek2D.
* **Engine**: Restricts search to `src/`, `tests/`, `.github/`, and `tools/`. Ideal for internal architecture or bug-fixing queries.
* **All**: Searches the entire codebase.

## VS Code Integration

The Lurek2D VS Code extension acts as the primary interface for the RAG system.
* **Auto-Indexing**: A file watcher listens for changes to `.lua`, `.rs`, and `.md` files. On save, it invokes a background update, ensuring the SQLite index is always perfectly in sync without requiring a full rebuild.
* **Human Webview**: The `Lurek2D: Search Knowledge Base (RAG)` command opens a dedicated UI panel. Developers can query the index, select a profile, and click directly into source files.
* **Agent MCP**: The extension hosts an MCP server that exposes two core tools to AI agents: `lurek2d.ragSearch` and `lurek2d.ragBuildIndex`.

## Rationale: Why FTS5?

We deliberately avoided massive Python dependencies (like PyTorch or `sentence-transformers`) to maintain Lurek2D's lightweight philosophy. SQLite FTS5 provides instantaneous full-text search out of the box with standard Python 3.11+.

To compensate for the lack of semantic "vector" search, we artificially boost the BM25 weighting of the `title` column and explicitly sort `type='api'` rows to the top. This ensures that a query for `lurek.render.rectangle` immediately returns the exact, structured API definition rather than a test file that happens to use the term frequently.
