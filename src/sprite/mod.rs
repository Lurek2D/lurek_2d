//! Exports the sprite surface for single sprites, sheets, atlases, nine-slice panels, texture packs, and batches.
//! Keeps navigation explicit by pointing readers to owners for clip playback, region lookup, scaling, and batching.
//! Re-exports `Sprite`, `SpriteSheet`, `SpriteAtlas`, `TextureAtlas`, `NineSlice`, and `SpriteBatch` symbols.
//! `animator.rs` owns timed playback, atlas files own regions, and `sprite_sheet.rs` owns grid frame lookup.
//! `sprite.rs` stays the per-instance draw state owner, while `sprite_batch.rs` holds grouped submission data.
//! Change this index when the public sprite symbol map moves, not when rendering or animation rules change.

/// Stateful clip animator used by the `lurek.sprite` API.
pub mod animator;
/// Texture atlas region map and TexturePacker JSON parser.
pub mod atlas;
/// Nine-slice panel geometry for scalable UI borders and boxes.
pub mod nine_slice;
/// Core Sprite type with transform, tint, and region data.
#[allow(clippy::module_inception)]
pub mod sprite;
/// SpriteBatch: deferred draw-call accumulation for grouped sprite rendering.
pub mod sprite_batch;
/// SpriteSheet: uniform grid frame extraction from a single texture.
pub mod sprite_sheet;
/// Texture atlas packing, named regions, and region-level nine-slice metadata.
pub mod texture_atlas;
pub use animator::{AnimatorEvent, SpriteAnimator, SpriteClip};
pub use atlas::{parse_texturepacker_json, AtlasEntry, SpriteAtlas};
pub use nine_slice::NineSlice;
pub use sprite::Sprite;
pub use sprite_batch::SpriteBatch;
pub use sprite_sheet::SpriteSheet;
pub use texture_atlas::{AtlasRegion, NineSliceInsets, TextureAtlas};
