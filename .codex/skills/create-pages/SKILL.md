---
name: create-pages
description: "Load this skill when creating or modifying generated docs site templates, pages output, or docs-site build flow. Skip it for plain source docs edits that do not affect generated pages."
---
# create-pages

## Mission
- Create or modify the generated docs site while preserving source/template/output consistency.

## When To Load
- Creating or modifying generated docs site templates, pages output, or docs-site build flow.

## When To Skip
- Plain source docs edits that do not affect generated pages.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect source docs, templates, and generated pages before editing.
- Modify existing templates or generated surfaces when they own the requested display; create new pages only when the site needs a new route.
- Keep generated output aligned with template/source ownership.
- Run `tools/python.cmd tools/gen_all_docs.py` after template or generator changes.
- Run strict link checking for navigation and CAG links.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- The target artifact was created or modified in the narrowest owning location.
- Existing content was preserved and updated when it already owned the behavior.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `docs/AGENTS.md`, `docs/templates/AGENTS.md`, `content/AGENTS.md`, `pages/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "docs templates pages generated site" --profile all --limit 10`, `tools/python.cmd tools/gen_all_docs.py`, `tools/python.cmd tools/audit/cag_link_check.py --strict`
- Owner profile: `doc_writer`

## Common RAG Queries
- Use when locating docs-site templates and generators:
  - `docs templates pages generated site`
  - `pages build docs markdown template`
  - `sidebar nav frontmatter generated page`
- Common areas to inspect after top hits:
  - `pages/`
  - `docs/`
  - docs build scripts in `tools/`
  - generated site assets

## References
- `contracts: docs/AGENTS.md, docs/templates/AGENTS.md, content/AGENTS.md, pages/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "docs templates pages generated site" --profile all --limit 10, tools/python.cmd tools/gen_all_docs.py, tools/python.cmd tools/audit/cag_link_check.py --strict`
- `agent: doc_writer`
