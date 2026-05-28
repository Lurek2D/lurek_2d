//! RGBA color types, palettes, blending, and color-space conversions.
//!
//! - Linear RGBA float color with named constants and brand palette.
//! - Color-space transforms: RGB↔HSL, HSV→RGB, sRGB gamma↔linear.
//! - Predefined palettes: CSS named colors, retro consoles, game-dev common.
//! - Blending modes: lerp, multiply, screen, overlay, additive.

/// Core RGBA color type and color-space conversions.
pub mod color_core;
/// Predefined named color palettes.
pub mod palette;
/// Color blending and interpolation operations.
pub mod blend;

pub use color_core::{Color, gamma_to_linear, linear_to_gamma, hsl_to_rgb, hsv_to_rgb};
pub use palette::{Palette, css_named, retro};
pub use blend::{lerp_color, multiply, screen, overlay, additive, alpha_blend};
