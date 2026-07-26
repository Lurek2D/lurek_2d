# Project Structure

A Lurek project is a folder of Lua scripts, assets, and optional data files. The runtime loads the folder and executes `main.lua`.

```text
my_game/
  conf.toml
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
| `conf.toml` | Optional startup configuration for window and runtime settings. |
| `assets/` | Images, sounds, fonts, and game-specific media. |
| `data/` | TOML, JSON, CSV, or other project data. |
| `scripts/` | Optional Lua modules owned by your project. |

## Runtime Model

The engine owns the window, GPU, audio mixer, input polling, filesystem sandbox, and frame loop. Lua owns game/app state and calls public `lurek.*` APIs.

Use forward slashes in asset paths, even on Windows.

```lua
local image = lurek.render.newImage("assets/player.png")
```

## Next Steps

- [First Game](first-game.md)
- [Lua API Overview](lua-api.md)
- [Examples](examples.md)
