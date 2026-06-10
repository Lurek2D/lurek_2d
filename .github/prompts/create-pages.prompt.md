---
name: create-pages
description: "Load this skill when creating or modifying generated docs site templates, pages output, or docs-site build flow. Skip it for plain source docs edits that do not affect generated pages."
---

# Goal
- Create or modify the generated docs site while preserving source/template/output consistency.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-pages/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect source docs, templates, and generated pages before editing.
5. Modify existing templates or generated surfaces when they own the requested display; create new pages only when the site needs a new route.
6. Keep generated output aligned with template/source ownership.
7. Run `tools/python.cmd tools/gen_all_docs.py` after template or generator changes.
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
- User: Use `create-pages` for the requested scope.
- Agent: Loads `.codex/skills/create-pages/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-pages/SKILL.md`
- contracts: docs/AGENTS.md, docs/templates/AGENTS.md, content/AGENTS.md, pages/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "docs templates pages generated site" --profile all --limit 10, tools/python.cmd tools/gen_all_docs.py, tools/python.cmd tools/audit/cag_link_check.py --strict
- agent: doc_writer

