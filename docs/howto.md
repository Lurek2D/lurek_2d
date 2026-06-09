# Codex setup for `lurek_2D`

This note turns the official Codex docs into a project-specific setup guide for this repo.

## 1. What Codex reads first

- Codex reads `AGENTS.md` files before doing work.
- It builds one instruction chain per run:
  - global `~/.codex/AGENTS.override.md` or `~/.codex/AGENTS.md`
  - then project files from the repo root down to the current working directory
- Only one file per directory is used.
- Files closer to the current working directory override earlier guidance because they are appended later.
- The combined project-instruction payload stops at `project_doc_max_bytes` and defaults to `32 KiB`.

Implication for `lurek_2D`:

- Keep the root `AGENTS.md` focused on repo-wide invariants.
- Keep folder-level `AGENTS.md` files short and specific to that subtree.
- Put Codex workspace policy in `.codex/AGENTS.md`, not in product source.

## 2. What this repo already has

- `.codex/config.toml` keeps the repo-local performance and capability toggles explicit:
  - `model = "gpt-5.2-codex"`
  - `model_reasoning_effort = "medium"`
  - `approval_policy = "on-failure"`
  - `sandbox_mode = "workspace-write"`
  - `personality = "pragmatic"`
  - `web_search = "cached"`
  - `fast_mode = true`
  - `hooks = true`
  - `memories = true`
  - `multi_agent = true`
  - `personality = true`
  - `shell_snapshot = true`
  - `shell_tool = true`
  - `undo = true`
  - `child_agents_md = true`
- `.codex/config.toml` already registers these role profiles:
  - `developer`
  - `tester`
  - `reviewer`
  - `architect`
  - `content`
  - `extension`
  - `builder`
  - `manager`
- `.codex/config.toml` now also registers the repo-local MCP server `lurek_tools`.
- `.codex/agents/` is the runtime overlay location for those roles.
- `.codex/skills/` is the background skill library.
- `.codex/skills/` is for reusable skills and chat-loadable workflows.
- `.codex/AGENTS.md` explicitly treats `.github/agents`, `.github/skills`, `.github/prompts`, and `copilot-instructions.md` as legacy reference only.
- Project config should stay focused on defaults that apply to every role. Per-role differences such as sandbox level, approval policy, and reasoning effort belong in `.codex/agents/*.toml`.

## 3. Lurek-specific guardrails Codex should always obey

- Desktop only.
- 2D only.
- LuaJIT is the primary runtime; Lua 5.4 is fallback only.
- The public Lua surface is only `lurek.*`.
- Do not add `#[cfg(test)]` blocks under `src/`.
- Keep `mod.rs` files limited to exports and module-level docs.
- Keep business logic in `src/`; keep `src/lua_api/` thin.
- Do not edit `docs/api/lurek.lua` directly; update `src/lua_api/` and regenerate.
- Keep public API changes synchronized with specs, examples, and coverage.

For this repo, the highest-value Codex habit is to treat those rules as hard constraints, not suggestions.

## 4. How to use skills well

- Codex can activate skills explicitly or implicitly.
  - Explicit: `/skills` or `$skill` in CLI/IDE.
  - Implicit: Codex can choose a skill when the task matches the skill `description`.
- Keep skill descriptions short and precise.
  - Front-load the main use case and trigger words.
  - Narrow descriptions improve implicit matching.
- Codex only keeps a limited initial skill list in context.
  - The list is capped at roughly 2% of the context window, or about 8,000 characters when the window is unknown.
  - If there are many skills, Codex shortens descriptions first and may omit some skills.
- Skill folders should contain `SKILL.md` with frontmatter:
  - `name`
  - `description`
- Codex detects skill changes automatically.
  - If a change does not appear, restart Codex.
- If two skills share the same `name`, Codex does not merge them.

Practical advice for `lurek_2D`:

- Keep deep process knowledge in `.codex/skills/`.
- Keep small, reusable procedural playbooks there.
- If you need a distributable skill set, package it as a plugin instead of copying folders around.
- If a skill becomes noisy or too broad, disable it with `skills.config` instead of deleting it.

