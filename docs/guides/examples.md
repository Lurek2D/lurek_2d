# Runnable Examples

`content/examples/` contains runnable one-file examples for public `lurek.*` APIs. Each module owns one example file, and each public API has one owning example block.

## Recommended Starting Examples

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

## Run Examples

```powershell
cargo run -- content/examples/render.lua
tools/python.cmd tools/demos/smoke_sweep.py --kind example
```

## Source Of Truth

The canonical example index is [content/examples/README.md](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/README.md).

Generated module pages and Wiki pages reuse these examples. If an example is wrong, fix the owning `content/examples/<module>.lua` block rather than copying a workaround into docs.
