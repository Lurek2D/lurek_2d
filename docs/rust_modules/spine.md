# spine

## General Info

- Module group: `Feature Systems`
- Source path: `src/spine/`
- Binding: `src/lua_api/spine_api.rs`
- Namespace: `lurek.spine`
- Lua API surface: `3` functions, `5` types, `34` methods
- Rust test path(s): tests/rust/unit/spine_tests.rs
- Lua test path(s): tests/lua/unit/test_spine.lua

## Summary

Moving beyond traditional frame-by-frame sprites, this module enables fluid, dynamic animations using hierarchical bone trees and slot-based attachments. Central to the system is the `Skeleton` struct, which maintains an ordered array of `Bone` elements. Each bone stores local transform properties (position, rotation, scale) and automatically computes accumulated world-space transforms as they propagate down the parent-child hierarchy. Visual representation is handled via `Slot` attachments, which bind graphical content—such as sprite regions, meshes, or bounding boxes—to specific bones with precise draw-order and blend-mode configurations, ensuring correct back-to-front rendering even in complex layered characters.

To achieve sophisticated, procedural motion, the module features a dedicated Inverse Kinematics (IK) system. The `IKConstraint` solver calculates the necessary joint rotations for a two-bone chain (e.g., an arm or leg) to reach a specific world-space target, vastly simplifying dynamic interactions like foot placement on uneven terrain or aiming weapons. The animation pipeline itself is driven by `SkeletonAnimation` clips, which organize multiple `BoneTimeline` and `SlotTimeline` sequences containing keyed property changes. The runtime efficiently interpolates between these keyframes using various easing curves (linear, stepped, bezier) and applies the resulting poses to the skeleton. Animations can be blended together using configurable weights, allowing for smooth transitions between states (like transitioning from a run cycle to a jump).

The module also supports extensive customization and event handling. The Skin system allows developers to group specific slot attachments into switchable visual sets, enabling character customization (e.g., changing armor or weapons) without duplicating the underlying animation rig. Furthermore, `EventKeyframe` markers can be embedded within timelines to trigger Lua callbacks at precise moments, perfect for syncing footstep audio or hit-box activation. Fully exposed through the `lurek.spine.*` API, this module provides the robust tooling necessary to bring complex, expressive, and interactive 2D characters to life.

## Files

### [bone.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/spine/bone.rs)

- This file defines the skeletal bone unit that carries local pose data and resolved world transform state.
- Parent linkage is part of the model so chains of motion can propagate naturally through a hierarchy.
- The type exists as the core transform-bearing element for the rest of the spine animation system.
- It is where local intent becomes world-space pose context for attached visuals and constraints.

### [ik.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/spine/ik.rs)

- This file implements the focused inverse-kinematics solver used when a short bone chain should reach toward a target automatically.
- It computes joint angles from geometric constraints instead of relying only on keyed animation values.
- Bend direction is part of the constraint so mirrored or elbow-up versus elbow-down poses can be chosen intentionally.
- The file adds procedural responsiveness to otherwise keyframed skeletal motion.
- It is the module's compact answer to target-seeking limb behavior.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/spine/mod.rs)

- This module provides the engine's skeletal animation runtime built around bones, slots, timelines, constraints, and posed rendering support.
- It turns hierarchical transform animation into a reusable feature system for articulated 2D characters and props.
- At the highest level this is the subsystem that gives the engine pose-driven animation instead of only frame-swapped sprites.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/spine/render.rs)

- This file converts a posed skeleton into renderer-facing commands for debug or simplified skeletal visualization.
- Bone and slot state are flattened here into ordinary draw operations so the rest of the renderer does not need skeleton awareness.
- The output emphasizes readable structure over full attachment rendering complexity.
- It is the handoff layer from skeletal pose data to generic draw command streams.

### [skeleton.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/spine/skeleton.rs)

- This file implements the main skeleton container that holds the full moving rig, visual attachment points, animations, and runtime playback state.
- Bones and slots are managed together here because final pose evaluation must understand both transform hierarchy and attachment ownership.
- Animation playback advances in this file, including looping, clamping, blending, and application of sampled values onto the rig.
- Constraint solving and skin switching are also coordinated here so procedural adjustments and visual variants act on the same live structure.
- World transforms are recomputed in hierarchy order, which keeps every downstream query grounded in one authoritative pose.
- Debug drawing support is included because skeletal systems are much easier to tune when their invisible structure can be inspected directly.
- The file is therefore the runtime brain of the spine subsystem rather than a passive data container.
- It is where skeletal state becomes animated pose over time.

### [slot.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/spine/slot.rs)

- This file defines the slot concept that binds visible attachments to bones without making the bone itself a rendering record.
- Slots carry appearance and ordering intent so one skeleton can swap visuals or reorder layers without changing its transform hierarchy.
- The type is the visual attachment bridge between pose evaluation and rendered character parts.

### [timeline.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/spine/timeline.rs)

- This file defines the animation timeline machinery that turns keyed values over time into sampled pose changes for a skeleton.
- Interpolation curves live here so motion can feel stepped, smooth, weighted, or otherwise shaped between authored keys.
- Bone-property timelines are stored and evaluated here because timing semantics should remain consistent across all clips.
- Event keyframes share the same temporal framework, which lets animation playback trigger gameplay or audio markers at controlled moments.
- Full animation clips are assembled from many timelines and can be sampled, blended, reversed, or parsed from serialized sources.
- The file is therefore the temporal logic center of the spine subsystem.
- It explains how authored motion unfolds, not just what a static pose looks like.
