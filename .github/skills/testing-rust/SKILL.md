---
name: testing-rust
description: "Load this skill when writing Rust unit tests in tests/rust/unit/ for internal Rust code not reachable via lurek.*. Skip it for writing Lua tests (use lua-scripting), implementing features, or Rust tests of public lurek.* behaviour (those MUST be Lua tests per TST-01)."
---
# testing-rust

## Mission

Own the non-Lua-reachable slice of the Lurek2D test architecture: centralised Rust unit tests under `tests/rust/unit/<module>_tests.rs`, integration / stress / golden binaries under `tests/rust/`, and harness registration for Lua BDD files. Enforces TST-01..TST-04 from [philosophy.md § Testing Constraints](../../../docs/architecture/philosophy.md#testing-constraints).

## When To Load

- Writing a Rust unit test for private / crate-private internals not exposed through `lurek.*`.
- Adding a new `tests/rust/unit/<module>_tests.rs` file.
- Registering a Lua test binary in `tests/lua/harness.rs`.
- Organising or auditing `tests/rust/` layout.
- Running scoped `cargo test` gates before a commit.

## When To Skip

- Writing tests for `lurek.*`-reachable behaviour — those MUST be Lua tests under `tests/lua/` per **TST-01**. Use the `lua-scripting` skill.
- Implementing features or fixing production bugs — route to `Developer`.
- Performance benchmarking — use `performance-profiling`.
- CI/CD pipeline setup — use `ci-cd-pipeline`.
- Lua API design — use `lua-api-design`.

## Domain Knowledge

### Binding testing constraints (TST-01..TST-04)

Full text: [philosophy.md § Testing Constraints](../../../docs/architecture/philosophy.md#testing-constraints). Short form:

- **TST-01** Any behaviour reachable through `lurek.*` MUST be tested in `tests/lua/`. Rust tests MUST NOT duplicate `lurek.*`-reachable coverage.
- **TST-02** Inline `#[cfg(test)] mod tests` blocks in `src/**/*.rs` are **banned**. All Rust unit tests live in `tests/rust/unit/<module>_tests.rs` (centralised, one file per `src/` module).
- **TST-03** `src/lua_api/<module>_api.rs` holds only `impl LuaUserData`, registration, and conversions. Business logic lives in `src/<module>/` and is tested there.
- **TST-04** `mod.rs` is declarations only; helpers, types, and impls go in sibling files and are tested by module name.

### Placement decision tree

1. Is the behaviour reachable through any `lurek.*` API? Yes -> **Lua test** in `tests/lua/{unit,integration,stress,evidence,golden,security}/test_<...>.lua`.
2. Otherwise, is it a public or `pub(crate)` Rust symbol with internal-only callers? Yes -> **Rust unit test** in `tests/rust/unit/<module>_tests.rs`.
3. Cross-module / end-to-end Rust behaviour? -> `tests/rust/ext/` or a registered `[[test]]` binary under `tests/rust/`.

### Owns
- Rust integration patterns (`tests/rust/ext/<module>_tests.rs`).
- Rust unit patterns (`tests/rust/unit/<module>_tests.rs`) — the sole legal home for `#[test]` fns covering internals.
- Lua BDD harness registration (`tests/lua/harness.rs`).
- Float-comparison strategy (Rust and Lua).
- `<subject>_<scenario>_<expected>` naming; no `test_` prefix.
- Coverage tools (`tools/audit/test_coverage.py`, `tools/audit/unit_test_api_coverage.py`).

### Two-layer test system

See [snippets/1-test-architecture-overview.txt](snippets/1-test-architecture-overview.txt) for the layout table. Every layer runs via `cargo test` and must be headless.

### Adding a Rust unit test (TST-02-compliant)

- File: `tests/rust/unit/<module>_tests.rs` (create if absent; register in `Cargo.toml` if the file is a new `[[test]]` target).
- Body skeleton and a migrate-from-inline before/after pair are in [examples/2-adding-a-new-rust-integration.rs](examples/2-adding-a-new-rust-integration.rs) and [snippets/extended-notes.md](snippets/extended-notes.md).
- Run scoped: see [snippets/2-adding-a-new-rust-integration-2.ps1](snippets/2-adding-a-new-rust-integration-2.ps1).

### Adding a Lua test

- File + `@covers` + summary contract: [examples/3-1-create-the-lua-file.lua](examples/3-1-create-the-lua-file.lua).
- Harness registration (manual; no auto-discovery): [examples/3-2-harness-registration.rs](examples/3-2-harness-registration.rs).

### Banned patterns

- `#[cfg(test)] mod tests` (or any `#[test]` fn) anywhere under `src/**/*.rs` — **TST-02** violation; Reviewer rejects.
- Rust integration tests that exercise `lurek.*` behaviour reachable from Lua — **TST-01** violation; rewrite as a Lua BDD test.
- Adding logic (math, branching, loops) to a `src/lua_api/*_api.rs` closure solely to make it testable — **TST-03** violation; extract to `src/<module>/` first, then test the domain function.
- Registering tests against symbols defined inside `mod.rs` — **TST-04** violation; move the definition into a sibling file first.

See [snippets/extended-notes.md](snippets/extended-notes.md) for extended guidance on naming, float comparison, evidence vs golden contracts, and coverage tooling.

## Companion File Index

- [snippets/1-test-architecture-overview.txt](snippets/1-test-architecture-overview.txt) — two-layer test architecture.
- [examples/2-adding-a-new-rust-integration.rs](examples/2-adding-a-new-rust-integration.rs) — Rust unit test skeleton (TST-02).
- [snippets/2-adding-a-new-rust-integration-2.ps1](snippets/2-adding-a-new-rust-integration-2.ps1) — scoped `cargo test` invocations.
- [examples/3-1-create-the-lua-file.lua](examples/3-1-create-the-lua-file.lua) — Lua BDD test file skeleton.
- [examples/3-2-harness-registration.rs](examples/3-2-harness-registration.rs) — harness registration pattern.
- [examples/test-structure.lua](examples/test-structure.lua) — describe/it nesting.
- [examples/6-test-vm-helpers-rust-side.rs](examples/6-test-vm-helpers-rust-side.rs) — test-VM helpers (Rust side).
- [snippets/running-quality-gates.ps1](snippets/running-quality-gates.ps1) — gate commands.
- [snippets/extended-notes.md](snippets/extended-notes.md) — extended notes (naming, float comparison, evidence/golden contracts, coverage).

## References

- [docs/architecture/philosophy.md § Testing Constraints](../../../docs/architecture/philosophy.md#testing-constraints) — canonical text of TST-01..TST-04.
- [docs/architecture/test-framework.md](../../../docs/architecture/test-framework.md) — placement decision tree and banned-patterns list.
- [tools/audit/test_coverage.py](../../../tools/audit/test_coverage.py) — Rust+Lua test-coverage cross-reference report.
- [tools/audit/unit_test_api_coverage.py](../../../tools/audit/unit_test_api_coverage.py) — unit-level API coverage metrics.
- [tools/audit/lua_evidence_golden_contract_audit.py](../../../tools/audit/lua_evidence_golden_contract_audit.py) — evidence/golden contract enforcement.
---
name: testing-rust
description: "Load this skill when writing Rust unit tests in tests/rust/unit/ for internal Rust code not reachable via lurek.*. Skip it for writing Lua tests (use lua-scripting), implementing features, or Rust tests of public lurek.* behaviour (those MUST be Lua tests per TST-01)."
---
# testing-rust

## Mission

Own the non-Lua-reachable slice of the Lurek2D test architecture: centralised Rust unit tests under `tests/rust/unit/<module>_tests.rs`, integration / stress / golden binaries under `tests/rust/`, and harness registration for Lua BDD files. Enforces TST-01..TST-04 from [philosophy.md § Testing Constraints](../../../docs/architecture/philosophy.md#testing-constraints).

## When To Load

- Writing a Rust unit test for private / crate-private internals not exposed through `lurek.*`
- Adding a new `tests/rust/unit/<module>_tests.rs` file
- Registering a Lua test binary in `tests/lua/harness.rs`
- Organising or auditing `tests/rust/` layout
- Running scoped `cargo test` gates before a commit

## When To Skip

- Writing tests for `lurek.*`-reachable behaviour â€” those MUST be Lua tests under `tests/lua/` per **TST-01**. Use the `lua-scripting` skill.
- Implementing features or fixing production bugs â€” route to `Developer`.
- Performance benchmarking â€” use `performance-profiling`.
- CI/CD pipeline setup â€” use `ci-cd-pipeline`.
- Lua API design â€” use `lua-api-design`.

## Domain Knowledge

### Binding testing constraints (TST-01..TST-04)

Full text: [philosophy.md § Testing Constraints](../../../docs/architecture/philosophy.md#testing-constraints). Short form:

- **TST-01** Any behaviour reachable through `lurek.*` MUST be tested in `tests/lua/`. Rust tests MUST NOT duplicate `lurek.*`-reachable coverage.
- **TST-02** Inline `#[cfg(test)] mod tests` blocks in `src/**/*.rs` are **banned**. All Rust unit tests live in `tests/rust/unit/<module>_tests.rs` (centralised, one file per `src/` module).
- **TST-03** `src/lua_api/<module>_api.rs` holds only `impl LuaUserData`, registration, and conversions. Business logic lives in `src/<module>/` and is tested there.
- **TST-04** `mod.rs` is declarations only; helpers/types/impls go in sibling files and are tested by module-name.

### Placement decision tree

1. Is the behaviour reachable through any `lurek.*` API? â†’ **Lua test** in `tests/lua/{unit,integration,stress,evidence,golden,security}/test_<...>.lua`.
2. Otherwise, is it a public or `pub(crate)` Rust symbol with internal-only callers? â†’ **Rust unit test** in `tests/rust/unit/<module>_tests.rs`.
3. Cross-module / end-to-end Rust behaviour? â†’ `tests/rust/ext/` or a registered `[[test]]` binary under `tests/rust/`.

### Owns
- Rust integration test patterns (`tests/rust/ext/<module>_tests.rs`)
- Rust unit patterns (`tests/rust/unit/<module>_tests.rs`) â€” the sole legal home for `#[test]` fns covering internals
- Lua BDD harness registration (`tests/lua/harness.rs`)
- Float-comparison strategy (Rust and Lua)
- `<subject>_<scenario>_<expected>` naming; no `test_` prefix
- Coverage tools (`tools/audit/test_coverage.py`, `tools/audit/unit_test_api_coverage.py`)

### Two-layer test system
See [snippets/1-test-architecture-overview.txt](snippets/1-test-architecture-overview.txt) for the layout table. Every layer runs via `cargo test` and must be headless.

### Adding a Rust unit test (TST-02-compliant)
- File: `tests/rust/unit/<module>_tests.rs` (create if absent; register in `Cargo.toml` if the file is a new `[[test]]` target).
- Body skeleton and a "migrate from inline" before/after pair are in [examples/2-adding-a-new-rust-integration.rs](examples/2-adding-a-new-rust-integration.rs) and [snippets/extended-notes.md](snippets/extended-notes.md).
- Run scoped: see [snippets/2-adding-a-new-rust-integration-2.ps1](snippets/2-adding-a-new-rust-integration-2.ps1).

### Adding a Lua test
- File + `@covers` + summary contract: [examples/3-1-create-the-lua-file.lua](examples/3-1-create-the-lua-file.lua).
- Harness registration (manual â€” no auto-discovery): [examples/3-2-harness-registration.rs](examples/3-2-harness-registration.rs).

### Banned patterns

- `#[cfg(test)] mod tests` (or any `#[test]` fn) anywhere under `src/**/*.rs` â€” **TST-02** violation; Reviewer rejects.
- Rust integration tests that exercise `lurek.*` behaviour reachable from Lua â€” **TST-01** violation; rewrite as a Lua BDD test.
- Adding logic (math, branching, loops) to a `src/lua_api/*_api.rs` closure solely to make it testable â€” **TST-03** violation; extract to `src/<module>/` first, then test the domain function.
- Registering tests against symbols defined inside `mod.rs` â€” **TST-04** violation; move the definition into a sibling file first.

See [snippets/extended-notes.md](snippets/extended-notes.md) for extended guidance on naming, float comparison, evidence vs golden contracts, and coverage tooling.

## Companion File Index

- [snippets/1-test-architecture-overview.txt](snippets/1-test-architecture-overview.txt) â€” two-layer test architecture
- [examples/2-adding-a-new-rust-integration.rs](examples/2-adding-a-new-rust-integration.rs) â€” Rust unit test skeleton (TST-02)
- [snippets/2-adding-a-new-rust-integration-2.ps1](snippets/2-adding-a-new-rust-integration-2.ps1) â€” scoped `cargo test` invocations
- [examples/3-1-create-the-lua-file.lua](examples/3-1-create-the-lua-file.lua) â€” Lua BDD test file skeleton
- [examples/3-2-harness-registration.rs](examples/3-2-harness-registration.rs) â€” harness registration pattern
- [examples/test-structure.lua](examples/test-structure.lua) â€” describe/it nesting
- [examples/6-test-vm-helpers-rust-side.rs](examples/6-test-vm-helpers-rust-side.rs) â€” test-VM helpers (Rust side)
- [snippets/running-quality-gates.ps1](snippets/running-quality-gates.ps1) â€” gate commands
- [snippets/extended-notes.md](snippets/extended-notes.md) â€” extended notes (naming, float comparison, evidence/golden contracts, coverage)

## References

- [docs/architecture/philosophy.md § Testing Constraints](../../../docs/architecture/philosophy.md#testing-constraints) — canonical text of TST-01..TST-04.
- [docs/architecture/test-framework.md](../../../docs/architecture/test-framework.md) — placement decision tree and banned-patterns list.
- [tools/audit/test_coverage.py](../../../tools/audit/test_coverage.py) — Rust+Lua test-coverage cross-reference report.
- [tools/audit/unit_test_api_coverage.py](../../../tools/audit/unit_test_api_coverage.py) — unit-level API coverage metrics.
- [tools/audit/lua_evidence_golden_contract_audit.py](../../../tools/audit/lua_evidence_golden_contract_audit.py) — evidence/golden contract enforcement.

