# Lua Tests Contract

## Mission & Scope
- Own canonical Lua coverage for public `lurek.*` behavior.
- Keep unit, integration, stress, security, evidence, and golden roles separate.

## Files
- `unit/`: 1:1 public API owners; `integration/`: multi-module scenarios.
- `stress/`, `security/`: load/hostile-input checks; `evidence/`: artifact producers; `golden/`: baseline comparisons.
- `library/`, `config/`, `fixtures/`: Lua package, config, and helper tests.

## Rules
- Unit coverage must reach 100% for public Lua APIs.
- Use one canonical `test_<module>_<category>.lua` owner per module/category.
- Start each BDD file with a plain prose comment.
- Put `-- @describe` directly before each `describe()`.
- Put the folder marker directly before each `it()` with matching indentation: `@covers`, `@integration`, `@stress`, or `@security`.
- Never use legacy `@tests`, `@description`, or `@category` markers.
- Unit files follow `unit/AGENTS.md`; evidence and golden files follow their child contracts.
- Integration markers name the APIs used by the scenario.
- Stress and security tests use one API family marker per `it()`.
- Prefer typed `expect_*` helpers over raw `assert`.
- Demo-specific headless tests live next to the game as `lurek_2d_content/games/**/test.lua`, not under `tests/lua/`.
- End runnable Lua files with one bare `test_summary()` as the last non-empty line.

## Workflow
- Run `tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit`.
- Run `tools/python.cmd tools/audit/unit_test_api_coverage.py`.
- Run `tools/python.cmd tools/audit/lua_nonunit_test_coverage.py` for non-unit layers.
