# Lua Tests Contract

Covers work under `tests/lua/`.

## Mission
- Own Lua-facing contract tests, integration checks, demos, evidence, and security coverage.
- Keep harness-visible metadata and assertions consistent.

## Scope
- `tests/lua/**`.
- Harness markers, `test_summary()`, and Lua assertion conventions.

## Local map
- `unit/`, `security/`, `integration/`, `stress/`, and `evidence/` use folder-specific markers.
- `demos/` holds headless demo contract tests.
- `content/games/**/test.lua` holds colocated game tests.

## Rules
- End harness-run test files with `test_summary()`.
- Use `assert_equal`, `assert_true`, `assert_false`, `assert_near`, and `assert_error` instead of bare `assert()`.
- Keep marker comments directly above the covered `it()` block.
- Use `@covers` in `unit/`, `@security` in `security/`, `@integration` in `integration/`, `@stress` in `stress/`, and `@evidence` in `evidence/`.
- Use `assert_near(...)` for float expectations.

## Workflow
- Read `tests/lua/harness.rs` and the nearest peer suite before adding a new Lua test file.
- Run `python tools/audit/lua_test_structure_audit.py --path <file>` after marker-heavy edits.

## References
- `tests/lua/harness.rs`
- `tools/audit/lua_test_structure_audit.py`
