<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/tilefield.md or source docstrings instead. -->

# tilefield

## TL;DR

`lurek.tilefield` is the shared tile-based gameplay data owner for multi-level maps. It stores independent blockers, costs, profile names, and author-defined cell refs so pathfinding, awareness, tilelight, minimap, and raycaster adapters can share one source of truth without depending on each other.

## General Info

- Module group: `Feature Systems`
- Source path: `src/tilefield`
- Binding: `src/lua_api/tilefield_api.rs`
- Namespace: `lurek.tilefield`
- Lua API surface: `6` functions, `2` types, `93` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- Coordinates exposed to Lua are one-based `x, y, z`; Rust storage is zero-based.
- `LTileField` is a single field with width, height, and one or more levels. This is the default one-level map model.
- `LTileFieldMap` is a 2D or layered map of shared `LTileField` handles. Use it when a world is chunked into fields or stacked as layers of fields.
- Supported topologies are `square`, `square4`, `square8`, `iso_square`, and `hex`. `square`/`square8` use eight neighbors, but radial range budgets use Euclidean square distance so a diagonal is `sqrt(2)`; `square4` uses Manhattan distance, and `iso_square` uses square gameplay math because projection belongs to tilemap/rendering.
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

### catalog.rs

- This file owns catalog behavior inside the tilefield subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate catalog state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

### category.rs

- This file owns category behavior inside the tilefield subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate category state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for category work.

### cell.rs

- This file owns cell behavior inside the tilefield subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate cell state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for cell work.
- Serialization, indexing, and boundary checks stay here when they depend on cell internals.
- Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
- Open this file when cell ownership changes, but keep unrelated subsystem policy in sibling modules.

### emitter.rs

- This file owns emitter behavior inside the tilefield subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate emitter state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

### field.rs

- This file owns field behavior inside the tilefield subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate field state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for field work.
- Serialization, indexing, and boundary checks stay here when they depend on field internals.
- Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
- Open this file when field ownership changes, but keep unrelated subsystem policy in sibling modules.
- The code favors small data transformations so examples, specs, and tests can assert behavior directly.
- Stateful changes are kept deterministic here so generated docs and smoke tests remain reproducible.
- Cross-module dependencies are intentionally narrow, with shared types imported only at this boundary.

### field_map.rs

- This file owns field map behavior inside the tilefield subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate field map state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for field map work.
- Serialization, indexing, and boundary checks stay here when they depend on field map internals.

### line.rs

- Owns deterministic tile-line traversal for square, isometric-square, hex, and vertical level checks.
- Converts two zero-based cell coordinates into ordered cells used by blocker and occlusion queries.
- Implements Bresenham square lines, axial hex interpolation, and same-column vertical level traversal.
- Keeps traversal math independent from movement, visibility, action, lighting, and rendering decisions.
- Rejects arbitrary diagonal multi-level lines so callers get a clear v1 boundary instead of guessed cells.

### mod.rs

- Indexes the tilefield gameplay-semantics subsystem and keeps its public Rust surface explicit.
- Exports cell, field, field-map, line, modifier, and topology owners used by Lua bindings and tests.
- Re-exports compact data types so callers can build field inputs without depending on file layout.
- Keeps tilefield independent from renderers, minimaps, raycasters, pathfinding, awareness, and tilelight state.
- Agents start here to trace which file owns blockers, costs, topology math, slots, and modifiers.
- Neighbor modules may consume exported data, but they do not become owners of tilefield semantics.

### modifier.rs

- This file owns modifier behavior inside the tilefield subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate modifier state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

### reference.rs

- This file owns reference behavior inside the tilefield subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate reference state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

### semantics.rs

- This file owns semantics behavior inside the tilefield subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate semantics state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for semantics work.

### topology.rs

- Owns the tilefield topology implementation for the tilefield subsystem and keeps related runtime rules local here.
- Keeps tilefield topology, authored grid data, and lookup helpers so helpers stay close to invariants this file updates.
- Defines how tilefield topology data is validated, transformed, or stored before neighboring systems consume it.
- Separates tilefield topology behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where tilefield code accepts inputs, reports errors, allocates state, or emits outputs.



## Lua API Ref

### Functions

- `lurek.tilefield.createLightsFromTileset(field, slot, tileset, opts?) -> table`: Creates normal render lights and occluders from tilefield refs whose tileset objects define `renderLight` or `occluder`.
- `lurek.tilefield.createPhysicsFromTileset(field, slot, tileset, world, opts?) -> LBody[]`: Creates physics bodies from tilefield refs whose tileset objects define `physics`.
- `lurek.tilefield.fromProvider(provider) -> LTileField`: Builds a native tilefield from a Lua provider table with width, height, optional levels/topology, slots, modifiers, regions, and optional getCell(x,y,z).
- `lurek.tilefield.fromTileMap(tilemap, opts?) -> LTileField`: Copies a tilemap layer into a tilefield, optionally applying tileset object defaults and a ref slot.
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

