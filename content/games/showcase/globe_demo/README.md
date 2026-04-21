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

| Input            | Action                                  |
| ---------------- | --------------------------------------- |
| Left-drag        | Pan the camera (lat/lon)                |
| Mouse wheel      | Zoom in / out                           |
| Hover            | Highlight province under cursor         |
| Left click       | Select province; show popup label       |
| Escape           | Quit                                    |

## What the demo shows

| API area              | Demonstrated calls                                              |
| --------------------- | --------------------------------------------------------------- |
| Globe creation        | `globe.new`, `globe.get`, `g:getName`                           |
| Province generation   | `g:addProvince`, `g:provinceCount`, `g:setProvinceAttr`         |
| Camera               | `g:setCamera`, `g:getCamera`, `g:pan`, `g:zoom`, `g:getLod`     |
| Picking              | `g:pick`, `g:pickLatLon`                                        |
| Fog of war           | `g:revealAll`, `g:setActiveViewer`                              |
| Markers              | `g:addMarker`, `g:setMarkerAttr`, `g:setMarkerVisible`          |
| Labels               | `g:addLabel`, `g:addLabel` (continent), `g:setLabelVisible`     |
| Layers               | `g:addLayer`, `g:setLayerColor`, `g:setLayerAlpha`              |
| Arcs                 | `g:addArc`, `g:removeArc` (flight path on click)                |
| Simulation           | `g:update`, `g:setTimeOfDay`, `g:getTimeOfDay`, `g:setRotation` |
| Borders              | `g:setBorders`                                                  |
| Constants            | `globe.MAX_PROVINCES`, `globe.LOD_FAR/MID/NEAR`                 |
| Rendering            | `g:emitFrame`                                                   |

## Province generation

Provinces are generated entirely in Lua — no external data files.
Seven continental regions are divided into lat/lon grids totalling ~200
provinces.  Each cell becomes a convex quadrilateral province with
grid-adjacent neighbors assigned automatically.
