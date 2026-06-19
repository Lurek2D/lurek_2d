# spine

## TL;DR

- Simulates skeletal rigs using bone hierarchies, slots, skin swaps, and target IK.

## General Info

- Module group: `Feature Systems`
- Source path: `src/spine/`
- Binding: `src/lua_api/spine_api.rs`
- Namespace: `lurek.spine`
- Lua API surface: `4` functions, `5` types, `34` methods
- Rust test path(s): tests/rust/unit/spine_tests.rs
- Lua test path(s): tests/lua/unit/test_spine_core_unit.lua

## Summary

- The `spine` module is the skeletal-animation surface for users who want bone-based rigs, slots, skins, and timeline-driven pose changes inside the engine.
- Bones, IK constraints, importers, skeleton state, slots, timelines, and render bridges work together so the same module can load authored rigs, pose them at runtime, and expose the result to the rest of the visual stack.
- That matters because skeletal animation is more than playback: projects also need skin changes, attachment control, hierarchy updates, and pose solving that stay coherent across several animation clips.
- Import support makes the module practical for authored content workflows, while runtime skeleton control keeps it useful for gameplay-driven animation changes after import.
- Runtime events, attachment swaps, and skin changes are especially important because skeletal content often needs to react to equipment, status, or scripted actions without reauthoring the rig itself.
- Constraint solving is a major part of the value, because believable skeletal motion often depends on live bone relationships rather than on clip playback alone.
- That keeps imported rigs flexible at runtime.
- Read `spine` as the owner of skeletal rig state and timeline evaluation.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### bone.rs

- This file owns `Bone`, the transform-bearing unit that stores one rig node's local pose and resolved world pose.
- It keeps parent linkage, local translation, rotation, scale, and accumulated world-space outputs in one record.
- Constructors cover root and child bones so importer and runtime code can build hierarchies without extra defaults.
- Open this file when bone transform payloads change; skeleton playback and rendering live in sibling owners.

### ik.rs

- This file owns `IKConstraint`, the two-bone inverse-kinematics solver used to aim short chains at a target.
- It stores chain indices, target position, and bend direction so procedural posing can complement keyed clips.
- `solve` uses law-of-cosines geometry to update root and elbow local rotations when referenced bones exist.
- This is the right owner for elbow-up versus elbow-down behavior or target-solving semantics across skeletal rigs.
- Open this file when IK math changes; timeline sampling and skeleton playback state live in siblings.

### importer.rs

- This file owns Spine and DragonBones JSON import for the skeletal runtime, turning payloads into `Skeleton` data.
- It defines `SpineImportError` plus parsing for bones, slots, skins, animations, and event channels across both formats.
- Bone and slot parsing resolve names into indices so the runtime receives parent-linked rigs instead of loose strings.
- Animation parsing maps translate, rotate, scale, and event data into `SkeletonAnimation` timelines with stable units.
- DragonBones and Spine variants share helpers for numeric extraction, duration handling, and error reporting.
- The importer rejects malformed or unsupported structures early so asset issues fail before runtime playback.
- This file is the boundary between third-party skeletal data formats and engine-owned rig, clip, and skin structures.
- Open this file when supported JSON schema or import policy changes; runtime skeleton behavior lives in siblings.

### mod.rs

- This module re-exports the spine subsystem surface for bones, slots, timelines, IK, import, and rendering.
- It keeps navigation explicit by mapping which sibling files own transform hierarchy, clip timing, import, or drawing.
- Public exports here route callers toward `Skeleton` as the runtime owner and importer functions for asset loading.
- `bone.rs`, `slot.rs`, and `ik.rs` hold the core rig pieces, while `timeline.rs` owns keyframe evaluation semantics.
- `skeleton.rs` coordinates playback and pose updates, and `render.rs` turns posed rigs into engine draw commands.
- Change this file when the public spine symbol map moves; change siblings when rig behavior or data rules change.

### render.rs

- This file owns the draw-command bridge that turns a posed `Skeleton` into generic debug render commands.
- It flattens bone transforms and slot attachments into circles and outlines for a skeleton-agnostic renderer.
- The output favors readable rig structure over full attachment rendering, making it useful for tooling and inspection.
- Open this file when skeleton-to-command translation changes; pose updates and slot ownership live in siblings.

