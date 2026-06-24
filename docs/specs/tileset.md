<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/tileset.md or source docstrings instead. -->

# tileset

## TL;DR

`lurek.tileset` owns reusable tileset metadata: atlas geometry, tile properties, object archetypes, animation frames, autotile rules, and catalogs that resolve typed tilefield refs for tilemap rendering.

## General Info

- Module group: `Feature Systems`
- Source path: `src/tileset`
- Binding: `src/lua_api/tileset_api.rs`
- Namespace: `lurek.tileset`
- Lua API surface: `3` functions, `2` types, `41` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- `LTileSet` describes what tile ids mean inside one atlas, independent of map storage and gameplay fields.
- Atlas geometry covers first gid, tile count, columns, tile size, spacing, margin, and computed source quads.
- Tile properties are arbitrary author metadata and are useful for editor imports, object refs, and examples.
- Object archetypes describe named tile objects with optional visual, blocker, cost, and property data.
- Tile animations stay local to the tileset so tilemap rendering can ask for the current tile frame.
- Autotile rules map neighborhood masks to tile ids, while tilemap owns where those rules are applied.
- `LTileCatalog` stores named tilesets and resolves `{ tileset, tile/object }` refs from tilefield slots.
- The legacy `lurek.tilemap.newTileSet` alias remains a compatibility path, but new code should use `lurek.tileset.newTileSet`.

This module primarily collaborates with `math`, `runtime`, `tilefield`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/tileset`
- Owning tier: `Feature Systems`
- Plugin tier: `core_keep`
- Lua binding owner: `src/lua_api/tileset_api.rs`
- Referenced engine modules: `math`, `runtime`, `tilefield`

## Imports

- `math`: Imports or references `src/math/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.
- `tilefield`: Imports or references `src/tilefield/`. Dependency stays inside `Feature Systems` and should remain acyclic.

## Source Files

### animation.rs

- This file owns animation behavior inside the tileset subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate animation state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

### archetype.rs

- This file owns archetype behavior inside the tileset subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate archetype state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for archetype work.

### autotile.rs

- This file owns autotile behavior inside the tileset subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate autotile state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

### catalog.rs

- This file owns catalog behavior inside the tileset subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate catalog state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for catalog work.

### mod.rs

- This module index owns the public shape of the tileset subsystem and its source navigation map.
- It declares which sibling files participate in tileset behavior and which names are reexported outward.
- Reexports here are intentionally narrow so callers do not depend on private implementation modules.
- Agents should start here to understand subsystem boundaries before opening deeper implementation files.
- New submodules belong here only when they add durable behavior rather than temporary test scaffolding.
- Keep this index synchronized with specs, examples, and Lua bindings whenever public ownership changes.

### tileset.rs

- This file owns tileset behavior inside the tileset subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate tileset state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for tileset work.
- Serialization, indexing, and boundary checks stay here when they depend on tileset internals.
- Renderer, API, and test layers should call through these helpers rather than duplicate private rules.

### visual.rs

- This file owns visual behavior inside the tileset subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate visual state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.



## Lua API Ref

### Functions

- `lurek.tileset.fromProvider(provider) -> LTileSet`: Builds a native tileset from a Lua provider table with atlas fields, objects, tileObjects, properties, and animations.
- `lurek.tileset.newCatalog(entries) -> LTileCatalog`: Creates a catalog that resolves typed references across named tilesets.
- `lurek.tileset.newTileSet(first_gid, tile_count, columns, tile_width, tile_height, spacing?, margin?) -> LTileSet`: Creates a native tileset from atlas dimensions.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LTileCatalog Type

- Creates a catalog that resolves typed references across named tilesets.

##### Fields

- No documented fields.

##### Methods

- `LTileCatalog:getIds() -> table`: Returns the sorted catalog ids available for typed tile references.
- `LTileCatalog:getObject(reference) -> table|nil`: Resolves object archetype metadata from a typed tile or object reference.
- `LTileCatalog:getTileset(id) -> LTileSet|nil`: Returns the tileset stored under a catalog id.
- `LTileCatalog:getVisual(reference) -> table|nil`: Resolves render visual metadata from a typed tile or object reference.
- `LTileCatalog:type() -> string`: Returns the userdata type name.
- `LTileCatalog:typeOf(name) -> boolean`: Checks whether this catalog matches a type name.

#### LTileSet Type

