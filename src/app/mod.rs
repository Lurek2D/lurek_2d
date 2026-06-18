//! This module re-exports the desktop app subsystem for runtime orchestration, splash, errors, callbacks, and HUD state.
//! It is the navigation map for host-loop ownership, startup surfaces, callback guards, and frame-profile helpers.
//! `app.rs` owns the main runtime loop, while `splash_screen.rs` and `error_screen.rs` cover startup and failure surfaces.
//! `lua_callbacks.rs` holds guarded `lurek.*` invocation helpers, and `debug_overlay.rs` renders the diagnostics HUD.
//! `frame_profile.rs` formats per-frame timing samples for logs, traces, and other small diagnostics surfaces.
//! Change this file when public app exports move; change sibling files when runtime behavior or startup flows change.

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
