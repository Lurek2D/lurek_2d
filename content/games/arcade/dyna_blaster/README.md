# Dyna Blaster

Top-down bomber-style arcade demo using scene flow, ECS entities, grid explosions, and TOML-driven UI.

## Features

- Scene flow with `lurek.scene` (menu, gameplay, game-over)
- Entity logic with `lurek.ecs` (player, enemies, bombs, flames)
- Direct game rendering with `lurek.render`
- HUD and overlays from `lurek.ui.loadLayoutFile` + `ui.toml`
- Grid blast propagation blocked by solid walls and destructible crates

## How to run

```bash
cargo run -- content/games/arcade/dyna_blaster
```

## What to look for

Move on the grid, place bombs, clear crates, and avoid blast zones. Enemy bots wander and can be removed by explosions. Losing all lives switches to the game-over scene.
