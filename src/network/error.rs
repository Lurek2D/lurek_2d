//! Network-specific error types.
//!
//! All public items are documented. See the parent module for architectural context
//! and the `lurek.*` Lua API for the scripting interface.

use thiserror::Error;

/// Errors produced by the networking subsystem.
///
/// # Variants
/// - `PeerLimitExceeded` — The requested peer count exceeds `MAX_PEERS`.
/// - `Io` — A socket-level I/O error occurred.
/// - `Enet` — An ENet-internal error surfaced from `rusty_enet`.
/// - `HostDestroyed` — The host has already been destroyed; further calls are invalid.
/// - `InvalidPeer` — The addressed peer index is out of range.
/// - `InvalidAddress` — Failed to parse a bind address string.
/// - `Http` — An HTTP request failed.
/// - `WebSocket` — A WebSocket operation failed.
/// - `Tcp` — A TCP socket operation failed.
/// - `Serialization` — Message pack/unpack failed.
/// - `Thread` — The network I/O thread encountered an error.
/// - `Http` — An HTTP request failed.
/// - `WebSocket` — A WebSocket operation failed.
/// - `Tcp` — A TCP socket operation failed.
/// - `Serialization` — Message pack/unpack failed.
/// - `Thread` — The network I/O thread encountered an error.
#[derive(Debug, Error)]
pub enum NetworkError {
    /// The requested peer count exceeds [`super::constants::MAX_PEERS`].
    #[error("peer count {requested} exceeds maximum of {max}")]
    PeerLimitExceeded {
        /// The value the caller asked for.
        requested: usize,
        /// The hard-coded ceiling.
        max: usize,
    },

    /// A socket-level I/O error occurred.
    #[error("network I/O error: {0}")]
    Io(#[from] std::io::Error),

    /// An ENet-internal error surfaced from `rusty_enet`.
    #[error("ENet error: {0}")]
    Enet(String),

    /// The host has already been destroyed; further calls are invalid.
    #[error("host has been destroyed")]
    HostDestroyed,

    /// The addressed peer index is out of range.
    #[error("invalid peer index {0}")]

    /// An HTTP request failed.
    #[error("HTTP error: {0}")]
    Http(String),

    /// A WebSocket operation failed.
    #[error("WebSocket error: {0}")]
    WebSocket(String),

    /// A TCP socket operation failed.
    #[error("TCP error: {0}")]
    Tcp(String),

    /// Message serialization or deserialization failed.
    #[error("serialization error: {0}")]
    Serialization(String),

    /// The network I/O thread encountered an error.
    #[error("network thread error: {0}")]
    Thread(String),
    InvalidPeer(usize),

    /// Failed to parse a bind address string (expected `"*:port"` or `"host:port"`).
    #[error("invalid bind address: {0}")]
    InvalidAddress(String),

    /// An HTTP request failed.
    #[error("HTTP error: {0}")]
    Http(String),

    /// A WebSocket operation failed.
    #[error("WebSocket error: {0}")]
    WebSocket(String),

    /// A TCP socket operation failed.
    #[error("TCP error: {0}")]
    Tcp(String),

    /// Message serialization or deserialization failed.
    #[error("serialization error: {0}")]
    Serialization(String),

    /// The network I/O thread encountered an error.
    #[error("network thread error: {0}")]
    Thread(String),
}
