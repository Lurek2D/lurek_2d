---
name: create-library
description: "Load this skill when creating or modifying pure Lua library modules under library with tests and docs. Skip it for engine Rust modules, content demos, or one-off snippets."
---

# Goal
- Create or modify pure Lua library modules that are reusable, documented, and covered.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-library/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect the target `library/<name>/` and existing library conventions first.
5. Modify an existing library when it owns the requested API; create `init.lua` and docs only for a new library.
6. Keep the public Lua interface small and documented.
7. Add or update Lua tests and examples that exercise real behavior.
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
- User: Use `create-library` for the requested scope.
- Agent: Loads `.codex/skills/create-library/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-library/SKILL.md`
- contracts: library/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "library Lua module conventions" --profile game --limit 10, tools/python.cmd tools/audit/library_coverage.py, tools/python.cmd tools/validate/validate_library.py --lib <name>
- agent: content

