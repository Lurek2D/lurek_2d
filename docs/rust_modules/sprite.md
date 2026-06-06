# sprite

## General Info

- Module group: `Feature Systems`
- Source path: `src/sprite/`
- Binding: `src/lua_api/sprite_api.rs`
- Namespace: `lurek.sprite`
- Lua API surface: `6` functions, `11` types, `27` methods
- Rust test path(s): `tests/rust/unit/sprite_tests.rs`
- Lua test path(s): `tests/lua/unit/test_sprite_core_unit.lua`

## Summary

This module turns raw textures into reusable sprites, sheets, and UI panels. It supports named texture atlases parsed from TexturePacker and Aseprite JSON data, mapping semantic names to specific regions while handling rotation and flip flags. This allows scripts to query packed sprites by name instead of raw coordinates.

Atlas parsing now shares the engine's common Aseprite loader with the animation module. This keeps frame-shape validation and malformed-export error behavior aligned across sprite-atlas import and Aseprite animation ingest, instead of maintaining separate parsers for the same source format.

For animations and interfaces, the system offers grid sheets and scalable panels. The sprite-sheet engine divides textures into grids, precomputing frame UVs for fast index lookup and character animations. A nine-slice engine splits frames into corners and edges, letting panels stretch to any size while keeping border dimensions crisp and distortion-free.

Row and column extraction on `SpriteSheet` are implemented with allocation-light internal paths (row slices and column iterators), while Lua still receives the same table-shaped frame arrays via `LSpriteSheet:getRow` and `LSpriteSheet:getColumn`.

To optimize drawing, the module provides lightweight sprite records and instanced batching. Sprite batches group quads sharing a single texture into one draw command, bypassing call overhead. Developers can configure batch capacities to keep render loops efficient.

Individual sprites can also carry optional normal-map texture state and a strength scalar for lit-sprite workflows. This extends the sprite data model without changing atlas, sheet, or batch APIs for unlit content.

The Lua API also provides a runtime atlas packer for dynamic content. `lurek.sprite.newAtlasPacker(width, height, padding)` builds an in-memory allocator that can pack named regions, query packed rectangles, and attach optional nine-slice insets for UI scaling workflows.

## Files

### [atlas.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/sprite/atlas.rs)

- This file handles named texture-atlas regions so packed art can be addressed by semantic names instead of raw pixel rectangles.
- It stores atlas entries with the orientation and flip metadata needed to interpret packing-tool output correctly.
- Parsers for common atlas JSON formats live here because importing packed textures is a content-pipeline concern rather than a render concern.
- Aseprite atlas parsing delegates to the shared loader in `src/animation/aseprite.rs`, keeping frame validation and error paths consistent with the animation subsystem.
- Lookup is structured for fast name access while still retaining ordered iteration when tools or UIs need to inspect atlas contents.
- Conversion from runtime-built atlas data is also supported so authored and generated atlases can share one representation.
- The file is the naming and region-mapping layer for packed sprite content.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/sprite/mod.rs)

- This module provides the engine's core 2D sprite asset and batching helpers around individual sprites, sheets, atlases, and scalable panels.
- It covers both how textured regions are described and how many of them are organized for animation, UI, or efficient drawing.
- At the highest level this is the feature layer that turns textures into reusable 2D presentation pieces.

### [nine_slice.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/sprite/nine_slice.rs)

- This file defines nine-slice scaling logic for UI panels and framed elements that must resize without destroying border fidelity.
- It splits one source region into corners, edges, and center pieces whose destination layout can adapt to arbitrary target sizes.
- Corner preservation and controlled edge stretching are the core visual promises of this file.
- It is the geometry helper behind scalable textured panels in the engine.

### [sprite.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/sprite/sprite.rs)

- This file defines the lightweight single-sprite record used when one textured image instance needs position, transform, and tint data.
- It also stores optional normal-map texture identity and intensity for lit-sprite rendering paths.
- It is intentionally small because many systems want sprite-like draw data without carrying atlas, animation, or batching machinery.
- The type is the simplest textured presentation unit in the sprite subsystem.

### [sprite_batch.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/sprite/sprite_batch.rs)

- This file implements sprite batching for cases where many textured quads share one source texture and should travel together through rendering.
- It accumulates per-instance transform and source-region data so callers can build dense draw groups without issuing one command per sprite.
- Capacity limits are part of the design because some workloads want explicit control over how much batch data is retained per frame.
- The file is the performance-oriented collection layer of the sprite subsystem.

### [sprite_sheet.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/sprite/sprite_sheet.rs)

- This file turns a texture divided into repeated cells into a navigable sprite-sheet structure for frame-based animation and lookup.
- Frame rectangles are precomputed so callers can move through rows, columns, ranges, and named groups without recalculating geometry each time.
- Directional layout helpers matter here because many character sheets encode facing and animation state as a regular grid convention.
- Preset constructors keep common authoring patterns, such as RPG-style character sheets, easy to adopt without custom math in game code.
- Debug visualization is included because sheet layout mistakes are easier to catch when the frame grid can be rendered and inspected directly.
- The file is the animation-frame organization layer of the sprite module.
