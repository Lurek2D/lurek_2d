# sprite

## TL;DR

- Manages 2D sprites, JSON atlases, animation sheets, nine-slice panels, and lit-sprite normal-map state.
- Supports sprite batching.

## General Info

- Module group: `Feature Systems`
- Source path: `src/sprite/`
- Binding: `src/lua_api/sprite_api.rs`
- Namespace: `lurek.sprite`
- Lua API surface: `8` functions, `13` types, `53` methods
- Rust test path(s): tests/rust/unit/sprite_tests.rs
- Lua test path(s): tests/lua/unit/test_sprite_core_unit.lua

## Summary

This module turns raw textures into reusable sprites, sheets, and UI panels. It supports named texture atlases parsed from TexturePacker and Aseprite JSON data, mapping semantic names to specific regions while handling rotation and flip flags. This allows scripts to query packed sprites by name instead of raw coordinates.

Atlas parsing now shares the engine's common Aseprite loader with the animation module. This keeps frame-shape validation and malformed-export error behavior aligned across sprite-atlas import and Aseprite animation ingest, instead of maintaining separate parsers for the same source format.

For animations and interfaces, the system offers grid sheets and scalable panels. The sprite-sheet engine divides textures into grids, precomputing frame UVs for fast index lookup and character animations. A nine-slice engine splits frames into corners and edges, letting panels stretch to any size while keeping border dimensions crisp and distortion-free.

Row and column extraction on `SpriteSheet` are implemented with allocation-light internal paths (row slices and column iterators), while Lua still receives the same table-shaped frame arrays via `LSpriteSheet:getRow` and `LSpriteSheet:getColumn`.

To optimize drawing, the module provides lightweight sprite records and instanced batching. Sprite batches group quads sharing a single texture into one draw command, bypassing call overhead. Developers can configure batch capacities to keep render loops efficient.

Individual sprites can also carry optional normal-map texture state and a strength scalar for lit-sprite workflows. This extends the sprite data model without changing atlas, sheet, or batch APIs for unlit content.

The Lua API also provides a runtime atlas packer for dynamic content. `lurek.sprite.newAtlasPacker(width, height, padding)` builds an in-memory allocator that can pack named regions, query packed rectangles, and attach optional nine-slice insets for UI scaling workflows.

Clip playback is now available as a Rust-backed animator userdata. `lurek.sprite.newAnimator(clips)` creates `LSpriteAnimator`, which handles named clip playback (`play`, `pause`, `resume`, `stop`), frame stepping (`update`, `currentFrame`), clip editing (`addClip`), timing helpers, and loop/end/frame callbacks.

## Imports

- `animation`: Imports or references `src/animation/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems.`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

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
- Optional normal-map metadata lives here as sprite-owned lighting data even when the renderer path is handled elsewhere.
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

### Functions

- `lurek.sprite.newAtlasPacker(width, height, padding) -> LAtlasPacker`: Creates a runtime atlas packer for dynamically allocating named sprite regions.
- `lurek.sprite.newAtlasSheet(atlas, sw, sh) -> LSpriteSheet`: Creates a sprite sheet from an existing atlas, treating each atlas entry as a frame within the given sheet dimensions.
- `lurek.sprite.newAnimator(clips?) -> LSpriteAnimator`: Creates a stateful clip animator from an optional clip-definition map.
- `lurek.sprite.newRPGMakerSheet(tw, th) -> LSpriteSheet`: Creates a sprite sheet using RPG Maker's standard character layout (4 columns Ă— 4 rows per character block).
- `lurek.sprite.newSheet(tw, th, fw, fh) -> LSpriteSheet`: Creates a new sprite sheet by dividing a texture of the given pixel size into a grid of equal-sized frames.
- `lurek.sprite.newSprite(texture_id, x, y) -> LSprite`: Creates a lightweight sprite record with transform and optional normal-map metadata.
- `lurek.sprite.parseAsepriteAtlas(json_str) -> LSpriteAtlas`: Parses an Aseprite JSON atlas string and returns a sprite atlas object.
- `lurek.sprite.parseAtlas(json_str) -> LSpriteAtlas`: Parses a TexturePacker JSON atlas string and returns a sprite atlas object.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAtlasPacker Type

- Lua-visible wrapper around an in-memory atlas packer for dynamic sprite region allocation.

##### Fields

- No documented fields.

##### Methods

