//! Defines the application module boundary for lifecycle orchestration from startup to shutdown. `app/mod` is the app module index, declaring `app`, `debug_overlay`, `error_screen`, `frame_profile`, `lua_callbacks`, and 1 more so agents can identify which files own each feature slice before opening implementation code.
//! Groups runtime loop control, visual fallback paths, callback guards, and profiling helpers. `src/app/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `app::{App, AppRunOptions}`, `debug_overlay::DebugOverlay`, `error_screen::ErrorScreen` centralized for the app subsystem.

#[allow(clippy::module_inception)]
/// Core application runtime: event loop bridge, frame lifecycle, and orchestration.
pub mod app;
/// Debug HUD overlay rendered on top of game output.
pub mod debug_overlay;
/// User-facing fatal error rendering and formatting helpers.
pub mod error_screen;
/// Frame profile formatting helpers.
pub mod frame_profile;
/// Lua callback invocation wrappers with optional instruction timeout guard.
pub mod lua_callbacks;
/// Splash branding asset loading and splash render-command generation.
pub mod splash_screen;
pub use app::{App, AppRunOptions};
pub use debug_overlay::DebugOverlay;
pub use error_screen::ErrorScreen;
