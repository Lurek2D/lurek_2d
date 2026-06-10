---
name: create-example
description: "Load this skill when creating or modifying API examples under content/examples for a specific public lurek API. Skip it for full demos, snippets, engine implementation, or non-public internals."
---

# Goal
- Create or modify concise runnable API examples that cover real public behavior.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-example/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect existing examples and current API signatures before writing.
5. Modify an existing example when it already owns the API; create a new file only for an uncovered surface.
6. Keep the example self-contained, runnable, and free of stub calls.
7. Run example coverage before and after the change.
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
- User: Use `create-example` for the requested scope.
- Agent: Loads `.codex/skills/create-example/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-example/SKILL.md`
- contracts: content/AGENTS.md, content/examples/AGENTS.md, docs/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "content examples API coverage" --profile game --limit 10, tools/python.cmd tools/audit/example_coverage.py --module <module>, tools/python.cmd tools/validate/validate_example_coverage.py
- agent: content

