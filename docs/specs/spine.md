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

- This file defines the skeletal bone unit that carries local pose data and resolved world transform state.
- Parent linkage is part of the model so chains of motion can propagate naturally through a hierarchy.
- The type exists as the core transform-bearing element for the rest of the spine animation system.
- It is where local intent becomes world-space pose context for attached visuals and constraints.

### ik.rs

- This file implements the focused inverse-kinematics solver used when a short bone chain should reach toward a target automatically.
- It computes joint angles from geometric constraints instead of relying only on keyed animation values.
- Bend direction is part of the constraint so mirrored or elbow-up versus elbow-down poses can be chosen intentionally.
- The file adds procedural responsiveness to otherwise keyframed skeletal motion.
- It is the module's compact answer to target-seeking limb behavior.

### mod.rs

- This module provides the engine's skeletal animation runtime built around bones, slots, timelines, constraints, and posed rendering support.
- It turns hierarchical transform animation into a reusable feature system for articulated 2D characters and props.
- At the highest level this is the subsystem that gives the engine pose-driven animation instead of only frame-swapped sprites.

### render.rs

- This file converts a posed skeleton into renderer-facing commands for debug or simplified skeletal visualization.
- Bone and slot state are flattened here into ordinary draw operations so the rest of the renderer does not need skeleton awareness.
- The output emphasizes readable structure over full attachment rendering complexity.
- It is the handoff layer from skeletal pose data to generic draw command streams.

### skeleton.rs

- This file implements the main skeleton container that holds the full moving rig, visual attachment points, animations, and runtime playback state.
- Bones and slots are managed together here because final pose evaluation must understand both transform hierarchy and attachment ownership.
- Animation playback advances in this file, including looping, clamping, blending, and application of sampled values onto the rig.
- Constraint solving and skin switching are also coordinated here so procedural adjustments and visual variants act on the same live structure.
- World transforms are recomputed in hierarchy order, which keeps every downstream query grounded in one authoritative pose.
- Debug drawing support is included because skeletal systems are much easier to tune when their invisible structure can be inspected directly.
- The file is therefore the runtime brain of the spine subsystem rather than a passive data container.
- It is where skeletal state becomes animated pose over time.

### slot.rs

- This file defines the slot concept that binds visible attachments to bones without making the bone itself a rendering record.
- Slots carry appearance and ordering intent so one skeleton can swap visuals or reorder layers without changing its transform hierarchy.
- The type is the visual attachment bridge between pose evaluation and rendered character parts.

### timeline.rs

- This file defines the animation timeline machinery that turns keyed values over time into sampled pose changes for a skeleton.
- Interpolation curves live here so motion can feel stepped, smooth, weighted, or otherwise shaped between authored keys.
- Bone-property timelines are stored and evaluated here because timing semantics should remain consistent across all clips.
- Event keyframes share the same temporal framework, which lets animation playback trigger gameplay or audio markers at controlled moments.
- Full animation clips are assembled from many timelines and can be sampled, blended, reversed, or parsed from serialized sources.
- The file is therefore the temporal logic center of the spine subsystem.
- It explains how authored motion unfolds, not just what a static pose looks like.

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

- Lua-facing skeleton object providing bone hierarchy, slots, IK, skins, and animation playback.

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

- Lua-facing animation object containing bone timelines, keyframes, events, and easing curves.

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
