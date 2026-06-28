<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/tilelight.md or source docstrings instead. -->

# tilelight

## TL;DR

- Tile-based environment lighting computed from a shared `LTileField`.

## General Info

- Module group: `Feature Systems`
- Source path: `src/tilelight`
- Binding: `src/lua_api/tilelight_api.rs`
- Namespace: `lurek.tilelight`
- Lua API surface: `2` functions, `1` types, `26` methods
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

- This file owns color behavior inside the tilelight subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate color state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for color work.

### map.rs

- This file owns map behavior inside the tilelight subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate map state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for map work.
- Serialization, indexing, and boundary checks stay here when they depend on map internals. It keeps maintenance boundari.
- Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
- Open this file when map ownership changes, but keep unrelated subsystem policy in sibling modules.
- The code favors small data transformations so examples, specs, and tests can assert behavior directly.
- Stateful changes are kept deterministic here so generated docs and smoke tests remain reproducible.
- Cross-module dependencies are intentionally narrow, with shared types imported only at this boundary.

### mod.rs

- This module index owns the public shape of the tilelight subsystem and its source navigation map.
- It declares which sibling files participate in tilelight behavior and which names are reexported outward.
- Reexports here are intentionally narrow so callers do not depend on private implementation modules.
- Agents should start here to understand subsystem boundaries before opening deeper implementation files.
- New submodules belong here only when they add durable behavior rather than temporary test scaffolding.
- Keep this index synchronized with specs, examples, and Lua bindings whenever public ownership changes.

### source.rs

- This file owns source behavior inside the tilelight subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate source state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for source work.
- Serialization, indexing, and boundary checks stay here when they depend on source internals.
- Renderer, API, and test layers should call through these helpers rather than duplicate private rules.



## Lua API Ref

### Functions

- `lurek.tilelight.compute(field, opts?) -> LTileLightMap`: Creates and computes a tile light map for a shared tilefield or Lua tilefield provider table.
- `lurek.tilelight.new(field) -> LTileLightMap`: Creates a tile light map attached to a shared tilefield or copied from a Lua tilefield provider table.

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

- `LTileLightMap:addAreaLight(opts) -> nil`: Adds a rectangular area light and returns its stable id.
- `LTileLightMap:addLineLight(opts) -> nil`: Adds a tile line light and returns its stable id.
- `LTileLightMap:addPointLight(opts) -> nil`: Adds a point light and returns its stable id.
- `LTileLightMap:addRectLight(opts) -> integer`: Alias for `addAreaLight`.
- `LTileLightMap:clearAreaLights() -> nil`: Removes all rectangular area lights currently stored on this tile light map.
- `LTileLightMap:clearLineLights() -> nil`: Removes all line lights currently stored on this tile light map.
- `LTileLightMap:clearPointLights() -> nil`: Removes all point lights currently stored on this tile light map.
- `LTileLightMap:clearRectLights() -> nil`: Alias for `clearAreaLights`.
- `LTileLightMap:compute(opts?) -> nil`: Computes tile light from ambient, point lights, line lights, and sun light.
- `LTileLightMap:exportLayer(z?) -> table`: Exports one level of computed light as row-major `{r,g,b,luma}` tables.
- `LTileLightMap:exportVolume() -> table`: Exports all computed light levels as nested row-major tables.
- `LTileLightMap:getLight(x, y, z?) -> number, number, number, number`: Returns r, g, b, and luma for one cell.
- `LTileLightMap:getSize() -> integer, integer, integer`: Returns light-map width, height, and level count.
- `LTileLightMap:removeAreaLight(id) -> boolean`: Removes a rectangular area light by id and returns whether it existed.
- `LTileLightMap:removeLineLight(id) -> boolean`: Removes a line light by id and returns whether it existed.
- `LTileLightMap:removePointLight(id) -> boolean`: Removes a point light by id and returns whether it existed.
- `LTileLightMap:removeRectLight(id) -> boolean`: Alias for `removeAreaLight`.
- `LTileLightMap:setAmbient(color) -> nil`: Sets ambient tile light stored on this light map.
- `LTileLightMap:setGlobalLight(opts) -> nil`: Compatibility alias for top sun light parameters used during light computation.
- `LTileLightMap:setSunLight(opts) -> nil`: Sets tile sun light parameters used during light computation.
- `LTileLightMap:type() -> string`: Returns the Lua-visible type name for this tile light map handle.
- `LTileLightMap:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.
- `LTileLightMap:updateAreaLight(id, opts) -> nil`: Updates an existing rectangular area light by id.
- `LTileLightMap:updateLineLight(id, opts) -> nil`: Updates an existing tile line light by id.
- `LTileLightMap:updatePointLight(id, opts) -> nil`: Updates an existing point light by id.
- `LTileLightMap:updateRectLight(id, opts) -> nil`: Alias for `updateAreaLight`.

## Examples

- `content/examples/tilelight.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- `LTileLightMap` must match the source field dimensions and topology before compute.
- Point lights use the field `light` channel. `blocks.light=true` is full occlusion; `costs.light` is a `0..1` transmission multiplier for partial blockers such as smoked glass, grates, or shade screens.
- Global top light is attenuated by `sunOcclusion` from upper levels, preserving the configured global color while reducing intensity below occluding cells.
- Exported light layers are passive data suitable for minimap overlays, render adapters, diagnostics, and Lua game logic.
