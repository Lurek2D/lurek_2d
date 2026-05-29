# spine

## TL;DR

- The `spine` module is an advanced Feature Systems tier component that provides a complete, high-performance runtime for 2D skeletal animation.

## General Info

- Module group: `Feature Systems`
- Source path: `src/spine/`
- Lua API path(s): `src/lua_api/spine_api.rs`
- Primary Lua namespace: `lurek.spine`
- Rust test path(s): tests/rust/unit/spine_tests.rs
- Lua test path(s): tests/lua/unit/test_spine.lua

## Summary

Moving beyond traditional frame-by-frame sprites, this module enables fluid, dynamic animations using hierarchical bone trees and slot-based attachments. Central to the system is the `Skeleton` struct, which maintains an ordered array of `Bone` elements. Each bone stores local transform properties (position, rotation, scale) and automatically computes accumulated world-space transforms as they propagate down the parent-child hierarchy. Visual representation is handled via `Slot` attachments, which bind graphical content—such as sprite regions, meshes, or bounding boxes—to specific bones with precise draw-order and blend-mode configurations, ensuring correct back-to-front rendering even in complex layered characters.

To achieve sophisticated, procedural motion, the module features a dedicated Inverse Kinematics (IK) system. The `IKConstraint` solver calculates the necessary joint rotations for a two-bone chain (e.g., an arm or leg) to reach a specific world-space target, vastly simplifying dynamic interactions like foot placement on uneven terrain or aiming weapons. The animation pipeline itself is driven by `SkeletonAnimation` clips, which organize multiple `BoneTimeline` and `SlotTimeline` sequences containing keyed property changes. The runtime efficiently interpolates between these keyframes using various easing curves (linear, stepped, bezier) and applies the resulting poses to the skeleton. Animations can be blended together using configurable weights, allowing for smooth transitions between states (like transitioning from a run cycle to a jump).

The module also supports extensive customization and event handling. The Skin system allows developers to group specific slot attachments into switchable visual sets, enabling character customization (e.g., changing armor or weapons) without duplicating the underlying animation rig. Furthermore, `EventKeyframe` markers can be embedded within timelines to trigger Lua callbacks at precise moments, perfect for syncing footstep audio or hit-box activation. Fully exposed through the `lurek.spine.*` API, this module provides the robust tooling necessary to bring complex, expressive, and interactive 2D characters to life.

## Files

### bone.rs

- Bone struct holding local and accumulated world-space transform.
- Parent-child hierarchy via optional parent index.
- Constructors for root bones and parented child bones.

### ik.rs

- Two-bone inverse-kinematics constraint for skeleton animation.
- Solves root and elbow rotations via law-of-cosines to reach a world-space target.
- Supports configurable bend direction (positive or negative).

### mod.rs

- Skeletal animation runtime: bones, slots, IK, timelines, and pose blending.
- Hierarchical bone transforms with parent-relative computation.
- Keyframe-driven animation clips with easing and interpolation.
- Skeleton-level render assembly converting posed bones to draw commands.

### render.rs

- Convert a Skeleton's bone and slot state into a flat list of RenderCommands.
- Draw bones as filled circles at world positions with slot-derived colors.
- Draw slot attachments as outline rectangles around their parent bone.

### skeleton.rs

- Skeleton struct holding bones, slots, animations, IK constraints, skins, and playback state.
- Bone and slot management: add, find by name, query world transforms.
- Animation playback: start/stop clips, advance time, loop or clamp at duration.
- IK constraint registration and per-frame solving against bone poses.
- Skin system: register skins, switch active skin, map attachments per slot.
- World-transform recomputation traversing bones in parent-before-child order.
- Debug visualization: rasterise skeleton bones and slot markers into ImageData.

### slot.rs

- Slot struct: named attachment point on a bone with RGBA tint and optional texture reference.
- Constructor defaults to white opaque colour, no attachment, and draw-order zero.
- Draw-order field drives back-to-front rendering when multiple slots share a bone.

### timeline.rs

- Easing curves (linear, quadratic in/out, step) for inter-keyframe interpolation.
- Keyframe storage and sorted insertion for bone property timelines.
- BoneTimeline evaluation with clamping and step-hold semantics.
- Event keyframes fired at specific animation times for Lua callback dispatch.
- SkeletonAnimation clip: multi-timeline playback, blending, reversal, and JSON parsing.

## Lua API Ref

