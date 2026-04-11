# spine

## General Info

- Module group: `Feature Systems.`
- Source path: `src/spine/`
- Lua API path(s): `src/lua_api/spine_api.rs`
- Primary Lua namespace: `lurek.spine`
- Rust test path(s): tests/rust/unit/spine_tests.rs
- Lua test path(s): tests/lua/unit/test_spine.lua

## Summary

The spine module owns skeletal 2D animation data for rigs that need parent-child transform propagation instead of frame-only sprite swaps. It exists so games can build a `Skeleton` from bones and slots, update world transforms deterministically, and query attachment points from Lua without exposing renderer internals.

Its core boundary is the bone graph and slot metadata: local transforms, parent indices, root transform state, and slot attachment records live here, while timeline playback, texture ownership, and final draw policy stay outside the module. The render helper in this directory is intentionally a debug-facing bridge that turns current skeleton state into simple draw commands rather than a full animation renderer.

**Scope boundary**: This module currently depends on `image`, `render`, `runtime`. It stays within the Feature Systems responsibility boundary defined in the architecture docs.

## Files

- `bone.rs`: Individual bone data with local transform input and cached world transform output.
- `mod.rs`: Module root and re-export surface for the public skeletal types.
- `render.rs`: Debug render-command generation for bones and slot attachment placeholders.
- `skeleton.rs`: Skeleton ownership, bone and slot management, transform propagation, and CPU image helpers.
- `slot.rs`: Slot data binding an attachment name, tint, and draw order to a bone index.

## Types

- `Bone` (`struct`, `bone.rs`): Single skeletal node with local transform fields and propagated world transform fields.
- `BoneParams` (`struct`, `skeleton.rs`): Convenience parameter bundle for creating bones in one call.
- `Skeleton` (`struct`, `skeleton.rs`): Top-level rig object that owns bones, slots, root transform state, and hierarchy updates.
- `Slot` (`struct`, `slot.rs`): Attachment record that binds a named visual slot to a specific bone.

## Functions

- `Bone::new` (`bone.rs`): Creates a new bone with identity local transform and no parent.
- `Bone::with_parent` (`bone.rs`): Creates a bone with a parent index and local offset.
- `Skeleton::generate_render_commands` (`render.rs`): Generate debug render commands for the skeleton at the given world position.
- `Skeleton::new` (`skeleton.rs`): Creates a new empty skeleton.
- `Skeleton::add_bone` (`skeleton.rs`): Adds a bone to the skeleton and returns its index.
- `Skeleton::add_slot` (`skeleton.rs`): Adds a slot to the skeleton and returns its index.
- `Skeleton::find_bone` (`skeleton.rs`): Finds a bone by name and returns its index.
- `Skeleton::find_slot` (`skeleton.rs`): Finds a slot by name and returns its index.
- `Skeleton::add_bone_full` (`skeleton.rs`): Creates and adds a bone with the given local transform in one call.
- `Skeleton::add_slot_full` (`skeleton.rs`): Creates and adds a slot with an optional attachment name in one call.
- `Skeleton::bone_world_transform` (`skeleton.rs`): Returns the world-space transform of the bone at the given index.
- `Skeleton::set_root_position` (`skeleton.rs`): Sets the root bone's local position and propagates world transforms.
- `Skeleton::bone_count` (`skeleton.rs`): Returns the number of bones in this skeleton.
- `Skeleton::slot_count` (`skeleton.rs`): Returns the number of slots in this skeleton.
- `Skeleton::update_world_transforms` (`skeleton.rs`): Propagates local transforms down the bone hierarchy to compute world transforms.
- `Skeleton::draw_to_image` (`skeleton.rs`): Renders the skeleton as a stick figure to an `ImageData`.
- `Skeleton::draw_bones_to_image` (`skeleton.rs`): Draw skeleton with colour-coded joints and bone labels.
- `Slot::new` (`slot.rs`): Creates a new slot bound to a bone with default white colour and no attachment.

## Lua API Reference

- Binding path(s): `src/lua_api/spine_api.rs`
- Namespace: `lurek.spine`

### Module Functions
- `lurek.spine.newSkeleton`: Creates a new empty skeleton with the given name.

### `Skeleton` Methods
- `Skeleton:addBone`: Adds a root bone with optional local transform and returns its index.
- `Skeleton:findBone`: Returns the index of the named bone, or nil if not found.
- `Skeleton:findSlot`: Returns the index of the named slot, or nil if not found.
- `Skeleton:updateWorldTransforms`: Propagates local transforms down the bone hierarchy to compute world positions.
- `Skeleton:getBoneWorld`: Returns the world-space transform of a bone as a table, or nil if out of range.
- `Skeleton:setPosition`: Sets the root bone position and propagates world transforms.
- `Skeleton:boneCount`: Returns the total number of bones.
- `Skeleton:slotCount`: Returns the total number of slots.
- `Skeleton:drawToImage`: Renders the skeleton as a stick-figure debug view into a new ImageData.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/spine/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
