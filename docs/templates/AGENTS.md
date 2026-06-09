# Templates Contract

Covers work under `docs/templates/`.

## Mission
- Own the starter templates for repo contracts, skills, prompts, specs, and system guidance.
- Keep template text aligned with the live directory structure.

## Scope
- `docs/templates/` template files.
- Repo-local contract, skill, prompt, spec, and system scaffolds.

## Local map
- `AGENT_TEMPLATE.md` is the source for repo-local `AGENTS.md` files.
- `SKILL_TEMPLATE.md` is the source for `.codex/skills/*/SKILL.md`.
- `PROMPT_TEMPLATE.md` is the source for workflow prompt scaffolds.
- `SPEC_TEMPLATE.md` is the source for `docs/specs/<module>.md`.
- `SYSTEM_PROMPT_TEMPLATE.md` is the source for the always-loaded repo contract.

## Rules
- Keep template files lean and specific.
- Update templates when the folder layout changes.
- Update downstream docs or scaffolds after a template change.

## Workflow
- Copy the nearest template, then fill it with folder-specific detail.
- If a template changes, update the files generated from it.

## References
- `AGENT_TEMPLATE.md`
- `SKILL_TEMPLATE.md`
- `PROMPT_TEMPLATE.md`
- `SPEC_TEMPLATE.md`
- `SYSTEM_PROMPT_TEMPLATE.md`
