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
- Each example block must contain at least 5 relevant non-comment code lines inside that `do ... end` body.
- Treat each API example block as standalone material for generated API pages.
- Do not put any top-level Lua setup, constants, callbacks, helper functions, helper methods, tables, or reusable logic outside marker-owned `do ... end` blocks.
- Duplicate setup inside each owning `do ... end` block when needed; never make a block depend on code outside that block.
- Examples teach usage and context; they are not exhaustive tests and they are not mini games.
- Keep examples executable, deterministic enough to boot cleanly, and free of TODO stubs.
- Map every `-- @api:` comment to working code that shows a concrete use case with short prose context.
- Keep the full module example runnable in Lurek without errors even when no assertions are made.
- Use forward-slash paths inside `assets/`.

## Workflow
- Run `tools/python.cmd tools/demos/smoke_sweep.py --kind example`.
- Run `tools/python.cmd tools/audit/example_coverage.py --report --no-stubs --no-partials`.
- If an API belongs in a showcase or evidence artifact instead of an example, move that behavior out; do not widen the example owner.
