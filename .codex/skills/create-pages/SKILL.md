---
name: create-pages
description: "Load this skill when creating or modifying generated docs site templates, pages output, or docs-site build flow. Skip it for plain source docs edits that do not affect generated pages."
---

# create-pages

## Mission
- Create or modify the generated docs site while preserving source/template/output consistency.

## Domain Knowledge
- Generated docs pages live under `lurek_2d_pages/`.
- Durable source prose lives under `docs/`.
- Page generators live under `tools/docs/`.
- Shared docs templates live under `docs/templates/`.
- Generated pages are not hand-edited.
- Module pages, API pages, Lua docs, indexes, search data, and sitemap are separate outputs.
- Route names, filenames, anchors, and relative links are public site contracts.
- A route rename affects navigation, search, sitemap, and incoming links.
- Generated output must not contain absolute workspace paths.
- The same pages source and templates must emit identical site files.
- A second full generation run must produce no diff.
- HTML text, attributes, anchors, and URLs use correct escaping.
- Static assets work from the site root and nested routes.
- Shared page changes are checked at desktop and narrow widths.
- Code blocks must wrap or scroll without breaking layout.
- Search and sitemap entries must match rendered canonical routes.
- Deployable page output includes `index.html`, `api/`, `lua-docs/`, `modules/`, `assets/`, `search/`, and `sitemap.xml`.
- Only output produced by the documented generator flow belongs in the pages repository.
- A source or template fix is made in the engine workspace before pages are regenerated.
- Representative review covers the index, one module route, one API route, and one nested route.
- Relative-root links must work from both the site root and nested directories.
- Canonical metadata is generated with the same route used by navigation and sitemap entries.

## Workflow
1. Read the docs, template, and pages contracts.
2. Select one representative generated output.
3. Trace it to source prose, metadata, generator, and template.
4. Classify the change as content, presentation, or route topology.
5. Edit the upstream owner.
6. Run the narrow generator.
7. Inspect HTML or data output for unrelated changes.
8. Check ordering, anchors, links, and absolute paths.
9. Render representative index, module, API, and code-heavy pages.
10. Check desktop and narrow widths.
11. Test navigation, search, cross-links, and new routes.
12. Check canonical metadata and sitemap entries.
13. Run the full docs generation.
14. Run freshness and strict link checks.
15. Run full generation a second time.
16. Require no second-run diff.

## References
- `contracts: docs/AGENTS.md, docs/templates/AGENTS.md, lurek_2d_pages/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "docs templates pages generated site" --profile all --limit 10, tools/python.cmd tools/gen_all_docs.py, tools/python.cmd tools/audit/cag_link_check.py --strict`
- `agent: doc_writer`
- RAG: `docs templates pages generated site <route>`; trace one output in `lurek_2d_pages/` back to its source, generator, template, and navigation/search owner.
