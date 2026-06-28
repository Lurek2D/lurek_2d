//! This module re-exports the screen-overlay subsystem for ambient tint, weather, water, transitions, and controller state.
//! It is the navigation map for long-lived overlay data, timed screen effects, and renderer-facing overlay ownership.
//! `controller.rs` owns the main `Overlay` runtime, while `ambient.rs`, `weather.rs`, and `water.rs` hold state blocks.
//! `screen_effects.rs` and `transition.rs` cover timed flashes, shakes, fades, and full-screen transition playback models.
//! `atmosphere.rs` groups clouds, fog, haze, vignette, grain, and lightning so callers can compose atmospheric layers.
//! `status.rs` owns stacked player-state overlays such as frozen, poison, and danger feedback recipes.
//! Change this file when public overlay exports move; change sibling files when overlay simulation or render data changes.

/// Ambient color state derived from time-of-day settings.
pub mod ambient;
/// Atmospheric overlay states such as clouds, fog, and lightning.
pub mod atmosphere;
/// Screen overlay controller for weather, flashes, fades, and haze.
pub mod controller;
/// Status-overlay stack state for HUD and fullscreen danger treatments.
pub mod status;
/// Screen-space flash, shake, and fade state types.
pub mod screen_effects;
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
pub use status::{
    normalize_status_intensity, StatusCompositeMode, StatusLayerTarget, StatusOverlayLayer,
    StatusOverlayStack, StatusVisualRecipe, STATUS_INTENSITY_MAX,
};
pub use screen_effects::{FadeState, FlashState, ShakeState};
pub use transition::{ScreenTransition, TransitionKind};
pub use water::WaterOverlayState;
pub use weather::{
    WeatherParticle, WeatherProfile, WeatherState, WeatherType, WEATHER_RNG_VERSION,
};
