# Examples Contract

## Mission & Scope
- Own runnable single-file examples for public `lurek.*` APIs.
- Keep examples small, isolated, and synced with generated API specs.

## Files
- `README.md`: Example index by namespace.
- `*.lua`: One namespace or tight API group per file.
- `assets/`: Resources loaded by examples.

## Rules
- Teach clear API usage, not full game state machines.
- Keep examples executable and free of stubs.
- Map `-- @api:` comments to working code.
- Use forward-slash paths inside `assets/`.

## Workflow
- Run `python tools/demos/smoke_sweep.py --kind example`.
- Run `python tools/audit/example_coverage.py` for API mapping gaps.