Note on discovery:

- The official Codex docs describe repository skill discovery under `.agents/skills` along the path from the current working directory up to the repo root.
- This repo also uses `.codex/skills` as its Codex-local workspace layer.
- If you want both mechanisms to see the same content, keep the two aligned or mirror the important items.

## 5. How to use subagents well

Built-in agents:

- `default`: general-purpose fallback agent
- `worker`: execution-focused agent for implementation and fixes
- `explorer`: read-heavy codebase exploration agent

Project custom agents:

- Put standalone TOML files under `.codex/agents/` for project-scoped agents.
- Put them under `~/.codex/agents/` for personal agents.
- One file defines one agent.

Required fields in each custom agent file:

- `name`
- `description`
- `developer_instructions`

Optional fields can inherit from the parent session when omitted:

- `nickname_candidates`
- `model`
- `model_reasoning_effort`
- `sandbox_mode`
- `mcp_servers`
- `skills.config`

Global agent limits in `[agents]`:

- `agents.max_threads` defaults to `6`
- `agents.max_depth` defaults to `1`
- `agents.job_max_runtime_seconds` is optional and falls back to the per-call default when unset

Important rule:

- Keep `agents.max_depth = 1` unless you truly need recursive delegation.
- Raising depth can increase token usage, latency, and local resource consumption quickly.

Practical advice for `lurek_2D`:

- Use `developer` for Rust runtime and Lua API binding work.
- Use `tester` for tests and harness registration.
- Use `architect` for specs and architecture docs.
- Use `content` for `content/` and `library/` Lua assets.
- Use `extension` for the VS Code extension.
- Use `builder` for tools, packaging, CI, and release work.
- Use `reviewer` for repo-wide validation and read-only checks.
- Use `manager` for long multi-step orchestration.

If a custom agent name matches a built-in agent, the custom agent wins.

## 5a. Repo-local MCP tools

This repo now exposes a local stdio MCP server from `tools/mcp/lurek_mcp_server.py`.

Primary tools:

- `rag_search`
- `rag_rebuild_index`
- `lua_api_health_suite`
- `quality_report`
- `doc_audit`
- `doc_coverage`
- `module_docstring_audit`
- `unit_test_api_coverage`
- `library_coverage`
- `lua_api_test_coverage`
- `lua_api_docstring_audit`
- `lua_example_coverage`
- `lua_spec_coverage`
- `lua_binding_validation`
- `repo_test_coverage`
- `cag_validate`
- `cag_link_check`
- `tool_registry_audit`
- `strict_api_check`
- `strict_api_check_math`

Use these when you want structured audit output inside Codex instead of raw CLI stdout.
The server shells out to the checked-in Python scripts under `tools/`, so the MCP view stays aligned with the repo source of truth.

## 6. Config file knobs that matter most

`~/.codex/config.toml` is where global Codex defaults live, unless `CODEX_HOME` changes the home directory.

Useful knobs for this repo:

- `skills.config`
  - Disable a skill without deleting it.
- `model`
  - Sets the default model for the CLI and IDE.
- `shell_environment_policy`
  - Use `inherit = all | core | none` to control baseline subprocess environment inheritance.
  - Use `set` for explicit environment overrides.
  - Use `include_only` to whitelist only the env vars you want Codex to keep.
- `approval_policy`
  - Controls when Codex pauses before running generated commands.
- `sandbox_mode`
  - Controls filesystem and network access while commands run.
- `model_reasoning_effort`
  - Raises or lowers how much reasoning the model spends on a turn.
- `web_search`
  - `cached` is the fast, safer default for local work; `live` fetches the most recent data.
- `personality`
  - Sets the default communication style for supported models.
- `show_raw_agent_reasoning`
  - Only enable if you have a reason to inspect raw reasoning output.
- `log_dir`
  - Sends Codex logs to a fixed directory and also enables the plaintext TUI log there.
- `--profile <name>`
  - Selects `~/.codex/<profile>.config.toml` when you need a separate global profile.

