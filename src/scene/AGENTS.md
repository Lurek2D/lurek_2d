# Scene Module Contract

## Mission & Scope
- Own scene stack flow, overlays, lifecycle callbacks, transitions, and shared scene data.
- Keep state changes explicit across push, pop, switch, pause, and resume.

## Files
- `stack.rs`, `scene.rs`: Stack ownership and scene descriptors.
- `transition.rs`: Scene transition state.

## Rules
- Preserve lifecycle callback order when changing stack behavior.
- Overlay scenes must not accidentally consume base-scene update/render rules.
- Avoid global scene data; pass data through scene APIs.

## Workflow
- Validate stack behavior with `cargo test` until a dedicated scene test target exists.
