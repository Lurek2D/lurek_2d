# Templates Contract

## Mission & Scope
- Own shared scaffolds for contracts, role configs, CAG skills, and spec overlays.
- Keep template structure stable for validators, generators, and copy targets.

## Files
- `AGENTS_TEMPLATE.md`: Copy to `<owned-dir>/AGENTS.md` for a nested contract.
- `ROLE_CONFIG_TEMPLATE.toml`: Copy to `.codex/agents/<role>.toml` for a registered role overlay.
- `SKILL_TEMPLATE.md`: Copy to `.codex/skills/<skill-name>/SKILL.md` for a reusable skill.
- `SPEC_TEMPLATE.md`: Copy to `docs/specs/manual/<module>.md`; generated `docs/specs/<module>.md` stays tool-owned.

## Rules
- Templates contain structure, placeholders, and copy guidance, not feature-specific policy.
- CAG templates must stay compatible with `tools/validate/cag_validate.py`.
- Spec templates must describe manual overlay input only and must not suggest hand-editing generated specs.
- After format changes, validate downstream files before broad edits.

## Workflow
- Run `tools/python.cmd tools/validate/cag_validate.py` after CAG template changes.
- Run `tools/python.cmd tools/audit/cag_link_check.py --strict` after template path or link changes.
