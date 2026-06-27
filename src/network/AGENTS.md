# Network Module Contract

## Mission & Scope
- Own ENet gameplay networking, LAN lobby/room helpers, payload packing, RPC, prediction, and snapshot sync.
- Keep the runtime network surface focused on small direct-IP or LAN multiplayer.

## Files
- `enet.rs`: ENet transport backend.
- `host.rs`, `peer.rs`, `queue.rs`: Runtime ownership and handoff.
- `lobby.rs`, `message.rs`, `net_sync.rs`, `rpc.rs`, `net_state.rs`, `relay.rs`: Small multiplayer helpers.

## Rules
- Network messages must be typed, bounded when possible, and loss behavior documented.
- Never hold locks while invoking Lua or user callbacks.
- Surface disconnects and protocol errors as data, not panics.
- Do not add web-service transports, streaming feeds, auth, or SaaS matchmaking back into `lurek.network`.

## Workflow
- Validate with `cargo test --test network_tests`.
