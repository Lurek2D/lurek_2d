//! Sprite handling for Lurek2D.
//!
//! Contains sprite, sprite batch, sprite sheet, and nine-slice types
//! extracted from the render module.

/// Individual sprite with position, scale, rotation, and color.
pub mod sprite;
/// Batched sprite renderer for efficient multi-sprite drawing.
pub mod sprite_batch;
/// Sprite sheet with named frame regions.
pub mod sprite_sheet;
/// Nine-slice scalable sprite for UI panels and borders.
pub mod nine_slice;

pub use nine_slice::NineSlice;
pub use sprite::Sprite;
pub use sprite_batch::SpriteBatch;
pub use sprite_sheet::SpriteSheet;
