---
name: create-test-rust
description: "Load this skill when creating or modifying Rust tests for private engine seams and internal module behavior. Skip it for public lurek API tests that belong in Lua or content demo smoke tests."
---

# Goal
- Create or modify Rust tests only for internal logic that is not better covered through public Lua API tests.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-test-rust/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect `Cargo.toml` test targets and existing `tests/rust/unit/` files before editing.
5. Modify the module-specific test target when one exists; create a new Rust test target only when needed and registered in `Cargo.toml`.
6. Do not add `#[cfg(test)]` to `src/`; use public/private seams allowed by `src/AGENTS.md`.
7. Run the module-specific Cargo test target from `Cargo.toml`, or `cargo test` when no narrow target exists.
8. Report changed files, findings, validation output, and unresolved blockers.

# Success Criteria
- [ ] The active `.codex/skills` workflow and this legacy prompt do not conflict.
- [ ] Required validation commands are run or explicitly reported as blocked.
- [ ] Output includes concrete files, tools, and owner profile.

# Anti-patterns
- Using `.github/skills` as the active source when `.codex/skills` has a same-name skill.
- Skipping RAG, AGENTS contracts, or repo audit tools before broad manual inspection.
- Creating new artifacts when an existing owner should be modified.

# Example Invocation
- User: Use `create-test-rust` for the requested scope.
- Agent: Loads `.codex/skills/create-test-rust/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-test-rust/SKILL.md`
- contracts: src/AGENTS.md, tests/AGENTS.md, tests/rust/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "Rust tests internal module Cargo target" --profile engine --limit 10, cargo test --test <module_tests>, cargo test, cargo clippy -- -D warnings
- agent: tester

