# spine

## General Info

- Module group: `Feature Systems`
- Source path: `src/spine/`
- Feature gate: `spine`
- Binding: `src/lua_api/spine_api.rs`
- Namespace: `lurek.spine`
- Lua API surface: `4` functions, `5` types, `34` methods
- Rust test path(s): tests/rust/unit/spine_tests.rs
- Lua test path(s): tests/lua/unit/test_spine_core_unit.lua
- Bench path(s): benches/spine_update_world_transforms.rs

## Summary

This module provides a skeletal animation runtime for 2D assets, offering pose-driven movement through hierarchies of bones and slots. Bones carry local transform offsets that propagate down parent-child chains to resolve world-space positions. To achieve organic, procedural responsiveness alongside keyframed animations, the system implements an inverse-kinematics solver that constrains joint angles toward target positions with controllable bend directions.

Skins and slots isolate visual assets from bone hierarchies. Slots are attached directly to bones to manage layering and draw order, letting sprites swap dynamically. Skins group slot mappings to switch visual variants on a single skeletal rig. Playback advances through sampled timelines, interpolating values with smooth or stepped curves while triggering timeline event markers.

Per-frame pose updates are designed to avoid cloning full animation or IK constraint objects in runtime hot paths. Animation sampling and IK solving operate on borrowed indexed data, so update loops scale with rig size without extra heap churn from repeated structural clones.

The module is available only when the `spine` feature is enabled. That feature gate applies to the Rust module, Lua bindings, and the dedicated `spine_update_world_transforms` benchmark that tracks hierarchy-update cost for the public `updateWorldTransforms` path.

The module also integrates rendering and diagnostic layers. It flattens rig poses into generic draw commands, letting the renderer paint attachments without skeleton awareness. The system parses standard Spine and DragonBones JSON rig files (bones, slots, skins, and basic timelines) and provides software visualizers that render skeleton linkages to CPU images for debug inspection.

Current public behavior is covered through the Lua-facing spine test suite, including construction, hierarchy updates, animation playback helpers, and render-adjacent debug outputs, while the benchmark focuses specifically on steady-state world-transform recomputation.

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
- The module is compiled only behind the `spine` feature gate, matching the optional nature of skeletal runtime support.
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
- A dedicated no-harness benchmark measures repeated `update_world_transforms` runs against this hierarchy-update path.
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
