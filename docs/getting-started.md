# Getting Started

Lurek runs Lua scripts through a Rust runtime. A project can be as small as one folder with a `main.lua` file.

## Requirements

- Rust 1.78 or newer for building the engine from source.
- A desktop target: Windows, Linux, or macOS.
- Lua knowledge is useful, but the runtime owns rendering, audio, input, physics, filesystem access, and other engine systems.

## Run An Existing Example

From the repository root:

```powershell
cargo run -- content/examples/render.lua
```

Run a larger reference game:

```powershell
cargo run -- content/games/hex_logistics
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

- If you pass a folder, Lurek looks for `main.lua` inside it.
- If you pass a Lua file, Lurek runs that file as the main script.
- `conf.toml` or `conf.lua` can configure the window and runtime before the script runs.
- If no callback is defined, the script is still valid; callbacks are optional.

## Next Steps

- [First Game](first-game.md)
- [Project Structure](project-structure.md)
- [Lua API Overview](lua-api.md)
- [Examples](examples.md)