### skeleton.rs

- This file owns `Skeleton`, the main runtime container for bones, slots, animations, IK constraints, skins, and playback.
- It stores root transform, pose arrays, registered clips, skin mappings, and current animation state in one owner.
- Helpers add or find bones and slots, switch skins, start or stop animations, and expose attachment or pose queries.
- Animation updates sample timelines here, then IK solving and hierarchy traversal recompute the final world-space pose.
- World transform updates require parent-before-child order, making this file the owner of pose propagation invariants.
- Debug image helpers live here so rig tuning can inspect the same live structure that gameplay and rendering use.
- Open this file when skeletal runtime semantics change; importer parsing and draw-command translation live in siblings.

### slot.rs

- This file owns `Slot`, the attachment record that links drawable content and tint state to one skeleton bone.
- It stores slot identity, bone index, tint channels, optional attachment name, and draw-order intent for the rig.
- Open this file when attachment payloads change; bone transforms and skeleton playback coordination live in siblings.

### timeline.rs

- This file owns the keyframe system for skeletal animation, including easing curves, events, timelines, and clips.
- It stores sorted keys per bone property and evaluates them into sampled values so every clip shares one timing model.
- `BoneTimeline` interpolates translation, rotation, and scale, while `EasingType` defines the curve between keys.
- `SkeletonAnimation` groups timelines plus event markers, then applies, blends, reverses, or serializes pose data.
- Event collection and pose snapshots live here so runtime playback and tooling can inspect the same temporal model.
- This file is the timing boundary between imported animation data and mutable bone fields on a live skeleton.
- Open this file when clip sampling semantics change; skeleton state and importer parsing live in sibling owners.



## Lua API Ref

### Functions

- `lurek.spine.animationFromJson(json) -> LSkeletonAnimation`: Parses a JSON string into a SkeletonAnimation. Returns nil if parsing fails or the format is invalid.
- `lurek.spine.newSkeleton(name) -> LSkeleton`: Creates a new empty skeleton with the given name. Add bones and slots to build the hierarchy.
- `lurek.spine.newSkeletonAnimation(name, duration) -> LSkeletonAnimation`: Creates a new empty animation with the given name and duration. Add keyframes to define motion.
- `lurek.spine.skeletonFromJson(json) -> LSkeleton`: Parses a Spine or DragonBones JSON string into a full runtime skeleton.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LSkeleton Type

- Lua-facing skeleton object providing bone hierarchy, slots, IK, skins, and animation playback.

##### Fields

- No documented fields.

##### Methods

