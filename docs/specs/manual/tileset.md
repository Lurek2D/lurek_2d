# tileset Manual Notes

## TL;DR

`lurek.tileset` owns reusable tileset metadata: atlas geometry, tile properties, object archetypes, animation frames, autotile rules, and catalogs that resolve typed tilefield refs for tilemap rendering.

## Summary

- `LTileSet` describes what tile ids mean inside one atlas, independent of map storage and gameplay fields.
- Atlas geometry covers first gid, tile count, columns, tile size, spacing, margin, and computed source quads.
- Tile properties are arbitrary author metadata and are useful for editor imports, object refs, and examples.
- Object archetypes describe named tile objects with optional visual, blocker, cost, and property data.
- Tile animations stay local to the tileset so tilemap rendering can ask for the current tile frame.
- Autotile rules map neighborhood masks to tile ids, while tilemap owns where those rules are applied.
- `LTileCatalog` stores named tilesets and resolves `{ tileset, tile/object }` refs from tilefield slots.
- The legacy `lurek.tilemap.newTileSet` alias remains a compatibility path, but new code should use `lurek.tileset.newTileSet`.

## Boundaries

- `tilemap` owns map layers, chunks, tile ids, coordinate transforms, imports, and render payload assembly.
- `tilefield` owns gameplay blockers, costs, categories, refs, and profile application.
- `tileset` may provide profile names and object metadata, but it does not own movement or visibility rules.
- `render`, `image`, and asset loading own textures and GPU resources; tilesets only describe atlas-local metadata.

## Validation and limits

All Lua-created tilesets use checked construction. `tileCount`, `columns`, `tileWidth`,
and `tileHeight` must be greater than zero; the global GID range and atlas width/height
must fit checked arithmetic. The default ceilings are:

- 1,000,000 tiles; 65,536 columns; 16,777,216 pixels per atlas dimension;
- 65,536 archetypes, catalog entries, terrain profiles, and 4/8-way rule entries;
- 256 properties per owner, 1,000,000 properties per tileset, 1,000,000 animation
  sequences, and 256 frames per sequence;
- 256 bytes per name, 4,096 bytes per author string, and 4,096 cells per footprint side.

The Rust owner exposes these as `TilesetLimits` for deterministic importer/test limits.
Invalid local ids, empty names, non-finite numbers, non-positive animation durations,
unsupported enum strings, and out-of-range archetype defaults return errors before the
mutation is published. Lua errors include the canonical `lurek.tileset.<method>` prefix.

## Catalog snapshot semantics

`lurek.tileset.newCatalog` clones each supplied `LTileSet` into a bounded catalog.
Catalog entries are immutable snapshots from the perspective of the original Lua handle:
mutating the source tileset after catalog creation does not update the catalog entry.
The `lurek.tileset` namespace owns catalog construction and typed-ref resolution; it does
not materialize tilefield gameplay state. Shared live handles are intentionally not part
of this contract.

## Namespace and compatibility timeline

`lurek.tileset.newTileSet` is the canonical constructor. The existing
`lurek.tilemap.newTileSet` name remains a compatibility alias during migration and uses
the same validated implementation. New examples and docs should use `lurek.tileset`;
the alias may be deprecated in a future compatibility release after callers have moved.

## Animation boundary

Tileset animation stores only a local tile id and a positive frame duration in
milliseconds. Tilemap consumes this metadata for GID frame selection and timers.
General sprite/entity timelines, playback controllers, callbacks, and animation state
belong to `sprite` and `animation`, not to `tileset`.
