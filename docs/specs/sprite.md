# sprite

## General Info

- Module group: `Feature Systems`
- Source path: `src/sprite/`
- Lua API path(s): `src/lua_api/sprite_api.rs`
- Primary Lua namespace: `lurek.sprite`
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

The `sprite` module is a powerful Feature Systems tier component dedicated to 2D texture rendering primitives. It provides the essential building blocks for 2D game visuals, encompassing sprite sheets, texture atlases, scalable UI panels, and high-performance batch rendering. At its most basic level, the `Sprite` struct defines a single textured unit with properties for position, scale, rotation, and color tint. To manage animation frames, the `SpriteSheet` divides a single texture into a uniform grid. It supports precomputed frame rectangles, named frame groups for animation sequences, and specific layouts for directional character sprites (such as the standard RPG Maker 3x4 layout). 

For more complex texture packing, the module features a comprehensive `SpriteAtlas` system. It parses standard texture atlas formats, specifically supporting JSON exports from popular tools like TexturePacker and Aseprite. The atlas stores named regions (`AtlasEntry`) complete with pixel rectangles and flags for rotation or flipping, allowing for O(1) name lookups and seamless integration with existing art pipelines. The module also includes `NineSlice`, a specialized struct that generates 9-patch geometry. This enables the creation of scalable UI elements—such as dialog boxes, health bars, or menu panels—that preserve their corner and edge pixel ratios while stretching to fit target dimensions.

To ensure optimal rendering performance, the module provides the `SpriteBatch` mechanism. A `SpriteBatch` acts as a deferred draw-call collector bound to a single texture atlas. Instead of submitting individual sprites to the GPU one by one, developers can accumulate hundreds of positioned, rotated, and scaled sprite entries into a single batch. This approach drastically reduces state changes and GPU draw calls, making it highly efficient for rendering dense tile layers, complex UI screens, or large swarms of characters. Fully accessible via the `lurek.sprite.*` Lua API, this module is indispensable for performant 2D game development in Lurek2D.

## Source Documentation

### `atlas.rs`
- Named atlas region type (`AtlasEntry`) with pixel rect, rotation, and flip flags.
- `SpriteAtlas` lookup table: ordered Vec + HashMap for O(1) name lookup.
- TexturePacker JSON parser supporting both array and object frame formats.
- Aseprite JSON parser with the same dual-format support.
- Conversion from `image::TextureAtlas` for runtime atlas building.

### `mod.rs`
- Sprite, SpriteSheet, and SpriteBatch types for 2D rendering
- Texture atlas parsing (TexturePacker JSON) and region lookup
- Nine-slice panel geometry for scalable UI elements

### `nine_slice.rs`
- Nine-slice (9-patch) descriptor that splits a texture into corners, edges, and a center.
- Generates source/destination patch tuples for scalable UI borders and panels.
- Preserves corner pixel ratios while stretching edges and center to fit target dimensions.

### `sprite.rs`
- Single-sprite data type holding texture, position, scale, rotation, and colour tint.
- Constructor and transform setters for positioning and styling sprites.
- Designed as a lightweight value object consumed by the render pipeline.

### `sprite_batch.rs`
- Deferred sprite draw-call collector bound to a single texture atlas.
- Accumulates positioned, rotated, scaled source-quad entries for batch submission.
- Supports optional capacity cap to limit per-frame draw volume.

### `sprite_sheet.rs`
- Uniform grid frame extraction from a single texture via per-frame width/height.
- Precomputed Rect lookup by linear index, row, column, or arbitrary range.
- Named frame groups for tagging animation sequences within the grid.
- Directional animation layout (rows or columns) for multi-facing character sheets.
- Preset constructors for RPGMaker 3×4 sheets and SpriteAtlas-backed sheets.
- Debug visualisation that rasterises the grid into an ImageData with coloured borders.

## Types

