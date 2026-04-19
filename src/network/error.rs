//! Network-specific error types.
//!
//! [`NetworkError`] is the unified error enum for all network transport layers:
//! ENet UDP, HTTP, TCP, WebSocket, and MessagePack serialization. Each variant
//! carries enough context for the Lua binding layer to produce a useful error
//! message.

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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn peer_limit_display() {
        let e = NetworkError::PeerLimitExceeded {
            requested: 5000,
            max: 4096,
        };
        let msg = format!("{e}");
        assert!(msg.contains("5000"));
        assert!(msg.contains("4096"));
    }

    #[test]
    fn host_destroyed_display() {
        let e = NetworkError::HostDestroyed;
        assert_eq!(format!("{e}"), "host has been destroyed");
    }

    #[test]
    fn invalid_peer_display() {
        let e = NetworkError::InvalidPeer(99);
        assert!(format!("{e}").contains("99"));
    }

    #[test]
    fn io_error_from_conversion() {
        let io_err = std::io::Error::new(std::io::ErrorKind::NotFound, "no socket");
        let net_err: NetworkError = io_err.into();
        assert!(format!("{net_err}").contains("no socket"));
    }

    #[test]
    fn serialization_error_display() {
        let e = NetworkError::Serialization("bad data".to_string());
        assert!(format!("{e}").contains("bad data"));
    }
}
