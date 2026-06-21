# Examples Contract

## Mission & Scope
- Own runnable single-file examples for every public `lurek.*` API.
- Keep examples aligned with generated API specs and usable by both humans and agents as the first reference layer.

## Files
- `README.md`: Example index by namespace.
- `*.lua`: One module per file, with all APIs for that module grouped there.
- `assets/`: Resources loaded by examples.

## Rules
- Coverage is 100%: every public Lua API must have exactly one owning example block.
- One API = one `-- @api:` marker = one runnable `do ... end` block.
- Examples teach usage and context; they are not exhaustive tests and they are not mini games.
- Keep examples executable, deterministic enough to boot cleanly, and free of TODO stubs.
- Map every `-- @api:` comment to working code that shows a concrete use case with short prose context.
- Keep the full module example runnable in Lurek without errors even when no assertions are made.
- Use forward-slash paths inside `assets/`.

## Workflow
- Run `tools/python.cmd tools/demos/smoke_sweep.py --kind example`.
- Run `tools/python.cmd tools/audit/example_coverage.py --report --no-stubs --no-partials`.
- If an API belongs in a showcase or evidence artifact instead of an example, move that behavior out; do not widen the example owner.
