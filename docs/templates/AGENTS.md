# Templates Contract

This file adds local rules for work under `docs/templates/`.

## Mission
- Own the canonical starter templates used to scaffold repo contracts, skills, prompts, specs, and system guidance.
- Keep template text aligned with the live directory structure and current migration model.

## Local rules
- `AGENT_TEMPLATE.md` is the source template for repo-local `AGENTS.md` files.
- `SKILL_TEMPLATE.md` is the source template for `.codex/skills/*/SKILL.md` files.
- `PROMPT_TEMPLATE.md` is the source template for workflow prompt scaffolds and any skill-to-prompt migration notes.
- `SPEC_TEMPLATE.md` is the source template for `docs/specs/<module>.md`.
- `SYSTEM_PROMPT_TEMPLATE.md` is the source template for the always-loaded repo contract.
- Keep template files lean, specific, and synchronized with the live structure they describe.
- When the folder layout changes, update the templates before or together with any generated or copied artifacts.

## Workflow
- Copy the nearest template, then fill it with folder-specific detail rather than inventing a new shape.
- If a template changes, update the downstream docs or scaffolded files that were generated from it.

## References
- `AGENT_TEMPLATE.md`
- `SKILL_TEMPLATE.md`
- `PROMPT_TEMPLATE.md`
- `SPEC_TEMPLATE.md`
- `SYSTEM_PROMPT_TEMPLATE.md`
