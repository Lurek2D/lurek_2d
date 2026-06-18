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

- The `sprite` module is the engine's textured-2D surface for users who want single sprites, sheets, atlases, scalable panels, and batched instances to share one coherent runtime model.
- It unifies several common 2D visual patterns that often become fragmented in smaller engines: stand-alone images, atlas regions, sheet-based animation helpers, batched draws, and resizable textured panels all belong to the same family here.
- Atlas support matters because production assets are frequently packed, and a sprite system that does not understand regions and packing semantics quickly forces users into repetitive coordinate plumbing.
- Sheet-oriented helpers broaden the feature into frame-driven presentation while still staying lighter-weight than the more general `animation` module.
- Nine-slice and panel-oriented support matter because many projects mix game objects with UI-like scalable textured elements and still want one shared textured-visual layer.
- Batching support gives the module practical performance value. When many sprites share material or texture context, the engine can treat them as a coordinated draw family rather than as unrelated one-off submissions.
- `image` owns raw pixel assets and `render` performs final drawing, while `sprite` owns the runtime model for textured 2D instances, atlases, sheets, and related presentation helpers.
- Read `sprite` as the common textured-2D layer above raw images and below higher-level gameplay or UI meaning.


## Imports

- `animation`: Imports or references `src/animation/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems.`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### animator.rs

- This file owns `SpriteClip`, `AnimatorEvent`, and `SpriteAnimator` for named clip playback over sheet frames.
- It stores clip definitions, selected clip state, current frame, elapsed time, and the playing flag in one owner.
- Normalization rules clamp invalid clip ranges and fps so Lua or tool input cannot produce broken playback state.
- The `update` loop emits frame, loop, and end events while advancing elapsed time in frame-sized playback steps.
- Playback helpers add clips, switch current clips, pause, resume, stop, and report active frame or durations.
- Open this file when clip-timing semantics change; sheet geometry and render submission belong to siblings.

### atlas.rs

- This file owns `AtlasEntry` and `SpriteAtlas`, the named-region model for packed sprite texture content.
- It stores ordered entries, a name-to-index lookup map, and rotation or flip metadata needed to decode atlas output.
- Parser functions turn TexturePacker and Aseprite JSON payloads into atlas records, so import policy lives here.
- Lookup helpers support name access, index access, name listing, and atlas construction from engine texture regions.
- Open this file when packed-region semantics or atlas import rules change, not single-sprite transform behavior.

### mod.rs

- This module gathers the sprite subsystem surface for single sprites, sheets, atlases, panels, and batches.
- It keeps navigation explicit by pointing readers to the file that owns clip playback, lookup, scaling, or batching.
- Re-exports here make `Sprite`, `SpriteSheet`, `SpriteAtlas`, `NineSlice`, and `SpriteBatch` easy to reach.
- `animator.rs` owns frame-timed clip playback, while `atlas.rs` and `sprite_sheet.rs` own region lookup models.
- `sprite.rs` stays the minimal per-instance draw state owner, and `sprite_batch.rs` holds grouped submission data.
- Change this file when the public sprite symbol map moves, not when rendering or animation rules change.

### nine_slice.rs

- This file owns `NineSlice` and `Patch` tuples for scalable panels whose borders must survive resizing cleanly.
- It stores the texture key, edge inset sizes, and source texture dimensions used to split nine source regions.
- The `patches` method returns source and destination quads so callers can stretch edges and center without corner drift.
- Open this file when panel-scaling geometry changes; atlas lookup, sprite state, and batching live in siblings.

### sprite.rs

- This file owns `Sprite`, the minimal textured instance record for transform, tint, and optional normal-map state.
- It stores render-facing fields directly on one struct so systems can pass lightweight draw data without atlas owners.
- Setters here mutate position, scale, rotation, color, and normal-map properties while math helpers stay delegated.
- Open this file when per-sprite draw state changes; animation playback and grouped submission live elsewhere.

### sprite_batch.rs

- This file owns `SpriteBatch` and `BatchEntry`, the single-texture accumulation layer for grouped sprite draws.
- It stores the batch texture binding, per-entry source quads, transforms, pivots, and an optional capacity limit.
- Helpers add entries, expose the borrowed entry slice, and clear retained frame data without rebuilding allocations.
- Open this file when grouped submission shape changes; sprite state, atlas parsing, and animation live in siblings.

### sprite_sheet.rs

- This file owns `SpriteSheet`, `FrameGroup`, and `ColumnFrames` for frame extraction from grids or atlas frames.
- It stores frame dimensions, grid counts, precomputed rects, named groups, and optional directional layout data.
- Helpers expose rows, columns, ranges, named groups, and direction-specific frames without recomputing rectangles.
- The `draw_to_image` path renders a debug view of the frame grid so authors can inspect layout and group starts.
- Constructors cover uniform sheets, RPGMaker-style direction sheets, and atlas-backed sheets mapped into groups.
- Open this file when frame indexing or grouping semantics change; playback and per-instance state live elsewhere.



## Lua API Ref

### Functions

- `lurek.sprite.newAnimator(clips?) -> LSpriteAnimator`: Creates a stateful sprite clip animator from an optional clip definition table.
- `lurek.sprite.newAtlasPacker(width, height, padding) -> LAtlasPacker`: Creates a runtime atlas packer for dynamically allocating named sprite regions.
- `lurek.sprite.newAtlasSheet(atlas, sw, sh) -> LSpriteSheet`: Creates a sprite sheet from an existing atlas, treating each atlas entry as a frame within the given sheet dimensions.
- `lurek.sprite.newRPGMakerSheet(tw, th) -> LSpriteSheet`: Creates a sprite sheet using RPG Maker's standard character layout (4 columns Ă— 4 rows per character block).
- `lurek.sprite.newSheet(tw, th, fw, fh) -> LSpriteSheet`: Creates a new sprite sheet by dividing a texture of the given pixel size into a grid of equal-sized frames.
- `lurek.sprite.newSprite(texture_id, x, y) -> LSprite`: Creates a lightweight sprite record with transform and optional normal-map metadata.
- `lurek.sprite.parseAsepriteAtlas(json_str) -> LSpriteAtlas`: Parses an Aseprite JSON atlas string and returns a sprite atlas object.
- `lurek.sprite.parseAtlas(json_str) -> LSpriteAtlas`: Parses a TexturePacker JSON atlas string and returns a sprite atlas object.

### Callbacks

- `LSpriteAnimator:onEnd` param `fn` (`function`): Callback signature `(clip_name)`.
- `LSpriteAnimator:onFrame` param `fn` (`function`): Callback signature `(row, col, clip_name)`.
- `LSpriteAnimator:onLoop` param `fn` (`function`): Callback signature `(clip_name)`.

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
- `LSpriteAnimator:play(name, restart?) -> nil`: Plays or restarts a named animation clip.
- `LSpriteAnimator:resume() -> nil`: Resume playback from current frame when a clip is selected.
- `LSpriteAnimator:stop() -> nil`: Stop playback and reset to the first frame of the current clip.
- `LSpriteAnimator:type() -> string`: Returns the type name of this object.
- `LSpriteAnimator:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LSpriteAnimator:update(dt) -> nil`: Advance playback by delta time and dispatch callback events.

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

## References

- `animation`: Imports or references `src/animation/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems.`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
