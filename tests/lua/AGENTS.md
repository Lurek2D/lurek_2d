# Lua Tests Contract

Adds local rules for `tests/lua/`.

## Mission & Scope
- Own Lua-facing unit, integration, security, stress, and visual evidence tests for public namespaces.
- Enforce Lua test harness syntax, metadata tags, and assertion style.
- Maintain colocated tests for games and headless execution flows.

## Files
- `unit/`: Core contract tests verifying individual API parameters and outputs.
- `security/` / `stress/`: Robustness tests for sandbox limits and high allocations.
- `demos/`: Headless scripts that run game demos for a fixed frame count.
- `harness.rs`: Rust entrypoint executing the Lua test suite.

## Rules
- Every test file executed by the test runner must terminate with `test_summary()`.
- Use specific assertion methods (like `assert_equal`, `assert_true`, `assert_near`) rather than raw Lua `assert`.
- Place metadata tags such as `@covers`, `@security`, and `@integration` right above the target `it()` block.
- When a public Rust-facing behavior is moved out of `tests/rust/unit/`, add the canonical Lua coverage here and keep the `@covers` markers on the public `lurek.*` entry points.
- Always use `assert_near` with epsilon parameters for coordinate, color, or matrix floating-point checks.

## Workflow
- Add newly created test files to the execution list inside `tests/lua/harness.rs`.
- Audit marker and tag syntax validity using `python tools/audit/lua_test_structure_audit.py --path tests/lua/`.

## References
- tests/lua/harness.rs
- tools/audit/lua_test_structure_audit.py
