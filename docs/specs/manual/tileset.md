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

