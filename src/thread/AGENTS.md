# Thread Contract

This file adds local rules for work under `src/thread/`.

## Mission
- Own worker VMs, channel messaging, thread lifecycle, and Lua-facing concurrency rules.

## Local rules
- Worker VMs are isolated Lua states. Do not design features that depend on shared globals, userdata, or metatables across VMs.
- Keep the Lua-facing worker surface restricted to APIs that are safe away from the main thread.
- Channel payloads must stay serializable and simple enough to cross VM boundaries predictably.
- Favor non-blocking polling patterns for gameplay-facing message loops unless a protocol explicitly requires backpressure or blocking semantics.
- Shutdown order matters: worker termination must happen before the main VM tears down shared thread resources.
- Treat silent worker failure as a protocol bug. Worker designs should expose explicit error-status messages instead of hoping a main-thread stack trace will exist.
- Keep Lua-facing contracts in `src/lua_api/thread_api.rs` and core concurrency machinery in `src/thread/`.

## Workflow
- Read `docs/specs/thread.md` before changing worker lifecycle, payload shape, or channel behavior.
- Validate both success and shutdown/error paths when changing worker protocols.

## References
- `docs/specs/thread.md`
- `src/lua_api/thread_api.rs`
