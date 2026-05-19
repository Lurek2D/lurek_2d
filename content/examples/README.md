# Lurek2D Examples Guide

`content/examples/` is the single-file example set for the public `lurek.*` API.

## What This Folder Is For

- Each file focuses on one engine namespace or closely related API surface.
- Examples are small reference snippets, not full games.
- The folder complements the generated API reference in [../../docs/api/lurek.md](../../docs/api/lurek.md).

## How To Use It

1. Open the file that matches the API area you want to learn, for example `render.lua`, `audio.lua`, `input.lua`, `physics.lua`, or `ui.lua`.
2. Search for `--@api-stub:` to jump to a specific callable.
3. Copy the relevant snippet into your own `main.lua` and adapt it to your project.

## What You Will Find Here

| File | Focus |
|---|---|
| `render.lua` | Drawing, images, text, meshes, render targets, and GPU-facing helpers |
| `audio.lua` | Sources, playback, buses, filters, and sound data |
| `input.lua` | Keyboard, mouse, and gamepad queries |
| `physics.lua` | Bodies, shapes, raycasts, and collision helpers |
| `scene.lua` | Scene lifecycle and scene-stack flows |
| `tilemap.lua` | Tile grids, tilesets, and map traversal helpers |
| `ui.lua` | Widgets, retained UI state, and interaction helpers |

## Related Docs

| Topic | Link |
|---|---|
| Lua API reference | [../../docs/api/lurek.md](../../docs/api/lurek.md) |
| Project reference | [../../wiki/Project-Reference.md](../../wiki/Project-Reference.md) |
| Contributor handbook | [../../docs/handbook.md](../../docs/handbook.md) |
| Test suite overview | [../../tests/README.md](../../tests/README.md) |

Examples should stay aligned with the generated API docs. If an example looks wrong, fix the source API docs in `src/lua_api/*_api.rs`, regenerate the docs, and then update the example if needed.
