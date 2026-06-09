# Examples Contract

Covers work under `content/examples/`.

## Mission & Scope
- Deliver runnable, single-file teaching examples for every namespace in the public `lurek.*` API surface.
- Keep examples isolated and simple to serve as reference snippets for engine and game developers.
- Maintain accurate alignment with the generated API reference specs to avoid user confusion.

## Files
- `README.md`: Index mapping example scripts to target namespaces.
- `*.lua`: Namespace-specific example files (e.g., `physics.lua`, `render.lua`, `ui.lua`).
- `assets/`: Textures, fonts, sound files, and other resources loaded by the examples.

## Rules
- One file must teach exactly one namespace or closely related API namespace; do not cross-pollinate logic.
- Keep example code strictly executable and free of stub blocks; always map `-- @api-stub:` comments to working, runnable code blocks.
- Never write complex game state machines here; focus on clear, step-by-step API usage.
- All asset lookups in examples must use forward slashes and refer to subfolders inside the `assets/` directory.

## Workflow
- Run the full smoke test sweep `python tools/demos/smoke_sweep.py --kind example` after modifying any example.
- Validate API mappings using `python tools/audit/example_coverage.py` to identify missing namespace stubs.

## References
- content/examples/README.md
- docs/api/lurek.md
- tools/audit/example_coverage.py
