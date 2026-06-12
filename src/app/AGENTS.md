# App Module Contract

## Mission & Scope
- Own desktop startup, event-loop integration, splash, and frame progression.
- Keep host events routed through guarded runtime callbacks.

## Files
- `main_loop.rs`, `runner.rs`: Launch and frame control.
- `error_screen.rs`, `splash_screen.rs`: User-visible startup/failure surfaces.

## Rules
- Never call Lua callbacks directly from raw host events without guard/error paths.
- Keep surface, resize, focus, and visibility changes deferred to safe frame points.
- Any unsafe platform call must name the window/surface invariant.

## Workflow
- Validate app changes with `cargo test --test app_tests`.
