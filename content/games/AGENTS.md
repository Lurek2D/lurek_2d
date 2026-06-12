# Games Contract

## Mission & Scope
- Own runnable game demos, simulations, and prototypes under `content/games/`.
- Keep each game smoke-testable and catalog-ready.

## Files
- `README.md`: Game index by category.
- `*/main.lua`: Required entry point.
- `*/conf.toml`: Optional local config.
- `*/screen.png`: Catalog preview.

## Rules
- Every game folder needs a valid `main.lua` with required callbacks.
- Never call low-level presentation swaps such as `lurek.window.present`.
- Keep game state in local tables or module scope.
- Keep custom assets inside the game folder and load them by relative path.

## Workflow
- Run one demo with `python tools/dev/parallel_cargo.py run debug -- content/games/<category>/<name>/main.lua`.
- Run all game smoke checks with `python tools/demos/smoke_sweep.py --kind game`.
