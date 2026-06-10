---
name: create-integration-test
description: "Load this skill when creating or modifying Lua integration tests that prove interactions between two or more modules. Skip it for single-module unit tests, Rust-only internal tests, or performance stress tests."
---

# Goal
- Create or modify integration tests that verify cross-module public Lua behavior.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-integration-test/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect existing integration tests and involved API specs before writing.
5. Modify an existing integration file for the module pair when present; create under `tests/lua/integration/` only for new coverage.
6. Use public `lurek.*` APIs and explicit state assertions.
7. Add or confirm harness registration when a new file is introduced.
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
- User: Use `create-integration-test` for the requested scope.
- Agent: Loads `.codex/skills/create-integration-test/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-integration-test/SKILL.md`
- contracts: tests/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "Lua integration tests module interaction" --profile game --limit 10, tools/python.cmd tools/audit/integration_coverage.py, cargo test --test lua_tests
- agent: tester

