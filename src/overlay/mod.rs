//! This module re-exports overlay surface for `ambient.rs`, `atmosphere.rs`, `controller.rs`, and helpers.
//! It keeps navigation explicit by showing which sibling files own state, validation, transport, or render behavior.
//! Public exports here route callers toward `ambient.rs`, `atmosphere.rs`, and `controller.rs` first, while deeper owners.
//! Open this file when the public overlay symbol map moves; edit siblings when runtime rules themselves change.
//! This index exists to organize entrypoints, not to absorb the state, caches, or algorithms its children own.
//! Use neighboring owners for behavioral fixes, and keep this file limited to exports, docs, and navigation.

/// Ambient color state derived from time-of-day settings.
pub mod ambient;
/// Atmospheric overlay states such as clouds, fog, and lightning.
pub mod atmosphere;
/// Screen overlay controller for weather, flashes, fades, and haze.
pub mod controller;
/// Screen-space flash, shake, and fade state types.
pub mod screen_effects;
/// Status-overlay stack state for HUD and fullscreen danger treatments.
pub mod status;
/// Full-screen transition effects and playback state.
pub mod transition;
/// Water distortion overlay state and update helpers.
pub mod water;
/// Weather particle types and simulation state.
pub mod weather;

pub use ambient::AmbientState;
pub use atmosphere::{
    CloudState, FilmGrainState, FogState, HeatHazeState, LightningState, VignetteState,
};
pub use controller::{
    Overlay, OverlayAccessibilityPolicy, OverlayDiagnostics, OverlayError, OverlayImageLimits,
    OverlayLimits, OverlayRenderLayer, OverlayRenderPlan, OverlayShaderPolicy, OverlayStats,
};
pub use screen_effects::{FadeState, FlashState, ShakeState};
pub use status::{
    normalize_status_intensity, StatusCompositeMode, StatusLayerTarget, StatusOverlayLayer,
    StatusOverlayStack, StatusVisualRecipe, STATUS_INTENSITY_MAX,
};
pub use transition::{ScreenTransition, TransitionKind};
pub use water::WaterOverlayState;
pub use weather::{
    WeatherParticle, WeatherProfile, WeatherState, WeatherType, WEATHER_RNG_VERSION,
};
