---
name: create-tool
description: "Load this skill when creating or modifying tools under tools, audit scripts, validators, generators, or CLI registry entries. Skip it for product runtime changes or one-off local scripts that should stay in work/."
---

# Goal
- Create or modify repo tools so they are discoverable, documented, locally runnable, and registered.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-tool/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect existing tool family, `tools/agent_cli_reference.md`, and nearest `AGENTS.md` before editing.
5. Modify an existing tool when it owns the behavior; create a new script only for a new reusable command.
6. Implement `--help`, deterministic output, and Windows-local execution.
7. Register changed tools in `tools/agent_cli_reference.md`.
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
- User: Use `create-tool` for the requested scope.
- Agent: Loads `.codex/skills/create-tool/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-tool/SKILL.md`
- contracts: tools/AGENTS.md, tools/audit/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "tools audit validator CLI registry" --profile engine --limit 10, tools/python.cmd tools/audit/tool_registry_audit.py, tools/python.cmd tools/validate/cag_validate.py
- agent: builder

