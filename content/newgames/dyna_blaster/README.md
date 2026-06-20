# Dyna Blaster

**Category:** Newgames selection  
**Source reference:** `content/games/arcade/dyna_blaster`  
**Runtime path:** `content/newgames/dyna_blaster`

## Design

Bomb maze action game. This newgames version is kept as a playable mini-game entry, not an API showcase. The original candidate was copied only as reference material and normalized into the `content/newgames` contract.

## How To Play

- Run `cargo run -- content/newgames/dyna_blaster`.
- Use the controls shown in-game or inherited from the original game screen.
- Press `Escape` to quit where the game supports it.
- Use `R`, `Space`, or `Enter` for restart/start actions where the game supports them.

## Structure

- `main.lua` is a thin bootstrap.
- `scripts/game.lua` contains the selected playable game runtime.
- `scripts/project.lua` stores newgames metadata.
- `assets/` contains local generated PNG/audio assets and source notes.
- `screen.png` is the gameplay catalog screenshot.

## Lurek APIs

This entry uses the Lurek APIs already present in the selected game, commonly including `lurek.render`, `lurek.input`, `lurek.ui`, `lurek.particle`, `lurek.audio`, `lurek.timer`, and `lurek.event`.
