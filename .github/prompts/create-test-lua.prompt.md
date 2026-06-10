---
name: create-test-lua
description: "Load this skill when creating or modifying Lua tests for public lurek APIs under tests/lua. Skip it for Rust-only internals, integration-only coverage, or visual evidence tests."
---

# Goal
- Create or modify Lua tests that are canonical coverage for public `lurek.*` APIs.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-test-lua/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect existing test files, harness registration, and coverage output before writing.
5. Modify the matching `tests/lua/` file when present; create a new file only for uncovered module coverage.
6. Use `@covers` markers, specific assertions, and `test_summary()`.
7. Register new files in `tests/lua/harness.rs`.
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
- User: Use `create-test-lua` for the requested scope.
- Agent: Loads `.codex/skills/create-test-lua/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-test-lua/SKILL.md`
- contracts: tests/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "Lua unit tests public API coverage" --profile game --limit 10, tools/python.cmd tools/audit/lua_api_test_coverage.py --module <module>, tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/, cargo test --test lua_tests, tools/python.cmd tools/validate/cag_validate.py
- agent: tester

