<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/tileset.md or source docstrings instead. -->

# tileset

## TL;DR

`lurek.tileset` owns reusable tileset metadata: atlas geometry, tile properties, object archetypes, animation frames, autotile rules, and catalogs that resolve typed tilefield refs for tilemap rendering.

## General Info

- Module group: `Feature Systems`
- Source path: `src/tileset`
- Binding: `src/lua_api/tileset_api.rs`
- Namespace: `lurek.tileset`
- Lua API surface: `3` functions, `2` types, `43` methods
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

- Owns local tile-id and frame-duration records for tileset animations.
- These frames are metadata consumed by tilemap timing/render selection; they are
- intentionally not general entity animation timelines.

### archetype.rs

- Owns reusable object archetypes and their author-default validation.
- Archetypes describe defaults for neighboring owners to materialize. They do not
- create physics bodies, lights, blockers, or render resources themselves.

### autotile.rs

- Owns autotile matching modes and terrain-profile metadata.
- The module describes authoring metadata only. Tilemap owns neighborhood scans,
- map mutation, and dirty-region propagation when these rules are applied.

### catalog.rs

- Owns snapshot catalogs that resolve typed tilefield references to tileset metadata.
- A catalog stores cloned `TileSet` values intentionally. A catalog lookup is a
- stable snapshot; mutating the original Lua tileset after `newCatalog` does not
- mutate the catalog entry. Shared live handles remain a separate future feature.

### error.rs

- Defines the error vocabulary shared by tileset construction and metadata mutation.
- The tileset boundary reports these errors to Lua with the owning API name added by
- the binding. Keeping the structured cases here prevents arithmetic, id, and limit
- failures from becoming unrelated free-form strings across the subsystem.

### limits.rs

- Owns conservative allocation and numeric ceilings for atlas-local tileset metadata.
- These limits are deliberately tileset-specific. They are not borrowed from `tilemap`,
- because a tileset has different hostile-input risks: atlas arithmetic, nested author
- records, rule tables, and copied catalog snapshots all need independent bounds.

### mod.rs

- This module index owns the public shape of the tileset subsystem and its source navigation map.
- It declares which sibling files participate in tileset behavior and which names are reexported outward.
- Reexports here are intentionally narrow so callers do not depend on private implementation modules.
- Agents should start here to understand subsystem boundaries before opening deeper implementation files.
- New submodules belong here only when they add durable behavior rather than temporary test scaffolding.
- Keep this index synchronized with specs, examples, and Lua bindings whenever public ownership changes.

### tileset.rs

- Owns validated atlas geometry and atlas-local metadata registries.
- `TileSet` stores local tile ids, object mappings, properties, animations, and
- autotile metadata. It never owns map cells, GPU resources, or runtime gameplay
- state. All Lua-created instances enter through `try_new` so checked dimensions,
- global-id ranges, and tileset-specific ceilings are enforced before registration.

### visual.rs

- Owns atlas-local visual references stored on tileset object archetypes.
- Visual records contain identifiers and source rectangles only. Texture loading,
- handles, GPU lifetime, and draw submission remain owned by asset/image/render.



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

- Lua-facing handle that shares ownership of one native tile catalog.

##### Fields

- No documented fields.

##### Methods

- `LTileCatalog:getIds() -> table`: Returns the sorted catalog ids available for typed tile references.
- `LTileCatalog:getObject(reference) -> table|nil`: Resolves object archetype metadata from a typed tile or object reference.
- `LTileCatalog:getTileset(id) -> LTileSet|nil`: Returns the tileset stored under a catalog id.
- `LTileCatalog:getVisual(reference) -> table|nil`: Resolves render visual metadata from a typed tile or object reference.
- `LTileCatalog:type() -> string`: Returns the Lua-visible userdata type name for this tile catalog.
- `LTileCatalog:typeOf(name) -> boolean`: Checks whether this catalog matches a type name.

#### LTileSet Type

- Lua-facing handle that shares ownership of one native tileset.

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
- `LTileSet:getTerrainProfile(name) -> table|nil`: Returns a Godot-style terrain-set profile.
- `LTileSet:getTextureDimensions() -> integer`: Returns the computed texture width and height in pixels.
- `LTileSet:getTileCount() -> integer`: Returns the number of tile entries in this tileset.
- `LTileSet:getTileDimensions() -> integer`: Returns the tile width and height in pixels.
- `LTileSet:getTileHeight() -> integer`: Returns the height of each tile in pixels.
- `LTileSet:getTileObject(tile_id) -> string|nil`: Returns the object archetype name mapped to one tile.
- `LTileSet:getTileWidth() -> integer`: Returns the width of each tile in pixels.
- `LTileSet:removeObject(name) -> boolean`: Removes an object archetype by name.
- `LTileSet:setAnimation(tile_id, frames) -> nil`: Replaces the animation frames for one tile.
- `LTileSet:setAutoTileMode(type_name, mode) -> nil`: Sets the autotile matching mode for a tile type.
- `LTileSet:setAutoTileRule(type_name, bitmask, tile_id) -> nil`: Sets a four-neighbor autotile bitmask rule for a tile type.
- `LTileSet:setAutoTileRule8(type_name, bitmask, tile_id) -> nil`: Sets an eight-neighbor autotile bitmask rule for a tile type.
- `LTileSet:setObject(name, object) -> nil`: Stores an object archetype and its visual, pathing, lighting, and custom metadata.
- `LTileSet:setPhysicsShape(tile_id, shape?) -> nil`: Sets or clears the physics shape label for one tile.
- `LTileSet:setProfile(tile_id, profile?) -> nil`: Sets or clears the named gameplay profile for one tile.
- `LTileSet:setProperty(tile_id, name, value) -> nil`: Sets or clears a custom string-convertible tile property.
- `LTileSet:setTerrainProfile(name, profile) -> nil`: Sets a Godot-style terrain-set profile for autotile authoring.
- `LTileSet:setTileObject(tile_id, object_name?) -> nil`: Assigns or clears the object archetype mapped to one tile.
- `LTileSet:type() -> string`: Returns the Lua-visible userdata type name for this tileset.
- `LTileSet:typeOf(name) -> boolean`: Checks whether this tileset matches a type name.

## Examples

- `content/examples/tileset.lua` (present)

## Architecture Links

- No module-specific architecture links registered.

## Notes

- No additional module-specific notes.
