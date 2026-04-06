# `thread` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 1 — Basic Core |
| **Status**     | Implemented — Full                                   |
| **Lua API** | `luna.thread` |
| **Source** | `src/thread/` |
| **Rust Tests** | `tests/unit/thread_tests.rs`                    |
| **Tests** | `tests/thread_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_thread.lua` |

## Summary

The `thread` module provides background Lua worker threads and a typed-value
Channel for inter-thread communication, enabling game scripts to delegate
expensive or blocking work to parallel OS threads without freezing the main
game loop. Each `LuaThread` receives a Lua code string, spawns a dedicated
Rust thread to execute it, and communicates back through named `Channel`
objects that the main script polls each frame via `luna.thread.channel()`.
`ChannelValue` is the typed wire format — Nil, Bool, Number, or String —
enforcing that only serialisable primitives cross the VM boundary and
preventing accidental state sharing between independent Lua VMs. The
`demand()` call provides a blocking receive for thread synchronisation when
the main loop explicitly chooses to wait for a result. Background threads are
the only supported concurrency primitive: LuaJIT VMs cannot share state, so
the module makes inter-VM communication deliberate and auditable rather than
implicit.

## Architecture

```
Lua (main thread)
  └── LuaChannel (send/receive)
        └── Worker (background thread, optionally runs Lua)
```

## Source Files

| File | Purpose |
|------|---------|
| `channel.rs` | Thread-safe channel for Lua inter-thread communication |
| `worker.rs` | Background Lua thread with independent VM |

## Submodules

### `thread::channel`

Thread-safe channel for Lua inter-thread communication.

- **`ChannelValue`** (enum): Serializable values that can be sent between threads.
- **`Channel`** (struct): Thread-safe MPMC channel for Lua inter-thread communication.  Internally uses a `Mutex<VecDeque>` protected queue with...
- **`LuaChannel`** (struct): Lua UserData wrapper for a thread-safe channel.
- **`lua_to_channel_value`** (fn): Convert a Lua value into a `ChannelValue` for cross-thread transfer.
- **`channel_value_to_lua`** (fn): Convert a `ChannelValue` back into a Lua value.

### `thread::worker`

Background Lua thread with independent VM.

- **`ThreadState`** (enum): Execution state of a background Lua thread.
- **`LuaThread`** (struct): A background Lua thread running its own VM.  Created via `luna.thread.newThread(code)`. Call `start()` to spawn the OS...

## Key Types

### Structs

#### `thread::channel::Channel`

Thread-safe MPMC channel for Lua inter-thread communication.  Internally uses a `Mutex<VecDeque>` protected queue with...

#### `thread::channel::LuaChannel`

Lua UserData wrapper for a thread-safe channel.

#### `thread::worker::LuaThread`

A background Lua thread running its own VM.  Created via `luna.thread.newThread(code)`. Call `start()` to spawn the OS...

### Enums

#### `thread::channel::ChannelValue`

Serializable values that can be sent between threads.

#### `thread::worker::ThreadState`

Execution state of a background Lua thread.

## Public Functions

- **`channel_value_to_lua()`** `channel::` — Convert a `ChannelValue` back into a Lua value.
- **`lua_to_channel_value()`** `channel::` — Convert a Lua value into a `ChannelValue` for cross-thread transfer.

## Lua API

Exposed under `luna.thread.*` by `src/lua_api/thread_api/`.

## Item Summary

| Kind | Count |
|------|-------|
| `enum` | 2 |
| `fn` | 2 |
| `mod` | 2 |
| `struct` | 3 |
| **Total** | **9** |

## Lua Examples

```lua
function luna.load()
    -- Create inter-thread channel
    ch = luna.thread.newChannel()

    -- Start background worker
    worker = luna.thread.newThread([[
        local ch = ...
        for i = 1, 100 do
            ch:push(i * i)
        end
        ch:push("done")
    ]], ch)
    worker:start()
end

function luna.update(dt)
    local val = ch:pop()
    if val == "done" then
        print("Worker finished")
    end
end
```

## References

| Module    | Relationship  | Notes                                              |
|-----------|-----------    |----------------------------------------------------|
| `engine`  | Imports from  | Uses `SharedState`, but only for creating Channel objects |
| `math`    | Related       | Workers may import `math` (it's safe to use across threads) |
| `lua_api` | Imported by   | `src/lua_api/thread_api.rs` registers `luna.thread.*` |

## Notes

- Each worker thread creates its own isolated Lua VM — they do NOT share `SharedState`.
- Only these modules are safe to use inside worker Lua VMs: `luna.math`, `luna.data`, `luna.thread` (channel only), `luna.filesystem` (read-only).
- `Channel` is MPMC (multi-producer multi-consumer) and thread-safe.
- `channel:demand()` blocks the calling thread until a value arrives — use carefully to avoid deadlocks.
- Do NOT call `luna.graphics.*` or `luna.audio.*` from worker threads.
