# Codex Workspace Contract

This folder owns the Codex-specific workspace layer for `lurek_2D`.

## Purpose
- Keep Codex-local workflow assets separate from product source.
- Provide role runtime profiles, background skills, task-skills, and migration notes.
- Minimize duplication between root `AGENTS.md`, nested `AGENTS.md`, and local workflow assets.
- Keep the current CAG layer explicit: profile config, role overlays, reusable skills, and user-invoked task workflows.

## Structure
- `config.toml` registers Codex agent roles and references per-role config files.
- `agents/` contains runtime config overlays for the named Codex roles.
- `skills/` contains background procedural playbooks for the agent.
- `task-skills/` contains user-invoked workflows derived from legacy prompts.
- `migration/` contains source-to-target mapping and migration notes.
- `howto.md` is the repo-specific Codex setup guide distilled from official OpenAI docs.

## Local map
- `config.toml` is the first file to check when role registration, features, or routing feel wrong.
- `agents/` currently defines the active role set: `developer`, `tester`, `reviewer`, `architect`, `content`, `extension`, `builder`, and `manager`.
- `skills/` is the internal background layer; it already includes routing, validation, Rust, Lua, docs, testing, architecture, UI, and extension-oriented skills.
- `task-skills/` mirrors the old prompt catalog; use it for named create/review workflows, not as generic background context.
- `migration/` is for transition notes only; do not treat it as current operating policy if `.codex/` already has the replacement.

## Rules
- Background skills are internal-first and may be loaded by the agent when useful.
- Task-skills are user-facing workflows and should not be auto-selected as generic background skills.
- Agent role files in `agents/` are runtime configuration, not task instructions.
- Prefer linking to the nearest nested `AGENTS.md` instead of repeating folder rules here.
- Treat `.github/agents`, `.github/skills`, `.github/prompts`, and `copilot-instructions.md` as legacy reference during the migration period.

## How to route
- Use root `AGENTS.md` for repository-wide invariants.
- Use the nearest nested `AGENTS.md` for folder-specific rules.
- Use `agents/` for role runtime settings.
- Use `skills/` for background process knowledge.
- Use `task-skills/` when the user explicitly asks to run a named workflow.
- Use `howto.md` when changing how Codex itself should be configured for this repo.

## Notes
- `reviewer` and `manager` are role profiles, not folder-owned local agents.
- Review-only behavior must come from role settings, nested `AGENTS.md`, and review task-skills.
- Keep migration notes current when source mappings change.
