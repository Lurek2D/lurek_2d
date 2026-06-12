# Physics Module Contract

## Mission & Scope
- Own Rapier-backed worlds, bodies, colliders, joints, queries, and stepping.
- Keep simulation deterministic across variable render frame rates.

## Files
- `world.rs`, `body.rs`, `collider.rs`: Core physics state.
- `query.rs`, `joints.rs`: Spatial queries and constraints.

## Rules
- Step physics with fixed timestep semantics; do not bind simulation to render delta directly.
- Validate shape dimensions, filters, and material ranges before Rapier calls.
- Keep handle lifetimes explicit when removing bodies or colliders.

## Workflow
- Validate with `cargo test --test physics_tests`.
