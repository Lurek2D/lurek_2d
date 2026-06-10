---
name: create-module
description: "Load this skill when creating or modifying Rust engine modules in src with Lua API, specs, examples, and tests. Skip it for small docs-only updates, pure Lua content, or VS Code extension work."
---

# Goal
- Create or modify Rust engine modules while keeping public Lua API, specs, examples, and tests aligned.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-module/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect existing `src/<module>/`, `src/lua_api/`, specs, examples, and tests before deciding create vs modify.
5. Create a new top-level module only when no current module owns the behavior.
6. Keep `src/lua_api/` registration-only and implement logic in the domain module.
7. Update specs, generated API docs, Lua tests, and examples when public behavior changes.
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
- User: Use `create-module` for the requested scope.
- Agent: Loads `.codex/skills/create-module/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-module/SKILL.md`
- contracts: src/AGENTS.md, src/lua_api/AGENTS.md, docs/architecture/AGENTS.md, docs/specs/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "Rust engine module lua_api docs specs" --profile engine --limit 10, tools/python.cmd tools/gen_all_docs.py, cargo test, cargo clippy -- -D warnings, tools/python.cmd tools/validate/cag_validate.py
- agent: developer