Advanced details that matter in this repo:

- Project-scoped `.codex/config.toml` files load from the repo root down to the current working directory, and the closest file wins on conflicts.
- Project config only applies when the project is trusted. If the project is untrusted, Codex skips local `.codex/` layers, including config, hooks, and rules.
- Relative paths inside project config resolve relative to the containing `.codex/` directory.
- Project config should not be used for provider or telemetry redirection knobs; keep those in user config.
- `project_root_markers` changes how Codex decides what counts as the project root. The default is to treat `.git` as the root marker.
- Custom model providers can be defined in config, but built-in provider IDs like `openai`, `ollama`, and `lmstudio` are reserved.

For `lurek_2D`, keep the repo config narrow:

- use `.codex/config.toml` for shared capability toggles and repo-local MCP servers
- keep role-specific sandbox, approval, and reasoning settings in `.codex/agents/*.toml`
- keep other experimental features disabled unless a task explicitly needs them
- prefer `web_search = "cached"` for speed unless you need fresh live results
- use `shell_snapshot = true` and `fast_mode = true` for the best routine command performance
- `memories = true` helps Codex keep relevant repo context across turns
- `undo = true` adds per-turn git ghost snapshots and makes iterative changes safer, at the cost of extra repo activity

## 6a. Hooks and config layers

- Codex can load hooks from either `hooks.json` files or inline `[hooks]` tables in `config.toml`.
- The main places to look are `~/.codex/hooks.json`, `~/.codex/config.toml`, `<repo>/.codex/hooks.json`, and `<repo>/.codex/config.toml`.
- Project-local hooks follow the same trust boundary as project config.
- If a single layer contains both `hooks.json` and inline `[hooks]`, Codex loads both and warns, so keep one representation per layer.
- For this repo, keep hook logic close to the layer it applies to and avoid duplicating the same rule in both global and project config.

## 7. Recommended repo layout for Codex work in Lurek

- Root `AGENTS.md`
  - Repository contract, invariants, and validation gates.
- Nested `AGENTS.md`
  - Folder-specific rules for `src/`, `src/lua_api/`, `tests/`, `docs/`, `content/`, `library/`, `tools/`, and `extension/`.
- `.codex/AGENTS.md`
  - Workspace policy for Codex-local files.
- `.codex/config.toml`
  - Role registration and feature toggles.
- `.codex/agents/*.toml`
  - Agent runtime overlays.
- `.codex/skills/*`
  - Internal background skills.
- `.codex/skills/*`
  - User-facing workflows.

This split is the main thing that keeps the repo clean:

- source code stays in product folders
- policy stays in `AGENTS.md`
- role behavior stays in `.codex/agents`
- reusable know-how stays in `.codex/skills`

## 8. Suggested workflow when starting a Lurek task

1. Open the repo at the correct root.
2. Let Codex load the root `AGENTS.md` and the nearest nested `AGENTS.md`.
3. Pick the right role:
   - `developer` for runtime or binding changes
   - `tester` for tests
   - `architect` for docs and contracts
   - `content` for examples and Lua modules
   - `extension` for editor integration
   - `builder` for tooling and CI
   - `reviewer` for validation
   - `manager` for orchestration
4. Keep task-specific instructions narrow.
5. Prefer the smallest skill or agent that solves the work.
6. Validate the change with the repo gates.
7. If the public API changes, update specs, examples, and regenerated docs.

## 9. Repo validation gates to keep in mind

- `cargo test`
- `cargo clippy -- -D warnings`
- `python tools/validate/cag_validate.py`
- `python tools/audit/cag_link_check.py --strict`

If a task changes behavior, leave a command trail that shows how it was validated.

## 10. Source URLs used for this note

- https://developers.openai.com/codex/guides/agents-md
- https://developers.openai.com/codex/skills
- https://developers.openai.com/codex/subagents
- https://developers.openai.com/codex/config-basic
- https://developers.openai.com/codex/config-advanced
- https://developers.openai.com/codex/config-reference
- https://developers.openai.com/codex/config-sample
