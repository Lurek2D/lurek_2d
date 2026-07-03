//! Owns the network constants implementation for the network subsystem and keeps related runtime rules local here.
//! Keeps transport state, peers, and protocol-facing helpers so helpers stay close to invariants this file updates.
//! Defines how network constants data is validated, transformed, or stored before neighboring systems consume it.

/// Hard ceiling on simultaneous peer connections across all transports.
pub const MAX_PEERS: usize = 4096;
/// Default peer slot count used when the game does not specify a capacity.
pub const DEFAULT_PEERS: usize = 64;
/// Hard ceiling on logical channels per connection.
pub const MAX_CHANNELS: usize = 255;
/// Default channel count used when the game does not configure channels.
pub const DEFAULT_CHANNELS: usize = 2;
