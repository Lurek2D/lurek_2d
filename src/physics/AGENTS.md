# Physics Module Contract

## Mission & Scope

- Own the authoritative 2D simulation, spatial queries, collision terrain, liquids, flows, zones, and altitude sidecars.
- Do not absorb rendering, tile storage, pathfinding, scene scheduling, image decoding, or gameplay weapon policy.

## Files

- `world.rs`, `world/`: world state, stepping, bodies, joints, queries, and flow/gravity application.
- `terrain.rs`, `liquid.rs`: bounded destructible occupancy, collider rebuilds, liquid state, and snapshots.
- `limits.rs`, `error.rs`: shared ceilings and strict failure vocabulary.

## Rules

- Enforce every `PhysicsLimits` ceiling on every creation, mutation, query, serialization, and workload path.
- Lua-facing numeric input must be finite and range-checked before mutating core state; return named `lurek.physics.*` errors.
- Keep body and joint lifetimes explicit; stale references must fail and backing storage must remain bounded.
- Bulk creation, adapters, terrain rebuilds, and deserialization must preflight then commit atomically.
- `stepFixed` accepts only bounded valid steps, carries the unconsumed remainder, and aggregates deterministic events for the whole call.
- `step` and `stepFixed` dispatch equivalent contact callbacks after releasing world borrows; callbacks may affect only later work.
- Sort or otherwise define all externally observable query, event, and partial-rebuild ordering.
- `lurek.physics.createBodiesFromTilefield` is the canonical tilefield conversion facade; tilefield compatibility helpers only forward.
- Emit bounded debug shape snapshots only; `render` owns commands, buffers, and pixels.

## Workflow

- Keep bindings thin: parse, validate, convert, invoke strict core APIs, and surface contextual errors.
- Exercise creation, fixed stepping, teardown, and recreation in Rust tests.
- Maintain Lua unit, security, and stress coverage for limits, hostile input, callback reentrancy, and resource ceilings.
- Validate with `cargo test --test physics_tests`, relevant Lua suites, and the physics audit gates.
