---
name: create-pages
description: "Create or modify the generated docs site and the templates that feed it."
---
# create-pages

## Goal
- Update the generated docs site structure, styles, or generators, and rebuild the published static site content.

## Required inputs
- Target web feature or design change
- User must define the visual or functional change to the docs site
- Agent must collect the site generation pipeline scripts

## Profile hint
- `architect`

## Read these contracts
- `docs/AGENTS.md`
- `docs/templates/AGENTS.md`
- `content/AGENTS.md`
- `pages/AGENTS.md`

## Steps
- Read the listed contracts before changing docs-site templates, source docs, or generated-site markup.
- Modify the source templates inside `docs/templates/` or the source docs/content that feed the site.
- Regenerate `pages/` from the source docs and templates; do not hand-edit generated HTML unless the generator output is the artifact under test.
- Execute `python tools/gen_all_docs.py` to rebuild the HTML output. If the script exits with code >0, fix the template parsing errors.
- Execute `python tools/audit/cag_link_check.py --strict`. If it returns >0 broken links, fix the internal navigation anchors and repeat step 4.

## Outputs
- Modified template files
- Regenerated HTML content

## Success criteria
- [ ] `python tools/gen_all_docs.py` exits with code 0.
- [ ] `python tools/audit/cag_link_check.py --strict` reports exactly 0 broken links.

## Stop conditions
- Hand-editing generated HTML files instead of their templates.
- Introducing heavy JavaScript that impacts doc load times.

## References
- `contracts: docs/AGENTS.md, docs/templates/AGENTS.md, content/AGENTS.md, pages/AGENTS.md`
- `tools: python tools/gen_all_docs.py, python tools/audit/cag_link_check.py`
- `agent: Doc-Writer`

