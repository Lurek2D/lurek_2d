# Examples Contract

This file adds local rules for work under `content/examples/`.

## Mission
- Own runnable API-teaching examples.
- Keep example coverage truthful and easy to audit.

## Scope
- `content/examples/*.lua`
- Example coverage tags and loader-facing example structure.

## Local rules
- One file should teach one concept cluster, not the whole module.
- Keep each `-- @api-stub:` marker immediately above the runnable block it documents.
- Do not add stub tags without real executable example code underneath them.
- Keep examples aligned with current `docs/api/lurek.md` names and signatures.
- If an API rename or signature change breaks an example, update the example, the spec, and the generated docs in the same task.

## Workflow
- Run `cargo test --test examples_load_test` after adding or changing an example file.
- Use `python tools/audit/example_coverage.py` when the goal is closing API example gaps.

## References
- `content/examples/README.md`
- `docs/api/lurek.md`
- `tools/audit/example_coverage.py`
