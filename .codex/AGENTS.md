# Codex Workspace Contract

This folder owns the Codex-specific workspace layer for `lurek_2D`.

## Mission & Scope
- Keep Codex-local workflow assets (role profiles, skills, prompts) separate from product source code.
- Minimize duplication between root and nested contracts by keeping `.codex/` configuration-centric.
- Maintain the active Context Augmented Guidance (CAG) layer configuration and role mappings.

## Files
- `config.toml`: Registers active Codex agent roles and details their tool capabilities.
- `agents/`: Contains role-specific runtime configuration overlays for the active roles.
- `skills/`: procedural workflows and background playbooks that can be loaded in chat.

## Rules
- Role definition files in `agents/` serve as runtime configuration, not direct task instructions.
- Prefer linking to the nearest nested `AGENTS.md` rather than duplicating directory rules here.
- Pick the narrowest CAG artifact: invariants in `AGENTS.md`, role identities in `agents/`, reusable workflows in `skills/`.
- Validate all configuration changes using `tools/python.cmd tools/validate/cag_validate.py`.
- Review-oriented roles must not modify code unless the user explicitly requests bug fixes.

## Workflow
- Verify configuration shifts by running the CAG validator.
- Ensure new skills are registered in `config.toml` before attempting to load them.

## References
- .codex/config.toml
- .codex/agents/
