//! Exports the image subsystem surface for CPU bitmaps, effects, formats, layers, palettes, and visual helpers.
//! Acts as the navigation index for single-bitmap ownership, showing where loading, editing, and specs live.
//! Re-exports `ImageData`, compressed assets, palette LUTs, layered images, GIF helpers, and compatibility types.
//! Keeps atlas, nine-slice, and sprite-sheet concepts outside image so sprite remains the texture-region owner.
//! Open this file when tracing which image feature belongs to storage, processing, serialization, or UI support.
//! This index owns image visibility and composition, not the pixel algorithms implemented in child modules.

/// Core RGBA image storage and drawing helpers.
pub mod image_data;
/// Shared CPU image resource ceilings.
pub mod limits;
/// Core RGBA image buffer type.
pub use image_data::ImageData;
/// Image resource limit configuration.
pub use limits::ImageLimits;
/// Compressed image file decoding helpers.
pub mod compressed;
/// Image-space effects and resampling filters.
pub mod effects;
/// Supported compressed image formats and decoded data.
pub use compressed::{CompressedFormat, CompressedImageData};
/// Palette lookup tables and color remapping helpers.
pub mod palette_lut;
/// Palette lookup table type.
pub use palette_lut::PaletteLUT;
/// Layered image storage and compositing.
pub mod layers;
/// Single image layer and layered image types.
pub use layers::{ImageLayer, LayeredImage};
/// Animated GIF encoding helpers.
pub mod animated_gif;
/// Online rectangle bin-packing algorithm for texture atlases.
pub mod rect_packing;
/// Image-to-render-command bridge helpers.
pub mod render;
/// Custom image serialization helpers.
pub mod serial;
/// Texture loading and CPU-side texture metadata.
pub mod texture;
/// Animated GIF export types.
pub use animated_gif::{AnimatedGifFrame, AnimatedGifOptions, AnimatedGifRepeat};
/// Rectangle packing types.
pub use rect_packing::{PackedRect, RectPacker};
/// Texture upload helpers and texture metadata types.
pub use texture::{premultiply_alpha_rgba8_in_place, Texture, TextureColorSpace};
