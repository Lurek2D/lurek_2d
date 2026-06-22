# Reference Games

Reference games are larger playable projects under `content/games/`. They show how several `lurek.*` modules fit together in a complete loop.

## Current Catalog

The generated source catalog is [content/games/README.md](https://github.com/Lurek2D/lurek_2d/blob/main/content/games/README.md).

Good starting points:

| Game | What it demonstrates |
|---|---|
| Cannon Fodder | Input, render, timer, UI, and automation patterns. |
| Dungeon Crawler | Raycaster, input, render, event, timer, and UI. |
| Europa Universalis 2 Lite | Strategy map, image, input, minimap, render, save, and data-oriented state. |
| Household Finance Lab | Dataframe, charts, UI, filesystem, image, and local tool workflows. |
| Hex Logistics | Tilemap, render, input, math, timer, and logistics-style state. |
| Music Composer | Audio-adjacent creative tooling, camera, input, particles, render, and timer. |
| Sensible Soccer | Arcade input, render, timer, UI, and window control. |

## Run A Game

```powershell
cargo run -- content/games/hex_logistics
```

## Role In The Docs

Reference games are not API reference material. Use them after reading the module guides and examples when you want to see module combinations in a complete project.
