//! `src/color/mod.rs` is the module index that exposes core color math, blending helpers, and curated palettes.
//! It reexports `Color`, conversion functions, blend operators, and palette accessors through one stable color surface.
//! No color instances or palette storage live here; this file only declares child modules and defines public visibility.
//! Read this index when wiring rendering or styling code, because it shows where color math ends and palette data begins.
//! Changes here reshape the color boundary, since reexports decide which helpers other systems import without deep paths.
//! This module keeps channel math, conversion logic, and preset palette data separated for clearer ownership and reuse.

/// Color blending and interpolation operations.
pub mod blend;
/// Core RGBA color type and color-space conversions.
pub mod color_core;
/// Predefined named color palettes.
pub mod palette;

pub use blend::{additive, alpha_blend, lerp_color, multiply, overlay, screen};
pub use color_core::{gamma_to_linear, hsl_to_rgb, hsv_to_rgb, linear_to_gamma, Color};
pub use palette::{css_named, retro, Palette};