- Binding: `src/lua_api/spine_api.rs`
- Namespace: `lurek.spine`

### Functions

- `lurek.spine.animationFromJson`: Parses a JSON string into a SkeletonAnimation. Returns nil if parsing fails or the format is invalid.
- `lurek.spine.newSkeleton`: Creates a new empty skeleton with the given name. Add bones and slots to build the hierarchy.
- `lurek.spine.newSkeletonAnimation`: Creates a new empty animation with the given name and duration. Add keyframes to define motion.

### Enums

- No documented module-level enums/constants.

### Types


#### LSkeleton Type


##### Fields

- No documented fields.

##### Methods

- `LSkeleton:addAnimation`: Registers a SkeletonAnimation object with this skeleton so it can be played by name.
- `LSkeleton:addBone`: Adds a root-level bone to the skeleton with optional transform properties.
- `LSkeleton:addChildBone`: Adds a bone as a child of an existing bone, inheriting its parent's world transform.
- `LSkeleton:addIKConstraint`: Adds an inverse-kinematics constraint that controls a chain of bones to reach a target position.
- `LSkeleton:addSkin`: Registers a new named skin on this skeleton. Skins remap slot attachments for visual variants.
- `LSkeleton:addSlot`: Adds a slot attached to a specific bone, optionally assigning a default attachment name.
- `LSkeleton:blendAnimation`: Blends an animation pose onto the skeleton at a given time with a weight factor for smooth transitions.
- `LSkeleton:boneCount`: Returns the total number of bones in the skeleton.
- `LSkeleton:drawToImage`: Renders the skeleton into an in-memory image of the given dimensions and returns it as LImageData userdata.
- `LSkeleton:findBone`: Searches for a bone by name and returns its zero-based index, or nil if not found.
- `LSkeleton:findSlot`: Searches for a slot by name and returns its zero-based index, or nil if not found.
- `LSkeleton:getAnimationTime`: Returns the current playback time of the active animation in seconds.
- `LSkeleton:getBoneWorld`: Returns the final world-space transform of a bone after hierarchy resolution.
- `LSkeleton:getSkin`: Returns the name of the currently active skin, or nil if no skin is set.
- `LSkeleton:playAnimation`: Starts playing a named animation on this skeleton. Optionally loops.
- `LSkeleton:setIKTarget`: Sets the world-space target position for a named IK constraint. Call updateWorldTransforms after.
- `LSkeleton:setPosition`: Sets the root bone world position, shifting the entire skeleton.
- `LSkeleton:setSkin`: Activates a named skin, applying its slot-attachment mappings to the skeleton.
- `LSkeleton:setSkinMapping`: Maps a slot to a specific attachment name within a skin. When that skin is active, the slot shows this attachment.
- `LSkeleton:slotCount`: Returns the total number of slots in the skeleton.
- `LSkeleton:stopAnimation`: Stops the currently playing animation and resets playback state.
- `LSkeleton:type`: Returns the type name of this userdata object.
- `LSkeleton:typeOf`: Checks whether this object is of the given type name. Supports "LSkeleton" and "Object".
- `LSkeleton:updateAnimation`: Advances the current animation by a delta time, applying bone transforms to the skeleton.
- `LSkeleton:updateWorldTransforms`: Recomputes world transforms for all bones in hierarchy order. Call after modifying bone locals or IK targets.


#### LSkeletonAnimation Type


##### Fields

- No documented fields.

##### Methods

- `LSkeletonAnimation:addEventKey`: Inserts an event trigger at a specific time within the animation timeline.
- `LSkeletonAnimation:addKeyframe`: Adds a keyframe to a bone's property timeline at a specific time with a value and easing curve.
- `LSkeletonAnimation:getDuration`: Returns the total duration of this animation in seconds.
- `LSkeletonAnimation:getEvents`: Collects all events that fire within a time range. Useful for triggering sound effects or gameplay actions.
- `LSkeletonAnimation:getTimelineCount`: Returns the number of bone-property timelines in this animation.
- `LSkeletonAnimation:poseAt`: Samples all timelines at a given time and returns the computed pose as an array of bone-property-value entries.
- `LSkeletonAnimation:reverse`: Creates a new animation that plays this animation's keyframes in reverse order.
- `LSkeletonAnimation:type`: Returns the type name of this userdata object.
- `LSkeletonAnimation:typeOf`: Checks whether this object is of the given type name. Supports "LSkeletonAnimation" and "Object".

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
