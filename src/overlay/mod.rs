//! Screen-space overlay subsystem for ambient lighting, atmosphere, and scene transitions. `overlay/mod` is the overlay module index, declaring `ambient`, `atmosphere`, `controller`, `screen_effects`, `transition`, and 2 more so agents can identify which files own each feature slice before opening implementation code.
//! Groups the state and render paths for weather, water, flash, fog, and fade effects. `src/overlay/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `ambient::AmbientState`, `atmosphere::{ CloudState, FilmGrainState, FogState, HeatHazeState, LightningState, VignetteState, }`, `controller::Overlay`, `screen_effects::{FadeState, FlashState, ShakeState}`, and 3 more centralized for the overlay subsystem.

/// Ambient color state derived from time-of-day settings.
pub mod ambient;
/// Atmospheric overlay states such as clouds, fog, and lightning.
pub mod atmosphere;
/// Screen overlay controller for weather, flashes, fades, and haze.
pub mod controller;
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
pub use controller::Overlay;
pub use screen_effects::{FadeState, FlashState, ShakeState};
pub use transition::{ScreenTransition, TransitionKind};
pub use water::WaterOverlayState;
pub use weather::{WeatherParticle, WeatherState, WeatherType};
