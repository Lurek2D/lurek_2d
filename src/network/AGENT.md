# `network` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Unassigned |
| **Status** | Implemented — Full |
| **Lua API** | `luna.network` |
| **Source** | `src/network/` |
| **Rust Tests** | `tests/unit/network_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_network.lua` |
| **Architecture** | — |

## Summary

The `network` module provides UDP networking via ENet for peer-to-peer and client-server
multiplayer games. It is a Tier 1 Engine Subsystem that wraps the `rusty_enet` crate.

A `NetworkHost` binds to a local UDP socket and acts simultaneously as a server (accepts
incoming connections) and as a client (opens outgoing connections). The `service(timeout)`
event pump drives all I/O; it returns events such as `Connect`, `Receive`, and `Disconnect`.
Packets are delivered over numbered channels with configurable reliability.

Two Lua API surfaces are exposed: `luna.network` (high-level options tables, event tables,
camelCase naming) and `luna.net` / `enet` (raw ENet signatures with underscore naming and
multi-value returns, for developers porting Lua/ENet code from LÖVE).

Constants such as `MAX_PEERS` and `MAX_CHANNELS` are defined in `constants.rs`.
`NetworkError` provides Lua-friendly error messages.

**Scope boundary**: This module handles transport only — no game protocol, no encryption,
no matchmaking. Higher-level networking logic lives in Lua scripts.
## Architecture

```
network (module root)
  ├── constants.rs — Compile-time limits and defaults for the networking subsystem. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
  ├── error.rs — Network-specific error types. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
  ├── host.rs — ENet host wrapper for the Luna2D networking subsystem. [`NetworkHost`] owns a `rusty_enet::Host<UdpSocket>` and provides a safe Rust API that the Lua binding layers (`network_api`, `net_api`) consume. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.
```

## Source Files

| File | Purpose |
|------|---------|
| `constants.rs` | Compile-time limits and defaults for the networking subsystem. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |
| `error.rs` | Network-specific error types. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |
| `host.rs` | ENet host wrapper for the Luna2D networking subsystem. [`NetworkHost`] owns a `rusty_enet::Host<UdpSocket>` and provides a safe Rust API that the Lua binding layers (`network_api`, `net_api`) consume. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface. |

## Submodules

### `network::constants`

Compile-time limits and defaults for the networking subsystem. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

### `network::error`

Network-specific error types. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

- **`NetworkError`** (enum): TODO: one-line description.

### `network::host`

ENet host wrapper for the Luna2D networking subsystem. [`NetworkHost`] owns a `rusty_enet::Host<UdpSocket>` and provides a safe Rust API that the Lua binding layers (`network_api`, `net_api`) consume. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.

- **`NetworkHost`** (struct): TODO: one-line description.
- **`PeerStats`** (struct): TODO: one-line description.
- **`NetworkEvent`** (enum): TODO: one-line description.

## Key Types

### Structs

#### `network::host::NetworkHost`

TODO: description from `///` doc comment.

#### `network::host::PeerStats`

TODO: description from `///` doc comment.

### Enums

#### `network::error::NetworkError`

TODO: description from `///` doc comment.

#### `network::host::NetworkEvent`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.network.*` by `src\lua_api\network_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `network`.

## Lua Examples

```lua
-- Example: Basic network usage
function luna.load()
    -- TODO: replace with real network setup
    local obj = luna.network.network()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 2 |
| `enum`   | 2 |
| `fn`     | 0 |
| **Total** | **4** |

## References

| Module | Relationship | Notes |
|--------|--------------|-------|
| `engine` | Imports from | Uses SharedState, EngineError |
| `math` | Imports from | Vec2, Color, Rect |
| `lua_api` | Imported by | Binds public API to Lua |

TODO: Add entries for similar modules and explain the separation of duties.

## Notes

TODO: Document unique facts an agent must know before editing this module:
- External crate constraints (version, thread-safety, API limitations)
- Hardware or OS-specific behaviour (e.g., headless fallback on CI)
- Known limitations or intentional omissions
- Best practices and anti-patterns for this module
- What Lua scripts will break if the API changes
