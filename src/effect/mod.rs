//! Visual effect sub-system: particle effects, screen-space post-processing, and shakes.
//!
//! - Orchestrates `particle`, `tween`, `dsp` integrations for composite effects.
//! - All effects are data-driven: configured from Lua tables, not hard-coded structs.
//! - Effects are lifetime-managed; expired effects are removed at the start of each tick.
//! - No GPU work is performed here — effect data is converted to `RenderCommand`s.

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
