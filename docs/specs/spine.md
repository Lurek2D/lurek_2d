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
- Lua test path(s): tests/lua_reorg/unit/test_spine_core_unit.lua

## Summary

- This module gives users skeletal 2D animation with bones, slots, skins, and timeline playback.
- Bone hierarchies support pose propagation from local transforms to world-space outputs.
- Slot and skin systems separate rig structure from visual attachment variants.
- Timeline sampling supports smooth and stepped interpolation styles.
- Event keyframes support trigger points for gameplay or audio synchronization.
- IK constraints support target-driven limb posing with bend-direction control.
- Animation blending supports transition-friendly pose mixing.
- Runtime APIs support play, stop, seek-style updates, and clip management.
- JSON import support bridges Spine and DragonBones authored content into runtime rigs.
- Render conversion paths flatten pose data into draw-friendly outputs.
- Debug image generation helps inspect skeleton state and hierarchy behavior.
- Feature gating keeps module usage explicit for builds that need skeletal animation.
- The module is useful for character animation, articulated props, and procedural pose adjustments.
- For users, it centralizes rig playback and control without custom per-character math.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

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

### importer.rs

- Imports standard Spine and DragonBones JSON skeleton shapes into runtime Skeleton data.
- The importer focuses on common production fields for bones, slots, skins, and basic timelines.
- It intentionally rejects malformed or unsupported structures with explicit, stable errors.

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
