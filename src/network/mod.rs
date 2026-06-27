//! This module is the network index, exposing ENet host ownership, sync helpers, and local lobby coordination.
//! `host.rs` owns ENet peers, while `message.rs` owns portable wire values.
//! `lobby.rs`, `relay.rs`, `rpc.rs`, `net_sync.rs`, and `netstate.rs` cover higher-level multiplayer coordination.
//! Open this file to navigate subsystem boundaries; actual transport logic and state live in sibling modules.

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
