# Pages Contract

This file adds local rules for work under `pages/`.

## Mission
- Own the generated static site output published under `pages/`.
- Keep generated web output aligned with the source docs, templates, and generators.

## Local rules
- Treat `pages/` as build output, not as hand-authored source.
- Do not edit HTML, sitemap, or generated asset files here unless the generator itself changed and the output is part of the same regeneration step.
- Source changes for site content belong in `docs/`, `content/`, `library/`, `src/`, or the relevant generator/template files.
- Keep the site navigation, anchors, and page layout consistent with the docs and API sources that generated them.
- If a page structure changes, regenerate the site and verify links rather than patching the emitted HTML manually.

## Workflow
- Read the source template or docs file first, then regenerate the site output from the generator.
- Use the narrowest validation that proves the changed page group still links correctly.

## References
- `docs/`
- `content/`
- `docs/templates/`
- `tools/gen_all_docs.py`
