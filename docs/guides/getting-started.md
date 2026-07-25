# Getting Started

Lurek2D runs Lua scripts through a Rust desktop runtime. A project can start as one folder with a `main.lua` file and grow into a larger game, simulation, or local tool.

## Requirements

- Rust 1.78 or newer when building the engine from source.
- A desktop target: Windows, Linux, or macOS.
- Basic Lua knowledge helps, but the runtime owns rendering, audio, input, physics, filesystem access, and other engine systems.

## Run An Existing Example

From the repository root:

```powershell
cargo run -- content/examples/render.lua
```

Run a larger reference game:

```powershell
cargo run -- lurek_2d_content/games/hex_logistics
```

## Create A Small Project

Create a folder with this shape:

```text
my_game/
  main.lua
  assets/
  data/
```

Then run it:

```powershell
cargo run -- path/to/my_game
```

## How The Runtime Finds Your Game

- If you pass a folder, Lurek2D looks for `main.lua` inside it.
- If you pass a Lua file, Lurek2D runs that file as the main script.
- `conf.toml` or `conf.lua` can configure the window and runtime before the script runs.
- Callbacks are optional; a script can still be valid without defining every runtime hook.

## Next Steps

- [First Game](first-game.md)
- [Project Structure](project-structure.md)
- [Lua API Overview](../lua-api.md)
- [Examples](examples.md)
