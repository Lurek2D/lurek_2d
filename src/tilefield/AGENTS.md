# Tilefield Module Contract

## Mission & Scope
- Own tile-based gameplay semantics for multi-level fields: movement, vision, action, point light, and top light.
- Keep algorithms data-oriented and renderer-independent.

## Files
- `field.rs`, `cell.rs`: Field storage, bounds, channel state, profiles, exports.
- `line.rs`, `topology.rs`: Grid topology, distances, and line traversal.
- `light.rs`: Tile point lights and global top-light accumulation.
- `profile.rs`: Named object profiles and built-in defaults.

## Rules
- Keep coordinates zero-based internally and convert at Lua boundaries.
- Do not depend on raycaster, minimap, render, or visibility from this module.
- Keep channel semantics independent; never infer action from vision or movement from light.

## Workflow
- Validate with `cargo test --test tilefield_tests` and Lua tilefield unit coverage.
