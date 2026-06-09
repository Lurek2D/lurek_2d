# Codex Workspace Contract

This folder owns the Codex-specific workspace layer for `lurek_2D`.

## Purpose
- Keep Codex-local workflow assets separate from product source.
- Provide role runtime profiles, background skills, and migration notes.
- Minimize duplication between root `AGENTS.md`, nested `AGENTS.md`, and local workflow assets.
- Keep the current CAG layer explicit: profile config, role overlays, reusable skills, and migration notes.

## Structure
- `config.toml` registers Codex agent roles and references per-role config files.
- `agents/` contains runtime config overlays for the named Codex roles.
- `skills/` contains background procedural playbooks and reusable chat-loadable workflows for the agent.
- `migration/` contains source-to-target mapping and migration notes.
- `howto.md` is the repo-specific Codex setup guide distilled from official OpenAI docs.

## Local map
- `config.toml` is the first file to check when role registration, features, or routing feel wrong.
- `agents/` currently defines the active role set: `developer`, `tester`, `reviewer`, `architect`, `content`, `extension`, `builder`, and `manager`.
- `skills/` is the internal loadable layer; it includes background know-how and reusable workflows that can be loaded by agents or used directly in chat.
- `migration/` is for transition notes only; do not treat it as current operating policy if `.codex/` already has the replacement.

## Rules
- Background skills are internal-first and may be loaded by the agent when useful.
- Agent role files in `agents/` are runtime configuration, not task instructions.
- Prefer linking to the nearest nested `AGENTS.md` instead of repeating folder rules here.
- Treat `.github/agents`, `.github/skills`, `.github/prompts`, and `copilot-instructions.md` as legacy reference during the migration period.
- Pick the smallest CAG artifact that carries the rule: always-on invariants in `AGENTS.md`, role identity in `agents/*.toml`, reusable know-how in `skills/`, migration notes in `migration/`.
- Before creating a new skill, check whether the durable part belongs in a nearer nested `AGENTS.md` instead.
- If a reusable workflow is likely to be used by both agents and humans in chat, prefer `skills/` over prompt-only wrappers.
- Validate every `.codex/` content change with `python tools/validate/cag_validate.py` and follow with `python tools/audit/cag_link_check.py --strict` after renames, moves, or deletions.
- Review-oriented skills stay read-only unless the user explicitly expands scope to include fixes.
- Review outputs should lead with findings, exact evidence when available, and a binary accept/reject or pass/fail gate condition.

## How to route
- Use root `AGENTS.md` for repository-wide invariants.
- Use the nearest nested `AGENTS.md` for folder-specific rules.
- Use `agents/` for role runtime settings.
- Use `skills/` for background process knowledge.
- Use `howto.md` when changing how Codex itself should be configured for this repo.

## Notes
- `reviewer` and `manager` are role profiles, not folder-owned local agents.
- Review-only behavior must come from role settings, nested `AGENTS.md`, and review skills.
- Keep migration notes current when source mappings change.