- `LAtlasPacker:clear() -> nil`: Removes all packed regions and resets packing shelves.
- `LAtlasPacker:getDimensions() -> integer`: Returns the current width and height of this atlas packer.
- `LAtlasPacker:getRegion(name) -> table`: Returns the named packed atlas region, or nil if not found.
- `LAtlasPacker:pack(name, w, h) -> boolean`: Packs a named region into this atlas and returns whether allocation succeeded.
- `LAtlasPacker:regionCount() -> integer`: Returns the number of currently packed regions.
- `LAtlasPacker:setNineSlice(name, left, right, top, bottom) -> boolean`: Sets nine-slice insets for a previously packed region.
- `LAtlasPacker:type() -> string`: Returns the type name of this object.
- `LAtlasPacker:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LAtlasPackerGetRegionResult Type

- Generated result shape from @field tags.

##### Fields

- `h` (`integer`): Region height in pixels.
- `name` (`string`): Region key.
- `nine_slice` (`table?`): Optional nine-slice inset table `{left, right, top, bottom}`.
- `w` (`integer`): Region width in pixels.
- `x` (`integer`): Left coordinate in atlas pixels.
- `y` (`integer`): Top coordinate in atlas pixels.

##### Methods

- No documented methods.

#### LSpriteAnimator Type

- Lua-visible wrapper around Rust-side clip animation playback state.

##### Fields

- No documented fields.

##### Methods

- `LSpriteAnimator:addClip(name, def) -> nil`: Add or replace a named clip definition.
- `LSpriteAnimator:clipDuration() -> number`: Return full one-pass duration for the current clip.
- `LSpriteAnimator:currentClip() -> string`: Return the currently selected clip name.
- `LSpriteAnimator:currentFrame() -> integer`: Return current draw frame as sprite-sheet row and column.
- `LSpriteAnimator:frameDuration() -> number`: Return frame duration for the current clip.
- `LSpriteAnimator:isPlaying() -> boolean`: Return whether the animator is currently playing.
- `LSpriteAnimator:onEnd(fn) -> nil`: Set callback fired when a non-looping clip reaches its end.
- `LSpriteAnimator:onFrame(fn) -> nil`: Set callback fired on each frame advance.
- `LSpriteAnimator:onLoop(fn) -> nil`: Set callback fired when a looping clip wraps.
- `LSpriteAnimator:pause() -> nil`: Pause playback without resetting frame state.
- `LSpriteAnimator:play(name, restart?) -> nil`: Play or restart a named clip.
- `LSpriteAnimator:resume() -> nil`: Resume playback from current frame when a clip is selected.
- `LSpriteAnimator:stop() -> nil`: Stop playback and reset to the first frame of the current clip.
- `LSpriteAnimator:type() -> string`: Returns the type name of this object.
- `LSpriteAnimator:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LSpriteAnimator:update(dt) -> nil`: Advance playback by delta time and dispatch callback events.

#### LSprite Type

- Lua-visible single sprite data container, including optional normal-map metadata for lit sprites.

##### Fields

- No documented fields.

##### Methods

- `LSprite:clearNormalMap() -> nil`: Removes the assigned normal map from this sprite.
- `LSprite:getNormalIntensity() -> number`: Returns the normal-map intensity multiplier.
- `LSprite:getNormalMap() -> integer`: Returns the assigned normal-map texture handle, or nil when absent.
- `LSprite:getPosition() -> number`: Returns the sprite anchor position in pixels.
- `LSprite:hasNormalMap() -> boolean`: Returns whether the sprite currently has a normal map.
- `LSprite:setNormalIntensity(intensity) -> nil`: Sets the normal-map intensity used by lit sprite workflows.
- `LSprite:setNormalMap(texture_id) -> nil`: Assigns the texture used as this sprite's normal map for lit sprite workflows.
- `LSprite:setPosition(x, y) -> nil`: Sets the sprite anchor position in pixels.
- `LSprite:type() -> string`: Returns the type name of this object.
- `LSprite:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LSpriteAtlas Type

- Lua-visible wrapper around a SpriteAtlas, providing named region lookups.

##### Fields

- No documented fields.

##### Methods

- `LSpriteAtlas:entryCount() -> integer`: Returns the total number of entries (sprite regions) in the atlas.
- `LSpriteAtlas:entryNames() -> string[]`: Returns an array of all entry names in the atlas.
- `LSpriteAtlas:getByIndex(index) -> table`: Returns a sprite region by its 1-based index in the atlas.
- `LSpriteAtlas:getEntry(name) -> table`: Looks up a named sprite region in the atlas by its original filename or tag.
- `LSpriteAtlas:getFlipped(name, flip_x, flip_y) -> table`: Returns a copy of a named atlas entry with the specified flip flags applied.
- `LSpriteAtlas:type() -> string`: Returns the type name of this object.
- `LSpriteAtlas:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

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

- `LSpriteSheet:drawToImage(w, h) -> LImage`: Renders the sprite sheet grid into an LImage of the given size for debugging or previews.
- `LSpriteSheet:getColumn(col) -> table`: Returns all frame quads in the given column of the sprite sheet grid.
- `LSpriteSheet:getFrame(index) -> table`: Returns the UV quad for a single frame by its 1-based index.
- `LSpriteSheet:getFrameCount() -> integer`: Returns the total number of frames in this sprite sheet.
- `LSpriteSheet:getFrameSize() -> integer`: Returns the pixel dimensions of a single frame cell.
- `LSpriteSheet:getGridSize() -> integer`: Returns the number of columns and rows in the sprite sheet grid.
- `LSpriteSheet:getGroupFrames(name) -> table`: Returns the frame quads for a named animation group.
- `LSpriteSheet:getGroupNames() -> string[]`: Returns an array of all named animation group names defined on this sheet.
- `LSpriteSheet:getRow(row) -> table`: Returns all frame quads in the given row of the sprite sheet grid.
- `LSpriteSheet:nameGroup(name, start, count) -> nil`: Defines a named animation group as a contiguous range of frames.
- `LSpriteSheet:type() -> string`: Returns the type name of this object.
- `LSpriteSheet:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

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
