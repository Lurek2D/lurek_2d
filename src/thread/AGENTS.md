# Thread Contract

Covers work under `src/thread/`.

## Mission
- Own worker VMs, channel messaging, thread lifecycle, and Lua-facing concurrency rules.

## Scope
- `src/thread/` worker VM and channel logic.

## Local map
- `docs/specs/thread.md` defines the worker contract.
- `src/lua_api/thread_api.rs` is the Lua-facing edge.

## Rules
- Worker VMs are isolated Lua states.
- Keep the Lua-facing worker surface limited to APIs safe off the main thread.
- Channel payloads must stay serializable and simple.
- Prefer non-blocking polling unless the protocol needs backpressure or blocking.
- Worker termination must happen before the main VM tears down shared thread resources.
- Treat silent worker failure as a protocol bug.
- Keep Lua-facing contracts in `src/lua_api/thread_api.rs` and core concurrency machinery in `src/thread/`.

## Workflow
- Read `docs/specs/thread.md` before changing worker lifecycle, payload shape, or channel behavior.
- Validate both success and shutdown or error paths when changing worker protocols.

## References
- `docs/specs/thread.md`
- `src/lua_api/thread_api.rs`
