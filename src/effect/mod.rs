//! This module re-exports the post-effect subsystem surface for effect instances, stacks, presets, render, and draws.
//! It is the navigation map for effect ownership, command generation, named presets, and stack-level debug tooling.
//! `effect.rs` owns one runtime effect instance, while `stack.rs` manages ordering, enable flags, and target dimensions.
//! `effect_type.rs` defines built-in identities and default parameters, and `image_effect.rs` groups shared pass chains.
//! `render.rs`, `draw.rs`, and `presets.rs` cover renderer commands, debug previews, and ready-made visual recipes.
//! It also forwards legacy overlay exports, so change this file when public effect symbols or compatibility edges move.

/// Shared post-fx validation contract and diagnostics.
pub mod contract;
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

pub use contract::{
    PostFxDebugImageLimits, PostFxDiagnostic, PostFxDiagnosticSeverity, PostFxDiagnostics,
    PostFxDuplicatePolicy, PostFxError, PostFxLimits, PostFxParamKind, PostFxParamSchema,
    POSTFX_AUTO_UNIFORMS,
};
pub use effect::PostFxEffect;
pub use effect_type::PostFxEffectType;
pub use image_effect::ImageEffect;
pub use presets::{build_preset, preset_names, EffectPreset};
pub use render::{PostFxCommandPlan, PostFxPassPlan};
pub use stack::PostFxStack;

// Backward-compat re-exports from the overlay module.
pub use crate::overlay::{
    AmbientState, CloudState, FadeState, FilmGrainState, FlashState, FogState, HeatHazeState,
    LightningState, Overlay, ScreenTransition, ShakeState, TransitionKind, VignetteState,
    WaterOverlayState, WeatherParticle, WeatherState, WeatherType,
};
