# Project Structure

A Lurek project is a folder of Lua scripts, assets, and optional data files. The runtime loads the folder and executes `main.lua`.

```text
my_game/
  conf.toml or conf.lua
  main.lua
  assets/
    player.png
    click.ogg
  data/
    level1.toml
  scripts/
    enemies.lua
```

## Files

| Path | Role |
|---|---|
| `main.lua` | Entry script. Define callbacks here or require your own modules. |
| `conf.toml` or `conf.lua` | Optional startup configuration for window and runtime settings. |
| `assets/` | Images, sounds, fonts, and game-specific media. |
| `data/` | TOML, JSON, CSV, or other project data. |
| `scripts/` | Optional Lua modules owned by your project. |

## Runtime Model

The engine owns the window, GPU, audio mixer, input polling, filesystem sandbox, and frame loop. Lua owns game/app state and calls public `lurek.*` APIs.

Use forward slashes in asset paths, even on Windows.

```lua
local image = lurek.render.newImage("assets/player.png")
```

## Core Terms

- `lurek.*` is the public engine API used by game scripts.
- A callback is a function invoked by the runtime, such as `lurek.init`, `lurek.process(dt)`, or `lurek.draw`.
- `dt` is the elapsed time since the previous frame in seconds.
- `main.lua` is the project entry script; `conf.toml` or `conf.lua` is optional startup configuration.
- Lureksome is the collection of reusable pure-Lua libraries layered over the runtime API.

## Next Steps

- [First Game](first-game.md)
- [Lua API Overview](lua-api.md)
- [Examples](examples.md)
