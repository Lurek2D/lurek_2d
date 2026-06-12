---
name: create-test-stress
description: "Load this skill when creating or modifying stress tests, ceilings, or heavy-load validation for a module. Skip it for normal unit tests, integration tests, or benchmark-free code reviews."
---

# Goal
- Create or modify stress coverage that records realistic load ceilings and failure behavior.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-test-stress/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect current stress reports, existing stress tests, and user threshold before editing.
5. Modify an existing stress case when it owns the module; create a new stress path only for missing load coverage.
6. Keep load deterministic and record artifacts under `work/<short-chat-name>/` when temporary output is needed.
7. Run the stress script and monitor OOM, timeout, and frame-time behavior.
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
- User: Use `create-test-stress` for the requested scope.
- Agent: Loads `.codex/skills/create-test-stress/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-test-stress/SKILL.md`
- contracts: tests/AGENTS.md, tests/lua_reorg/AGENTS.md, tools/audit/AGENTS.md, work/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "stress tests performance ceilings" --profile engine --limit 10, tools/python.cmd tools/audit/stress_report.py
- agent: tester

