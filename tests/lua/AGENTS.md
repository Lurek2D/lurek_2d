# Lua Tests Contract

This file adds local rules for work under `tests/lua/`.

## Mission
- Own Lua-facing contract tests, integration checks, demos, evidence, and security coverage.
- Keep harness-visible metadata and assertions consistent.

## Scope
- `tests/lua/**`
- Harness markers, `test_summary()`, and Lua assertion conventions.

## Local rules
- End harness-run test files with `test_summary()`.
- Use harness assertions such as `assert_equal`, `assert_true`, `assert_false`, `assert_near`, and `assert_error` instead of bare `assert()`.
- Keep marker comments directly above the covered `it()` block.
- Use the folder-specific markers consistently: `@covers` in `unit/`, `@security` in `security/`, `@integration` in `integration/`, `@stress` in `stress/`, and `@evidence` in `evidence/`.
- For float expectations, always use `assert_near(...)`.
- Colocated game tests belong in `content/games/**/test.lua`; headless demo contract tests belong in `tests/lua/demos/`.

## Workflow
- Read `tests/lua/harness.rs` and the nearest peer suite before adding a new Lua test file.
- Run `python tools/audit/lua_test_structure_audit.py --path <file>` after marker-heavy edits.

## References
- `tests/lua/harness.rs`
- `tools/audit/lua_test_structure_audit.py`
