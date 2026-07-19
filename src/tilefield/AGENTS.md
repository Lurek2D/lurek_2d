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
- `TileFieldLimits` bounds dense cells, map products, levels, categories, modifiers, slots, regions, refs, dirty rectangles, provider rows, snapshot entries, and stored string lengths. Check `u64` products before allocation.
- Provider imports and Lua snapshot restores build/validate replacement state before swapping it into a live field; failed restore leaves the original field unchanged.
- Every successful mutation increments version and dirty state. Dirty cells coalesce and fall back to a bounded coarse level rectangle; `beginEdit` is nested and does not discard pending changes.
- `clear` resets cells, regions, occupants, resources, and buildability while retaining category/modifier/slot definitions. Occupant id `0` means empty; missing buildability is `true`; empty resource labels are absent.
- Tilefield stores authored environmental light metadata only. Runtime physics body creation belongs to `physics`; render light/occluder creation belongs to `light`. The legacy tilefield aliases are compatibility shims during migration.
- Hostile-input coverage belongs in `tests/lua/security/test_tilefield_security.lua` and large bounded mutations belong in the tilefield stress suite.

## Workflow
- Validate with `cargo test --test tilefield_tests` and Lua tilefield unit coverage.
