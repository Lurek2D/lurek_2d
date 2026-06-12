# Lua Reorg Contract

Adds local rules for canonical `tests/lua_reorg/`.

## Mission & Scope
- Own canonical Lua coverage for public `lurek.*` behavior.
- Keep module/category file layout stable across unit, integration, stress, security, evidence, and golden suites.
- Enforce exact marker ownership and deterministic Lua test execution.

## Files
- `unit/`: Canonical 1:1 public API ownership tests.
- `integration/`: Multi-module Lua scenarios.
- `stress/`: Load and throughput Lua scenarios.
- `security/`: Hostile input and sandbox behavior checks.
- `evidence/`: Artifact-producing Lua evidence suites.
- `golden/`: Compare-only Lua golden suites.
- `library/`: Pure-Lua library tests.
- `config/`: Lua-side config and runtime configuration checks.
- `demos/`: Headless demo load and smoke validation.
- `fixtures/`: Shared Lua helpers and deterministic fixture code.

## Rules
- Keep canonical public `lurek.*` coverage in this tree.
- Use one canonical file per module/category: `test_<module>_unit.lua`, `test_<modules>_integration.lua`, `test_<module>_stress.lua`, and matching suffixes for other categories.
- For unit coverage, enforce exact ownership: `1 API = 1 unit it() = 1 directly-adjacent -- @covers`.
- Only unit coverage must reach `100%` across the public Lua API.
- Do not leave unit `it()` blocks without a directly preceding `-- @covers`.
- Do not duplicate the same public API across multiple unit `it()` blocks.
- For `stress` and `security`, enforce `1 API = 1 family marker = 1 it()`.
- For `evidence`, treat the block as evidence emission: it should create the artifact and pass when that artifact is successfully produced.
- For `evidence`, allow one `it()` block to carry multiple `-- @evidence` markers when the same output artifact is genuine evidence for each marked API. Do not mark every incidental helper API used by the block.
- For `golden`, treat the block as baseline comparison: compare current output with the stored golden artifact and pass only when the comparison contract succeeds.
- For `integration`, use one canonical file per module-pair or module-set and keep `-- @integration` markers aligned with the APIs the scenario actually exercises.
- Inside each module unit file, keep `lurek.<module>.*` tests first, then userdata/object method tests for that module.
- Prefer specific helpers like `expect_equal`, `expect_true`, `expect_near`, `expect_nil`, and `expect_no_error` over raw Lua `assert`.
- End every runnable Lua file with `test_summary()`.

## Workflow
- Audit structure with `python tools/audit/lua_test_structure_audit.py --path tests/lua_reorg/unit`.
- Audit API ownership with `python tools/audit/unit_test_api_coverage.py`.
- Audit non-unit marker ownership with `python tools/audit/lua_nonunit_test_coverage.py`.
- Close missing coverage module by module and keep the file ordering stable while adding tests.
