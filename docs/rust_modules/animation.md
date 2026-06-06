# animation

## General Info

- Module group: `Feature Systems`
- Source path: `src/animation/`
- Binding: `src/lua_api/animation_api.rs`
- Namespace: `lurek.animation`
- Lua API surface: `7` functions, `8` types, `65` methods
- Rust test path(s): tests/rust/unit/animation_tests.rs
- Lua test path(s): tests/lua/unit/test_animation.lua, tests/lua/stress/test_animation_stress.lua, tests/lua/integration/test_tween_animation.lua, tests/lua/integration/test_render_animation.lua, tests/lua/integration/test_animation_timer.lua, tests/lua/golden/test_animation_golden.lua

## Summary

The animation module provides a complete control and playback layer for sprite-based and skeletal animations. It acts as the import and execution pipeline for asset files, translating grid layouts, manual rectangles, and Aseprite JSON metadata into optimized runtime clips. The frame-animation engine supports diverse playback behaviors, including loop, reverse, ping-pong, and one-shot progression, while scaling speeds dynamically.

To coordinate character states, the module implements a parameter-driven animation state machine. This framework permits organizers to arrange individual clips into state networks, governing transitions using parameter checks and timeline triggers. Transitions are softened by automated crossfades that calculate blend states and transition weights, preventing visual jerks and ensuring fluid behavior across state boundaries.

For complex movements, the module features a layered animation blending architecture. Multiple clip streams can combine dynamically using ordered layering, stacking weights, and custom bone masks that restrict blend influences to specific skeletal sub-regions. Skeletal animations are supported by a Spine integration bridge that keeps skeleton hierarchies and coordinate transformations synchronized with state transitions.

Coordinated elements can be grouped into synchronization groups to enforce identical playback phases across entities. Additionally, the system provides standalone parameter curves that interpolate values over keyframed timelines using stepped, linear, or custom ease callbacks. These systems bridge abstract timing states with textured coordinates, generating render-ready draw payloads for visual execution.

## Files

### [aseprite.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/aseprite.rs)

- Parses Aseprite export data into engine-ready frame geometry, timing, and clip-tag metadata.
- Supports multiple JSON frame layout variants while enforcing deterministic playback ordering.
- Validates structural assumptions early so malformed exports fail before runtime animation usage.
- Extracts frame rectangles and durations into normalized data consumable by controller pipelines.
- Serves as the import boundary between external authoring output and internal animation contracts.

### [blend.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/blend.rs)

- Implements layered animation blending where multiple clip outputs combine into one final pose.
- Applies per-layer influence weights to shape how strongly each source contributes over time.
- Supports optional bone masks for partial-body mixing without disturbing unrelated motion regions.
- Maintains ordered layer stacking so blend precedence stays explicit and predictable.
- Serves as the composition core for expressive multi-source character animation behavior.

### [clip.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/clip.rs)

- Defines reusable animation clip metadata over frame spans, playback direction, and loop policy.
- Carries baseline timing settings that playback systems use when frame durations are unspecified.
- Serves as a compact contract shared by controller, state-machine, and blend-layer orchestration.

### [controller.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/controller.rs)

- Implements the central frame-animation runtime that owns clips, frames, cursor state, and event flow.
- Advances playback through forward, reverse, ping-pong, looped, and paused progression modes.
- Applies speed scaling and transition blending so timing and clip handoff remain artistically controllable.
- Builds runtime clip libraries from grids, explicit frame data, and imported authoring metadata.
- Emits timeline events for frame changes and lifecycle boundaries to drive gameplay synchronization.
- Exposes current frame sampling for render-facing systems that require stable quad lookup each tick.
- Maintains deterministic update behavior so identical input timing yields identical playback state.
- Supports preview and inspection flows used by tools and debugging overlays.
- Keeps clip selection, event buffering, and cursor mutation within one cohesive control surface.
- Serves as the primary animation execution engine for sprite and timeline-driven characters.

### [curve.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/curve.rs)

- Implements keyframed property timelines that interpolate numeric animation parameters over time.
- Supports stepped, linear, eased, and callback-defined transitions for authored motion behavior.
- Evaluates sparse named tracks into sampled property values at arbitrary timeline positions.
- Provides both single-property reads and full snapshot sampling for synchronized consumers.
- Keeps interpolation semantics explicit so authored curves remain predictable across runtime contexts.
- Serves as the parameter animation layer beneath higher-level state and clip orchestration.

### [event.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/event.rs)

- Defines the event payload contract emitted by animation playback state transitions.
- Captures completion, loop, and frame-change signals as stable timeline reaction points.
- Serves gameplay and scripting systems that listen to animation progression milestones.

### [frame.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/frame.rs)

- Defines the minimal frame payload of source rectangle and optional per-frame timing override.
- Supports clip timing fallback by allowing zero-duration frames to inherit clip-level FPS behavior.
- Serves as the shared frame unit across import, playback, preview, and rendering pathways.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/mod.rs)

- Defines the animation module boundary that unifies playback, blending, transitions, and render bridging.
- Groups import, curve, event, sync, and state-control subsystems into one coherent runtime surface.
- Keeps frame-based and bridge-based animation features accessible through a consistent composition root.
- Serves as the high-level integration entry for character animation behavior in engine runtime.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/render.rs)

- Converts active animation frame state into renderer-ready textured draw command payloads.
- Bundles atlas identity and transform inputs so frame sampling maps cleanly to render execution.
- Keeps rendering adaptation lightweight while preserving consistent frame-to-visual translation.
- Serves as the bridge between animation runtime output and command-stream based rendering.

### [spine_bridge.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/spine_bridge.rs)

- Bridges animation state-machine transitions to Spine clip playback through explicit state mapping.
- Owns skeleton progression and transform refresh so Spine output remains time-synchronized.
- Keeps external state changes aligned with internal skeleton animation updates each frame.
- Serves as the integration layer between engine animation logic and Spine runtime evaluation.

### [state_machine.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/state_machine.rs)

- Implements animation finite-state control with typed parameters and condition-driven transitions.
- Evaluates transition rules each frame to move between clip-bound states deterministically.
- Parses authored condition expressions into executable checks used during state progression.
- Activates destination clips immediately on state change to keep visual intent synchronized.
- Provides parameterized graph control for expressive authored animation behavior.
- Serves as the transition-governance layer above raw clip playback execution.

### [sync_group.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/animation/sync_group.rs)

- Defines synchronization groups for animation instances that must maintain shared playback phase.
- Tracks unique membership so timing alignment stays stable across coordinated animated entities.
- Serves as lightweight grouping state for systems that enforce multi-entity animation sync.
