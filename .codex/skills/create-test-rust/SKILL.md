---
name: create-test-rust
description: "Load this skill when creating or modifying Rust tests for private engine seams and internal module behavior. Skip it for public lurek API tests that belong in Lua or content demo smoke tests."
---
# create-test-rust

## Mission
- Create or modify Rust tests only for internal logic that is not better covered through public Lua API tests.
- Keep Rust tests focused on private seams; there is no repo-wide 100% Rust unit coverage requirement.

## When To Load
- Creating or modifying Rust tests for private engine seams and internal module behavior.

## When To Skip
- Public lurek API tests that belong in Lua or content demo smoke tests.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect `Cargo.toml` test targets and existing `tests/rust/unit/` files before editing.
- Modify the module-specific test target when one exists; create a new Rust test target only when needed and registered in `Cargo.toml`.
- Do not add `#[cfg(test)]` to `src/`; use public/private seams allowed by `src/AGENTS.md`.
- Delete or avoid public-Lua duplication rather than expanding it.
- Run the module-specific Cargo test target from `Cargo.toml`, or `cargo test` when no narrow target exists.
- Run clippy after changing Rust test code or shared helpers.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- The target artifact was created or modified in the narrowest owning location.
- Existing content was preserved and updated when it already owned the behavior.
- Rust tests prove only private/internal behavior that cannot be owned better in Lua.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `src/AGENTS.md`, `tests/AGENTS.md`, `tests/rust/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "Rust tests internal module Cargo target" --profile engine --limit 10`, `cargo test --test <module_tests>`, `cargo test`, `cargo clippy -- -D warnings`
- Owner profile: `tester`

## Common RAG Queries
- Use when finding existing internal Rust test patterns:
  - `Rust tests internal module Cargo target`
  - `#[cfg(test)] mod tests assert`
  - `engine module unit test helper`
- Common areas to inspect after top hits:
  - `src/`
  - `tests/`
  - private helpers near touched modules
  - engine specs in `docs/`

## References
- `contracts: src/AGENTS.md, tests/AGENTS.md, tests/rust/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Rust tests internal module Cargo target" --profile engine --limit 10, cargo test --test <module_tests>, cargo test, cargo clippy -- -D warnings`
- `agent: tester`
