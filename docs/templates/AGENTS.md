# Templates Contract

## Mission & Scope
- Own templates for roles, skills, prompts, specs, and scripts.
- Keep template structure stable for validators and generators.

## Files
- `AGENT_TEMPLATE.md`: Codex role profile format.
- `SKILL_TEMPLATE.md`: Skill playbook format.
- `PROMPT_TEMPLATE.md`: Workflow prompt format.
- `SPEC_TEMPLATE.md`: Module spec format.

## Rules
- Templates contain structure and placeholders, not feature-specific rules.
- Template changes must match validator and generator expectations.
- After format changes, validate downstream files before broad edits.

## Workflow
- Run `python tools/validate/cag_validate.py` after CAG template changes.
