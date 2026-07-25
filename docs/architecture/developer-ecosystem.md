# Developer Ecosystem Architecture

## Purpose

Developer tooling is optional and remains outside the runtime binary. It consumes public APIs, generated metadata, debug protocols, or workspace files through explicit boundaries.

## Surfaces

| Surface | Location | Responsibility |
|---|---|---|
| VS Code extension | `lurek_2d_extension/` | Editing, commands, generated API data, debug/RAG clients |
| Workbench | `lurek_2d_workbench/` | Native project and editor workflows |
| CAG | `.codex/` and `AGENTS.md` | Agent routing, contracts, roles, reusable skills |
| RAG | `tools/rag/` | Local lexical retrieval over configured workspace sources |
| MCP | `tools/mcp/` and clients | Structured access to repo tools and diagnostics |
| Generated docs | `lurek_2d_pages/` | Public static output rebuilt from workspace sources |

None of these surfaces becomes an engine state authority.

## Extension And Workbench Boundaries

- The extension and Workbench own editor UI and project-service state.
- Runtime interaction uses documented commands, files, generated metadata, or debugbridge protocols.
- Editor-generated source is external input until the runtime parser validates it.
- The extension is built and tested in `lurek_2d_extension/`; Workbench behavior is owned by `lurek_2d_workbench/`.
- A tooling failure must not change the engine's public API contract or make a packaged game depend on an editor.

## CAG

- Root and nested `AGENTS.md` files own path-local invariants.
- `.codex/agents/` owns registered role overlays.
- `.codex/skills/` owns reusable workflows and routing predicates.
- `.codex/coverage.toml` maps required domains to their owners.
- Validators, not copied prose, define the accepted artifact shape.

See [Codex CAG System](cag-system.md).

## Local RAG

`tools/rag/rag.toml` is the hand-edited retrieval configuration. The tooling derives and validates its contract, builds versioned DuckDB lexical-index snapshots, and atomically selects the active generation. Queries use Unicode-aware lexical ranking, exact symbol/path boosts, source authority, generated-output penalties, and profile filters.

Readers continue to use the last valid snapshot while a new generation is built. A failed rebuild does not replace the active index.

## MCP Boundary

MCP tools adapt existing repo commands; they do not create a second implementation of docs, RAG, or audit policy. Inputs are validated, paths stay within the workspace, and mutating commands retain their existing preview/approval behavior.

## Failure Rules

- Missing optional tooling degrades developer experience, not runtime behavior.
- Stale generated metadata is detected through freshness/quality checks and regenerated from its owner.
- Invalid editor output is rejected by the consuming parser or validator.
- RAG failure falls back to direct repository inspection; stale snapshots are not presented as newly built state.
