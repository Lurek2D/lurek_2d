//! Defines the debugbridge module boundary for runtime-to-IDE transport and state exchange.
//! Groups shared bridge state and TCP server functionality under one integration surface.
//! Serves as the composition entry for engine-side debugbridge capabilities.

/// Expose shared bridge state and pending request or response buffers.
pub mod bridge;
/// Expose TCP server loop and JSON-RPC message dispatch handlers.
pub mod server;
/// Re-export shared bridge state and queue item types for integration code.
pub use bridge::{BridgeShared, PendingRequest, PendingResponse, PrintEntry, SharedBridge};
/// Re-export server entry points for network thread startup and message handling.
pub use server::{handle_client_message, server_thread};
