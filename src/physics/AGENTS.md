# Physics Module Contract

## Mission & Scope
- Own the authoritative 2D simulation, spatial queries, collision terrain, liquids, flows, zones, and altitude sidecars.
- Do not own rendering, tile storage, pathfinding, scenes, images, or gameplay rules.

## Files
- `world.rs`, `world/`: World state, stepping, bodies, joints, and queries.
- `terrain.rs`, `liquid.rs`, `flow.rs`, `zone.rs`: Terrain and environment simulation.
- `body.rs`, `collision.rs`, `shape.rs`, `material.rs`: Body and collision data.
- `limits.rs`, `error.rs`: Limits and errors.

## Rules
- Apply `PhysicsLimits` to every create, update, query, load, save, and work path.
- Check Lua numbers for finite values and valid ranges before mutation.
- Stale body and joint handles must fail safely. Storage stays bounded.
- Bulk changes, terrain rebuilds, and loads must validate first, then commit once.
- `step` and `stepFixed` release world borrows before callbacks.
- Keep public query and event order stable.
- `lurek.physics.createBodiesFromTilefield` owns tilefield conversion; compatibility helpers only forward.
- Debug output contains bounded shapes only. `render` owns pixels and GPU data.

## Workflow
- Run `cargo test --test physics_tests`.
- Run physics Lua unit, security, and stress tests for public behavior.
