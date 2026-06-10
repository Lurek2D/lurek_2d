---
name: create-snippet
description: "Load this skill when creating or modifying Lua snippets and generated VS Code snippet output. Skip it for full examples, docs pages, or extension features unrelated to snippets."
---

# Goal
- Create or modify snippets that reflect idiomatic public API usage and generated editor output.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-snippet/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect existing snippets, current API docs, and generated extension output before editing.
5. Modify an existing snippet when it owns the use case; create only for uncovered high-value API usage.
6. Follow snippet template marker order and naming conventions.
7. Regenerate VS Code snippets when inventory changes.
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
- User: Use `create-snippet` for the requested scope.
- Agent: Loads `.codex/skills/create-snippet/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-snippet/SKILL.md`
- contracts: content/snippets/AGENTS.md, docs/AGENTS.md, extension/vscode/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "content snippets API usage" --profile game --limit 10, tools/python.cmd tools/audit/snippet_coverage.py, tools/python.cmd tools/snippets/gen_vscode_snippets.py, tools/python.cmd tools/validate/validate_snippets.py
- agent: doc_writer

