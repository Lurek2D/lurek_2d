<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/tilefield.md or source docstrings instead. -->

# tilefield

## TL;DR

`lurek.tilefield` is the shared tile-based gameplay data owner for multi-level maps. It stores independent blockers, costs, profile names, and author-defined cell refs so pathfinding, awareness, tilelight, minimap, and raycaster adapters can share one source of truth without depending on each other.

## General Info

- Module group: `Feature Systems`
- Source path: `src/tilefield`
- Binding: `src/lua_api/tilefield_api.rs`
- Namespace: `lurek.tilefield`
- Lua API surface: `3` functions, `2` types, `56` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- Coordinates exposed to Lua are one-based `x, y, z`; Rust storage is zero-based.
- `LTileField` is a single field with width, height, and one or more levels. This is the default one-level map model.
- `LTileFieldMap` is a 2D or layered map of shared `LTileField` handles. Use it when a world is chunked into fields or stacked as layers of fields.
- Supported topologies are `square`, `square4`, `square8`, `iso_square`, and `hex`. `square` keeps the existing eight-way distance behavior, `square4` uses Manhattan distance, and `iso_square` uses square gameplay math because projection belongs to tilemap/rendering.
- Channels are intentionally independent: seeing through a cell does not imply acting, moving, or lighting through it.
- Built-in profiles include `empty`, `wall`, `window`, `door_closed`, `door_open`, and `half_wall`.
- The `light` channel and `sunOcclusion` are environment inputs consumed by `lurek.tilelight`; `tilefield` does not store point lights or computed light values.
- Cell refs such as `floor`, `wall_left`, `roof`, or `object` are author-defined slots. They are useful for mapping tile ids, object ids, or block slots onto the same gameplay field without forcing every system to own separate data.

This module is mostly self-contained inside the Feature Systems group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/tilefield`
- Owning tier: `Feature Systems`
- Plugin tier: `core_keep`
- Lua binding owner: `src/lua_api/tilefield_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### cell.rs

- Owns per-cell gameplay channel data for blockers, traversal costs, and sun occlusion in tilefield maps.
- Defines the fixed semantic channels used by Lua, pathfind adapters, visibility checks, and tile lighting.
- Keeps movement, vision, action, point-light, top-light, and author-defined object references independent.
- Provides parsing and default-state helpers for field mutation without depending on higher-level systems.
- Does not know about topology, rendering, minimap presentation, player masks, or pathfinding algorithms.

### field.rs

- Owns multi-level tilefield storage, channel blockers, channel costs, profiles, and cell exports.
- Implements bounds checks, cell mutation, profile application, line queries, and layer exports.
- Stores cells and named profiles in one grid owner.
- Uses topology and line helpers locally so callers can query blockers without owning traversal logic.
- Provides renderer-independent input consumed by movement, awareness, tilelight, minimap, and render adapters.
- Keeps action, vision, movement, light, and sun channels independent by never inferring one from another.
- Returns controlled string errors at the domain boundary so Lua bindings can attach lurek.tilefield names.
- Does not depend on pathfind, awareness, tilelight, raycaster, minimap, tilemap rendering, or renderer state.

### field_map.rs

- Owns a grid of shared `TileField` handles for chunked and stacked tilefield worlds.
- Stores map-level dimensions separately from each contained field's cell dimensions.
- Provides the bridge between a single field, a 2D field map, and layered field maps.
- Keeps the map container data-oriented and independent from pathfinding, awareness, tilelight, minimap, and render.

### line.rs

- Owns deterministic tile-line traversal for square, isometric-square, hex, and vertical level checks.
- Converts two zero-based cell coordinates into ordered cells used by blocker and occlusion queries.
- Implements Bresenham square lines, axial hex interpolation, and same-column vertical level traversal.
- Keeps traversal math independent from movement, visibility, action, lighting, and rendering decisions.
- Rejects arbitrary diagonal multi-level lines so callers get a clear v1 boundary instead of guessed cells.

### mod.rs

- Indexes the tilefield gameplay-semantics subsystem and keeps its public Rust surface explicit.
- Exports cell, field, field-map, line, profile, and topology owners used by Lua bindings and tests.
- Re-exports compact data types so callers can build field inputs without depending on file layout.
- Keeps tilefield independent from renderers, minimaps, raycasters, pathfinding, awareness, and tilelight state.
- Agents start here to trace which file owns blockers, costs, topology math, and profiles.
- Neighbor modules may consume exported data, but they do not become owners of tilefield semantics.

### profile.rs

