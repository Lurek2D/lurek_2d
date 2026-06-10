# Rust Tests Contract

Adds local rules for `tests/rust/`.

## Mission & Scope
- Own Rust-side unit, integration, golden, security, and stress tests.
- Verify internal engine behavior, private crate functions, and serialization not reachable from Lua.
- Keep test execution deterministic and headless inside normal Cargo flows.

## Files
- `unit/`: Crate-level tests for private helpers and module implementations.
- `golden/`: Snapshot tests for layout coordinates and render outputs.
- `fixtures/`: Pre-constructed data files and configs loaded during test runs.

## Rules
- Keep all unit tests contained under `tests/rust/unit/` using the file suffix `_tests.rs`.
- Do not add unit tests for functions that can be fully verified in the Lua scripting layer; port those cases into `tests/lua/unit/` instead.
- Treat public `lurek.*` behavior as Lua-first coverage. Keep Rust tests for private/internal implementations or wrapper glue that Lua cannot reach.
- Use golden tests exclusively for deterministic output structures (like coordinate mappings or static TOML layouts).
- Use local resources inside `tests/rust/fixtures/` or another checked-in Rust test fixture path instead of downloading files or relying on external global resources.

## Workflow
- Run local unit tests targeting a single module using `cargo test --test <name>`.
- Format and check code quality using `cargo clippy --all-targets -- -D warnings`.

## References
- tests/rust/unit/
- Cargo.toml
