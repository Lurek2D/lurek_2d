# Tilefield Module Contract

## Mission & Scope
- Own tile gameplay data: movement, vision, actions, light inputs, references, regions, and modifiers.
- Keep algorithms data-oriented and renderer-independent.

## Files
- `field.rs`, `field_map.rs`, `cell.rs`: Field and cell storage.
- `category.rs`, `semantics.rs`, `modifier.rs`: Gameplay channels and modifiers.
- `line.rs`, `topology.rs`: Distances and line traversal.
- `reference.rs`, `catalog.rs`, `emitter.rs`, `limits.rs`: References, catalogs, light input, and limits.

## Rules
- Keep coordinates zero-based internally and convert at Lua boundaries.
- Do not depend on render, awareness, pathfind, minimap, raycaster, or tilelight.
- Keep channel semantics independent; never infer action from vision or movement from light.
- Apply `TileFieldLimits` before allocation, import, snapshot load, export, or large work. Check size products with `u64`.
- Imports and snapshot loads build a full valid replacement before changing a live field.
- Each successful change updates version and dirty state. Nested `beginEdit` must keep pending changes.
- `clear` removes live cell data but keeps category, modifier, and slot definitions.
- Store authored light facts only. `physics`, `light`, and `tilelight` own runtime results.

## Workflow
- Run `cargo test --test tilefield_tests` and tilefield Lua unit/security/stress tests.
