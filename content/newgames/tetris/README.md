# Falling Blocks

Falling Blocks is a compact Tetris-style arcade game. The player rotates and places tetrominoes, clears full rows, manages a hold slot, and survives as the drop speed rises with each level.

## How To Play

- Run `cargo run -- content/newgames/tetris`.
- Press `Enter` to start.
- Move with `A/D` or arrow keys.
- Rotate with `W` or `Up`.
- Hold `S` or `Down` for soft drop.
- Press `Space` for hard drop.
- Press `C` to hold one piece.
- Press `R` after game over to restart, or `Escape` to quit.

## Implementation

- `main.lua` only wires Lurek callbacks and modules.
- `scripts/pieces.lua` owns tetromino definitions and rotation.
- `scripts/board.lua` owns board collision, locking, ghost drop, and line clearing.
- `scripts/state.lua` owns score, level, active piece, hold slot, and game-state transitions.
- `scripts/input.lua` maps player controls through `lurek.input`.
- `scripts/effects.lua` uses `lurek.particle` and `lurek.tween` for line-clear feedback.
- `scripts/audio.lua` uses `lurek.audio.playSfx` for short feedback sounds.
- `scripts/renderer.lua` uses `lurek.render` for board, pieces, ghost, previews, and particles.
- `scripts/ui.lua` drives the TOML HUD through `lurek.ui`.

## Lurek APIs Used

`lurek.window`, `lurek.input`, `lurek.render`, `lurek.ui`, `lurek.particle`, `lurek.tween`, `lurek.audio`, `lurek.timer`, `lurek.event`, and `lurek.automation`.
