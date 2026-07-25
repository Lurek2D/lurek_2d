# Runtime Module Contract

## Mission & Scope
- Own shared engine state, config, runtime modes, messages, and headless flow.
- Keep shared state typed and observable.

## Files
- `config.rs`, `mode.rs`, `os.rs`: Runtime config, mode, and host facts.
- `shared_state.rs`, `resource_keys.rs`: Shared handles and resource keys.
- `lua_execution.rs`, `messages.rs`, `log_messages.rs`: Script execution and messages.
- `headless.rs`: Headless runtime support.

## Rules
- Do not add untyped global state; extend `shared_state.rs` or a subsystem owner.
- Keep resource keys stable and validate lookups before mutation.
- Config defaults must be deterministic and documented at the field boundary.

## Workflow
- Validate with `cargo test --test runtime_tests`.
