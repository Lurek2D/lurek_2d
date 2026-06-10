---
name: create-rag-artifact
description: "Load this skill when creating or modifying RAG corpus configuration, indexing rules, retrieval ranking, or recall tests. Skip it for normal code search, one-off rg usage, or unrelated docs edits."
---

# Goal
- Create or modify RAG sources, ranking, and indexes so Codex retrieval finds canonical repo context.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-rag-artifact/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect `tools/rag/rag.toml`, `build_index.py`, `query.py`, and current recall before changing configuration.
5. Modify existing source lists, chunking, or ranking before adding new indexing logic.
6. Rebuild the index after source or ranking changes.
7. Run recall queries for `.codex/skills`, `.codex/AGENTS.md`, and active `.codex/agents/*.toml`.
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
- User: Use `create-rag-artifact` for the requested scope.
- Agent: Loads `.codex/skills/create-rag-artifact/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-rag-artifact/SKILL.md`
- contracts: .codex/AGENTS.md, tools/AGENTS.md, tools/rag/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "RAG rag.toml build_index query" --profile engine --limit 10, tools/python.cmd tools/rag/build_index.py, tools/python.cmd tools/rag/query.py "create-module skill" --profile all --limit 10, tools/python.cmd tools/rag/query.py "Codex AGENTS skills agents" --profile engine --limit 10
- agent: cag_architect

