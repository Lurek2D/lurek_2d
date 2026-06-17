//! Provides the high-level visual effects module boundary for post-processing composition and runtime control. `effect/mod` is the effect module index, declaring `draw`, `effect`, `effect_type`, `image_effect`, `presets`, and 2 more so agents can identify which files own each feature slice before opening implementation code.
//! Connects effect instances, stacks, presets, and renderer integration into one coherent pipeline surface. `src/effect/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `effect::PostFxEffect`, `effect_type::PostFxEffectType`, `image_effect::ImageEffect`, `presets::{build_preset, preset_names, EffectPreset}`, and 2 more centralized for the effect subsystem.
//! Delivers a data-driven effect orchestration layer that scripts and systems can configure predictably. The file documents how effect submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! `effect/mod` is the effect module index, declaring `draw`, `effect`, `effect_type`, `image_effect`, `presets`, and 2 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/effect/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `effect::PostFxEffect`, `effect_type::PostFxEffectType`, `image_effect::ImageEffect`, `presets::{build_preset, preset_names, EffectPreset}`, and 2 more centralized for the effect subsystem.
//! The file documents how effect submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

/// Debug image rendering for post-effect stacks.
pub mod draw;
#[allow(clippy::module_inception)]
/// Post-effect instance state and parameter accessors.
pub mod effect;
/// Built-in post-effect type identifiers and default parameter maps.
pub mod effect_type;
/// Image-scoped collections of post effects.
pub mod image_effect;
/// Named post-effect preset builders.
pub mod presets;
/// Render-command generation for post-effect capture and apply passes.
pub mod render;
/// Ordered post-effect stack management utilities.
pub mod stack;

pub use effect::PostFxEffect;
pub use effect_type::PostFxEffectType;
pub use image_effect::ImageEffect;
pub use presets::{build_preset, preset_names, EffectPreset};
pub use stack::PostFxStack;

// Backward-compat re-exports from the overlay module.
pub use crate::overlay::{
    AmbientState, CloudState, FadeState, FilmGrainState, FlashState, FogState, HeatHazeState,
    LightningState, Overlay, ScreenTransition, ShakeState, TransitionKind, VignetteState,
    WaterOverlayState, WeatherParticle, WeatherState, WeatherType,
};
