---
name: create-pages
description: Create or modify feature in gitub pages folder, then regnerate all content for modules lua.
---

# GOAL
- Update the GitHub pages structure, styles, or generators, and rebuild the static site content.

# INPUTS REQUIRED
- Target web feature or design change
= User must define the visual or functional change to the docs site
- Agent must collect the site generation pipeline scripts

# STEPS TO DO
1. Load skills: html-css, documentation.
2. Modify the static HTML/CSS template structures inside `docs/`.
3. Execute `python tools/gen_all_docs.py` to rebuild the HTML output. If the script exits with code >0, fix the template parsing errors.
4. Execute `python tools/audit/cag_link_check.py --strict`. If it returns >0 broken links, fix the internal navigation anchors and repeat step 4.

# OUTPUTS PROVIDED
- Modified template files
- Regenerated HTML content

# SUCCESS CRITERIA
- `python tools/gen_all_docs.py` exits with code 0.
- `python tools/audit/cag_link_check.py --strict` reports exactly 0 broken links.

# ANIT PATTERNS
- Hand-editing generated HTML files instead of their templates.
- Introducing heavy JavaScript that impacts doc load times.

# REFERENCES
- skills: html-css, documentation
- tools: python tools/gen_all_docs.py, python tools/audit/cag_link_check.py
- agent: Doc-Writer
