# Lua Reorg Contract

## Mission & Scope
- Own canonical Lua coverage for public `lurek.*` behavior.
- Keep marker ownership exact and execution deterministic.

## Files
- `unit/`: 1:1 public API ownership tests.
- `integration/`: Multi-module scenarios.
- `stress/`, `security/`: Load and hostile-input checks.
- `evidence/`: Artifact-producing suites.
- `golden/`: Baseline comparison suites.
- `library/`, `config/`, `demos/`, `fixtures/`: Lua package, config, demo, and helper tests.

## Rules
- Unit coverage must reach 100% for public Lua APIs.
- Use one canonical file per module/category: `test_<module>_unit.lua`, `test_<modules>_integration.lua`, `test_<module>_stress.lua`, etc.
- For unit tests: `1 API = 1 unit it() = 1 directly-adjacent -- @covers`.
- Multiple `-- @covers` markers are temporary only; canonical end state is 1 API per `it()`.
- Do not leave unit `it()` blocks without a preceding `-- @covers`.
- Do not duplicate one public API across multiple unit `it()` blocks.
- In module unit files, test `lurek.<module>.*` functions before userdata/object methods.
- For `stress` and `security`, use `1 API = 1 family marker = 1 it()`.
- For `integration`, markers must match APIs exercised by the scenario.
- For `evidence`, pass by producing the intended artifact; one block may carry multiple `-- @evidence` markers for one meaningful artifact.
- Keep one owning evidence file per public module when the owner is known.
- For `golden`, pass only when current output matches the stored baseline.
- Prefer `expect_equal`, `expect_true`, `expect_near`, `expect_nil`, and `expect_no_error` over raw `assert`.
- End runnable Lua files with `test_summary()`.

## Workflow
- Run `python tools/audit/lua_test_structure_audit.py --path tests/lua_reorg/unit`.
- Run `python tools/audit/unit_test_api_coverage.py`.
- Run `python tools/audit/lua_nonunit_test_coverage.py`.
- Close missing coverage module by module.
