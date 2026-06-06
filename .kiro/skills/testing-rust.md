---
inclusion: manual
---

# testing-rust

## Mission
Own the testing strategy, file layout, assertion patterns, and coverage tooling for both Rust unit tests and Lua binding tests.

## When To Use
- Writing Rust unit tests for internal code in `tests/rust/unit/`.
- Writing Lua tests for `lurek.*` API surface in `tests/lua/`.
- Understanding which test layer to use for a given behavior.
- Checking test coverage metrics.

## When To Skip
- Implementing features, Lua scripting unrelated to tests.

## Rules

### Lua-First Split (TST-01)
Behavior reachable through `lurek.*` belongs in `tests/lua/unit/test_<module>_<layer>.lua`. Rust-only private internals go in `tests/rust/unit/<module>_tests.rs`. When in doubt, prefer the Lua layer.

### No cfg(test) in src/
Every test using `src/` code but about private internals lives in `tests/rust/unit/<module>_tests.rs` as a separate binary target.

### File Naming
- Rust test files: `<module>_tests.rs` (with the `s`).
- Lua unit test files: `test_<module>_<layer>.lua`.

### Lua Test File Structure
Each file ends with `test_summary()`. Use `assert_equal`, `assert_true`, `assert_near`, or `assert_error` from the harness — not bare `assert()`. Missing `test_summary()` means the harness reports 0 tests.

### Registration
- New Lua test files must be registered in `tests/lua/harness.rs` under the correct suite.
- New Rust test binaries must be added to `Cargo.toml` as `[[test]]` targets.

### Float Comparison
Use `assert_near(a, b, epsilon)` always. Direct `==` on floats is a defect.

### Determinism Checklist
Fixed random seed, fixed `dt = 1/60`, no filesystem reads outside `tests/fixtures/`, no wall-clock time, no window.

### Test Granularity
One failing reason per test. `test_body_position_after_one_step()` is valid. `test_physics_all()` is not.

### Marker Rules (enforced by `python tools/audit/lua_test_structure_audit.py`)
- `tests/lua/unit/` → `-- @covers ...`
- `tests/lua/security/` → `-- @security ...`
- `tests/lua/integration/` → `-- @integration ...`
- `tests/lua/stress/` → `-- @stress ...`
- `tests/lua/evidence/` → `-- @evidence ...`

Marker lines must sit directly above the `it()` they annotate and be indented exactly like that `it()`. For `@covers`: mark only symbols that are called AND assertion-backed in that same `it()`.

`-- @tests` is FORBIDDEN.

### Manual Cleanup Workflow
Work in batches of max 3 Lua files. Read each file fully before editing. Apply manual marker corrections. After each batch, run `python tools/audit/lua_test_structure_audit.py --path <file>` for each touched file and proceed only if all pass.

### Marker Accuracy (Critical)
A marker symbol must correspond to a call that TESTS the symbol, not merely uses it. Setup calls without assertions are invisible to markers — remove them from the marker list.

### Integration Tests
Only place in `tests/lua/integration/` if they test behavior across at least TWO modules from different subsystems. Tests of a single-module contract belong in `tests/lua/unit/`.

### Security Tests
Use "supported contract first" principle. Every rejection test must tie to one explicit invalidity reason: type mismatch, range violation, malformed payload, or forbidden operation.

### Demo Tests
Go in `tests/lua/demos/test_<name>.lua` and `tests/demo_smoke_tests.rs` — not in `tests/lua/unit/`.

## References
- `tests/lua/`
- `tests/rust/unit/`
- `tools/audit/test_coverage.py`
- `tools/audit/lua_api_test_coverage.py`
