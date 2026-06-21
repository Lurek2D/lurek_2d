# Games Contract

## Mission & Scope
- Own finished runnable games and mini games under `content/games/`.
- Keep `content/games/` reserved for complete playable projects, not API showcases or mechanic scraps.

## Files
- `README.md`: Public catalog of finished catalog candidates only.
- `*/main.lua`: Required entry point.
- `*/conf.toml`: Optional local config.
- `*/screen.png`: Catalog preview.
- `*/README.md`: Declares the project status and should state `Scale: game` or `Scale: minigame`.

## Rules
- Every game folder needs a valid `main.lua` with required callbacks.
- Every entry must be a complete playable product. Small is fine; incomplete is not.
- `game` and `minigame` differ by scope only. Both still need rules, gameplay loop, menu/UI where needed, scoring/progression where needed, and AI/systems where the design calls for them.
- `content/games/` is not the home for API showcases, single-mechanic labs, or examples of 2-3 features.
- If a folder mainly demonstrates one API or produces a useful artifact, move that value to `content/examples/` or `tests/lua/evidence/` before keeping or deleting the game folder.
- Never call low-level presentation swaps such as `lurek.window.present`.
- Keep game state in local tables or module scope.
- Keep custom assets inside the game folder and load them by relative path.

## Workflow
- Classify legacy content first with `tools/python.cmd tools/demos/audit_games.py`.
- Keep only catalog-ready `KEEP` entries in the generated README; backlog and migration work belongs in `work/games-audit.*`.
- Run one game with `tools/python.cmd tools/dev/parallel_cargo.py run debug -- content/games/<category>/<name>/main.lua`.
- Run all game smoke checks with `tools/python.cmd tools/demos/smoke_sweep.py --kind game`.
