//! Defines the color module boundary for channel types, conversion logic, palettes, and blending helpers. `color/mod` is the color module index, declaring `blend`, `color_core`, `palette` so agents can identify which files own each feature slice before opening implementation code.
//! Groups core color math and curated palette sources into one reusable runtime surface. `src/color/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `blend::{additive, alpha_blend, lerp_color, multiply, overlay, screen}`, `color_core::{gamma_to_linear, hsl_to_rgb, hsv_to_rgb, linear_to_gamma, Color}`, `palette::{css_named, retro, Palette}` centralized for the color subsystem.

/// Color blending and interpolation operations.
pub mod blend;
/// Core RGBA color type and color-space conversions.
pub mod color_core;
/// Predefined named color palettes.
pub mod palette;

pub use blend::{additive, alpha_blend, lerp_color, multiply, overlay, screen};
pub use color_core::{gamma_to_linear, hsl_to_rgb, hsv_to_rgb, linear_to_gamma, Color};
pub use palette::{css_named, retro, Palette};
