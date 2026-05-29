# sprite

## TL;DR

- The `sprite` module is a powerful Feature Systems tier component dedicated to 2D texture rendering primitives.

## General Info

- Module group: `Feature Systems`
- Source path: `src/sprite/`
- Lua API path(s): `src/lua_api/sprite_api.rs`
- Primary Lua namespace: `lurek.sprite`
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

It provides the essential building blocks for 2D game visuals, encompassing sprite sheets, texture atlases, scalable UI panels, and high-performance batch rendering. At its most basic level, the `Sprite` struct defines a single textured unit with properties for position, scale, rotation, and color tint. To manage animation frames, the `SpriteSheet` divides a single texture into a uniform grid. It supports precomputed frame rectangles, named frame groups for animation sequences, and specific layouts for directional character sprites (such as the standard RPG Maker 3x4 layout). 

For more complex texture packing, the module features a comprehensive `SpriteAtlas` system. It parses standard texture atlas formats, specifically supporting JSON exports from popular tools like TexturePacker and Aseprite. The atlas stores named regions (`AtlasEntry`) complete with pixel rectangles and flags for rotation or flipping, allowing for O(1) name lookups and seamless integration with existing art pipelines. The module also includes `NineSlice`, a specialized struct that generates 9-patch geometry. This enables the creation of scalable UI elements—such as dialog boxes, health bars, or menu panels—that preserve their corner and edge pixel ratios while stretching to fit target dimensions.

To ensure optimal rendering performance, the module provides the `SpriteBatch` mechanism. A `SpriteBatch` acts as a deferred draw-call collector bound to a single texture atlas. Instead of submitting individual sprites to the GPU one by one, developers can accumulate hundreds of positioned, rotated, and scaled sprite entries into a single batch. This approach drastically reduces state changes and GPU draw calls, making it highly efficient for rendering dense tile layers, complex UI screens, or large swarms of characters. Fully accessible via the `lurek.sprite.*` Lua API, this module is indispensable for performant 2D game development in Lurek2D.

## Files

### atlas.rs

- Named atlas region type (`AtlasEntry`) with pixel rect, rotation, and flip flags.
- `SpriteAtlas` lookup table: ordered Vec + HashMap for O(1) name lookup.
- TexturePacker JSON parser supporting both array and object frame formats.
- Aseprite JSON parser with the same dual-format support.
- Conversion from `image::TextureAtlas` for runtime atlas building.

### mod.rs

- Sprite, SpriteSheet, and SpriteBatch types for 2D rendering
- Texture atlas parsing (TexturePacker JSON) and region lookup
- Nine-slice panel geometry for scalable UI elements

### nine_slice.rs

- Nine-slice (9-patch) descriptor that splits a texture into corners, edges, and a center.
- Generates source/destination patch tuples for scalable UI borders and panels.
- Preserves corner pixel ratios while stretching edges and center to fit target dimensions.

### sprite.rs

- Single-sprite data type holding texture, position, scale, rotation, and colour tint.
- Constructor and transform setters for positioning and styling sprites.
- Designed as a lightweight value object consumed by the render pipeline.

### sprite_batch.rs

- Deferred sprite draw-call collector bound to a single texture atlas.
- Accumulates positioned, rotated, scaled source-quad entries for batch submission.
- Supports optional capacity cap to limit per-frame draw volume.

### sprite_sheet.rs

- Uniform grid frame extraction from a single texture via per-frame width/height.
- Precomputed Rect lookup by linear index, row, column, or arbitrary range.
- Named frame groups for tagging animation sequences within the grid.
- Directional animation layout (rows or columns) for multi-facing character sheets.
- Preset constructors for RPGMaker 3×4 sheets and SpriteAtlas-backed sheets.
- Debug visualisation that rasterises the grid into an ImageData with coloured borders.

## Lua API Ref

- Binding: `src/lua_api/sprite_api.rs`
- Namespace: `lurek.sprite`

### Functions

- `lurek.sprite.newAtlasSheet`: Creates a sprite sheet from an existing atlas, treating each atlas entry as a frame within the given sheet dimensions.
- `lurek.sprite.newRPGMakerSheet`: Creates a sprite sheet using RPG Maker's standard character layout (4 columns × 4 rows per character block).
- `lurek.sprite.newSheet`: Creates a new sprite sheet by dividing a texture of the given pixel size into a grid of equal-sized frames.
- `lurek.sprite.parseAsepriteAtlas`: Parses an Aseprite JSON atlas string and returns a sprite atlas object.
- `lurek.sprite.parseAtlas`: Parses a TexturePacker JSON atlas string and returns a sprite atlas object.

### Enums

- No documented module-level enums/constants.

### Types


#### LSpriteAtlas Type


##### Fields

- No documented fields.

##### Methods

- `LSpriteAtlas:entryCount`: Returns the total number of entries (sprite regions) in the atlas.
- `LSpriteAtlas:entryNames`: Returns an array of all entry names in the atlas.
- `LSpriteAtlas:getByIndex`: Returns a sprite region by its 1-based index in the atlas.
- `LSpriteAtlas:getEntry`: Looks up a named sprite region in the atlas by its original filename or tag.
- `LSpriteAtlas:getFlipped`: Returns a copy of a named atlas entry with the specified flip flags applied.
- `LSpriteAtlas:type`: Returns the type name of this object.
- `LSpriteAtlas:typeOf`: Checks whether this object matches the given type name.


#### LSpriteSheet Type


##### Fields

- No documented fields.

##### Methods

- `LSpriteSheet:drawToImage`: Renders the sprite sheet grid into an LImage of the given size for debugging or previews.
- `LSpriteSheet:getColumn`: Returns all frame quads in the given column of the sprite sheet grid.
- `LSpriteSheet:getFrame`: Returns the UV quad for a single frame by its 1-based index.
- `LSpriteSheet:getFrameCount`: Returns the total number of frames in this sprite sheet.
- `LSpriteSheet:getFrameSize`: Returns the pixel dimensions of a single frame cell.
- `LSpriteSheet:getGridSize`: Returns the number of columns and rows in the sprite sheet grid.
- `LSpriteSheet:getGroupFrames`: Returns the frame quads for a named animation group.
- `LSpriteSheet:getGroupNames`: Returns an array of all named animation group names defined on this sheet.
- `LSpriteSheet:getRow`: Returns all frame quads in the given row of the sprite sheet grid.
- `LSpriteSheet:nameGroup`: Defines a named animation group as a contiguous range of frames.
- `LSpriteSheet:type`: Returns the type name of this object.
- `LSpriteSheet:typeOf`: Checks whether this object matches the given type name.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems.`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
