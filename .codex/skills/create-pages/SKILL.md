---
name: create-pages
description: "Load this skill when creating or modifying generated docs site templates, pages output, or docs-site build flow. Skip it for plain source docs edits that do not affect generated pages."
---

# create-pages

## Mission
- Create or modify the generated docs site while preserving source/template/output consistency.

## Domain Knowledge
- `../lurek_2D_pages/` is generated site output; durable prose lives in `docs/`, page structure in generators under `tools/docs/`, and reusable presentation scaffolding in `docs/templates/` or generator-owned templates.
- The docs pipeline has multiple products—module pages, API reference, Lua docs, search data, sitemap, and index/navigation—so a source change can be correct while one downstream index remains stale.
- Stable anchors and relative links are public site contracts. Renaming a heading, route, or generated filename requires checking incoming links and search/navigation consumers, not just the rendered target.
- Generated diffs should be deterministic and attributable to source/template changes; timestamps, filesystem order, or environment-specific paths are generator defects.
- Visual correctness includes code wrapping, navigation hierarchy, mobile width, dark/light contrast where supported, and absence of source-template tokens in final HTML.
- Page generators should escape prose, code, anchors, and metadata according to their output context. Trusted Markdown and generated symbol data still need distinct HTML/attribute/URL handling to prevent malformed pages.
- Search index and sitemap generation are content-discovery contracts: canonical URLs, titles, headings, and exclusion rules should match rendered routes so stale or private/generated fragments do not become primary entry points.
- Asset references must remain deployable from the static site root and nested routes; a page that works only when opened from the repository filesystem has not validated its URL strategy.

## Workflow
- Trace one representative output backward from `../lurek_2D_pages/` to its generator, template, source doc, module metadata, and navigation/search registration; decide whether the request changes content, shared presentation, or route topology before editing.
- Modify the upstream owner and run the narrow generator first, inspecting the emitted HTML/data diff for unintended pages, unstable ordering, broken anchors, or leaked absolute paths before running the full docs build.
- Render representative index, module, API, and code-heavy pages at desktop and narrow widths when shared templates/styles change; test navigation, search entry, cross-links, and 404 behavior for new or renamed routes.
- Run the complete docs generation, freshness checks, and strict link audit; ensure a second generation produces no diff and review generated changes as build artifacts rather than hand-correcting `../lurek_2D_pages/`.
- Serve or open the generated site through the same relative-root assumptions as deployment and inspect browser-console/network failures for representative nested routes, rather than validating only raw HTML text.
- Compare page metadata, canonical links, sitemap entries, and search results for a new or renamed route, ensuring deletion/redirect handling does not leave duplicate discoverable pages.

## References
- `contracts: docs/AGENTS.md, docs/templates/AGENTS.md, content/AGENTS.md, ../lurek_2D_pages/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "docs templates pages generated site" --profile all --limit 10, tools/python.cmd tools/gen_all_docs.py, tools/python.cmd tools/audit/cag_link_check.py --strict`
- `agent: doc_writer`
- RAG: Use when locating docs-site templates and generators; `docs templates pages generated site`; `pages build docs markdown template`; `sidebar nav frontmatter generated page`; `../lurek_2D_pages/`; `docs/`; docs build scripts in `tools/`; generated site assets
