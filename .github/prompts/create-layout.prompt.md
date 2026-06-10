---
name: create-layout
description: "Load this skill when creating or modifying TOML UI layouts under content/layouts and producing visual/evidence validation. Skip it for HTML UI, engine renderer internals, or non-layout Lua examples."
---

# Goal
- Create or modify layout assets that follow current content rules and visual evidence expectations.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-layout/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect existing layouts and UI primitives before editing.
5. Modify a matching layout when present; create a new TOML layout only when no existing asset owns the screen.
6. Keep layout dimensions, anchors, and naming consistent with content conventions.
7. Run snap-to-grid and layout fixer after hand edits.
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
- User: Use `create-layout` for the requested scope.
- Agent: Loads `.codex/skills/create-layout/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-layout/SKILL.md`
- contracts: content/AGENTS.md, content/layouts/AGENTS.md, content/examples/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "content layouts TOML UI primitives" --profile game --limit 10, tools/python.cmd tools/ui/snap_to_grid.py content/layouts/ --grid 8 --recursive, tools/python.cmd tools/ui/fix_layouts.py content/layouts/ --recursive --fix, tests/lua/evidence/test_gui_evidence.lua
- agent: content

