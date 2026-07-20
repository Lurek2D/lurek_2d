---
name: create-test-rust
description: "Load this skill when creating or modifying Rust tests for private engine seams and internal module behavior. Skip it for public lurek API tests that belong in Lua or content demo smoke tests."
---

# create-test-rust

## Mission
- Create or modify Rust tests only for internal logic that is not better covered through public Lua API tests.
- Keep Rust tests focused on private seams; there is no repo-wide 100% Rust unit coverage requirement.

## Domain Knowledge
- Rust tests are external targets under `tests/rust/unit|ext|golden`, explicitly named in `Cargo.toml`; the repository deliberately avoids inline `#[cfg(test)]` modules under `src/`.
- A `pub(crate)` test seam is acceptable only when it exposes a narrow invariant that Lua cannot reach; broadening production visibility to simplify a test is an architecture change, not test setup.
- Public `lurek.*` semantics remain Lua-owned, while Rust tests are strongest for parsers, checked arithmetic, serialization, state machines, resource accounting, and wrapper conversion glue before/after mlua calls.
- Headless determinism excludes ambient GPU/audio devices, network, downloads, global filesystem state, and wall-clock timing from normal unit targets; runtime-dependent coverage belongs in explicit ext/smoke targets.
- Cargo target names, file paths, fixtures, and filters must agree because an orphan test file is invisible to `cargo test --test <name>`.
- Tests crossing crate-private seams should preserve production construction and ownership order; fabricating invalid internal state is appropriate only when corruption or defensive handling is the invariant under test.
- Golden Rust tests fit deterministic structural encodings, coordinate transforms, or static layouts where reviewable output is more stable than a large assertion set, not live renderer/device observations.
- Concurrency tests need explicit synchronization and bounded completion rather than sleeps, because scheduler timing on Windows otherwise turns race detection into intermittent noise.

## Workflow
- Classify the contract as private pure logic, wrapper glue, deterministic golden, or runtime extension; confirm Lua cannot own it and locate the existing Cargo target/fixture owner before writing a new seam or file.
- Build the smallest deterministic fixture and assert invariants plus failure boundaries, using checked values and serialized structures instead of timing or device observations; add a documented `pub(crate)` seam only when no existing public/internal path exposes the invariant.
- Place the case in the module target or create and register the narrowest new target, then run its exact `cargo test --test <name> <filter>` command and deliberately vary a boundary input to prove the test is sensitive to the defect.
- Run the full target and `cargo clippy --all-targets -- -D warnings`; if the change touches shared helpers or serialization formats, run dependent targets and golden compatibility checks without duplicating Lua-owned public behavior.
- Check fixture provenance and cleanup, preferring checked-in minimal inputs and task-local temporary output over workspace-global files; ensure parallel Cargo targets cannot contend for one mutable fixture path.
- Review whether each assertion proves a stable invariant or an implementation detail, retaining exact internal structure only when compatibility, ordering, or serialized format is itself the contract.

## References
- `contracts: src/AGENTS.md, tests/AGENTS.md, tests/rust/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Rust tests internal module Cargo target" --profile engine --limit 10, cargo test --test <module_tests>, cargo test, cargo clippy -- -D warnings`
- `agent: tester`
- RAG: Use when finding existing internal Rust test patterns; `Rust tests internal module Cargo target`; `#[cfg(test)] mod tests assert`; `engine module unit test helper`; `src/`; `tests/`; private helpers near touched modules; engine specs in `docs/`
