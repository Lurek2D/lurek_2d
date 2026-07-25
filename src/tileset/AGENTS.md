# Tileset Module Contract

## Mission & Scope
- Own atlas-local tile metadata, animation, autotile rules, and visual tile profiles.
- Keep map storage, coordinates, imports, and dirty state in `tilemap`.

## Files
- `tileset.rs`, `catalog.rs`: Tile metadata and catalog snapshots.
- `animation.rs`, `autotile.rs`: Animation and autotile rules.
- `archetype.rs`, `visual.rs`: Object defaults and visual profiles.
- `limits.rs`, `error.rs`: Limits and errors.

## Rules
- `TileSet` explains GIDs; it does not own map cells or map-wide indexes.
- Keep GID ranges and animation metadata stable across valid changes.
- `tilemap` owns map mutation and dirty updates.
- Lua construction and mutation use checked, bounded paths. Errors name `lurek.tileset.<method>`.
- Archetypes are defaults only. Other modules create their own runtime state.
- Catalog entries are snapshots, not live shared tilesets.

## Workflow
- Run `cargo test --test tileset_tests`.
- Run tilemap tests after animation or autotile contract changes.
- Run tileset Lua security/stress tests for public changes.
