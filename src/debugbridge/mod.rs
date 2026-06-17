//! Defines the debugbridge module boundary for runtime-to-IDE transport and state exchange. `debugbridge/mod` is the debugbridge module index, declaring `bridge`, `server` so agents can identify which files own each feature slice before opening implementation code.
//! Groups shared bridge state and TCP server functionality under one integration surface. `src/debugbridge/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `bridge::{BridgeShared, PendingRequest, PendingResponse, PrintEntry, SharedBridge}`, `server::{handle_client_message, server_thread}` centralized for the debugbridge subsystem.

/// Expose shared bridge state and pending request or response buffers.
pub mod bridge;
/// Expose TCP server loop and JSON-RPC message dispatch handlers.
pub mod server;
/// Re-export shared bridge state and queue item types for integration code.
pub use bridge::{BridgeShared, PendingRequest, PendingResponse, PrintEntry, SharedBridge};
/// Re-export server entry points for network thread startup and message handling.
pub use server::{handle_client_message, server_thread};
