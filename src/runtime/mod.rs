//! This module is the runtime index, re-exporting config, shared state, modes, errors, messages, and headless flow.
//! It is the navigation point for startup policy, shared engine state, process modes, and stable runtime contracts.
//! `shared_state.rs` owns the mutable cross-system hub, while `config.rs` owns TOML-backed startup configuration.
//! `error.rs` owns failure vocabulary, `mode.rs` owns startup mode parsing, and `headless.rs` runs no-window sessions.
//! `messages.rs` and `log_messages.rs` own runtime text lookup plus stable log identifiers and formatting helpers.
//! Change this file when public runtime exports move; change siblings when startup or shared-state rules change.

/// Runtime configuration model loaded from `conf.toml`.
pub mod config;
/// Engine-wide error types and snapshot helpers.
pub mod error;
/// No-window Lua runtime used by headless startup mode.
pub mod headless;
/// Log message identifiers and log-level override helpers.
pub mod log_messages;
/// Shared Lua execution policy used by GUI and headless hosts.
pub mod lua_execution;
/// Message catalog loader and lookup API.
pub mod messages;
/// Runtime mode parsing and display helpers.
pub mod mode;
/// OS-level utilities including clipboard, system info, and platform detection.
pub mod os;
/// Slot-map key types used by runtime-owned resources.
pub mod resource_keys;
/// Shared mutable runtime state consumed by app and Lua callbacks.
pub mod shared_state;
pub use config::Config;
pub use error::{EngineError, EngineResult, ErrorCategory, ErrorSnapshot};
pub use headless::{run_headless, run_headless_checked, HeadlessOptions};
pub use lua_execution::{call_function_with_policy, LuaExecutionPolicy};
pub use messages::MessageCatalog;
pub use mode::{RuntimeMode, RuntimeModeParseError};
pub use shared_state::{
    ErrorInfo, FrameProfile, FullscreenType, PhysicsRunConfig, RendererStats, ResourceMemoryStats,
    ScreenshotRequest, SharedState, WindowState,
};
