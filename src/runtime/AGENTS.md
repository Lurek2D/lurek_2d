# Runtime Module Contract

## Mission & Scope
- Own central engine state, resource pools, config, frame timing, and subsystem handles.
- Keep shared state typed and observable.

## Files
- `state.rs`, `config.rs`: Runtime state and TOML-backed defaults.
- `resources.rs`, `stats.rs`: Pools, budgets, and usage metrics.

## Rules
- Do not add untyped global state; extend runtime state or a module owner.
- Keep resource IDs stable and validate pool lookups before mutation.
- Config defaults must be deterministic and documented at the field boundary.

## Workflow
- Validate with `cargo test --test runtime_tests`.
