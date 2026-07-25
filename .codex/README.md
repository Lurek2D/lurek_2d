# Codex workspace

This folder is the active Codex-local setup for `lurek_2D`.

## What lives here

- `AGENTS.md` owns workspace-only CAG rules.
- `config.toml` owns shared repo-local Codex defaults, feature toggles, MCP registration, and the role registry.
- `agents/` stores per-role runtime overlays.
- `skills/` stores reusable workflows and background playbooks.
- `coverage.toml` maps domains to their owning contracts and skills.
- `migration/` stores old-to-new CAG mapping notes and is not active guidance.

## How instruction loading works

- Codex reads global user guidance first, then project `AGENTS.md` files from the repo root down to the working directory.
- The nearest `AGENTS.md` owns path-local rules; keep root contracts broad and nested contracts narrow.
- Put product invariants in repo contracts, not in `.codex/`.
- Use `.codex/AGENTS.md` for CAG process and workspace policy only.

## How to use skills and roles

- Skills can load explicitly or implicitly from their frontmatter `description`.
- Keep skill descriptions narrow so implicit routing stays predictable.
- Put durable path rules in the nearest `AGENTS.md`; put reusable procedures in `.codex/skills/`.
- Active skills should stay compact: Mission, Domain Knowledge, Workflow, and References only.
- Role overlays live in `.codex/agents/*.toml` and must match the registered `[agents.<name>]` entry in `.codex/config.toml`.
- Choose the narrowest role that owns the target surface, and keep subagent depth shallow unless the task clearly needs delegation.

## Config and hooks

- Global defaults live in `~/.codex/config.toml`; repo-local shared defaults live in `.codex/config.toml`.
- Project config and hooks load only when the repo is trusted.
- Keep shared feature toggles, MCP servers, and repo-wide defaults in `.codex/config.toml`.
- Keep per-role sandbox, approval, reasoning, and verbosity choices in `.codex/agents/*.toml`.
- Hooks can live in `hooks.json` or inline `[hooks]` tables, but avoid duplicating the same rule in both forms within one layer.
- Keep provider, telemetry, and other user-machine-specific settings in user config rather than the shared repo layer.

## Local MCP and validation

- `.codex/config.toml` registers the repo-local `lurek_tools` MCP server from `tools/mcp/lurek_mcp_server.py`.
- Use that MCP surface when you want structured RAG, docs, coverage, or quality-gate output inside Codex.
- For direct CLI validation, run `tools/python.cmd tools/validate/cag_validate.py`.
- Run `tools/python.cmd tools/audit/cag_link_check.py --strict` after path or link changes in CAG artifacts.

## Optional local runtime

- `tools/python.cmd tools/dev/headroom_runtime.py install` creates a workspace-local Headroom runtime under `work/headroom/`.
- Use `wrap-codex`, `proxy`, or `mcp-serve` from that helper when you want local experimentation without baking optional runtime settings into shared config.

## Legacy note

- The old repository-hosted Copilot role, prompt, and skill directories are legacy reference only; active guidance lives under `.codex/`.
