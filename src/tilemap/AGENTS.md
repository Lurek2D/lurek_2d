# Tilemap Module Contract

## Mission & Scope
- Own map storage, chunks, imports, coordinate conversion, dirty regions, and render helpers.
- Keep large maps incremental instead of rebuilding whole buffers.
- `TileMap` and `ChunkMap` are authoritative storage owners; `LargeMapRenderer` is an explicit dense render snapshot/cache and is never an implicit second source of truth.
- Atlas-local tileset creation and metadata belong to `src/tileset`; `lurek.tilemap.newTileSet` is a compatibility alias over the canonical tileset constructor.

## Files
- `chunk.rs`, `map.rs`, `layer.rs`: Storage and layer state.
- `tmx.rs`, `ldtk.rs`: Importers.
- `render.rs`, `coords.rs`: Drawing and coordinate math.

## Rules
- Preserve orientation-specific math for orthogonal, isometric, and hex maps.
- Dirty-region updates must stay local to changed chunks or layers.
- Import errors should include source format and missing field context.
- Route fallible public construction and mutation through `TileMapLimits`; validate dimensions, chunk counts, operation counts, decoded bytes, and finite/positive float inputs before allocation or projection.
- Chunk serialization is little-endian `LCM2`, versioned, flags-reserved, and must reject bad headers, versions, flags, sizes, truncation, and trailing bytes.
- TMX/LDtk importers must enforce raw/decoded budgets, bounded layer/object/node counts, safe external-resource policy, and safe asset paths before filesystem work.
- Reverse GID indexes may be eager or lazy, but `set_tile`, `fill`, and import paths must invalidate or update them exactly once; animation timers must be pruned when culling state is rebuilt.
- Keep Lua registration closures thin: one-based index conversion, option parsing, and importer/render table conversion belong in named helpers.

## Workflow
- Validate with `cargo test --test tilemap_tests`.
- For public API or contract changes, regenerate docs and run the tilemap API/spec/example/security audits plus `cargo clippy -- -D warnings`.
