# Games Contract

Adds local rules for `content/games/`.

## Mission & Scope
- Deliver category-grouped 2D game demos, simulations, and prototypes.
- Maintain standard config templates and lifecycle entry points.
- Keep every game runnable in smoke tests and headless runners.

## Files
- `README.md`: Game index by category such as `action/`, `arcade/`, `rpg/`, and `simulation/`.
- `*/main.lua`: Required entry point for game loops and callbacks.
- `*/conf.toml`: Optional local config for window settings and assets.
- `*/screen.png`: Visual preview screenshots used in catalog indexing.

## Rules
- Every game folder must have a valid `main.lua` with the required callbacks.
- Never call low-level window buffers or manual presentation swaps like `lurek.window.present`.
- Keep local game state inside local tables or module scope.
- Custom game assets must live exclusively inside the game's subdirectory and be loaded via relative paths.

## Workflow
- Run individual game demos via `python tools/dev/parallel_cargo.py run debug -- content/games/<category>/<name>/main.lua`.
- Validate all games load and capture screenshots using `python tools/demos/smoke_sweep.py --kind game`.

## References
- content/games/README.md
- tests/games_load_test.rs
