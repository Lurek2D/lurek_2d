# Games Contract

Covers work under `content/games/`.

## Mission & Scope
- Deliver category-grouped 2D game demos, simulations, and prototypes showcasing real-world game logic in Lurek2D.
- Maintain standard configuration templates and lifecycle entry points across all games.
- Ensure every game is fully runnable and compliant with automated smoke tests and headless runners.

## Files
- `README.md`: List of all games grouped by categories (e.g., `action/`, `arcade/`, `rpg/`, `simulation/`).
- `*/main.lua`: Required entry points implementing game loops and callbacks.
- `*/conf.toml`: Optional local configs specifying window settings and asset dependencies.
- `*/screen.png`: Visual preview screenshots used in catalog indexing.

## Rules
- Every game folder must have a valid `main.lua` entry script implementing the required callbacks (tick, physics, draw).
- Never invoke low-level window buffers or manual presentation swaps like `lurek.window.present`; frame swaps are owned by the engine runtime.
- Keep all local game states isolated inside local tables or module scopes to facilitate hot-reloading.
- Custom game assets must live exclusively inside the game's subdirectory and be loaded via relative paths.

## Workflow
- Run individual game demos via `python tools/dev/parallel_cargo.py run debug -- content/games/<category>/<name>/main.lua`.
- Validate all games load and capture screenshots using `python tools/demos/smoke_sweep.py --kind game`.

## References
- content/games/README.md
- tests/games_load_test.rs
