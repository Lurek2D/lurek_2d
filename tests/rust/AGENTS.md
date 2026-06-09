# Rust Tests Contract

Covers work under `tests/rust/`.

## Mission & Scope
- Own the Rust-side unit, integration, golden/snapshot, security, and performance stress test suites.
- Verify engine internal behaviors, private crate functions, and serialization layers not accessible from public Lua bindings.
- Maintain deterministic, headless test execution flows that run within standard Cargo pipelines.

## Files
- `unit/`: Crate-level unit tests testing private helper methods and module implementations.
- `golden/`: Snapshot-style regression tests verifying layout node coordinates and render outputs.
- `fixtures/`: Pre-constructed data files and configs loaded during test runs.

## Rules
- Keep all unit tests contained under `tests/rust/unit/` using the file suffix `_tests.rs`.
- Do not add unit tests for functions that can be fully verified in the Lua scripting layer; port those cases into `tests/lua/unit/` instead.
- Treat public `lurek.*` behavior as Lua-first coverage and keep Rust tests limited to private/internal implementations or wrapper glue that cannot be exercised from Lua.
- Use golden tests exclusively for deterministic output structures (like coordinate mappings or static TOML layouts).
- Use local resources inside `tests/fixtures/` instead of downloading files or relying on external global resources.

## Workflow
- Run local unit tests targeting a single module using `cargo test --test <name>`.
- Format and check code quality using `cargo clippy --all-targets -- -D warnings`.

## References
- tests/rust/unit/
- Cargo.toml