- `AtlasEntry` (`struct`, `atlas.rs`): A single named region within a sprite atlas.
- `SpriteAtlas` (`struct`, `atlas.rs`): In-memory sprite atlas built from a TexturePacker JSON export.
- `Patch` (`type`, `nine_slice.rs`): One computed source/destination rectangle tuple produced by a nine-slice layout.
- `NineSlice` (`struct`, `nine_slice.rs`): Scalable panel descriptor built from one texture plus four insets.
- `Sprite` (`struct`, `sprite.rs`): Smallest textured sprite unit with position, scale, rotation, and tint.
- `SpriteBatch` (`struct`, `sprite_batch.rs`): Shared-texture batch container used to prepare many sprite draws efficiently.
- `BatchEntry` (`struct`, `sprite_batch.rs`): One packed sprite instance inside a batch, including source quad and transform fields.
- `FrameGroup` (`struct`, `sprite_sheet.rs`): Named frame-range descriptor inside a sprite sheet.
- `DirectionLayout` (`enum`, `sprite_sheet.rs`): Enum describing whether directional frames are arranged by rows or columns.
- `SpriteSheet` (`struct`, `sprite_sheet.rs`): Atlas helper that maps grid frames and named groups to reusable regions.

## Functions

- `AtlasEntry::get_flipped` (`atlas.rs`): Clone this entry with the flip_x and flip_y flags replaced by the given values.
- `SpriteAtlas::new` (`atlas.rs`): Create an empty atlas with no entries.
- `SpriteAtlas::from_texture_atlas` (`atlas.rs`): Build a SpriteAtlas from an image::TextureAtlas, sorting regions by name.
- `SpriteAtlas::add_entry` (`atlas.rs`): Insert or replace an entry by name; updates both the Vec and the name map.
- `SpriteAtlas::get_entry` (`atlas.rs`): Look up a region by name; returns None when not present.
- `SpriteAtlas::get_by_index` (`atlas.rs`): Return the entry at the given insertion-order index, or None when out of bounds.
- `SpriteAtlas::entry_count` (`atlas.rs`): Return the total number of entries in this atlas.
- `SpriteAtlas::entry_names` (`atlas.rs`): Return all entry names in insertion order.
- `parse_texturepacker_json` (`atlas.rs`): Parses a TexturePacker JSON export string and returns a [`SpriteAtlas`].
- `parse_aseprite_json` (`atlas.rs`): Parses an Aseprite JSON export and returns a [`SpriteAtlas`].
- `NineSlice::new` (`nine_slice.rs`): Create a NineSlice with explicit border insets and full texture dimensions.
- `NineSlice::patches` (`nine_slice.rs`): Return the 9 Patch tuples for drawing a nine-slice box at (x, y) with target dimensions (w, h).
- `Sprite::new` (`sprite.rs`): Create a sprite at position with identity scale, zero rotation, and white tint.
- `Sprite::set_position` (`sprite.rs`): Set the world-space position to (x, y).
- `Sprite::set_scale` (`sprite.rs`): Set the non-uniform scale to (sx, sy).
- `Sprite::set_rotation` (`sprite.rs`): Set the rotation angle in radians.
- `Sprite::set_color` (`sprite.rs`): Replace the colour tint.
- `SpriteBatch::new` (`sprite_batch.rs`): Create a batch for texture_key with the given max_entries cap; 0 uses a default capacity of 256.
- `SpriteBatch::add` (`sprite_batch.rs`): Append a BatchEntry and return its index; returns None when the max_entries limit is reached.
- `SpriteBatch::clear` (`sprite_batch.rs`): Remove all entries without releasing the underlying allocation.
- `SpriteBatch::texture_key` (`sprite_batch.rs`): Return the TextureKey this batch is bound to.
- `SpriteBatch::entries` (`sprite_batch.rs`): Return the accumulated entry slice for this frame.
- `SpriteBatch::len` (`sprite_batch.rs`): Return the current number of entries in the batch.
- `SpriteBatch::is_empty` (`sprite_batch.rs`): Return true when the batch contains no entries.
- `SpriteBatch::buffer_size` (`sprite_batch.rs`): Return the configured max_entries cap; 0 means unlimited.
- `SpriteSheet::new` (`sprite_sheet.rs`): Create a SpriteSheet from texture dimensions and per-frame size; precomputes all frame Rects.
- `SpriteSheet::get_frame` (`sprite_sheet.rs`): Return the Rect for frame at linear index, or None when out of bounds.
- `SpriteSheet::get_frame_count` (`sprite_sheet.rs`): Return the total number of precomputed frames.
- `SpriteSheet::get_frame_size` (`sprite_sheet.rs`): Return (frame_width, frame_height) in pixels.
- `SpriteSheet::get_grid_size` (`sprite_sheet.rs`): Return (columns, rows) of the grid.
- `SpriteSheet::get_row` (`sprite_sheet.rs`): Return all frame Rects on the given row index; empty vec when row >= rows.
- `SpriteSheet::get_column` (`sprite_sheet.rs`): Return all frame Rects in the given column index; empty vec when col >= columns.
- `SpriteSheet::get_range` (`sprite_sheet.rs`): Return up to count frames starting at start; empty vec when start >= frame count.
- `SpriteSheet::name_group` (`sprite_sheet.rs`): Register a named frame group starting at start_frame for count consecutive frames.
- `SpriteSheet::get_group` (`sprite_sheet.rs`): Return the Rects for the named group, or None when the name is not registered.
- `SpriteSheet::get_group_names` (`sprite_sheet.rs`): Return all registered group names in unspecified order.
- `SpriteSheet::set_directions` (`sprite_sheet.rs`): Configure the sheet for directional animation with count directions arranged by layout.
- `SpriteSheet::get_direction_frames` (`sprite_sheet.rs`): Return all frame Rects for the given direction index; None when set_directions was not called or index out of range.
- `SpriteSheet::draw_to_image` (`sprite_sheet.rs`): Rasterise the sheet grid (red borders, green for group starts) into a new ImageData of the given dimensions.
- `SpriteSheet::from_rpgmaker` (`sprite_sheet.rs`): Create a SpriteSheet pre-configured for the RPGMaker 3×4 character sheet layout with named direction groups.
- `SpriteSheet::from_atlas` (`sprite_sheet.rs`): Build a SpriteSheet from a SpriteAtlas using atlas entry Rects as frames; names each entry as a group.

