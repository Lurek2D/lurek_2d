# Network Module Contract

## Mission & Scope
- Own ENet, TCP, WebSocket, peers, queues, and background network workers.
- Keep blocking transport work off the game frame.

## Files
- `enet.rs`, `tcp.rs`, `websocket.rs`: Transport backends.
- `host.rs`, `peer.rs`, `queue.rs`: Runtime ownership and handoff.

## Rules
- Cross-thread messages must be typed, bounded when possible, and loss behavior documented.
- Never hold locks while invoking Lua or user callbacks.
- Surface disconnects and protocol errors as data, not panics.

## Workflow
- Validate with `cargo test --test network_tests`.
