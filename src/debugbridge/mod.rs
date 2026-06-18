//! `src/debugbridge/mod.rs` is the module index that exposes the runtime debug bridge state and server entry points.
//! It reexports shared queue types and network handlers so runtime code and tooling consume one stable debugger surface.
//! No bridge state lives here; this file only declares child modules and defines which debug transport symbols are public.
//! Read this index when wiring IDE integration, because it shows where shared state ends and socket handling begins.
//! Changes here reshape the debugger boundary, since reexports decide what engine code may import without deep paths.
//! This module keeps bridge storage and TCP protocol handling separate, which makes debugger ownership easier to trace.

/// Expose shared bridge state and pending request or response buffers.
pub mod bridge;
/// Expose TCP server loop and JSON-RPC message dispatch handlers.
pub mod server;
/// Re-export shared bridge state and queue item types for integration code.
pub use bridge::{BridgeShared, PendingRequest, PendingResponse, PrintEntry, SharedBridge};
/// Re-export server entry points for network thread startup and message handling.
pub use server::{handle_client_message, server_thread};
