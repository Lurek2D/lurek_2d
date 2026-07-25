# Thread Module Contract

## Mission & Scope
- Own isolated Lua worker VMs, channels, promises, and thread handles.
- Keep cross-thread state message-passed, not shared mutably.

## Files
- `worker.rs`, `pool.rs`: Worker execution and pooling.
- `channel.rs`, `promise.rs`: Messages and completion state.

## Rules
- Do not move borrowed Lua values across thread boundaries.
- Channel payloads must stay serializable and clone-safe.
- Promise completion must be one-shot and observable after worker failure.

## Workflow
- Validate with `cargo test --test thread_tests`.
