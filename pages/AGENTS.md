# Pages Contract

Adds local rules for `pages/`.

## Mission & Scope
- Own the static HTML/CSS artifacts for the Lurek2D docs site.
- Maintain generated search indexes, nav lists, sitemaps, and error templates.
- Keep static build output separate from doc source.

## Files
- `404.html`: Custom not-found page.
- `CHANGELOG.html`: Compiled change summary from repo history.
- `sitemap.xml`: XML sitemap for indexed routes.
- `lua-docs/` / `modules/`: Generated reference docs for namespaces and systems.

## Rules
- All files in this directory are static build outputs; never edit any `.html`, `.css`, or `.xml` file under `pages/` manually.
- If web layout or formatting must change, update templates in `docs/templates/` or generators in `tools/`, then rebuild.
- Do not check in broken internal or external hyperlinks; the static link checker must pass prior to commits.

## Workflow
- Generate website assets via `python tools/gen_all_docs.py` to compile Markdown documentation into static HTML.
- Validate internal links and directory shapes using `python tools/audit/cag_link_check.py --strict`.

## References
- docs/
- tools/gen_all_docs.py
- tools/audit/cag_link_check.py
