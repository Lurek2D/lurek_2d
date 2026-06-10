---
name: create-demo
description: "Load this skill when creating or modifying runnable Lua demo games under content/games with validation and smoke coverage. Skip it for single-file examples, engine internals, or pure library modules."
---

# Goal
- Create or modify runnable demo games that exercise real Lurek2D APIs and remain validator-safe.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-demo/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect the target demo folder and nearby demos before deciding create vs modify.
5. Create a new `content/games/<name>/` only when no matching demo exists; otherwise modify the existing demo.
6. Keep `main.lua`, config, assets, and README aligned with current demo conventions.
7. Use real `lurek.*` calls and avoid placeholder gameplay.
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
- User: Use `create-demo` for the requested scope.
- Agent: Loads `.codex/skills/create-demo/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-demo/SKILL.md`
- contracts: content/AGENTS.md, content/games/AGENTS.md, tests/lua/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "content games demo conventions" --profile game --limit 10, tools/python.cmd tools/validate/validate_game.py <demo-dir>, cargo test --test demo_smoke_tests
- agent: content

