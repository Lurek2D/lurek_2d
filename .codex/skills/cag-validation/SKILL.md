---
name: cag-validation
description: "Load this skill when validating, debugging, or maintaining CAG files and cag_validate.py rules. Skip it for engine code or game scripts."
---
# cag-validation

## Use when
- Run cag_validate.py.
- Debug agent, skill, prompt, or system-prompt validation errors.
- Review CAG file quality.

## Avoid when
- Engine code quality.
- General CAG authoring only.
- CI/CD workflow setup.

## Repo rules
- `python tools/validate/cag_validate.py` is the entry gate for any CAG commit. It validates: frontmatter keys and required values, required sections, line count cap per file, known agent and skill names in cross-references, description field phrasing, prompt `expected_agent` names against the live roster.
- Scoped runs for fast iteration: `--type skill` validates all skills; `--type agent` validates all agents; passing a single file path validates just that file. Use scoped runs during authoring.
- `python tools/audit/cag_link_check.py --strict` verifies that every `.md` file path referenced in any CAG file actually exists. Run after any file rename, move, or deletion in `.github/` or `docs/`.
- `python tools/audit/cag_coverage.py` reports which agent roles lack associated skill bundles and which skills have no agent owner. An unowned skill is a candidate for removal; a role without primary skills is a routing gap.
- `python tools/audit/cag_persona_matrix.py` outputs the persona coverage matrix. Run it after any agent addition or removal to confirm no persona lost all its serving agents.
- Distinguishing content vs. validator defects: when validation fails, first confirm the rule exists in `cag_validate.py` source code.
- `--baseline` flag produces a baseline snapshot for comparison. Use it when starting a large CAG sweep: baseline at start, validate again at end, diff to confirm only intended changes.
- Common validator failures and their fixes: `unknown_agent_name` â†’ agent file was deleted or renamed without updating references; `description_phrasing` â†’ description does not start with "Load this skill when"; `section_missing` â†’ one of the four required sections is absent or has the wrong heading.
- SKILL.md files must not contain triple-backtick code fences. Single backticks are allowed for short inline command or path references when they improve clarity.

## Checks
- `python tools/validate/cag_validate.py`
- `python tools/audit/cag_link_check.py --strict`
- `python tools/audit/cag_coverage.py`
- `python tools/audit/cag_persona_matrix.py`

## References
- `tools/validate/cag_validate.py`
- `tools/audit/cag_link_check.py`
- `tools/audit/cag_coverage.py`
- `tools/audit/cag_persona_matrix.py`
- `tools/README.md`

