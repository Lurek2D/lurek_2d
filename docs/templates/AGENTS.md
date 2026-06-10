# Templates Contract

Adds local rules for `docs/templates/`.

## Mission & Scope
- Own template files for role configs, skills, specs, and scripts.
- Enforce structure and metadata rules across system templates.
- Help developers create workspace docs with no structural drift.

## Files
- `AGENT_TEMPLATE.md`: Format for active Codex role profiles.
- `SKILL_TEMPLATE.md`: Reusable skill playbook outline.
- `PROMPT_TEMPLATE.md`: Structure for system workflow prompts.
- `SPEC_TEMPLATE.md`: Structure guide for module specs.

## Rules
- Templates must contain only structural headers and placeholder annotations; do not hardcode feature-specific rules.
- If a template format changes, run the validator or generator that proves downstream files still conform, then audit affected outputs only.
- Any template changes must match the layout rules checked by the workspace validation suites.

## Workflow
- Copy the target template layout when creating a new specification, agent role, or skill handbook.
- Validate the workspace following template updates with `python tools/validate/cag_validate.py`.

## References
- docs/templates/SPEC_TEMPLATE.md
- tools/validate/cag_validate.py
