//! - Engine runtime foundations: configuration, shared state, and error types.
//! - Loads `conf.toml` into a typed `Config` struct consumed by all subsystems.
//! - Provides `SharedState` for mutable cross-module communication during a frame.
//! - Defines `EngineError` variants and slot-map resource keys.

/// Runtime configuration model loaded from `conf.toml`.
pub mod config;
/// Engine-wide error types and snapshot helpers.
pub mod error;
/// Log message identifiers and log-level override helpers.
pub mod log_messages;
/// Message catalog loader and lookup API.
pub mod messages;
/// Slot-map key types used by runtime-owned resources.
pub mod resource_keys;
/// Shared mutable runtime state consumed by app and Lua callbacks.
pub mod shared_state;
pub use config::Config;
pub use error::{EngineError, EngineResult, ErrorCategory, ErrorSnapshot};
pub use messages::MessageCatalog;
pub use shared_state::{
    ErrorInfo, FrameProfile, FullscreenType, PhysicsRunConfig, RendererStats, ResourceMemoryStats,
    ScreenshotRequest, SharedState, WindowState,
};
