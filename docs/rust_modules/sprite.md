# sprite

## General Info

- Module group: `Feature Systems`
- Source path: `src/sprite/`
- Binding: `src/lua_api/sprite_api.rs`
- Namespace: `lurek.sprite`
- Lua API surface: `5` functions, `9` types, `19` methods
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

It provides the essential building blocks for 2D game visuals, encompassing sprite sheets, texture atlases, scalable UI panels, and high-performance batch rendering. At its most basic level, the `Sprite` struct defines a single textured unit with properties for position, scale, rotation, and color tint. To manage animation frames, the `SpriteSheet` divides a single texture into a uniform grid. It supports precomputed frame rectangles, named frame groups for animation sequences, and specific layouts for directional character sprites (such as the standard RPG Maker 3x4 layout). 

For more complex texture packing, the module features a comprehensive `SpriteAtlas` system. It parses standard texture atlas formats, specifically supporting JSON exports from popular tools like TexturePacker and Aseprite. The atlas stores named regions (`AtlasEntry`) complete with pixel rectangles and flags for rotation or flipping, allowing for O(1) name lookups and seamless integration with existing art pipelines. The module also includes `NineSlice`, a specialized struct that generates 9-patch geometry. This enables the creation of scalable UI elements—such as dialog boxes, health bars, or menu panels—that preserve their corner and edge pixel ratios while stretching to fit target dimensions.

To ensure optimal rendering performance, the module provides the `SpriteBatch` mechanism. A `SpriteBatch` acts as a deferred draw-call collector bound to a single texture atlas. Instead of submitting individual sprites to the GPU one by one, developers can accumulate hundreds of positioned, rotated, and scaled sprite entries into a single batch. This approach drastically reduces state changes and GPU draw calls, making it highly efficient for rendering dense tile layers, complex UI screens, or large swarms of characters. Fully accessible via the `lurek.sprite.*` Lua API, this module is indispensable for performant 2D game development in Lurek2D.

## Files

### [atlas.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/sprite/atlas.rs)

- This file handles named texture-atlas regions so packed art can be addressed by semantic names instead of raw pixel rectangles.
- It stores atlas entries with the orientation and flip metadata needed to interpret packing-tool output correctly.
- Parsers for common atlas JSON formats live here because importing packed textures is a content-pipeline concern rather than a render concern.
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
