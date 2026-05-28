//! Screen-space overlay sub-system: ambient lighting, atmospheric effects, and scene transitions.

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
pub use atmosphere::{CloudState, FilmGrainState, FogState, HeatHazeState, LightningState, VignetteState};
pub use controller::Overlay;
pub use screen_effects::{FadeState, FlashState, ShakeState};
pub use transition::{ScreenTransition, TransitionKind};
pub use water::WaterOverlayState;
pub use weather::{WeatherParticle, WeatherState, WeatherType};
