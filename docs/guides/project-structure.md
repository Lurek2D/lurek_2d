# Project Structure

A Lurek2D project is a folder of Lua scripts, assets, and optional data files. The runtime loads that folder and executes `main.lua`.

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

## Common Files

| Path | Role |
|---|---|
| `main.lua` | Entry script. Define callbacks here or `require()` your own modules. |
| `conf.toml` or `conf.lua` | Optional startup configuration for window and runtime settings. |
| `assets/` | Images, sounds, fonts, and other game-specific media. |
| `data/` | TOML, JSON, CSV, or other authored data files. |
| `scripts/` | Optional Lua modules owned by your project. |

## Runtime Model

The engine owns the window, GPU, audio mixer, input polling, filesystem sandbox, and frame loop. Lua owns game state and calls the public `lurek.*` APIs.

Use forward slashes in asset paths, even on Windows:

```lua
local image = lurek.render.newImage("assets/player.png")
```

## Contributor Note

Examples, snippets, specs, and generated docs are repository content, not part of your shipped game folder. If you are working on the engine itself, start from [Contributor Docs](../contributing/index.md).

## Next Steps

- [First Game](first-game.md)
- [Lua API Overview](../lua-api.md)
- [Examples](examples.md)
