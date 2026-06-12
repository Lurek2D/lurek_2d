//! This module provides the engine's core 2D sprite asset and batching helpers around individual sprites, sheets, atlases, and scalable panels.
//! It covers both how textured regions are described and how many of them are organized for animation, UI, or efficient drawing.
//! At the highest level this is the feature layer that turns textures into reusable 2D presentation pieces.

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
