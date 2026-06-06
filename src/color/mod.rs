//! Defines the color module boundary for channel types, conversion logic, palettes, and blending helpers.
//! Groups core color math and curated palette sources into one reusable runtime surface.
//! Serves as the composition entry for engine-side and Lua-side color workflows.

/// Color blending and interpolation operations.
pub mod blend;
/// Core RGBA color type and color-space conversions.
pub mod color_core;
/// Predefined named color palettes.
pub mod palette;

pub use blend::{additive, alpha_blend, lerp_color, multiply, overlay, screen};
pub use color_core::{gamma_to_linear, hsl_to_rgb, hsv_to_rgb, linear_to_gamma, Color};
pub use palette::{css_named, retro, Palette};
