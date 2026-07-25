# Network Module Contract

## Mission & Scope
- Own ENet gameplay networking, LAN lobby/room helpers, payload packing, RPC, prediction, and snapshot sync.
- Keep the runtime network surface focused on small direct-IP or LAN multiplayer.

## Files
- `host.rs`, `message.rs`, `constants.rs`, `error.rs`: Transport state and packet rules.
- `lobby.rs`, `net_sync.rs`, `rpc.rs`, `netstate.rs`, `relay.rs`: LAN and gameplay helpers.

## Rules
- Network messages must be typed, bounded when possible, and loss behavior documented.
- Never hold locks while invoking Lua or user callbacks.
- Surface disconnects and protocol errors as data, not panics.
- Do not add web-service transports, streaming feeds, auth, or SaaS matchmaking back into `lurek.network`.

## Workflow
- Validate with `cargo test --test network_tests`.
