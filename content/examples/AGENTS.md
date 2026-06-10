# Examples Contract

Adds local rules for `content/examples/`.

## Mission & Scope
- Deliver runnable single-file teaching examples for the public `lurek.*` API.
- Keep examples isolated and simple as reference snippets.
- Keep examples aligned with the generated API specs.

## Files
- `README.md`: Index of example scripts by namespace.
- `*.lua`: Namespace example files such as `physics.lua`, `render.lua`, and `ui.lua`.
- `assets/`: Textures, fonts, sound files, and other resources loaded by the examples.

## Rules
- One file must teach one namespace or one tight related group. Do not mix unrelated logic.
- Keep example code executable and free of stubs. Map `-- @api-stub:` comments to working code.
- Never write complex game state machines here. Focus on clear API usage.
- All asset lookups in examples must use forward slashes and refer to subfolders inside the `assets/` directory.

## Workflow
- Run the full smoke test sweep `python tools/demos/smoke_sweep.py --kind example` after modifying any example.
- Validate API mappings using `python tools/audit/example_coverage.py` to identify missing namespace stubs.

## References
- content/examples/README.md
- docs/api/lurek.md
- tools/audit/example_coverage.py
