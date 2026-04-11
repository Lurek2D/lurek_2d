# sprite

## General Info

- Module group: `Feature Systems.`
- Source path: `src/sprite/`
- Lua API path(s): None direct
- Primary Lua namespace: None direct
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

The sprite module owns the engine's sprite-domain data types without taking ownership of the GPU backend. It exists so gameplay, UI, animation, and render-facing code can share a stable set of structs for single sprites, sprite batches, sprite sheets, and scalable nine-slice panels.

Its boundary is deliberately CPU-side: these types hold transforms, atlas regions, batch entries, and patch geometry, but they do not issue draw calls themselves. Rendering, texture loading, and shader execution stay in other modules, while `src/sprite/` remains the place to change sprite layout rules and batching data contracts.

**Scope boundary**: This module currently depends on `math`, `runtime`. It stays within the Feature Systems responsibility boundary defined in the architecture docs.

## Files

- `mod.rs`: Module root and re-export surface for the public sprite-related types.
- `nine_slice.rs`: Nine-slice descriptor and patch computation for scalable UI panels and borders.
- `sprite.rs`: Single sprite data with transform and tint information around a texture identifier.
- `sprite_batch.rs`: Batch container for many sprite entries that share one texture key.
- `sprite_sheet.rs`: Grid-based sprite sheet, named frame groups, and optional directional layout helpers.

## Types

- `Patch` (`type`, `nine_slice.rs`): One computed source/destination rectangle tuple produced by a nine-slice layout.
- `NineSlice` (`struct`, `nine_slice.rs`): Scalable panel descriptor built from one texture plus four insets.
- `Sprite` (`struct`, `sprite.rs`): Smallest textured sprite unit with position, scale, rotation, and tint.
- `SpriteBatch` (`struct`, `sprite_batch.rs`): Shared-texture batch container used to prepare many sprite draws efficiently.
- `BatchEntry` (`struct`, `sprite_batch.rs`): One packed sprite instance inside a batch, including source quad and transform fields.
- `FrameGroup` (`struct`, `sprite_sheet.rs`): Named frame-range descriptor inside a sprite sheet.
- `DirectionLayout` (`enum`, `sprite_sheet.rs`): Enum describing whether directional frames are arranged by rows or columns.
- `SpriteSheet` (`struct`, `sprite_sheet.rs`): Atlas helper that maps grid frames and named groups to reusable regions.

## Functions

- `NineSlice::new` (`nine_slice.rs`): Creates a new nine-slice definition.
- `NineSlice::patches` (`nine_slice.rs`): Returns the 9 source and destination rectangles for rendering.
- `Sprite::new` (`sprite.rs`): Creates a new `Sprite` at `position` using the texture identified by `texture_id`.
- `Sprite::set_position` (`sprite.rs`): Sets the world-space position of the sprite.
- `Sprite::set_scale` (`sprite.rs`): Sets the per-axis scale of the sprite.
- `Sprite::set_rotation` (`sprite.rs`): Sets the rotation of the sprite in radians.
- `Sprite::set_color` (`sprite.rs`): Sets the multiplicative tint color applied to the sprite.
- `SpriteBatch::new` (`sprite_batch.rs`): Creates a new empty sprite batch for the given texture.
- `SpriteBatch::add` (`sprite_batch.rs`): Adds a sprite entry to the batch.
- `SpriteBatch::clear` (`sprite_batch.rs`): Removes all entries from the batch.
- `SpriteBatch::texture_key` (`sprite_batch.rs`): Returns the texture key this batch draws from.
- `SpriteBatch::entries` (`sprite_batch.rs`): Returns a slice of all batch entries.
- `SpriteBatch::len` (`sprite_batch.rs`): Returns the number of entries in the batch.
- `SpriteBatch::is_empty` (`sprite_batch.rs`): Returns true if the batch has no entries.
- `SpriteBatch::buffer_size` (`sprite_batch.rs`): Returns the maximum number of entries (buffer size).
- `SpriteSheet::new` (`sprite_sheet.rs`): Create a new sprite sheet by dividing a texture into a uniform grid.
- `SpriteSheet::get_frame` (`sprite_sheet.rs`): Return the quad for a 0-based frame index.
- `SpriteSheet::get_frame_count` (`sprite_sheet.rs`): Total number of frames in the sheet.
- `SpriteSheet::get_frame_size` (`sprite_sheet.rs`): Dimensions of a single frame `(width, height)`.
- `SpriteSheet::get_grid_size` (`sprite_sheet.rs`): Grid dimensions `(columns, rows)`.
- `SpriteSheet::get_row` (`sprite_sheet.rs`): Return all frame quads in a 0-based row.
- `SpriteSheet::get_column` (`sprite_sheet.rs`): Return all frame quads in a 0-based column.
- `SpriteSheet::get_range` (`sprite_sheet.rs`): Return a contiguous range of frame quads starting at `start` (0-based).
- `SpriteSheet::name_group` (`sprite_sheet.rs`): Store a named frame group.
- `SpriteSheet::get_group` (`sprite_sheet.rs`): Return the frame quads for a named group.
- `SpriteSheet::get_group_names` (`sprite_sheet.rs`): Return the names of all defined groups.
- `SpriteSheet::set_directions` (`sprite_sheet.rs`): Set the directional mode (4 or 8 directions) and layout.
- `SpriteSheet::get_direction_frames` (`sprite_sheet.rs`): Return the frame quads for a 0-based direction index.

## Lua API Reference

- No dedicated direct `lurek.*` namespace is exposed by this module.

## References

- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/sprite/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- This module has no dedicated direct `lurek.*` namespace and is usually consumed through higher integration layers.
