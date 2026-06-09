# Examples Contract

Covers work under `content/examples/`.

## Mission
- Own runnable API-teaching examples.
- Keep example coverage truthful and easy to audit.

## Scope
- `content/examples/*.lua`.
- Example coverage tags and loader-facing example structure.

## Local map
- `README.md` is the local index.
- `-- @api-stub:` markers map to the runnable block below them.

## Rules
- One file should teach one concept cluster.
- Do not add stub tags without real executable example code underneath them.
- Keep examples aligned with current `docs/api/lurek.md` names and signatures.
- If an API rename or signature change breaks an example, update the example, spec, and generated docs in the same task.

## Workflow
- Run `cargo test --test examples_load_test` after adding or changing an example file.
- Use `python tools/audit/example_coverage.py` when closing API example gaps.

## References
- `content/examples/README.md`
- `docs/api/lurek.md`
- `tools/audit/example_coverage.py`
