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

- This file handles named texture-atlas regions so packed art can be addressed by semantic names instead of raw pixel rectangles.
- It stores atlas entries with the orientation and flip metadata needed to interpret packing-tool output correctly.
- Parsers for common atlas JSON formats live here because importing packed textures is a content-pipeline concern rather than a render concern.
- Lookup is structured for fast name access while still retaining ordered iteration when tools or UIs need to inspect atlas contents.
- Conversion from runtime-built atlas data is also supported so authored and generated atlases can share one representation.
- The file is the naming and region-mapping layer for packed sprite content.

### mod.rs

- This module provides the engine's core 2D sprite asset and batching helpers around individual sprites, sheets, atlases, and scalable panels.
- It covers both how textured regions are described and how many of them are organized for animation, UI, or efficient drawing.
- At the highest level this is the feature layer that turns textures into reusable 2D presentation pieces.

### nine_slice.rs

- This file defines nine-slice scaling logic for UI panels and framed elements that must resize without destroying border fidelity.
- It splits one source region into corners, edges, and center pieces whose destination layout can adapt to arbitrary target sizes.
- Corner preservation and controlled edge stretching are the core visual promises of this file.
- It is the geometry helper behind scalable textured panels in the engine.

### sprite.rs

- This file defines the lightweight single-sprite record used when one textured image instance needs position, transform, and tint data.
- It is intentionally small because many systems want sprite-like draw data without carrying atlas, animation, or batching machinery.
- The type is the simplest textured presentation unit in the sprite subsystem.

### sprite_batch.rs

- This file implements sprite batching for cases where many textured quads share one source texture and should travel together through rendering.
- It accumulates per-instance transform and source-region data so callers can build dense draw groups without issuing one command per sprite.
- Capacity limits are part of the design because some workloads want explicit control over how much batch data is retained per frame.
- The file is the performance-oriented collection layer of the sprite subsystem.

### sprite_sheet.rs

- This file turns a texture divided into repeated cells into a navigable sprite-sheet structure for frame-based animation and lookup.
- Frame rectangles are precomputed so callers can move through rows, columns, ranges, and named groups without recalculating geometry each time.
- Directional layout helpers matter here because many character sheets encode facing and animation state as a regular grid convention.
- Preset constructors keep common authoring patterns, such as RPG-style character sheets, easy to adopt without custom math in game code.
- Debug visualization is included because sheet layout mistakes are easier to catch when the frame grid can be rendered and inspected directly.
- The file is the animation-frame organization layer of the sprite module.

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

- Lua-visible wrapper around a SpriteAtlas, providing named region lookups.

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

#### LSpriteAtlasGetByIndexResult Type

- Generated result shape from @field tags.

##### Fields

- `flip_x` (`boolean`): Flip horizontally.
- `flip_y` (`boolean`): Flip vertically.
- `h` (`number`): H.
- `name` (`string`): Entry name.
- `rotated` (`boolean`): Whether the entry is rotated.
- `w` (`number`): W.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LSpriteAtlasGetEntryResult Type

- Generated result shape from @field tags.

##### Fields

- `h` (`number`): H.
- `name` (`string`): Entry name.
- `rotated` (`boolean`): Whether the entry is rotated.
- `w` (`number`): W.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LSpriteAtlasGetFlippedResult Type

- Generated result shape from @field tags.

##### Fields

- `flip_x` (`boolean`): Flip horizontally.
- `flip_y` (`boolean`): Flip vertically.
- `h` (`number`): H.
- `name` (`string`): Entry name.
- `rotated` (`boolean`): Whether the entry is rotated.
- `w` (`number`): W.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LSpriteSheet Type

- Lua-visible wrapper around a SpriteSheet, providing grid-based frame access,.

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

#### LSpriteSheetGetColumnResult Type

- Generated result shape from @field tags.

##### Fields

- `h` (`number`): H.
- `w` (`number`): W.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LSpriteSheetGetFrameResult Type

- Generated result shape from @field tags.

##### Fields

- `h` (`number`): H.
- `w` (`number`): W.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LSpriteSheetGetGroupFramesResult Type

- Generated result shape from @field tags.

##### Fields

- `h` (`number`): Height.
- `w` (`number`): Width.
- `x` (`number`): X position in atlas.
- `y` (`number`): Y position in atlas.

##### Methods

- No documented methods.

#### LSpriteSheetGetRowResult Type

- Generated result shape from @field tags.

##### Fields

- `h` (`number`): H.
- `w` (`number`): W.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems.`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
