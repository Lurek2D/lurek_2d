//! This module re-exports network surface for `constants.rs`, `error.rs`, `host.rs`, and `lobby.rs` and runtime helpers.
//! It keeps navigation explicit by showing which sibling files own state, validation, transport, or render behavior.
//! Public exports here route callers toward `constants.rs`, `error.rs`, and `host.rs` first, while deeper behavior owners.
//! Open this file when the public network symbol map moves; edit siblings when runtime rules themselves change.
//! This index exists to organize entrypoints, not to absorb the state, caches, or algorithms its children own.
//! Use neighboring owners for behavioral fixes, and keep this file limited to exports, docs, and navigation.

/// Shared numeric limits and protocol constants used across all network layers.
pub mod constants;
/// `NetworkError` type covering socket, protocol, and framing failures.
pub mod error;
/// Host-side peer management: accept loop, peer registry, and disconnect handling.
pub mod host;
/// Lobby state machine: room creation, join, leave, and member list tracking.
pub mod lobby;
/// `NetMessage` enum and binary framing used on every transport.
pub mod message;
/// Game-state snapshot diffing and reliable sync packets sent between peers.
pub mod net_sync;
/// Network state synchronization manager for replicated state across peers.
pub mod netstate;
/// Relay server client: punch-through, forwarding, and relay session lifecycle.
pub mod relay;
/// Remote Procedure Call (RPC) manager for networked function invocation.
pub mod rpc;
