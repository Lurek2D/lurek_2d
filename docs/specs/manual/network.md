# network manual spec overlay

## TL;DR

- Manages ENet UDP hosts, TCP/WebSocket pools, and ureq-backed HTTP/SSE channels.
- Coordinates MessagePack messaging, linear predictions, and snapshot syncs.

## Summary

- The `network` module is the engine's communication and session surface for users who need game state, tool messages, service calls, telemetry, or multiplayer traffic to move between processes or machines.
- Its scope is intentionally broad because real communication needs are broad. Raw TCP, HTTP-style requests, websockets, SSE-like streams, lobbies, host state, relays, RPC, sync structures, and worker-thread coordination all appear in one engine-facing family.
- That breadth is a practical advantage because projects often need several kinds of communication at once. A multiplayer game may also need service APIs, diagnostics channels, content downloads, and background coordination without wanting four unrelated networking stacks.
- Message and transport types are central to the contract because networking is not just about opening a socket; it is also about how payloads are described, routed, retried, synchronized, and surfaced to the rest of the engine.
- Session and host helpers matter because communication often begins before any gameplay packet is exchanged. Discovery, lobby state, connection negotiation, and participant tracking are all part of real multiplayer or remote-tool workflows.
- RPC-style and sync-oriented surfaces broaden the feature into structured state exchange, while background thread support keeps network activity off the main loop.
- This asynchronous model matters for responsiveness, retries, timeouts, and long-lived connections where the network layer must remain active even while other systems continue to update.
- HTTP, websocket, and streaming surfaces keep the module useful beyond multiplayer for tooling, remote control, telemetry, and services.
- Error typing and connection-state tracking are equally valuable because networking only becomes usable at scale when disconnects, retries, and degraded states are visible rather than hidden in transport internals.
- That shared transport layer also reduces the need for project-specific communication glue.
- The module is therefore useful for online play, local-network coordination, service-backed tools, live dashboards, remote assistants, telemetry sinks, and any feature that depends on structured communication beyond the current process.
- That breadth is one reason the subsystem belongs in the engine rather than in ad hoc project code.
- Domain modules define what should be exchanged, while `network` owns how those exchanges are carried, coordinated, monitored, and kept off the blocking path.
- Read `network` as the engine feature that turns remote communication into a reusable runtime capability.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
