# Window Module Contract

## Mission & Scope
- Own desktop window state, display queries, fullscreen, scaling, icon, and attention APIs.
- Keep event-loop-sensitive changes deferred and explicit.

## Files
- `event_loop.rs`: Window event handling and safe update points.
- `management.rs`: Window, display, fullscreen, and icon operations.
- `viewport.rs`: Logical and physical viewport conversion.

## Rules
- Do not apply mode or monitor changes outside safe event-loop points.
- Keep logical, physical, and scale-factor units explicit.
- Treat unsupported platform features as no-op/error data, not panics.

## Workflow
- Validate event-loop-facing changes with `cargo test --test app_tests`.
