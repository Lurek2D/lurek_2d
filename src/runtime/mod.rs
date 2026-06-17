//! This module provides the foundational runtime layer that the rest of the engine stands on during startup and per-frame execution.
//! Configuration, shared mutable state, error contracts, operating modes, and resource handle types are gathered here. `src/runtime/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `config::Config`, `error::{EngineError, EngineResult, ErrorCategory, ErrorSnapshot}`, `headless::{run_headless, run_headless_checked, HeadlessOptions}`, `messages::MessageCatalog`, and 2 more centralized for the runtime subsystem.
//! At the highest level this is the engine's coordination core, not a gameplay feature module. The file documents how runtime submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! `runtime/mod` is the runtime module index, declaring `config`, `error`, `headless`, `log_messages`, `messages`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/runtime/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `config::Config`, `error::{EngineError, EngineResult, ErrorCategory, ErrorSnapshot}`, `headless::{run_headless, run_headless_checked, HeadlessOptions}`, `messages::MessageCatalog`, and 2 more centralized for the runtime subsystem.
//! The file documents how runtime submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

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
/// OS-level utilities including clipboard, system info, and platform detection.
pub mod os;
/// Slot-map key types used by runtime-owned resources.
pub mod resource_keys;
/// Shared mutable runtime state consumed by app and Lua callbacks.
pub mod shared_state;
pub use config::Config;
pub use error::{EngineError, EngineResult, ErrorCategory, ErrorSnapshot};
pub use headless::{run_headless, run_headless_checked, HeadlessOptions};
pub use messages::MessageCatalog;
pub use mode::{RuntimeMode, RuntimeModeParseError};
pub use shared_state::{
    ErrorInfo, FrameProfile, FullscreenType, PhysicsRunConfig, RendererStats, ResourceMemoryStats,
    ScreenshotRequest, SharedState, WindowState,
};
