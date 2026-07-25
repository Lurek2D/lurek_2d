# Tilemap Module Contract

## Mission & Scope
- Own map storage, chunks, imports, coordinate conversion, dirty regions, and render helpers.
- Keep large maps incremental instead of rebuilding whole buffers.
- `TileMap` and `ChunkMap` own map data. Render caches are not a second source of truth.

## Files
- `tilemap.rs`, `chunk.rs`: Dense and chunked map storage.
- `tmx.rs`, `ldtk.rs`: Bounded importers.
- `render.rs`, `large_map_renderer.rs`: Render data and caches.
- `coords.rs`, `orientation.rs`, `isomap.rs`: Coordinate math.
- `tilemap_index.rs`, `limits.rs`, `error.rs`: Indexes, limits, and errors.

## Rules
- Preserve orientation-specific math for orthogonal, isometric, and hex maps.
- Keep dirty updates local to changed chunks or layers.
- Apply `TileMapLimits` before allocation, import, projection, or large work.
- `LCM2` chunk data is little-endian and versioned. Reject bad headers, flags, sizes, truncation, and trailing bytes.
- TMX and LDtk imports must limit bytes, layers, objects, nodes, and external paths.
- Update reverse GID indexes exactly once after map changes.
- Atlas tile metadata belongs to `tileset`; compatibility constructors only forward.

## Workflow
- Validate with `cargo test --test tilemap_tests`.
- Regenerate docs after public Lua API changes.