- `LTileField:applyModifier(x, y, z?, modifier) -> nil`: Applies a named modifier to one cell.
- `LTileField:applyProfile(x, y, z?, profile) -> nil`: Applies a legacy profile to one cell.
- `LTileField:applyTilesetObject(x, y, z?, slot, tileset, opts?) -> boolean`: Applies the object archetype defaults for a tileset tile referenced from one cell.
- `LTileField:applyTilesetObjectLayer(slot, tileset, opts?) -> integer`: Applies tileset object defaults for every referenced cell on one tilefield level.
- `LTileField:beginEdit() -> nil`: Clears pending dirty rectangles before a grouped tilefield edit.
- `LTileField:blocks(x, y, z?, channel) -> boolean`: Returns whether a cell blocks a channel.
- `LTileField:blocksCategory(x, y, z?, category) -> boolean`: Returns whether one cell blocks a category.
- `LTileField:clear() -> nil`: Clears all gameplay state, modifiers, and references in the field.
- `LTileField:clearCell(x, y, z?) -> nil`: Clears gameplay state for one addressed cell.
- `LTileField:clearLine(from_tbl, to_tbl, channel, opts?) -> boolean`: Returns true when the line between two cell tables has no blocker for a channel.
- `LTileField:clearModifier(x, y, z?, modifier) -> boolean`: Removes one modifier from one cell.
- `LTileField:clearOccupant(x, y, z?) -> boolean`: Clears any occupant id stored on one tile cell.
- `LTileField:clearRef(x, y, z?, slot) -> nil`: Clears a named object/tile reference from one cell.
- `LTileField:commitEdit(chunkSize?) -> table`: Clears and returns dirty rectangles accumulated since `beginEdit`.
- `LTileField:defineBlockWorldSlots() -> table`: Defines conventional ref slots for mutable block worlds without adding a new module.
- `LTileField:defineCategory(name, opts?) -> nil`: Defines or replaces a user category used by movement, awareness, light, sun, or custom systems.
- `LTileField:defineSlot(slot) -> nil`: Defines a named object slot that cells may reference.
- `LTileField:drainDirtyRects(chunkSize?) -> table`: Clears and returns pending dirty cell rectangles.
- `LTileField:exportBlockLayer(channel, z?) -> table`: Exports one blocker channel and level as a row-major boolean array.
- `LTileField:exportCostLayer(channel, z?) -> table`: Exports one cost channel and level as a row-major number array.
- `LTileField:exportRefLayer(slot, z?) -> nil`: Exports one named object/tile reference slot and level as a row-major array.
- `LTileField:firstBlocker(from_tbl, to_tbl, channel, opts?) -> table|nil`: Returns the first one-based blocking cell table between two cells, or nil.
- `LTileField:footprintPassable(x, y, z?, w, h, category) -> boolean`: Returns whether a rectangular footprint can occupy a cell anchor for a category.
- `LTileField:getCategories() -> string[]`: Returns the sorted names of all known cell categories.
- `LTileField:getCategory(name) -> table|nil`: Returns category metadata, or nil when the category is unknown.
- `LTileField:getCategoryCost(x, y, z?, category) -> number`: Returns one effective category cost.
- `LTileField:getCategoryFilter(x, y, z?, category) -> table`: Returns one effective RGB category filter.
- `LTileField:getCategoryTransmission(x, y, z?, category) -> number`: Returns one effective category transmission multiplier.
- `LTileField:getCell(x, y, z?) -> table`: Returns a table with blockers, costs, sun occlusion, refs, and modifiers.
- `LTileField:getCost(x, y, z?, channel) -> number`: Returns the cost for one cell/channel.
- `LTileField:getDirtyRects(chunkSize?) -> table`: Returns pending dirty cell rectangles without clearing them.
- `LTileField:getModifier(name) -> table|nil`: Returns a named tile modifier table, or nil.
- `LTileField:getModifiers(x, y, z?) -> string[]`: Returns active modifier names on one cell.
- `LTileField:getNeighbors(x, y, z?) -> table`: Returns topology-aware same-level neighbours for one cell.
- `LTileField:getOccupant(x, y, z?) -> integer`: Returns the occupant id stored on one tile cell.
- `LTileField:getProfile(name) -> table|nil`: Returns a legacy profile table, or nil.
- `LTileField:getRef(x, y, z?, slot) -> integer|table|nil`: Returns a named object/tile reference from one cell, or nil.
- `LTileField:getRefProperties(x, y, z?, slot, tileset, opts?) -> table|nil`: Reads all tileset properties for a tile referenced from one cell.
- `LTileField:getRefProperty(x, y, z?, slot, tileset, property, opts?) -> string|nil`: Reads a tileset property for a tile referenced from one cell.
- `LTileField:getRefPropertyBool(x, y, z?, slot, tileset, property, opts?) -> boolean|nil`: Reads a tileset property for a tile referenced from one cell and parses it as a boolean.
- `LTileField:getRefPropertyNumber(x, y, z?, slot, tileset, property, opts?) -> number|nil`: Reads a tileset property for a tile referenced from one cell and parses it as a number.
- `LTileField:getRefSlots() -> string[]`: Returns the sorted names of every declared reference slot.
- `LTileField:getRegionCells(name) -> table`: Returns one-based cells for a named region, or nil when it does not exist.
- `LTileField:getRegionNames() -> table`: Returns all region names in stable order.
- `LTileField:getRegionProperties(name) -> table`: Returns all properties for a named region, or nil when the region does not exist.
- `LTileField:getRegionProperty(name, key) -> string`: Returns one string property from a named region, or nil when absent.
- `LTileField:getResource(x, y, z?) -> string`: Returns a resource label stored on one tile cell.
- `LTileField:getSize() -> integer`: Returns field width, height, and level count.
- `LTileField:getSunOcclusion(x, y, z?) -> number`: Returns top-light occlusion in the inclusive range 0..1.
- `LTileField:getTopology() -> string`: Returns the field topology name used for coordinate interpretation.
- `LTileField:getVersion() -> integer`: Returns the current tilefield data version.
- `LTileField:hasSlot(slot) -> boolean`: Returns true when a named object slot is declared.
- `LTileField:inBounds(x, y, z?) -> boolean`: Returns whether one-based coordinates are inside the field.
- `LTileField:isBuildable(x, y, z?) -> boolean`: Returns whether one tile cell accepts build placement.
- `LTileField:line(opts) -> nil`: Returns topology-aware one-based cells between `from` and `to` tables.
- `LTileField:regionContains(name, x, y, z?) -> boolean`: Returns whether a named region contains a one-based tile cell.
- `LTileField:regionsAt(x, y, z?) -> table`: Returns all region names that contain the addressed one-based tile cell.
- `LTileField:removeModifier(name) -> boolean`: Removes a named modifier and clears it from all cells.
- `LTileField:removeProfile(name) -> boolean`: Removes a legacy profile and clears it from all cells.
- `LTileField:removeRegion(name) -> boolean`: Removes a named region definition and its stored cell membership from this field.
- `LTileField:removeSlot(slot) -> boolean`: Removes a named object slot and clears its references from the field.
- `LTileField:restore(snapshot) -> nil`: Replaces this tilefield state from a snapshot returned by `snapshot`.
- `LTileField:setBlock(x, y, z?, channel, blocked) -> nil`: Sets whether a cell blocks a channel.
- `LTileField:setBuildable(x, y, z?, buildable) -> nil`: Sets whether one tile cell accepts build placement.
- `LTileField:setCategoryBlock(x, y, z?, category, blocked) -> nil`: Sets one category blocker on one cell.
- `LTileField:setCategoryCost(x, y, z?, category, cost) -> nil`: Sets one movement-cost override for a category on one cell.
- `LTileField:setCategoryFilter(x, y, z?, category, filter) -> nil`: Sets one RGB category filter on one cell.
- `LTileField:setCategoryTransmission(x, y, z?, category, value) -> nil`: Sets one category transmission multiplier on one cell.
- `LTileField:setCell(x, y, z?, cell) -> nil`: Sets cell state from a table with optional `blocks`, `costs`, `sunOcclusion`, `refs`, and `modifiers`.
- `LTileField:setCost(x, y, z?, channel, cost) -> nil`: Sets the cost for one cell/channel.
- `LTileField:setModifier(name, modifier) -> nil`: Registers or replaces a named tile modifier.
- `LTileField:setOccupant(x, y, z?, occupant) -> nil`: Stores an occupant id on one tile cell.
- `LTileField:setProfile(name, profile) -> nil`: Registers or replaces a legacy tilefield profile.
- `LTileField:setRef(x, y, z?, slot, value) -> nil`: Sets a named object/tile reference on one cell.
- `LTileField:setRegionCells(name, cells) -> nil`: Defines or replaces a named region from explicit one-based tile cells.
- `LTileField:setRegionProperty(name, key, value) -> nil`: Sets or clears one string property on a named region. Numbers and booleans are stringified; nil removes the property.
- `LTileField:setRegionRect(name, x1, y1, x2, y2, z?) -> nil`: Defines or replaces a named region from an inclusive one-based tile rectangle.
- `LTileField:setResource(x, y, z?, resource?) -> nil`: Sets or clears a resource label on one tile cell.
- `LTileField:setSunOcclusion(x, y, z?, value) -> nil`: Sets top-light occlusion in the inclusive range 0..1.
- `LTileField:snapshot() -> table`: Captures block/cost/ref layers plus resource, buildable, and occupant cell facts.
- `LTileField:type() -> string`: Returns the Lua-visible type name for this tilefield handle.
- `LTileField:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.
- `LTileField:writeBlockLayer(channel, z?, values) -> nil`: Writes one full blocker channel layer from a row-major boolean array.
- `LTileField:writeCostLayer(channel, z?, values) -> nil`: Writes one full cost channel layer from a row-major number array.
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

## Architecture Links

- No module-specific architecture links registered.

## Notes

- No additional module-specific notes.
