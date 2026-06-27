# network manual spec overlay

## TL;DR

- Manages ENet UDP hosts for small client/server or peer-hosted games.
- Coordinates LAN lobby discovery, room state, MessagePack payloads, RPC helpers, prediction, and snapshot sync.
- Does not provide web-service, streaming, auth, or SaaS matchmaking runtime APIs.

## Summary

- The `network` module is the engine's small-game multiplayer surface for users who need direct IP or LAN-hosted sessions for roughly 8-16 players.
- ENet is the gameplay transport. It provides reliable and unreliable UDP channels, host/server/client roles, peer events, flushing, pinging, disconnects, stats, and metrics.
- LAN lobby and room helpers cover local coordination before gameplay packets flow: lobby advertisement/discovery, room creation, join/leave, readiness, room lookup, and player lists.
- MessagePack payload helpers keep gameplay messages compact and structured. Snapshot, prediction, reconciliation, net state, and RPC helpers are part of the same game-state exchange contract.
- Relay and punch helpers are lightweight string/payload helpers only. They do not create a built-in web relay client or internet matchmaking service inside `lurek.exe`.
- Web-service transports, streaming feeds, auth bootstrap, and SaaS-style matchmaking are intentionally outside the runtime network API. If a project needs internet services later, they should live in a separate service/tool while gameplay remains ENet-based.
- Read `network` as the engine feature for small multiplayer sessions, LAN discovery, and structured gameplay state exchange.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
