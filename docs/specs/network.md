# network

## General Info

- Module group: `Core Runtime`
- Source path: `src/network/`
- Lua API path(s): `src/lua_api/network_api.rs`
- Primary Lua namespace: `lurek.network`
- Rust test path(s): tests/rust/unit/network_tests.rs
- Lua test path(s): tests/lua/unit/test_network.lua, tests/lua/unit/test_network_constants.lua

## Summary

The network module gives Lurek2D a small ENet-backed UDP transport layer for multiplayer features. It owns host creation, peer connection lifecycle, packet send and broadcast operations, bandwidth and channel limits, and the typed event stream returned by servicing an ENet host.

This module exists so Lua gameplay code can use networking without depending directly on `rusty_enet` types or raw socket setup. The Rust side enforces Lurek2D-specific defaults such as peer caps and convenience byte-send helpers, while the Lua binding turns host operations and network events into script-friendly methods and tables.

It intentionally does not own matchmaking, replication strategy, game-state serialization, security, or NAT traversal. If the work involves packet schemas, rollback, prediction, or encrypted transport, that belongs in higher-level Lua code or another module. This module stops at transport reliability, peer management, and querying host or peer state.

**Scope boundary**: This module currently depends on `runtime`. It stays within the Core Runtime responsibility boundary defined in the architecture docs.

## Files

- `constants.rs`: Compile-time limits and defaults for the networking subsystem.
- `error.rs`: Network-specific error types.
- `host.rs`: ENet host wrapper for the Lurek2D networking subsystem.
- `mod.rs`: UDP networking via ENet — reliable packet transport for multiplayer games.

## Types

- `NetworkError` (`enum`, `error.rs`): Errors produced by the networking subsystem.
- `NetworkHost` (`struct`, `host.rs`): Wraps a `rusty_enet::Host<UdpSocket>` with Lurek2D-specific defaults and limit enforcement.
- `NetworkEvent` (`enum`, `host.rs`): Result of a single [`NetworkHost::service`] call.
- `PeerStats` (`struct`, `host.rs`): Statistics snapshot for a single peer.

## Functions

- `NetworkHost::new` (`host.rs`): Create a new ENet host bound to `bind_addr`.
- `NetworkHost::service` (`host.rs`): Poll for one network event.
- `NetworkHost::connect` (`host.rs`): Initiate a connection to a remote host.
- `NetworkHost::send` (`host.rs`): Send a packet to a specific peer.
- `NetworkHost::send_bytes` (`host.rs`): Send raw bytes to a specific peer with a reliability flag.
- `NetworkHost::broadcast` (`host.rs`): Broadcast a packet to all connected peers.
- `NetworkHost::broadcast_bytes` (`host.rs`): Broadcast raw bytes to all connected peers with a reliability flag.
- `NetworkHost::flush` (`host.rs`): Flush all queued packets without waiting for the next `service()`.
- `NetworkHost::disconnect` (`host.rs`): Request graceful disconnection from a peer.
- `NetworkHost::disconnect_now` (`host.rs`): Immediately disconnect a peer without handshake.
- `NetworkHost::disconnect_later` (`host.rs`): Disconnect a peer after all queued packets have been sent.
- `NetworkHost::reset_peer` (`host.rs`): Reset a peer connection immediately without notifying the remote side.
- `NetworkHost::ping` (`host.rs`): Send a ping to a peer to measure RTT.
- `NetworkHost::round_trip_time` (`host.rs`): Get the round-trip time estimate for a peer.
- `NetworkHost::peer_state` (`host.rs`): Get the connection state of a peer as a string.
- `NetworkHost::peer_address` (`host.rs`): Get the remote address of a peer.
- `NetworkHost::local_address` (`host.rs`): Get the local bind address.
- `NetworkHost::peer_limit` (`host.rs`): Get the number of allocated peer slots.
- `NetworkHost::channel_limit` (`host.rs`): Get the channel limit.
- `NetworkHost::set_channel_limit` (`host.rs`): Set the channel limit for future connections.
- `NetworkHost::bandwidth_limit` (`host.rs`): Get the bandwidth limits.
- `NetworkHost::set_bandwidth_limit` (`host.rs`): Set bandwidth limits.
- `NetworkHost::connected_peer_count` (`host.rs`): Get the number of currently connected peers.
- `NetworkHost::destroy` (`host.rs`): Destroy the host, closing the underlying socket.
- `NetworkHost::is_destroyed` (`host.rs`): Returns `true` if the host has been destroyed.
- `NetworkHost::connected_peer_ids` (`host.rs`): Get the IDs of all currently connected peers.
- `NetworkHost::peer_stats` (`host.rs`): Get per-peer statistics.

## Lua API Reference

- Binding path(s): `src/lua_api/network_api.rs`
- Namespace: `lurek.network`

### Module Functions
- `lurek.network.MAX_PEERS`: Maximum supported peer slots for one host.
- `lurek.network.DEFAULT_PEERS`: Default peer-slot count when host options omit `peers`.
- `lurek.network.MAX_CHANNELS`: Maximum supported ENet channels per connection.
- `lurek.network.DEFAULT_CHANNELS`: Default channel count when host options omit `channels`.
- `lurek.network.newHost`: Creates a new network host bound to the given address.

### `NetworkHost` Methods
- `NetworkHost:service`: Polls the network for one event, returning an event table or nil.
- `NetworkHost:flush`: Flushes all pending sends immediately.
- `NetworkHost:disconnect`: Gracefully disconnects a peer.
- `NetworkHost:disconnectNow`: Immediately disconnects a peer without handshake.
- `NetworkHost:resetPeer`: Resets a peer connection immediately without notifying the remote side.
- `NetworkHost:ping`: Sends a ping to a peer to measure round-trip time.
- `NetworkHost:getRoundTripTime`: Returns the round-trip time estimate for a peer in milliseconds.
- `NetworkHost:getPeerState`: Returns the connection state of a peer as a string.
- `NetworkHost:getPeerAddress`: Returns the remote address of a peer, or nil if unavailable.
- `NetworkHost:getAddress`: Returns the local bind address as a string.
- `NetworkHost:getPeerLimit`: Returns the maximum number of peer slots.
- `NetworkHost:getChannelLimit`: Returns the maximum number of channels per connection.
- `NetworkHost:setChannelLimit`: Sets the channel limit for future connections.
- `NetworkHost:getBandwidthLimit`: Returns the bandwidth limits as a table with incoming and outgoing fields.
- `NetworkHost:getConnectedPeerCount`: Returns the number of currently connected peers.
- `NetworkHost:getConnectedPeerIds`: Returns a table of connected peer IDs.
- `NetworkHost:getPeerStats`: Returns a statistics table for a peer.
- `NetworkHost:destroy`: Destroys the host, closing the underlying socket.
- `NetworkHost:isDestroyed`: Returns true if the host has been destroyed.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/network/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
