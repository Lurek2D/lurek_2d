# Tilefield Tactics

Scale: minigame

Tilefield Tactics is a compact tactical sandbox built around one shared `lurek.tilefield` model. Movement, visibility, action targeting, tile lighting, minimap data, and raycaster input all read from the same multi-level field.

## Run

```powershell
cargo run -- content/newgames/tilefield_tactics
```

## Controls

| Key | Action |
|---|---|
| WASD / Arrows | Move selected player |
| Tab | Switch player |
| Space | Toggle the door profile |
| Q / E | Change level |
| R | Reset |
| Escape | Quit |

## Design

The board is `12x12x3`. Walls, windows, open/closed doors, and half-walls are profiles on `lurek.tilefield`. Windows block movement and action but not vision or light. The door can be toggled during play and all dependent systems recompute from the field.

## APIs Used

- `lurek.tilefield` for profiles, blockers, costs, point lights, global light, exports, and multi-level field state.
- `lurek.pathfind` for movement range from the field.
- `lurek.awareness` for per-player visibility and action masks.
- `lurek.minimap` for passive visualization of exported terrain, fog, and light data.
- `lurek.raycaster` for field-derived scene input diagnostics.
- `lurek.render`, `lurek.input`, `lurek.window`, and `lurek.event` for the playable shell.