- Creates a native tileset from atlas dimensions.

##### Fields

- No documented fields.

##### Methods

- `LTileSet:getAnimation(tile_id) -> table|nil`: Returns the animation frames for one tile.
- `LTileSet:getAutoTileId(type_name, bitmask) -> integer|nil`: Resolves a four-neighbor autotile bitmask to a tile id.
- `LTileSet:getAutoTileId8(type_name, bitmask) -> integer|nil`: Resolves an eight-neighbor autotile bitmask to a tile id.
- `LTileSet:getAutoTileMode(type_name) -> string`: Returns the autotile matching mode for a tile type.
- `LTileSet:getColumns() -> integer`: Returns the number of atlas columns.
- `LTileSet:getFirstGid() -> integer`: Returns the first global tile id assigned to this tileset.
- `LTileSet:getMargin() -> integer`: Returns the atlas margin in pixels.
- `LTileSet:getObject(name) -> table|nil`: Returns object archetype metadata by name.
- `LTileSet:getObjectNames() -> table`: Returns all object archetype names in this tileset.
- `LTileSet:getPhysicsShape(tile_id) -> string|nil`: Returns the physics shape label for one tile.
- `LTileSet:getProfile(tile_id) -> string|nil`: Returns the named gameplay profile for one tile.
- `LTileSet:getProperties(tile_id) -> table`: Returns all custom properties for one tile.
- `LTileSet:getProperty(tile_id, name) -> string|nil`: Returns a custom tile property as a string.
- `LTileSet:getPropertyBool(tile_id, name) -> boolean|nil`: Returns a custom tile property parsed as a boolean.
- `LTileSet:getPropertyNumber(tile_id, name) -> number|nil`: Returns a custom tile property parsed as a number.
- `LTileSet:getQuad(tile_id) -> table`: Returns the atlas rectangle for one tile id.
- `LTileSet:getSpacing() -> integer`: Returns the spacing between atlas tiles in pixels.
- `LTileSet:getTextureDimensions() -> integer`: Returns the computed texture width and height in pixels.
- `LTileSet:getTileCount() -> integer`: Returns the number of tile entries in this tileset.
- `LTileSet:getTileDimensions() -> integer`: Returns the tile width and height in pixels.
- `LTileSet:getTileHeight() -> integer`: Returns the tile height in pixels.
- `LTileSet:getTileObject(tile_id) -> string|nil`: Returns the object archetype name mapped to one tile.
- `LTileSet:getTileWidth() -> integer`: Returns the tile width in pixels.
- `LTileSet:removeObject(name) -> boolean`: Removes an object archetype by name.
- `LTileSet:setAnimation(tile_id, frames) -> nil`: Replaces the animation frames for one tile.
- `LTileSet:setAutoTileMode(type_name, mode) -> nil`: Sets the autotile matching mode for a tile type.
- `LTileSet:setAutoTileRule(type_name, bitmask, tile_id) -> nil`: Sets a four-neighbor autotile bitmask rule for a tile type.
- `LTileSet:setAutoTileRule8(type_name, bitmask, tile_id) -> nil`: Sets an eight-neighbor autotile bitmask rule for a tile type.
- `LTileSet:setObject(name, object) -> nil`: Stores an object archetype and its visual, pathing, lighting, and custom metadata.
- `LTileSet:setPhysicsShape(tile_id, shape?) -> nil`: Sets or clears the physics shape label for one tile.
- `LTileSet:setProfile(tile_id, profile?) -> nil`: Sets or clears the named gameplay profile for one tile.
- `LTileSet:setProperty(tile_id, name, value) -> nil`: Sets or clears a custom string-convertible tile property.
- `LTileSet:setTileObject(tile_id, object_name?) -> nil`: Assigns or clears the object archetype mapped to one tile.
- `LTileSet:type() -> string`: Returns the userdata type name.
- `LTileSet:typeOf(name) -> boolean`: Checks whether this tileset matches a type name.

## Examples

- `content/examples/tileset.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_tileset_unit.lua` (present)
- Rust: none detected.

## Evidence / Golden

| Kind | Path |
|---|---|
| Current artifact | `tests/artifacts/current/image/tileset_128x128.png` |
| Baseline artifact | `tests/artifacts/baselines/image/tileset_128x128.png` |

## Architecture Links

- No module-specific architecture links registered.

## Notes

- No additional module-specific notes.
