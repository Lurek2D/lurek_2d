# Snake

Snake is a grid arcade game about steering a growing snake through a wrapped board, eating food, and avoiding self-collisions.

## How To Play

- Run `cargo run -- content/newgames/snake`.
- Press `Enter` to start.
- Steer with `WASD` or arrow keys.
- Eat red food to grow and increase speed.
- Avoid hitting your own body.
- Press `Enter` after game over to restart.
- Press `Escape` to quit.

## Implementation

- `main.lua` only wires Lurek callbacks.
- `scripts/state.lua` owns the snake body, wrapped grid movement, food placement, scoring, speed, and death state.
- `scripts/input.lua` maps keyboard controls through `lurek.input` and `lurek.keypressed`.
- `scripts/effects.lua` uses `lurek.particle` for food pickup bursts.
- `scripts/audio.lua` uses `lurek.audio.playSfx`.
- `scripts/renderer.lua` draws the grid, food, snake body, head, and particle effects with `lurek.render`.
- `scripts/ui.lua` drives the TOML HUD and overlays through `lurek.ui`.

## Lurek APIs Used

`lurek.window`, `lurek.input`, `lurek.render`, `lurek.ui`, `lurek.particle`, `lurek.audio`, `lurek.timer`, `lurek.event`, and `lurek.automation`.
