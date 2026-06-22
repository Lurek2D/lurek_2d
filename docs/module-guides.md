# Module Guides

Module pages explain what each `lurek.*` namespace is for, when to use it, common patterns, examples, and its generated API details.

## Core Starting Modules

| Module | Use it for |
|---|---|
| [render](modules/render.md) | Drawing shapes, images, text, canvases, shaders, and frame output. |
| [audio](modules/audio.md) | Sound playback, routing, source state, and mix control. |
| [input](modules/input.md) | Keyboard, mouse, gamepad, and pointer state. |
| [physics](modules/physics.md) | 2D bodies, colliders, simulation, contacts, and queries. |
| [scene](modules/scene.md) | Menus, game states, pause layers, transitions, and flow. |
| [sprite](modules/sprite.md) | Textured sprites, sheets, panels, and sprite batches. |
| [tilemap](modules/tilemap.md) | Tile worlds, map import, grid queries, and traversal. |
| [ui](modules/ui.md) | Menus, HUDs, editors, dashboards, and retained interface state. |
| [save](modules/save.md) | Save slots, persistence lifecycle, and restore flows. |

## Extended Modules

| Module | Use it for |
|---|---|
| [procgen](modules/procgen.md) | Procedural maps, names, structures, and generated support data. |
| [ai](modules/ai.md) | Gameplay intelligence, actors, behavior, coordination, and adaptation. |
| [automation](modules/automation.md) | Scripted replay, deterministic QA, and repeatable demos. |
| [compute](modules/compute.md) | Numeric processing and array-like transformations. |
| [pipeline](modules/pipeline.md) | Explicit multi-step workflows and DAG-style processing. |
| [dataframe](modules/dataframe.md) | Tabular data loading, querying, summarizing, and exporting. |
| [province](modules/province.md) | Region, ownership, border, and strategy-map state. |
| [graph](modules/flownet.md) | Flow-network and graph-oriented simulation. |
| [pathfind](modules/pathfind.md) | Navigation, graph search, and path analysis. |
| [network](modules/network.md) | HTTP, WebSocket, telemetry, sessions, and service calls. |

## Page Format

Generated module pages use this structure:

- Purpose
- When to use
- Minimal example
- Common patterns
- API reference and full callable details

Use [Lua API Overview](lua-api.md) when you need to move from a guide to exact signatures.
