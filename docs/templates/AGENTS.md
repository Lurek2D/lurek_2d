# Templates Contract

## Mission & Scope
- Own templates for contracts, roles, skills, and manual spec overlays.
- Keep template structure stable for CAG validators and spec generators.

## Files
- `AGENTS_TEMPLATE.md`: Nested contract scaffold.
- `ROLE_CONFIG_TEMPLATE.toml`: Codex role overlay format.
- `SKILL_TEMPLATE.md`: Skill playbook format.
- `SPEC_TEMPLATE.md`: Manual module-intent overlay format.

## Rules
- Templates contain structure and placeholders, not feature-specific rules or runnable examples.
- Template changes must match validator and generator expectations.
- After format changes, validate downstream files before broad edits.

## Workflow
- Run `python tools/validate/cag_validate.py` after CAG template changes.
