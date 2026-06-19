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

Optional Headroom:
- Use `tools/python.cmd tools/dev/headroom_runtime.py install` to create a workspace-local Headroom runtime under `work/headroom/`.
- If Headroom build support lags behind the active Python, rerun install with `--bootstrap-python <path-to-python313.exe>`.
- Use `tools/python.cmd tools/dev/headroom_runtime.py wrap-codex` to launch Codex through Headroom with `HEADROOM_OUTPUT_SHAPER=1`.
- Use `tools/python.cmd tools/dev/headroom_runtime.py proxy` or `mcp-serve` when you want proxy or MCP mode without modifying active `config.toml`.

Legacy note:
- `.github/agents`, `.github/prompts`, and `.github/skills` remain as migration reference only.
