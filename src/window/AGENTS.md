# Window Module Contract

## Mission & Scope
- Own desktop window state, display queries, fullscreen, scaling, icon, and attention APIs.
- Keep event-loop-sensitive changes deferred and explicit.

## Files
- `state.rs`, `display.rs`: Window and monitor state.
- `commands.rs`: Deferred window operations.

## Rules
- Do not apply mode or monitor changes outside safe event-loop points.
- Keep logical, physical, and scale-factor units explicit.
- Treat unsupported platform features as no-op/error data, not panics.

## Workflow
- Validate event-loop-facing changes with `cargo test --test app_tests`.
