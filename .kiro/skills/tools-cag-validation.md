---
inclusion: manual
---

# tools-cag-validation

## Mission
Own `cag_validate.py` usage, rule meaning, and CAG validation standards.

## When To Use
- Run `cag_validate.py`.
- Debug agent, skill, prompt, or system-prompt validation errors.
- Review CAG file quality.

## When To Skip
- Engine code quality, general CAG authoring only, CI/CD workflow setup.

## Rules

### cag_validate.py Checks
`python tools/validate/cag_validate.py` validates:
1. Frontmatter keys and required values.
2. Required sections (Mission, When To Load, When To Skip, Domain Knowledge).
3. Line count cap per file.
4. Known agent and skill names in cross-references.
5. Description field phrasing (must start with "Load this" or "Skip it for").
6. Prompt `expected_agent` names against the live roster.

A clean validator run is a commit prerequisite.

### Scoped Runs
- `--type skill` validates all skills.
- `--type agent` validates all agents.
- Passing a single file path validates just that file.
Use scoped runs during authoring. Run the full validator before committing.

### cag_link_check.py
`python tools/audit/cag_link_check.py --strict` verifies that every `.md` file path referenced in any CAG file actually exists. Run after any file rename, move, or deletion in `.github/` or `docs/`.

### cag_coverage.py
Reports which agent roles lack associated skill bundles and which skills have no agent owner. An unowned skill is a candidate for removal.

### cag_persona_matrix.py
Outputs the persona coverage matrix. Run after any agent addition or removal to confirm no persona lost all its serving agents.

### Content vs Validator Defects
When validation fails, first confirm the rule exists in `cag_validate.py` source code. If the rule is correct and the file is wrong, fix the file. If the rule is outdated, update the rule — but treat rule changes as a separate commit with a changelog entry.

### Baseline Flag
`--baseline` produces a baseline snapshot for comparison. Use it when starting a large CAG sweep.

### Common Failures and Fixes
- `unknown_agent_name` → agent file was deleted or renamed without updating references.
- `description_phrasing` → description does not start with "Load this skill when".
- `section_missing` → one of the four required sections is absent or has the wrong heading.

### No Code Blocks in SKILL.md
SKILL.md files must not contain code blocks (triple-backtick) or inline code (single-backtick). The validator enforces this. Write commands in plain prose without backtick formatting.

### After Validator Passes
Update `docs/CHANGELOG.md` with a `docs` or `chore` entry describing the CAG change.

## References
- `tools/validate/cag_validate.py`
- `tools/audit/cag_link_check.py`
- `tools/audit/cag_coverage.py`
- `tools/audit/cag_persona_matrix.py`
- `tools/README.md`
