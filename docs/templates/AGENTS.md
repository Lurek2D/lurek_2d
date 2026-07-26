# Templates Contract

## Mission & Scope
- Own templates for contracts, roles, skills, specs, and scripts.
- Keep template structure stable for validators and generators.

## Files
- `AGENTS_TEMPLATE.md`: Nested contract scaffold.
- `ROLE_CONFIG_TEMPLATE.toml`: Codex role overlay format.
- `SKILL_TEMPLATE.md`: Skill playbook format.
- `SPEC_TEMPLATE.md`: Module spec format.

## Rules
- Templates contain structure and placeholders, not feature-specific rules.
- Template changes must match validator and generator expectations.
- After format changes, validate downstream files before broad edits.

## Workflow
- Run `python tools/validate/cag_validate.py` after CAG template changes.
