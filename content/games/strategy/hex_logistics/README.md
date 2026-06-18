# Hex Logistics

**Category:** strategy

Hex Logistics is a Lurek2D port of a Gemini React canvas prototype. Fly a construction ship over a procedural hex sector, pay metal to construct buildings, queue drones from factories, and tune building priorities while physical drones move metal, gold, and energy between local storage and HQ.

## Controls

- `WASD` or arrows: fly the ship
- `1`: build HQ
- `2`: build metal mine on a metal vein
- `3`: build gold mine on a gold vein
- `4`: build energy generator
- `5`: build drone factory
- `6`: build defense turret
- `Q`: queue one drone at an active drone factory under the ship
- `Z` / `X` / `C`: set logistics priority under the ship to off, normal, or high
- `Escape`: quit

## Lurek APIs Used

- `lurek.init`, `lurek.process`, `lurek.draw`, `lurek.draw_ui` for the game loop
- `lurek.input.bind`, `isActionDown`, `wasActionPressed`, and mouse position for controls and hover
- `lurek.tilemap.toScreenHex` and `fromScreenHex` for axial hex projection and selection
- `lurek.render.drawHexTile`, `polygon`, `circle`, `rectangle`, `print`, and `setLineWidth` for hex map, ship, drones, buildings, and HUD
- `lurek.window.getDimensions` for camera centering and responsive HUD
- `lurek.math.distance` and `lurek.timer` for movement, timers, FPS, and UI pulse
