//! This file owns shared numeric limits for peers and ENet channels in networking.
//! It centralizes defaults such as `DEFAULT_PEERS`, `DEFAULT_CHANNELS`, and transport buffer capacities.
//! Open it when protocol ceilings change; host logic, runtime polling, and message framing live in siblings.

/// Hard ceiling on simultaneous peer connections across all transports.
pub const MAX_PEERS: usize = 4096;
/// Default peer slot count used when the game does not specify a capacity.
pub const DEFAULT_PEERS: usize = 64;
/// Hard ceiling on logical channels per connection.
pub const MAX_CHANNELS: usize = 255;
/// Default channel count used when the game does not configure channels.
pub const DEFAULT_CHANNELS: usize = 2;
