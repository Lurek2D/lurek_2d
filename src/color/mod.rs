//! Defines the color module boundary for channel types, conversion logic, palettes, and blending helpers.
//! Groups core color math and curated palette sources into one reusable runtime surface.
//! Serves as the composition entry for engine-side and Lua-side color workflows.

/// Core RGBA color type and color-space conversions.
pub mod color_core;
/// Predefined named color palettes.
pub mod palette;
/// Color blending and interpolation operations.
pub mod blend;

pub use color_core::{Color, gamma_to_linear, linear_to_gamma, hsl_to_rgb, hsv_to_rgb};
pub use palette::{Palette, css_named, retro};
pub use blend::{lerp_color, multiply, screen, overlay, additive, alpha_blend};