- Owns named tilefield profiles that stamp blocker, cost, and sun-occlusion semantics onto cells.
- Provides built-in wall, window, door, half-wall, and empty profiles for common tactical map objects.
- Stores profile data only, keeping renderer geometry and gameplay consumers independent of each other.
- Lets `TileField` apply reusable object semantics without duplicating channel maps at every call site.
- Does not calculate movement, visibility, action lines, lighting, minimap overlays, or render geometry.

### topology.rs

- Owns logical tilefield topology parsing and distance rules for square, isometric-square, and axial hex grids.
- Treats isometric-square as square gameplay math because projection belongs to tilemap and render code.
- Provides distance helpers used by field lighting, ranges, and topology-aware line generation.
- Does not store map data, render coordinates, pathfinding policies, player masks, or minimap presentation.



## Lua API Ref

### Functions

- `lurek.tilefield.fromTileMap(tilemap, opts?) -> LTileField`: Copies a tilemap layer into a tilefield, optionally applying profiles and a ref slot.
- `lurek.tilefield.new(opts) -> LTileField`: Creates a multi-level tilefield with explicit dimensions and topology.
- `lurek.tilefield.newFieldMap(opts) -> LTileFieldMap`: Creates a 2D or layered map of shared tilefields.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LTileField Type

- Lua-side handle wrapping a shared tilefield.

##### Fields

- No documented fields.

##### Methods

- `LTileField:applyProfile(x, y, z?, name) -> nil`: Applies a named profile to one cell.
- `LTileField:applyTilesetProfile(x, y, z?, slot, tileset, opts?) -> boolean`: Applies the tilefield profile named by a tileset tile referenced from one cell.
- `LTileField:applyTilesetStats(x, y, z?, slot, tileset, opts?) -> boolean`: Applies tileset gameplay properties for a tile referenced from one cell.
- `LTileField:applyTilesetStatsLayer(slot, tileset, opts?) -> integer`: Applies tileset gameplay properties for every referenced cell on one tilefield level.
- `LTileField:blocks(x, y, z?, channel) -> boolean`: Returns whether a cell blocks a channel.
- `LTileField:clear() -> nil`: Clears all cell gameplay state.
- `LTileField:clearCell(x, y, z?) -> nil`: Clears gameplay state for one addressed cell.
- `LTileField:clearLine(from_tbl, to_tbl, channel, opts?) -> boolean`: Returns true when the line between two cell tables has no blocker for a channel.
- `LTileField:clearRef(x, y, z?, slot) -> nil`: Clears a named object/tile reference from one cell.
- `LTileField:exportBlockLayer(channel, z?) -> table`: Exports one blocker channel and level as a row-major boolean array.
- `LTileField:exportCostLayer(channel, z?) -> table`: Exports one cost channel and level as a row-major number array.
- `LTileField:exportProfileLayer(z?) -> nil`: Exports one level of profile names as a row-major array.
- `LTileField:exportRefLayer(slot, z?) -> nil`: Exports one named object/tile reference slot and level as a row-major array.
- `LTileField:firstBlocker(from_tbl, to_tbl, channel, opts?) -> table|nil`: Returns the first one-based blocking cell table between two cells, or nil.
- `LTileField:getCell(x, y, z?) -> table`: Returns a table with blockers, costs, sun occlusion, and optional profile name.
- `LTileField:getCost(x, y, z?, channel) -> number`: Returns the cost for one cell/channel.
- `LTileField:getNeighbors(x, y, z?) -> table`: Returns topology-aware same-level neighbours for one cell.
- `LTileField:getProfile(name) -> table|nil`: Returns a named object profile table, or nil when absent.
- `LTileField:getRef(x, y, z?, slot) -> integer|nil`: Returns a named object/tile reference from one cell, or nil.
- `LTileField:getRefProperties(x, y, z?, slot, tileset, opts?) -> table|nil`: Reads all tileset properties for a tile referenced from one cell.
- `LTileField:getRefProperty(x, y, z?, slot, tileset, property, opts?) -> string|nil`: Reads a tileset property for a tile referenced from one cell.
- `LTileField:getRefPropertyBool(x, y, z?, slot, tileset, property, opts?) -> boolean|nil`: Reads a tileset property for a tile referenced from one cell and parses it as a boolean.
- `LTileField:getRefPropertyNumber(x, y, z?, slot, tileset, property, opts?) -> number|nil`: Reads a tileset property for a tile referenced from one cell and parses it as a number.
- `LTileField:getRefSlots() -> string[]`: Returns every named ref slot currently used by this field.
- `LTileField:getRegionCells(name) -> table?`: Returns one-based cells for a named region, or nil when it does not exist.
- `LTileField:getRegionNames() -> table`: Returns all region names in stable order.
- `LTileField:getSize() -> integer`: Returns field width, height, and level count.
- `LTileField:getSunOcclusion(x, y, z?) -> number`: Returns top-light occlusion in the inclusive range 0..1.
- `LTileField:getTopology() -> string`: Returns the field topology name used for coordinate interpretation.
- `LTileField:inBounds(x, y, z?) -> boolean`: Returns whether one-based coordinates are inside the field.
- `LTileField:line(opts) -> nil`: Returns topology-aware one-based cells between `from` and `to` tables.
- `LTileField:regionContains(name, x, y, z?) -> boolean`: Returns whether a named region contains a one-based tile cell.
- `LTileField:removeProfile(name) -> nil`: Removes a named object profile from the tilefield profile registry.
- `LTileField:removeRegion(name) -> boolean`: Removes a named region.
- `LTileField:setBlock(x, y, z?, channel, blocked) -> nil`: Sets whether a cell blocks a channel.
- `LTileField:setCell(x, y, z?, cell) -> nil`: Sets cell state from a table with optional `blocks`, `costs`, `sunOcclusion`, and `profile`.
- `LTileField:setCost(x, y, z?, channel, cost) -> nil`: Sets the cost for one cell/channel.
- `LTileField:setProfile(name, profile_tbl) -> nil`: Registers or replaces a named object profile.
- `LTileField:setRef(x, y, z?, slot, value) -> nil`: Sets a named object/tile reference on one cell.
- `LTileField:setRegionCells(name, cells) -> nil`: Defines or replaces a named region from explicit one-based tile cells.
- `LTileField:setRegionRect(name, x1, y1, x2, y2, z?) -> nil`: Defines or replaces a named region from an inclusive one-based tile rectangle.
- `LTileField:setSunOcclusion(x, y, z?, value) -> nil`: Sets top-light occlusion in the inclusive range 0..1.
- `LTileField:type() -> string`: Returns the Lua-visible type name for this tilefield handle.
- `LTileField:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.
- `LTileField:writeBlockLayer(channel, z?, values) -> nil`: Writes one full blocker channel layer from a row-major boolean array.
- `LTileField:writeCostLayer(channel, z?, values) -> nil`: Writes one full cost channel layer from a row-major number array.
- `LTileField:writeProfileLayer(z?, values) -> nil`: Writes one full profile-name layer from a row-major string-or-nil array.
- `LTileField:writeRefLayer(slot, z?, values) -> nil`: Writes one full named ref layer from a row-major integer-or-nil array.

#### LTileFieldMap Type

- Lua-side handle wrapping a grid of shared tilefields.

##### Fields

- No documented fields.

##### Methods

- `LTileFieldMap:getField(mapX, mapY, mapZ?) -> LTileField`: Returns the shared tilefield at one field-map coordinate.
- `LTileFieldMap:getFieldSize() -> integer`: Returns contained field width, height, and level count.
- `LTileFieldMap:getMapSize() -> integer`: Returns field-map width, height, and layer count.
- `LTileFieldMap:getTopology() -> string`: Returns the topology shared by every contained field.
- `LTileFieldMap:inBounds(mapX, mapY, mapZ?) -> boolean`: Returns whether one-based field-map coordinates are inside the field map.
- `LTileFieldMap:setField(mapX, mapY, mapZ?, field) -> nil`: Replaces one field-map slot with an existing compatible tilefield handle.
- `LTileFieldMap:type() -> string`: Returns the Lua-visible type name for this tilefield map handle.
- `LTileFieldMap:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.

