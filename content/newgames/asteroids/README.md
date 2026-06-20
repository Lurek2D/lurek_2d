# Asteroids

Asteroids is a vector-style arcade shooter. The player rotates a drifting ship, uses thrust to dodge rocks, fires limited bullets, clears asteroid waves, and survives with three lives.

## How To Play

- Run `cargo run -- content/newgames/asteroids`.
- Press `Enter` to start.
- Rotate with `A/D` or left/right arrows.
- Thrust with `W` or up arrow.
- Fire with `Space`.
- Press `R` after game over to restart.
- Press `Escape` to quit.

## Implementation

- `main.lua` only wires Lurek callbacks.
- `scripts/config.lua` contains tuning, colors, asset paths, and screen constants.
- `scripts/asteroids.lua` owns asteroid spawning, wave creation, motion, and splitting.
- `scripts/state.lua` owns ship state, bullets, collisions, scoring, lives, and wave progression.
- `scripts/input.lua` maps controls through `lurek.input`.
- `scripts/effects.lua` uses `lurek.particle` and `lurek.tween` for explosions, thrust, and score pops.
- `scripts/audio.lua` uses `lurek.audio.playSfx`.
- `scripts/renderer.lua` draws vector gameplay through `lurek.render`.
- `scripts/ui.lua` drives the TOML HUD through `lurek.ui`.

## Lurek APIs Used

`lurek.window`, `lurek.input`, `lurek.render`, `lurek.ui`, `lurek.particle`, `lurek.tween`, `lurek.audio`, `lurek.timer`, `lurek.event`, and `lurek.automation`.
