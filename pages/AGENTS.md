# Pages Contract

## Mission & Scope
- Own generated static site output for Lurek2D docs.
- Keep site files derived from docs templates and generators.

## Files
- `404.html`, `CHANGELOG.html`, `sitemap.xml`: Generated site artifacts.
- `lua-docs/`, `modules/`: Generated reference pages.

## Rules
- Do not edit `.html`, `.css`, or `.xml` under `pages/` by hand.
- Change web layout in `docs/templates/` or generators under `tools/`, then rebuild.
- Do not commit broken internal or external links.

## Workflow
- Run `python tools/gen_all_docs.py`.
- Run `python tools/audit/cag_link_check.py --strict`.
