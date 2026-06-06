---
inclusion: manual
---

# threading

## Mission
Own `lurek.thread` usage patterns, worker VM rules, and Channel-based coordination.

## When To Use
- Use worker VMs.
- Send messages across Channels.
- Design Lua work across threads.
- Review thread lifecycle and blocking behavior.

## When To Skip
- Rust thread internals, general game scripting.

## Rules

### Worker VM Isolation (Binding Constraint B-04)
Worker VMs are strictly isolated Lua states. No global tables, no shared userdata handles, no shared metatables cross VM boundaries. The only valid communication path is `lurek.thread.channel`.

### Worker-Safe lurek.* Surface
Workers can use: `lurek.math`, `lurek.data`, `lurek.fs` (read-only), `lurek.log`, `lurek.thread.channel`. Rendering, input, windowing, and audio APIs are main-thread-only. Calling a non-worker-safe API from a worker raises a runtime error.

### Channel Message Payloads
Must be serializable: booleans, numbers, strings, and flat tables of those types. No functions, no userdata, no metatables. For complex state, serialize to a plain table or a JSON string first.

### Polling Pattern (Preferred)
`local msg = chan:try_recv()` returns nil immediately if no message is available. Check it inside `on_process(dt)`. Never call `chan:recv()` (blocking) from the main thread — it stalls the frame loop.

### Worker Lifecycle
`lurek.thread.spawn(script_path, init_data)` creates and starts a worker. Workers do not automatically restart on error — handle failure in the message protocol by including a status field in every reply.

### Backpressure
If a channel's send queue fills, `chan:send(msg)` blocks or returns false depending on the channel mode. Design protocols to drain the queue or drop stale messages rather than relying on unbounded buffering.

### require Cache
The `require` cache (`package.loaded`) is per-VM. A library loaded in the main VM is not automatically available in a worker VM. Each worker must `require` its dependencies explicitly.

### Shutdown Sequencing
Always terminate workers before the main VM shuts down. `lurek.game.on_quit` is the correct place to call `worker:terminate()` and drain any pending messages.

### Debugging Thread Bugs
A failing worker does not produce a Rust stack trace on the main thread. Add explicit error-status messages to every worker protocol and log them in `on_process`.

### Never
Do not use Rust `std::thread::spawn` directly in game scripts or library modules. Worker VMs are the only supported Lua-level concurrency model.

## References
- `src/thread/`
- `src/lua_api/thread_api.rs`
- `docs/specs/thread.md`
