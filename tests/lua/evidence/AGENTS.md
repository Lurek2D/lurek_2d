# Lua Evidence Contract

## Mission & Scope
- Own artifact-producing Lua suites that demonstrate selected public APIs.
- Keep evidence focused on creating meaningful proof artifacts, not on assertion-driven pass/fail logic.

## Files
- `test_<module>_evidence.lua`: Canonical artifact producer for one owned module.
- `tests/artifacts/current/<module>/`: Fresh evidence output for that module.

## Rules
- Evidence passes when it produces the intended artifact under `tests/artifacts/current/<module>/`.
- Do not use file-level `@covers` in this folder.
- Do not use legacy `-- @evidence` markers; evidence ownership comes from the module file and prose rationale comments.
- Put a rationale block above every `it()` with exact `-- Does:`, `-- Shows:`, `-- Artifact:`, and `-- Why:` lines.
- The artifact must make the behavior legible to a reviewer. If the artifact does not clearly prove anything, redesign or remove it.
- Keep helper export APIs incidental; the module being evidenced owns the behavior.

## Workflow
- Run `tools/python.cmd tools/audit/lua_nonunit_test_coverage.py --category evidence`.
- Run `tools/python.cmd tools/audit/lua_evidence_golden_contract_audit.py`.
- Refresh baselines only after the new evidence output is intentionally reviewed.
