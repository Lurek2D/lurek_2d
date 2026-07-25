# Examples

`content/examples/` is the canonical runnable example layer for the public `lurek.*` API. Each file owns one module and demonstrates real usage patterns you can copy into a project.

## Recommended Starting Points

| Example | Use it for |
|---|---|
| [render.lua](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/render.lua) | Shapes, color, images, canvases, text, and draw commands. |
| [input.lua](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/input.lua) | Keyboard, mouse, and gamepad state. |
| [audio.lua](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/audio.lua) | Loading and playing sound. |
| [physics.lua](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/physics.lua) | Bodies, colliders, stepping, and queries. |
| [scene.lua](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/scene.lua) | Scene flow and state changes. |
| [tilemap.lua](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/tilemap.lua) | Grid worlds and tile rendering. |
| [ui.lua](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/ui.lua) | Menus, widgets, panels, and interaction. |
| [procgen.lua](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/procgen.lua) | Procedural generation helpers. |
| [dataframe.lua](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/dataframe.lua) | Table-shaped data loading and querying. |
| [automation.lua](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/automation.lua) | Replay and deterministic test workflows. |

## How To Use The Example Layer

- Run one file directly:

```powershell
cargo run -- content/examples/render.lua
```

- Sweep all examples:

```powershell
tools/python.cmd tools/demos/smoke_sweep.py --kind example
```

- Use [content/examples/README.md](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/README.md) when you need the repository ownership rules for `-- @api:` example blocks.

## How Examples Fit With The Rest Of The Docs

- Start here when you want runnable code before full reference material.
- Use [Module Guides](../module-guides.md) to choose a namespace.
- Use the [Full Lua API Reference](../api/lurek.md) for exact signatures and return values.
- Move on to [Reference Games](reference-games.md) when a one-file example is no longer enough.
