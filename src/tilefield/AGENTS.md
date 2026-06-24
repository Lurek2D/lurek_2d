# Tilefield Module Contract

## Mission & Scope
- Own tile-based gameplay semantics for single fields, field maps, and layered field maps: movement, vision, action, light-blocking inputs, top-light inputs, author refs, regions, and runtime modifiers.
- Keep algorithms data-oriented and renderer-independent.

## Files
- `field.rs`, `field_map.rs`, `cell.rs`: Field storage, field-map storage, bounds, channel state, refs, regions, modifiers, exports.
- `line.rs`, `topology.rs`: Grid topology, distances, and line traversal.
- `modifier.rs`: Runtime tile modifiers applied over base cell/object values.

## Rules
- Keep coordinates zero-based internally and convert at Lua boundaries.
- Do not depend on raycaster, minimap, render, awareness, pathfind, or tilelight from this module.
- Keep channel semantics independent; never infer action from vision or movement from light.

## Workflow
- Validate with `cargo test --test tilefield_tests` and Lua tilefield unit coverage.
