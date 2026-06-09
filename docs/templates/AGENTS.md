# Templates Contract

Covers work under `docs/templates/`.

## Mission & Scope
- Own the blueprint and template files defining structural guidelines for role configs, skills, specifications, and scripts.
- Enforce visual layout standards and metadata properties for all system documentation templates.
- Guide developers in initializing workspace documents consistently, ensuring zero structural drift.

## Files
- `AGENT_TEMPLATE.md`: Reference configuration format for active Codex role profiles.
- `SKILL_TEMPLATE.md`: Reusable playbook outline representing codex task procedures.
- `PROMPT_TEMPLATE.md`: Blueprint structure for system workflow prompt files.
- `SPEC_TEMPLATE.md`: Document structure guideline for module specifications under `docs/specs/`.

## Rules
- Templates must contain only structural headers and placeholder annotations; do not hardcode feature-specific rules.
- If a template format is updated, manually audit all downstream files using it to ensure complete compliance.
- Any template changes must match the layout rules checked by the workspace validation suites.

## Workflow
- Copy the target template layout when creating a new specification, agent role, or skill handbook.
- Validate the workspace following template updates with `python tools/validate/cag_validate.py`.

## References
- docs/specs/SPEC_TEMPLATE.md
- tools/validate/cag_validate.py
