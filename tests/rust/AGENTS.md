# Rust Tests Contract

Covers work under `tests/rust/`.

## Mission
- Own the Rust-side integration, unit, golden, config, security, and stress layers.
- Keep Rust tests focused on internal engine behavior not best covered through Lua-first checks.

## Scope
- `tests/rust/unit/`, `tests/rust/golden/`, `tests/rust/security/`, and `tests/rust/stress/`.
- Cargo-registered test binaries and related fixtures.

## Local map
- `unit/` holds internal engine checks.
- `golden/` holds snapshot-style evidence.
- `security/` and `stress/` stay isolated from the fast path.

## Rules
- Register every Rust test binary explicitly in `Cargo.toml`.
- Keep unit tests under `tests/rust/unit/` and name files `<module>_tests.rs`.
- Keep function names descriptive and scenario-based.
- Use golden tests for deterministic output.
- Keep Rust tests deterministic and headless.
- Reuse fixtures from `tests/rust/fixtures/`.

## Workflow
- Read the relevant spec and source module before writing or changing a Rust test.
- Register the new test binary, then run the narrowest `cargo test --test <name>` target that proves the behavior.

## References
- `Cargo.toml`
- `tests/rust/unit/`
- `tests/rust/golden/`
- `tests/rust/security/`
- `tests/rust/stress/`
