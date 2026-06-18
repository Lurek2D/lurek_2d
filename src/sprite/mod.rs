//! This module gathers the sprite subsystem surface for single sprites, sheets, atlases, panels, and batches.
//! It keeps navigation explicit by pointing readers to the file that owns clip playback, lookup, scaling, or batching.
//! Re-exports here make `Sprite`, `SpriteSheet`, `SpriteAtlas`, `NineSlice`, and `SpriteBatch` easy to reach.
//! `animator.rs` owns frame-timed clip playback, while `atlas.rs` and `sprite_sheet.rs` own region lookup models.
//! `sprite.rs` stays the minimal per-instance draw state owner, and `sprite_batch.rs` holds grouped submission data.
//! Change this file when the public sprite symbol map moves, not when rendering or animation rules change.

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
pub use animator::{AnimatorEvent, SpriteAnimator, SpriteClip};
pub use atlas::{parse_texturepacker_json, AtlasEntry, SpriteAtlas};
pub use nine_slice::NineSlice;
pub use sprite::Sprite;
pub use sprite_batch::SpriteBatch;
pub use sprite_sheet::SpriteSheet;
