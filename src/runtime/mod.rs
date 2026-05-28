//! Engine runtime foundations: configuration, shared state, and error types.
//!
//! - Sub-modules: `config`, `error`, `headless`, `log_messages`, and 5 more.

/// Runtime configuration model loaded from `conf.toml`.
pub mod config;
/// Engine-wide error types and snapshot helpers.
pub mod error;
/// No-window Lua runtime used by headless startup mode.
pub mod headless;
/// Log message identifiers and log-level override helpers.
pub mod log_messages;
/// Message catalog loader and lookup API.
pub mod messages;
/// Runtime mode parsing and display helpers.
pub mod mode;
/// Slot-map key types used by runtime-owned resources.
pub mod resource_keys;
/// Shared mutable runtime state consumed by app and Lua callbacks.
pub mod shared_state;
/// OS-level utilities including clipboard, system info, and platform detection.
pub mod os;
pub use config::Config;
pub use error::{EngineError, EngineResult, ErrorCategory, ErrorSnapshot};
pub use headless::{run_headless, run_headless_checked, HeadlessOptions};
pub use messages::MessageCatalog;
pub use mode::{RuntimeMode, RuntimeModeParseError};
pub use shared_state::{
    ErrorInfo, FrameProfile, FullscreenType, PhysicsRunConfig, RendererStats, ResourceMemoryStats,
    ScreenshotRequest, SharedState, WindowState,
};
