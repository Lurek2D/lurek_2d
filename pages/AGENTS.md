# Pages Contract

Covers work under `pages/`.

## Mission & Scope
- Own the static HTML/CSS web artifacts representing the online documentation portal for Lurek2D.
- Maintain generated search indexes, site navigation listings, sitemaps, and error templates.
- Enforce strict separation between static build outputs and documentation source code.

## Files
- `404.html`: Custom Page Not Found template used by static hosting services.
- `CHANGELOG.html`: Compiled historical change summary derived from repo git logs.
- `sitemap.xml`: XML sitemap containing indexable routes for search engine spiders.
- `lua-docs/` / `modules/`: Directories containing generated reference documents for namespaces and systems.

## Rules
- All files in this directory are static build outputs; never edit any `.html`, `.css`, or `.xml` file under `pages/` manually.
- If web layout or formatting fixes are required, update the generator templates in `docs/templates/` or generator scripts in `tools/` and run a full build.
- Do not check in broken internal or external hyperlinks; the static link checker must pass prior to commits.

## Workflow
- Generate website assets via `python tools/gen_all_docs.py` to compile Markdown documentation into static HTML.
- Validate internal links and directory shapes using `python tools/audit/cag_link_check.py --strict`.

## References
- docs/
- tools/gen_all_docs.py
- tools/audit/cag_link_check.py
