# Rust Tests Contract

This file adds local rules for work under `tests/rust/`.

## Mission
- Own the Rust-side integration, unit, golden, config, security, and stress test layers.
- Keep Rust tests focused on internal engine behavior that is not best covered through Lua-first checks.

## Local rules
- Register every Rust test binary explicitly in `Cargo.toml`; do not rely on implicit discovery.
- Keep unit tests under `tests/rust/unit/` and name files `<module>_tests.rs`.
- Keep function names descriptive and scenario-based; avoid a `test_` prefix on the Rust test function name itself.
- Use golden tests for deterministic output and keep baseline artifacts alongside the test harness flow.
- Use `tests/rust/golden/` for snapshot-style evidence and update the expected files only when the intended output changes.
- Keep Rust tests deterministic and headless. If a scenario needs the GPU, windowing, or audio stack, it probably belongs in a different layer.
- Reuse fixtures from `tests/rust/fixtures/` rather than building large inline fixtures repeatedly.
- Keep stress and security tests isolated from the standard fast path so they do not blur the normal unit contract.

## Workflow
- Read the relevant spec and source module before writing or changing a Rust test.
- Register the new test binary, then run the narrowest `cargo test --test <name>` target that proves the behavior.

## References
- `Cargo.toml`
- `tests/rust/unit/`
- `tests/rust/golden/`
- `tests/rust/security/`
- `tests/rust/stress/`
