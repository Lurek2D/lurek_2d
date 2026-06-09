# Codex workspace

This folder is the active Codex-local setup for `lurek_2D`.

Current contents:
- `AGENTS.md` for Codex workspace rules.
- `config.toml` for Codex role registration.
- `agents/` for per-role runtime overlays.
- `skills/` for background procedural skills and reusable workflows.
- `migration/` for old-to-new mapping notes.

Project MCP:
- `config.toml` also registers the repo-local `lurek_tools` MCP server.
- That server exposes RAG search/reindex plus docs, examples, specs, tests, and repo quality gates from `tools/mcp/lurek_mcp_server.py`.

Legacy note:
- `.github/agents`, `.github/prompts`, and `.github/skills` remain as migration reference only.
