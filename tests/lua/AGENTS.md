# Lua Tests Contract

Covers work under `tests/lua/`.

## Mission & Scope
- Own Lua-facing unit, integration, security, stress, and visual evidence tests for public namespaces.
- Enforce the Lua test harness syntax conventions, metadata annotation markers, and assertion styles.
- Maintain colocated tests for games and headless execution suites verifying game loops.

## Files
- `unit/`: Core contract tests verifying individual API parameters and outputs.
- `security/` / `stress/`: Robustness tests checking sandbox boundaries and high allocations.
- `demos/`: Headless scripts running game category demos for a fixed amount of frames.
- `harness.rs`: Rust entrypoint executing the Lua test suite.

## Rules
- Every test file executed by the test runner must terminate with `test_summary()`.
- Use specific assertion methods (like `assert_equal`, `assert_true`, `assert_near`) rather than raw Lua `assert`.
- Place appropriate metadata tags (e.g., `@covers`, `@security`, `@integration`) immediately above the target `it()` block.
- When a public Rust-facing behavior is moved out of `tests/rust/unit/`, add the canonical Lua coverage here and keep the `@covers` markers on the public `lurek.*` entry points.
- Always use `assert_near` with epsilon parameters for coordinate, color, or matrix floating-point checks.

## Workflow
- Add newly created test files to the execution list inside `tests/lua/harness.rs`.
- Audit marker and tag syntax validity using `python tools/audit/lua_test_structure_audit.py --path tests/lua/`.

## References
- tests/lua/harness.rs
- tools/audit/lua_test_structure_audit.py
