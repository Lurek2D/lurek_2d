# Globe Demo — Lurek2D

A showcase of the `lurek.globe.*` API: an interactive world globe with ~200
procedurally generated provinces, fog-of-war lifting, capital city markers,
continent labels, a political colour layer, day/night time progression, and
hover-highlight province picking.

## Run

```
cargo run -- content/games/showcase/globe_demo
```

## Controls

| Input                  | Action                                  |
| ---------------------- | --------------------------------------- |
| Left-drag              | Pan the camera (lat/lon)                |
| Mouse wheel            | Zoom in / out                           |
| Hover                  | Highlight province under cursor         |
| Left click             | Select province; show popup label       |
| WASD / Arrow keys      | Pan the camera                          |
| PageUp / PageDown      | Zoom in / out                           |
| Gamepad D-pad          | Pan the camera                          |
| Gamepad A              | Select focused province                 |
| Gamepad shoulder/X/Y   | Zoom in / out                           |
| Escape                 | Quit                                    |

## What the demo shows

| API area              | Demonstrated calls                                              |
| --------------------- | --------------------------------------------------------------- |
| Globe creation        | `globe.new`, `globe.get`, `g:getName`                           |
| Province generation   | `g:addProvince`, `g:provinceCount`, `g:setProvinceAttr`         |
| Camera               | `g:setCamera`, `g:getCamera`, `g:applyMouseDrag`, `g:applyWheelZoom`, `g:getLod` |
| Picking              | `g:pickSurface` for province hover/selection and surface hit data |
| Fog of war           | `g:revealAll`, `g:setActiveViewer`                              |
| Markers              | `g:addMarker`, `g:setMarkerAttr`, `g:setMarkerVisible`          |
| Labels               | `g:addLabel`, `g:addLabel` (continent), `g:setLabelVisible`     |
| Layers               | `g:addLayer`, `g:setLayerColor`, `g:setLayerAlpha`              |
| Arcs                 | `g:addArc`, `g:removeArc` (flight path on click)                |
| Simulation           | `g:update`, `g:setTimeOfDay`, `g:getTimeOfDay`, `g:setRotation` |
| Borders              | `g:setBorders`                                                  |
| Constants            | `globe.MAX_PROVINCES`, `globe.LOD_FAR/MID/NEAR`                 |
| Rendering            | Rust-side `g:draw()` globe rendering synchronized with camera, markers, labels, layers, and time-of-day |

## Province generation

Provinces are generated entirely in Lua — no external data files.
Seven continental regions are divided into lat/lon grids totalling ~200
provinces.  Each cell becomes a convex quadrilateral province with
grid-adjacent neighbors assigned automatically.

## Note

This build now renders the visible globe through `LGlobe:draw()`. The Lua
layer still owns the game-specific HUD and selection overlays, but the globe
surface, markers, labels, and lighting come from the engine module.
