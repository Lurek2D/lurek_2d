<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/tilelight.md or source docstrings instead. -->

# tilelight

## TL;DR

- Tile-based environment lighting computed from a shared `LTileField`.

## General Info

- Module group: `Feature Systems`
- Source path: `src/tilelight`
- Binding: `src/lua_api/tilelight_api.rs`
- Namespace: `lurek.tilelight`
- Lua API surface: `2` functions, `1` types, `18` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- The `tilelight` module owns light propagation over tile cells. It reads blockers, transmission costs, topology, and sun occlusion from `tilefield`, then produces computed RGB/luma layers.
- It is environment-level data, not player-specific knowledge. Fog-of-war, action masks, and remembered exploration belong to `awareness`.
- It is tile-level gameplay/light data, not the screen/world render-light system. Render-facing lights and occluders remain in `lurek.light`.
- Point lights, ambient light, and global top light live on `LTileLightMap` so `LTileField` can remain a reusable source of gameplay data for many independent systems.

This module primarily collaborates with `tilefield`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/tilelight`
- Owning tier: `Feature Systems`
- Plugin tier: `core_keep`
- Lua binding owner: `src/lua_api/tilelight_api.rs`
- Referenced engine modules: `tilefield`

## Imports

- `tilefield`: Imports or references `src/tilefield/`. Dependency stays inside `Feature Systems` and should remain acyclic.

## Source Files

### color.rs

- Owns tile-light color math in linear 0..1 RGB space.
- Keeps color accumulation independent from tilefield data and light-source storage.

### map.rs

- Owns tile-based light-map storage and accumulation over a shared `TileField`.
- Consumes tilefield blockers, light costs, sun occlusion, dimensions, and topology.
- Keeps computed light separate from render lighting, player awareness, movement, and minimap display.

### mod.rs

- Exports the tile-based lighting subsystem surface.
- The module computes light maps over `TileField` data without owning render submission or player awareness.

### source.rs

- Owns tile-light source data: point lights, line lights, temporal modulation, and sun settings.
- Does not compute light maps or read tilefield state.



## Lua API Ref

### Functions

- `lurek.tilelight.compute(field, opts?) -> LTileLightMap`: Creates and computes a tile light map for a shared tilefield.
- `lurek.tilelight.new(field) -> LTileLightMap`: Creates a tile light map attached to a shared tilefield.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LTileLightMap Type

- Lua-side handle wrapping a tile light map tied to one shared tilefield.

##### Fields

- No documented fields.

##### Methods

- `LTileLightMap:addLineLight(opts) -> nil`: Adds a tile line light and returns its stable id.
- `LTileLightMap:addPointLight(opts) -> nil`: Adds a point light and returns its stable id.
- `LTileLightMap:clearLineLights() -> nil`: Removes all line lights currently stored on this tile light map.
- `LTileLightMap:clearPointLights() -> nil`: Removes all point lights currently stored on this tile light map.
- `LTileLightMap:compute(opts?) -> nil`: Computes tile light from ambient, point lights, line lights, and sun light.
- `LTileLightMap:exportLayer(z?) -> nil`: Exports one level of computed light as row-major `{r,g,b,luma}` tables.
- `LTileLightMap:exportVolume() -> nil`: Exports all computed light levels as nested row-major tables.
- `LTileLightMap:getLight(x, y, z?) -> nil`: Returns r, g, b, and luma for one cell.
- `LTileLightMap:getSize() -> nil`: Returns light-map width, height, and level count.
- `LTileLightMap:removeLineLight(id) -> nil`: Removes a line light by id and returns whether it existed.
- `LTileLightMap:removePointLight(id) -> boolean`: Removes a point light by id and returns whether it existed.
- `LTileLightMap:setAmbient(color) -> nil`: Sets ambient tile light stored on this light map.
- `LTileLightMap:setGlobalLight(opts) -> nil`: Sets top-down global light parameters used during light computation.
- `LTileLightMap:setSunLight(opts) -> nil`: Sets tile sun light parameters used during light computation.
- `LTileLightMap:type() -> string`: Returns the Lua-visible type name for this tile light map handle.
- `LTileLightMap:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.
- `LTileLightMap:updateLineLight(id, opts) -> nil`: Updates an existing tile line light by id.
- `LTileLightMap:updatePointLight(id, opts) -> nil`: Updates an existing point light by id.

## Examples

- `content/examples/tilelight.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_tilelight_unit.lua` (present)
- Rust: none detected.

## Evidence / Golden

- No evidence or golden artifacts registered.

## Architecture Links

- Intentionally empty.

## Notes

- `LTileLightMap` must match the source field dimensions and topology before compute.
- Point lights use the field `light` channel. `blocks.light=true` is full occlusion; `costs.light` is a `0..1` transmission multiplier for partial blockers such as smoked glass, grates, or shade screens.
- Global top light is attenuated by `sunOcclusion` from upper levels, preserving the configured global color while reducing intensity below occluding cells.
- Exported light layers are passive data suitable for minimap overlays, render adapters, diagnostics, and Lua game logic.
