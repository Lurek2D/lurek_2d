---
name: create-pages
description: "Create or modify feature in gitub pages folder, then regnerate all content for modules lua."
---
# create-pages

## Goal
- Update the GitHub pages structure, styles, or generators, and rebuild the static site content.

## Required inputs
- Target web feature or design change
- User must define the visual or functional change to the docs site
- Agent must collect the site generation pipeline scripts

## Profile hint
- `architect`

## Load these skills
- `ui-html`
- `docs-general`

## Steps
- Load skills: ui-html, docs-general.
- Modify the static HTML/CSS template structures inside `docs/`.
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
- `skills: ui-html, docs-general`
- `tools: python tools/gen_all_docs.py, python tools/audit/cag_link_check.py`
- `agent: Doc-Writer`

## Invocation rules
- This is a user-invoked workflow. Do not auto-load it as a generic background skill.
- Start only after the user explicitly requests this named workflow or a clearly equivalent task.

