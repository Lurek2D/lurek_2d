# Lua Golden Contract

## Mission & Scope
- Own deterministic comparison suites for previously generated evidence artifacts.
- Keep this folder limited to baseline comparison, never artifact production.

## Files
- `test_<module>_golden.lua`: Canonical golden comparator for one owned module.
- `tests/artifacts/baselines/<module>/`: Reviewed committed baselines for that module.

## Rules
- Use one canonical file per module when the owner is clear: `test_<module>_golden.lua`.
- Golden tests compare `tests/artifacts/current/<module>/...` against `tests/artifacts/baselines/<module>/...`.
- Do not create new evidence here.
- Golden tests must not contain generation logic such as `lurek.*`, `savePNG`, `saveWAV`, `io.open`, or evidence directory creation.
- If evidence output is stale, fix the evidence owner first and reseed intentionally; do not patch golden tests around the mismatch.

## Workflow
- Run `tools/python.cmd tools/audit/lua_evidence_golden_contract_audit.py`.
- Run `tools/python.cmd tools/audit/golden_test.py`.
- Use `tools/python.cmd tools/audit/reseed_lua_artifacts.py --clean` only after evidence output has been reviewed.