## Lua API Reference

- Binding path(s): `src/lua_api/sprite_api.rs`
- Namespace: `lurek.sprite`

### Module Functions
- `lurek.sprite.newSheet`: Creates a new sprite sheet by dividing a texture of the given pixel size into a grid of equal-sized frames.
- `lurek.sprite.newRPGMakerSheet`: Creates a sprite sheet using RPG Maker's standard character layout (4 columns × 4 rows per character block).
- `lurek.sprite.parseAtlas`: Parses a TexturePacker JSON atlas string and returns a sprite atlas object.
- `lurek.sprite.newAtlasSheet`: Creates a sprite sheet from an existing atlas, treating each atlas entry as a frame within the given sheet dimensions.
- `lurek.sprite.parseAsepriteAtlas`: Parses an Aseprite JSON atlas string and returns a sprite atlas object.

### `LSpriteAtlas` Methods
- `LSpriteAtlas:getEntry`: Looks up a named sprite region in the atlas by its original filename or tag.
- `LSpriteAtlas:getByIndex`: Returns a sprite region by its 1-based index in the atlas.
- `LSpriteAtlas:entryCount`: Returns the total number of entries (sprite regions) in the atlas.
- `LSpriteAtlas:entryNames`: Returns an array of all entry names in the atlas.
- `LSpriteAtlas:getFlipped`: Returns a copy of a named atlas entry with the specified flip flags applied.
- `LSpriteAtlas:type`: Returns the type name of this object.
- `LSpriteAtlas:typeOf`: Checks whether this object matches the given type name.

### `LSpriteSheet` Methods
- `LSpriteSheet:getFrame`: Returns the UV quad for a single frame by its 1-based index.
- `LSpriteSheet:getFrameCount`: Returns the total number of frames in this sprite sheet.
- `LSpriteSheet:getRow`: Returns all frame quads in the given row of the sprite sheet grid.
- `LSpriteSheet:getColumn`: Returns all frame quads in the given column of the sprite sheet grid.
- `LSpriteSheet:getGroupFrames`: Returns the frame quads for a named animation group.
- `LSpriteSheet:getGroupNames`: Returns an array of all named animation group names defined on this sheet.
- `LSpriteSheet:nameGroup`: Defines a named animation group as a contiguous range of frames.
- `LSpriteSheet:getFrameSize`: Returns the pixel dimensions of a single frame cell.
- `LSpriteSheet:getGridSize`: Returns the number of columns and rows in the sprite sheet grid.
- `LSpriteSheet:drawToImage`: Renders the sprite sheet grid into an LImage of the given size for debugging or previews.
- `LSpriteSheet:type`: Returns the type name of this object.
- `LSpriteSheet:typeOf`: Checks whether this object matches the given type name.

## References

- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems.`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/sprite/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- This module has no dedicated direct `lurek.*` namespace and is usually consumed through higher integration layers.
