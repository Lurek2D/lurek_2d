# Codex Workspace Contract

Owns Codex-only guidance for `lurek_2D`.

## Mission & Scope
- Keep roles, skills, prompts, and config separate from product code.
- Put repo invariants in root or nested `AGENTS.md`; keep `.codex/` about CAG setup.
- Maintain active role mappings and reusable workflows.

## Files
- `config.toml`: Codex workspace defaults and registered agent mappings.
- `agents/`: Runtime role overlays, not direct task instructions.
- `skills/`: Reusable task workflows.

## Rules
- Pick the narrowest owner: contracts for invariants, `agents/` for roles, `skills/` for workflows.
- Prefer links to nearest contracts over copied rules.
- Keep the existing `.codex/skills/` catalog intact; do not create replacement skills without explicit user approval.
- Route only to agent profiles that actually exist under `.codex/agents/`.
- Keep skill owner labels synced with the registered profile names they target.
- Keep optional local runtimes repo-scoped; use `tools/dev/headroom_runtime.py` instead of hard-wiring Headroom into active `config.toml`.

## Workflow
- Run `tools/python.cmd tools/validate/cag_validate.py` after CAG config changes.
