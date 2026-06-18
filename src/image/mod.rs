//! Exports the image subsystem surface that groups buffers, effects, formats, atlases, layers, and visuals.
//! Acts as the navigation index for CPU image ownership, showing where loading, edits, packing, and specs live.
//! Re-exports ImageData, compressed assets, palette LUTs, layered images, GIF helpers, and atlas structures.
//! Keeps compatibility exports such as ProvinceGrid local to the module boundary instead of scattered in users.
//! Open this file first when tracing which image feature belongs to storage, processing, serialization, or UI.
//! This owner defines image-module visibility and composition, not the pixel algorithms implemented below it.

/// Core RGBA image storage and drawing helpers.
pub mod image_data;
/// Core RGBA image buffer type.
pub use image_data::ImageData;
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
/// Texture atlas packing and nine-slice metadata.
pub mod texture_atlas;
/// Image visualizations for debugging and analysis.
pub mod visualization;
/// Backward-compat re-export: province_grid moved to `crate::province::province_grid`.
pub use crate::province::province_grid::{AdjacencyPair, ProvinceGrid, ProvinceShapeCacheEntry};
/// Animated GIF export types.
pub use animated_gif::{AnimatedGifOptions, AnimatedGifRepeat};
/// Rectangle packing types.
pub use rect_packing::{PackedRect, RectPacker};
/// Texture upload helpers and texture metadata types.
pub use texture::{premultiply_alpha_rgba8_in_place, Texture, TextureColorSpace};
/// Texture atlas types and nine-slice metadata.
pub use texture_atlas::{NineSliceInsets, TextureAtlas};
