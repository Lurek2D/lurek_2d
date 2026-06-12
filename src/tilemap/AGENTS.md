# Tilemap Module Contract

## Mission & Scope
- Own map storage, chunks, imports, coordinate conversion, dirty regions, and render helpers.
- Keep large maps incremental instead of rebuilding whole buffers.

## Files
- `chunk.rs`, `map.rs`, `layer.rs`: Storage and layer state.
- `tmx.rs`, `ldtk.rs`: Importers.
- `render.rs`, `coords.rs`: Drawing and coordinate math.

## Rules
- Preserve orientation-specific math for orthogonal, isometric, and hex maps.
- Dirty-region updates must stay local to changed chunks or layers.
- Import errors should include source format and missing field context.

## Workflow
- Validate with `cargo test --test tilemap_tests`.
