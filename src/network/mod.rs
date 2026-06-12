//! Multiplayer networking across TCP, WebSocket, relay, and HTTP helpers.
//! Hosts the host/client model, lobby flow, peer management, and game-state sync.
//! Runs the background async runtime for non-blocking socket I/O.

/// Shared numeric limits and protocol constants used across all network layers.
pub mod constants;
/// `NetworkError` type covering socket, protocol, and framing failures.
pub mod error;
/// Host-side peer management: accept loop, peer registry, and disconnect handling.
pub mod host;
/// Blocking HTTP GET/POST helpers used for matchmaking and asset fetching.
pub mod http;
/// Lobby state machine: room creation, join, leave, and member list tracking.
pub mod lobby;
/// `NetMessage` enum and binary framing used on every transport.
pub mod message;
/// Game-state snapshot diffing and reliable sync packets sent between peers.
pub mod net_sync;
/// Background Tokio thread that owns the async socket runtime; started at engine init.
pub mod net_thread;
/// Network state synchronization manager for replicated state across peers.
pub mod netstate;
/// Relay server client: punch-through, forwarding, and relay session lifecycle.
pub mod relay;
/// Remote Procedure Call (RPC) manager for networked function invocation.
pub mod rpc;
/// Server-Sent Events (SSE) stream reader backed by a background thread.
pub mod sse;
/// Raw TCP transport: connect, send, receive, and graceful close.
pub mod tcp;
/// WebSocket transport wrapping `tungstenite`; mirrors the TCP interface.
pub mod websocket;
pub use sse::{SseEvent, SseStream};
