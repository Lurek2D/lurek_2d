<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/tilefield.md or source docstrings instead. -->

# tilefield

## TL;DR

`lurek.tilefield` is the tile-based gameplay semantics owner for multi-level maps. It stores independent blockers and costs for movement, vision, action, point light, and top light so pathfinding, visibility, minimap, and raycaster adapters can share one source of truth without depending on each other.

## General Info

- Module group: `Feature Systems`
- Source path: `src/tilefield`
- Binding: `src/lua_api/tilefield_api.rs`
- Namespace: `lurek.tilefield`
- Lua API surface: `2` functions, `1` types, `34` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- Coordinates exposed to Lua are one-based `x, y, z`; Rust storage is zero-based.
- Supported topologies are `square`, `iso_square`, and `hex`. `iso_square` uses square gameplay math because projection belongs to tilemap/rendering.
- Channels are intentionally independent: seeing through a cell does not imply acting, moving, or lighting through it.
- Built-in profiles include `empty`, `wall`, `window`, `door_closed`, `door_open`, and `half_wall`.
- Point lights use the `light` channel. `blocks.light=true` is full occlusion; `costs.light` is a `0..1` transmission multiplier for partial blockers such as smoked glass, grates, or shade screens.
- Point-light radius is radial: square and iso-square fields use Euclidean distance, while hex fields use hex distance. The square bounding box is only an iteration window, not the shape of the light.
- Point-light and global-light colors are RGB gameplay data, not renderer-only tint. Dusk, night, torch, alarm, and magical lights can use different colors and intensities.
- Global top light is attenuated by `sunOcclusion` from upper levels, preserving the configured global color while reducing intensity below occluding cells.

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
- Keeps movement, vision, action, point-light, and top-light values independent on every stored cell.
- Provides parsing and default-state helpers for field mutation without depending on higher-level systems.
- Does not know about topology, rendering, minimap presentation, player masks, or pathfinding algorithms.

### field.rs

- Owns multi-level tilefield storage, channel blockers, channel costs, profiles, and lighting state.
- Implements bounds checks, cell mutation, profile application, layer exports, and light accumulation.
- Stores cells, named profiles, point lights, global light, and computed light values in one grid owner.
- Uses topology and line helpers locally so callers can query blockers without owning traversal logic.
- Provides renderer-independent input consumed by movement, visibility, minimap, and render adapters.
- Keeps action, vision, movement, point-light, and sun channels independent by never inferring one from another.
- Returns controlled string errors at the domain boundary so Lua bindings can attach lurek.tilefield names.
- Does not depend on pathfind, visibility, raycaster, minimap, tilemap rendering, or renderer state.

### light.rs

- Owns tile-based light data records shared by `TileField` and Lua conversion code at the API boundary.
- Defines RGB colors, point-light definitions, point-light patch updates, and global top-light values.
- Keeps these structs data-only so the field solver can query blockers without cyclic module ownership.
- Provides clamp and construction helpers while leaving occlusion, falloff, and accumulation to `field.rs`.
- Does not render light, manage GPU state, infer visibility, or alter movement/action channel semantics.

### line.rs

- Owns deterministic tile-line traversal for square, isometric-square, hex, and vertical level checks.
- Converts two zero-based cell coordinates into ordered cells used by blocker and occlusion queries.
- Implements Bresenham square lines, axial hex interpolation, and same-column vertical level traversal.
- Keeps traversal math independent from movement, visibility, action, lighting, and rendering decisions.
- Rejects arbitrary diagonal multi-level lines so callers get a clear v1 boundary instead of guessed cells.

### mod.rs

- Indexes the tilefield gameplay-semantics subsystem and keeps its public Rust surface explicit.
- Exports cell, field, light, line, profile, and topology owners used by Lua bindings and tests.
- Re-exports compact data types so callers can build field inputs without depending on file layout.
- Keeps tilefield independent from renderers, minimaps, raycasters, pathfinding, and visibility state.
- Agents start here to trace which file owns blockers, costs, topology math, profiles, and lighting.
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

