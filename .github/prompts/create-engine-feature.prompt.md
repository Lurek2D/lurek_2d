---
name: create-engine-feature
description: "Load this skill when creating or modifying Rust engine features that may touch modules, Lua API, specs, examples, and tests end to end. Skip it for docs-only reviews, content-only demos, or VS Code extension work."
---

# Goal
- Deliver engine feature changes end to end while keeping public Lua contracts, specs, examples, and tests in sync.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-engine-feature/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect the existing module, spec, Lua API wrapper, examples, and tests before choosing create vs modify.
5. Use `create-module` only when a new top-level module is needed; otherwise update the existing owner module.
6. Change Lua API, specs, examples, and tests only when public behavior changes.
7. Keep `src/lua_api/` thin and put business logic in the Rust domain module.
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
- User: Use `create-engine-feature` for the requested scope.
- Agent: Loads `.codex/skills/create-engine-feature/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-engine-feature/SKILL.md`
- contracts: src/AGENTS.md, src/lua_api/AGENTS.md, tests/AGENTS.md, content/examples/AGENTS.md, docs/specs/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "engine feature src lua_api specs tests" --profile engine --limit 10, cargo test, cargo clippy -- -D warnings, tools/python.cmd tools/gen_all_docs.py, tools/python.cmd tools/validate/cag_validate.py
- agent: developer