- `LSkeleton:addAnimation(anim) -> nil`: Registers a SkeletonAnimation object with this skeleton so it can be played by name.
- `LSkeleton:addBone(name, opts?) -> integer`: Adds a root-level bone to the skeleton with optional transform properties.
- `LSkeleton:addChildBone(name, parent_idx, opts?) -> integer`: Adds a bone as a child of an existing bone, inheriting its parent's world transform.
- `LSkeleton:addIKConstraint(name, chain, bend_positive?) -> integer`: Adds an inverse-kinematics constraint that controls a chain of bones to reach a target position.
- `LSkeleton:addSkin(name) -> nil`: Registers a new named skin on this skeleton. Skins remap slot attachments for visual variants.
- `LSkeleton:addSlot(name, bone_idx, attachment?) -> integer`: Adds a slot attached to a specific bone, optionally assigning a default attachment name.
- `LSkeleton:blendAnimation(anim, time, blend_weight?) -> nil`: Blends an animation pose onto the skeleton at a given time with a weight factor for smooth transitions.
- `LSkeleton:boneCount() -> integer`: Returns the total number of bones in the skeleton.
- `LSkeleton:drawToImage(w, h) -> LImageData`: Renders the skeleton into an in-memory image of the given dimensions and returns it as LImageData userdata.
- `LSkeleton:findBone(name) -> integer`: Searches for a bone by name and returns its zero-based index, or nil if not found.
- `LSkeleton:findSlot(name) -> integer`: Searches for a slot by name and returns its zero-based index, or nil if not found.
- `LSkeleton:getAnimationTime() -> number`: Returns the current playback time of the active animation in seconds.
- `LSkeleton:getBoneWorld(idx) -> table`: Returns the final world-space transform of a bone after hierarchy resolution.
- `LSkeleton:getSkin() -> string`: Returns the name of the currently active skin, or nil if no skin is set.
- `LSkeleton:playAnimation(name, looping?) -> boolean`: Starts playing a named animation on this skeleton. Optionally loops.
- `LSkeleton:setIKTarget(name, x, y) -> boolean`: Sets the world-space target position for a named IK constraint. Call updateWorldTransforms after.
- `LSkeleton:setPosition(x, y) -> nil`: Sets the root bone world position, shifting the entire skeleton.
- `LSkeleton:setSkin(name) -> boolean`: Activates a named skin, applying its slot-attachment mappings to the skeleton.
- `LSkeleton:setSkinMapping(skin, slot, attachment) -> nil`: Maps a slot to a specific attachment name within a skin. When that skin is active, the slot shows this attachment.
- `LSkeleton:slotCount() -> integer`: Returns the total number of slots in the skeleton.
- `LSkeleton:stopAnimation() -> nil`: Stops the currently playing animation and resets playback state.
- `LSkeleton:type() -> string`: Returns the type name of this userdata object.
- `LSkeleton:typeOf(name) -> boolean`: Checks whether this object is of the given type name. Supports "LSkeleton" and "Object".
- `LSkeleton:updateAnimation(dt) -> nil`: Advances the current animation by a delta time, applying bone transforms to the skeleton.
- `LSkeleton:updateWorldTransforms() -> nil`: Recomputes world transforms for all bones in hierarchy order. Call after modifying bone locals or IK targets.

#### LSkeletonAnimation Type

- Lua-facing animation object containing bone timelines, keyframes, events, and easing curves.

##### Fields

- No documented fields.

##### Methods

- `LSkeletonAnimation:addEventKey(time, name, value?) -> nil`: Inserts an event trigger at a specific time within the animation timeline.
- `LSkeletonAnimation:addKeyframe(bone_idx, property, time, value, easing?) -> nil`: Adds a keyframe to a bone's property timeline at a specific time with a value and easing curve.
- `LSkeletonAnimation:getDuration() -> number`: Returns the total duration of this animation in seconds.
- `LSkeletonAnimation:getEvents(from, to) -> table`: Collects all events that fire within a time range. Useful for triggering sound effects or gameplay actions.
- `LSkeletonAnimation:getTimelineCount() -> integer`: Returns the number of bone-property timelines in this animation.
- `LSkeletonAnimation:poseAt(time) -> table`: Samples all timelines at a given time and returns the computed pose as an array of bone-property-value entries.
- `LSkeletonAnimation:reverse() -> LSkeletonAnimation`: Creates a new animation that plays this animation's keyframes in reverse order.
- `LSkeletonAnimation:type() -> string`: Returns the type name of this userdata object.
- `LSkeletonAnimation:typeOf(name) -> boolean`: Checks whether this object is of the given type name. Supports "LSkeletonAnimation" and "Object".

#### LSkeletonAnimationGetEventsResult Type

- Generated result shape from @field tags.

##### Fields

- `name` (`string`): Event name.
- `value` (`number`): Event value.

##### Methods

- No documented methods.

#### LSkeletonAnimationPoseAtResult Type

- Generated result shape from @field tags.

##### Fields

- `bone_idx` (`integer`): Bone index.
- `property` (`string`): Property name.
- `value` (`number`): Property value.

##### Methods

- No documented methods.

#### LSkeletonGetBoneWorldResult Type

- Generated result shape from @field tags.

##### Fields

- `rotation` (`number`): Rotation in degrees.
- `scale_x` (`number`): Horizontal scale.
- `scale_y` (`number`): Vertical scale.
- `x` (`number`): X position.
- `y` (`number`): Y position.

##### Methods

- No documented methods.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