- `lurek.tilefield.fromTileMap(tilemap, opts?) -> LTileField`: Copies a tilemap layer into a tilefield using solid and empty profiles.
- `lurek.tilefield.new(opts) -> LTileField`: Creates a multi-level tilefield with explicit dimensions and topology.

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

- `LTileField:addPointLight(opts) -> nil`: Adds a point light and returns its stable id.
- `LTileField:applyProfile(x, y, z?, name) -> nil`: Applies a named profile to one cell.
- `LTileField:blocks(x, y, z?, channel) -> boolean`: Returns whether a cell blocks a channel.
- `LTileField:clear() -> nil`: Clears all cell gameplay state and computed light values.
- `LTileField:clearCell(x, y, z?) -> nil`: Clears gameplay state and light values for one addressed cell.
- `LTileField:clearLine(from_tbl, to_tbl, channel, opts?) -> boolean`: Returns true when the line between two cell tables has no blocker for a channel.
- `LTileField:clearPointLights() -> nil`: Removes all point lights currently stored on this tilefield.
- `LTileField:computeLight(opts?) -> nil`: Computes tile light from ambient, point lights, and global top light.
- `LTileField:exportBlockLayer(channel, z?) -> table`: Exports one blocker channel and level as a row-major boolean array.
- `LTileField:exportCostLayer(channel, z?) -> table`: Exports one cost channel and level as a row-major number array.
- `LTileField:exportLightLayer(z?) -> table`: Exports one level of computed light as row-major `{r,g,b,luma}` tables.
- `LTileField:exportLightVolume() -> table`: Exports all computed light levels as nested row-major tables.
- `LTileField:exportProfileLayer(z?) -> nil`: Exports one level of profile names as a row-major array.
- `LTileField:firstBlocker(from_tbl, to_tbl, channel, opts?) -> table|nil`: Returns the first one-based blocking cell table between two cells, or nil.
- `LTileField:getCell(x, y, z?) -> table`: Returns a table with blockers, costs, sun occlusion, and optional profile name.
- `LTileField:getCost(x, y, z?, channel) -> number`: Returns the cost for one cell/channel.
- `LTileField:getLight(x, y, z?) -> number`: Returns r, g, b, and luma for one cell.
- `LTileField:getProfile(name) -> table|nil`: Returns a named object profile table, or nil when absent.
- `LTileField:getSize() -> integer`: Returns field width, height, and level count.
- `LTileField:getSunOcclusion(x, y, z?) -> number`: Returns top-light occlusion in the inclusive range 0..1.
- `LTileField:getTopology() -> string`: Returns the field topology name used for coordinate interpretation.
- `LTileField:inBounds(x, y, z?) -> boolean`: Returns whether one-based coordinates are inside the field.
- `LTileField:line(opts) -> nil`: Returns topology-aware one-based cells between `from` and `to` tables.
- `LTileField:removePointLight(id) -> boolean`: Removes a point light by id and returns whether it existed.
- `LTileField:removeProfile(name) -> nil`: Removes a named object profile from the tilefield profile registry.
- `LTileField:setBlock(x, y, z?, channel, blocked) -> nil`: Sets whether a cell blocks a channel.
- `LTileField:setCell(x, y, z?, cell) -> nil`: Sets cell state from a table with optional `blocks`, `costs`, `sunOcclusion`, and `profile`.
- `LTileField:setCost(x, y, z?, channel, cost) -> nil`: Sets the cost for one cell/channel.
- `LTileField:setGlobalLight(opts) -> nil`: Sets top-down global light parameters used during light computation.
- `LTileField:setProfile(name, profile_tbl) -> nil`: Registers or replaces a named object profile.
- `LTileField:setSunOcclusion(x, y, z?, value) -> nil`: Sets top-light occlusion in the inclusive range 0..1.
- `LTileField:type() -> string`: Returns the Lua-visible type name for this tilefield handle.
- `LTileField:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.
- `LTileField:updatePointLight(id, opts) -> nil`: Updates an existing point light by id.

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
