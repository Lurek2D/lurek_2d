---
name: create-test-rust
description: "Load this skill when creating or modifying Rust tests for private engine seams and internal module behavior. Skip it for public lurek API tests that belong in Lua or content demo smoke tests."
---

# create-test-rust

## Mission
- Create or modify Rust tests only for internal logic that is not better covered through public Lua API tests.
- Keep Rust tests focused on private seams; there is no repo-wide 100% Rust unit coverage requirement.

## Domain Knowledge
- Rust tests live under `tests/rust/`.
- Rust test files are external Cargo targets.
- Cargo target names are declared in `Cargo.toml`.
- The repo does not use inline `#[cfg(test)]` modules under `src/`.
- Rust tests own private engine behavior.
- Public `lurek.*` behavior is owned by Lua tests.
- `pub(crate)` may expose a narrow test seam.
- A test seam must document the invariant it exposes.
- Rust unit tests are headless and deterministic.
- Normal unit tests do not require GPU, audio devices, network, or downloads.
- Checked-in fixtures live under `tests/rust/fixtures/`.
- Golden tests are for deterministic structures and encodings.
- Runtime-dependent tests use explicit ext or smoke targets.
- Concurrency tests use synchronization, not sleep.
- Test output uses task-local temporary paths.
- An unregistered Rust test file is not executed by Cargo.
- Rust unit files live under `tests/rust/unit/` and use the `_tests.rs` suffix.
- Deterministic structural snapshots live under `tests/rust/golden/`.
- Rust coverage is intentionally not required to reach 100%.
- Golden ownership fits stable coordinates, encodings, and static TOML layouts.
- Test fixtures cannot download data or depend on machine-global resources.
- Rust test changes must pass `cargo clippy --all-targets -- -D warnings`.

## Workflow
1. Read `src/AGENTS.md` and `tests/rust/AGENTS.md`.
2. Confirm that Lua cannot own the behavior.
3. Classify the test as unit, ext, golden, perf, or stress.
4. Find the current Cargo target and fixture owner.
5. Create the smallest deterministic fixture.
6. Use production construction order.
7. Add a narrow documented `pub(crate)` seam only when needed.
8. Test the invariant and its failure boundary.
9. Avoid device, network, download, and wall-clock dependencies.
10. Register a new target in `Cargo.toml`.
11. Run `cargo test --test <name> <filter>`.
12. Change one boundary input and confirm the test detects it.
13. Run the full Cargo target.
14. Run dependent targets for shared formats or helpers.
15. Run `cargo clippy --all-targets -- -D warnings`.
16. Remove assertions that only freeze implementation details.

## References
- `contracts: src/AGENTS.md, tests/AGENTS.md, tests/rust/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Rust tests internal module Cargo target" --profile engine --limit 10, cargo test --test <module_tests>, cargo test, cargo clippy -- -D warnings`
- `agent: tester`
- RAG: `Rust tests internal <module> Cargo target`; inspect the private seam, matching `tests/rust/` target, Cargo registration, fixture owner, and related Lua coverage boundary.
