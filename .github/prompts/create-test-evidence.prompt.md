---
name: create-test-evidence
description: "Load this skill when creating or modifying Lua tests that produce evidence artifacts such as logs, snapshots, or golden files. Skip it for ordinary unit tests without artifacts or performance stress tests."
---

# Goal
- Create or modify evidence tests that produce durable artifacts for public Lua behavior.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-test-evidence/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect existing evidence tests, golden files, and target API before editing.
5. Modify an existing evidence path when it covers the module; create new artifact coverage only for missing contracts.
6. Save evidence in the established baseline artifact location.
7. Run golden comparison and evidence contract audit.
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
- User: Use `create-test-evidence` for the requested scope.
- Agent: Loads `.codex/skills/create-test-evidence/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-test-evidence/SKILL.md`
- contracts: tests/AGENTS.md, tests/lua/AGENTS.md, content/games/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "Lua evidence tests golden artifacts" --profile game --limit 10, tools/python.cmd tools/audit/lua_evidence_golden_contract_audit.py, tools/python.cmd tools/audit/golden_test.py
- agent: tester

