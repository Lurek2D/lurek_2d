# Particle Builder

A particle system editor backed by Lurek particle APIs.

## How To Play

- Run `cargo run -- content/newgames/particle_builder`.
- Use the keyboard hints shown in the app.
- Press `Escape` to quit.

## Structure

- `main.lua` wires modules and Lurek callbacks.
- `scripts/state.lua` owns app state.
- `scripts/input.lua` owns controls.
- `scripts/renderer.lua` draws the working surface.
- `ui.toml` defines the retained UI shell.

## Lurek APIs Used

`lurek.render`, `lurek.input`, `lurek.ui`, `lurek.event`, and app-specific APIs such as `lurek.dataframe`, `lurek.particle`, or `lurek.audio`.
