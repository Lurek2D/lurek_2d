# Lua Tests Contract

## Mission & Scope
- Own canonical Lua coverage for public `lurek.*` behavior.
- Keep marker ownership exact, execution deterministic, and category boundaries clean.

## Files
- `unit/`: 1:1 public API ownership tests.
- `integration/`: Multi-module scenarios.
- `stress/`, `security/`: Load and hostile-input checks.
- `evidence/`: Artifact-producing suites.
- `golden/`: Baseline comparison suites.
- `library/`, `config/`, `fixtures/`: Lua package, config, and helper tests.

## Rules
- Unit coverage must reach 100% for public Lua APIs.
- Use one canonical file per module/category: `test_<module>_unit.lua`, `test_<modules>_integration.lua`, `test_<module>_stress.lua`, and so on.
- Every BDD Lua test file starts with a plain prose header comment, every `describe()` has a directly preceding `-- @describe`, and describe docstrings contain only `@describe`.
- For unit tests: `1 API = 1 unit it() = 1 directly-adjacent -- @covers`.
- Multiple `-- @covers` markers are temporary only; canonical end state is 1 API per `it()`.
- Primary marker lines must use the folder marker and match `it()` indentation: unit `@covers`, integration `@integration`, stress `@stress`, security `@security`.
- Never use legacy `-- @tests`, `-- @description`, `-- @description:`, or `-- @category:` markers.
- Do not leave unit `it()` blocks without a preceding `-- @covers`.
- Do not duplicate one public API across multiple unit `it()` blocks.
- Put all assertions needed to prove one API inside that API's single owning `it()` block.
- In module unit files, test `lurek.<module>.*` functions before userdata/object methods.
- For `stress` and `security`, use `1 API = 1 family marker = 1 it()`.
- For `integration`, markers must match APIs exercised by the scenario.
- For `evidence`, pass by producing the intended artifact; do not treat evidence as assertion-driven testing.
- Keep one owning evidence file per public module when the owner is known.
- Do not use file-level `@covers` in evidence files.
- In evidence files, use only the owning module's APIs or its userdata methods as the thing being evidenced; helper sinks such as `lurek.image.savePNG` are just export plumbing.
- Put `Does`, `Shows`, `Artifact`, and `Why` comment lines above every evidence block.
- Evidence artifacts must prove something legible. If the team cannot say what an artifact demonstrates, it should be redesigned or removed.
- For `golden`, pass only when current output matches the stored baseline.
- Prefer `expect_equal`, `expect_true`, `expect_near`, `expect_nil`, and `expect_no_error` over raw `assert`.
- Demo-specific headless tests live next to the game as `content/games/**/test.lua`, not under `tests/lua/`.
- End runnable Lua files with exactly one bare `test_summary()` as the last non-empty line.

## Workflow
- Run `tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit`.
- Run `tools/python.cmd tools/audit/unit_test_api_coverage.py`.
- Run `tools/python.cmd tools/audit/lua_nonunit_test_coverage.py`, and also `tools/python.cmd tools/audit/lua_evidence_golden_contract_audit.py` when touching evidence or golden suites.
- Close missing coverage module by module.
