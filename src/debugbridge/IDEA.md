# IDEA — debugbridge

- **Module**: `debugbridge`
- **Path**: `src/debugbridge/`
- **Date**: 2026-04-18
- **Tier**: Edge/Integration

## Mission

Provide a JSON-over-TCP debug bridge for external tooling (VS Code extension, MCP server) to inspect and control a running Lurek2D game at runtime — including Lua eval, print capture, performance metrics, and screenshot requests.

## Strengths

- Clean two-thread architecture: TCP I/O on background thread, Lua-requiring ops queued for main-thread dispatch via `PendingRequest`/`PendingResponse`.
- Lightweight shared state with `Arc<Mutex<BridgeShared>>` — no complex channel system.
- Well-separated concerns: `bridge.rs` for data types, `server.rs` for networking/protocol.
- Print history + frame-time ring buffers provide useful tooling without high overhead.
- Protocol is newline-delimited JSON — trivial for external tools to consume.

## Gaps

- No authentication or handshake — any local process can connect (acceptable for 127.0.0.1 only, but lacks even a nonce).
- No protocol versioning — no way for client and server to negotiate capabilities.
- `print_history` uses `Vec::remove(0)` (O(n)) for eviction instead of `VecDeque`.
- `frame_times` uses `Vec::remove(0)` (O(n)) for eviction instead of `VecDeque`.
- No rate limiting on broadcast events — a chatty game could flood connected clients.
- Server loop uses a fixed 5ms sleep — not adaptive to load.
- No DAP (Debug Adapter Protocol) support for VS Code Lua breakpoints/stepping.
- No remote hot-reload trigger from bridge.

## Features (competitor cites)

1. **Protocol versioning / capability negotiation** — Godot's remote debugger sends a handshake with protocol version; LÖVE's `lurker` uses a version header. Lurek2D should add a `hello` handshake message with protocol version and supported methods.
2. **Breakpoint support via DAP** — Godot and Solar2D debug adapters support line-based breakpoints over DAP. Lurek2D could queue `setBreakpoint`/`removeBreakpoint` requests through the bridge for Lua-side hook registration.
3. **Structured object inspection** — Godot sends scene-tree hierarchies; Defold sends component graphs. Lurek2D could add `getSceneGraph` and `inspectObject(id)` methods returning structured ECS/scene data.

## Perf / Quality

- `push_print` and `record_frame` are O(n) on eviction due to `Vec::remove(0)`. Switch to `VecDeque` for O(1) amortized.
- `server_thread` busy-loops with 5ms sleep even when no clients are connected.
- `get_performance` scans all frame times each call — could cache last-computed stats and invalidate on `record_frame`.

## Test Gaps

- `server_thread` is not unit-tested (needs TCP listener — integration test territory).
- No test for concurrent access patterns (multiple clients queuing requests simultaneously).
- No test for screenshot request/scale clamping edge cases via protocol.

## TODO(dedup)

- `push_print` and `record_frame` share the same append-and-evict-oldest pattern. Extract a generic ring buffer helper or switch both to `VecDeque`.

## TODO(helper)

- Add a `BridgeShared::drain_responses()` helper to simplify the response-writing loop in `server_thread`.
- Add a `BridgeShared::queue_broadcast_json(&mut self, event: &str, data: serde_json::Value)` to reduce inline JSON construction.

## TODO(plugin)

- The debug bridge is a natural TIER-1-PLUGIN candidate — games that don't need runtime inspection shouldn't pay the TCP thread cost. Gate behind a `debugbridge` Cargo feature flag.

## References

- `src/lua_api/debugbridge_api.rs` — Lua bridge
- `docs/specs/debugbridge.md` — module spec
- `extensions/vscode/` — primary TCP client