## Examples

- `content/examples/tilefield.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_tilefield_unit.lua` (present)
- Rust: `tests/rust/unit/tilefield_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_tilefield_evidence.lua` |
| Golden test | `tests/lua/golden/test_tilefield_golden.lua` |
| Current artifact | `tests/artifacts/current/tilefield/tilefield_channels.png` |
| Current artifact | `tests/artifacts/current/tilefield/tilefield_lighting_multilevel.png` |
| Current artifact | `tests/artifacts/current/tilefield/tilefield_lighting_values.txt` |
| Current artifact | `tests/artifacts/current/tilefield/tilefield_raycaster_input.png` |
| Current artifact | `tests/artifacts/current/tilefield/tilefield_visibility_action_players.png` |
| Baseline artifact | `tests/artifacts/baselines/tilefield/tilefield_channels.png` |
| Baseline artifact | `tests/artifacts/baselines/tilefield/tilefield_lighting_multilevel.png` |
| Baseline artifact | `tests/artifacts/baselines/tilefield/tilefield_lighting_values.txt` |
| Baseline artifact | `tests/artifacts/baselines/tilefield/tilefield_raycaster_input.png` |
| Baseline artifact | `tests/artifacts/baselines/tilefield/tilefield_visibility_action_players.png` |

## Architecture Links

- No module-specific architecture links registered.

## Notes

- No additional module-specific notes.
