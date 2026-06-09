# Pages Contract

Covers work under `pages/`.

## Mission
- Own the generated static site output under `pages/`.
- Keep generated web output aligned with source docs, templates, and generators.

## Scope
- `pages/` generated static site output.

## Local map
- `docs/`, `content/`, `library/`, `src/`, and generator templates are the source inputs.
- Navigation, anchors, and page layout should match the generated sources.

## Rules
- Treat `pages/` as build output, not hand-authored source.
- Do not edit HTML, sitemap, or generated asset files here unless the generator changed and the output is part of the same regeneration.
- Regenerate and verify links when page structure changes.

## Workflow
- Read the source template or docs file first, then regenerate the site output from the generator.
- Use the narrowest validation that proves the changed page group still links correctly.

## References
- `docs/`
- `content/`
- `docs/templates/`
- `tools/gen_all_docs.py`
