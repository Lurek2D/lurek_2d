# animation

## TL;DR

- The `animation` module provides a comprehensive sprite and skeletal animation runtime for Lurek2D, managing frame sequences, blend layers, parameter-driven state machines, and synchronization groups.

## General Info

- Module group: `Feature Systems`
- Source path: `src/animation/`
- Lua API path(s): `src/lua_api/animation_api.rs`
- Primary Lua namespace: `lurek.animation`
- Rust test path(s): tests/rust/unit/animation_tests.rs
- Lua test path(s): tests/lua/unit/test_animation.lua, tests/lua/stress/test_animation_stress.lua, tests/lua/integration/test_tween_animation.lua, tests/lua/integration/test_render_animation.lua, tests/lua/integration/test_animation_timer.lua, tests/lua/golden/test_animation_golden.lua

## Summary

At its core, the module uses `AnimClip` to hold ordered sequences of `AnimFrame` entries, each specifying a source texture rectangle, an optional per-frame duration, and event triggers. This allows for both uniform and variable-timing animations. Playback is managed by the `Animation` controller, which handles forward, reverse, and ping-pong playback modes, along with looping and playback speed scaling.

To support complex character and entity animations, the module implements a robust `AnimStateMachine`. This finite-state machine (FSM) drives transitions between named animation clips based on configurable conditions. Transitions can evaluate float, integer, and boolean parameters using standard relational operators, enabling logic like switching from a 'running' state to a 'jumping' state when a velocity parameter exceeds a threshold. Furthermore, `BlendLayerSet` provides support for multi-layer additive and override mixing, allowing multiple animations to be combined—for instance, playing a 'shooting' animation on the upper body while a 'running' animation plays on the lower body.

For coordinated character movement and advanced timing, the `AnimSyncGroup` locks multiple animation keyframes to a shared normalized timeline. The module also includes `AnimCurve` and `AnimPropertyTimeline` to support easing-driven value interpolation along keyframes. These curves evaluate properties over time using step, linear, or custom easing functions, which are heavily utilized by higher-level animation systems to drive parameters smoothly.

The module offers seamless integration with external tools and formats. An Aseprite JSON importer (`load_aseprite_json`) parses exported frame tags into named clip ranges, supporting both array and object layouts while extracting per-frame durations. Additionally, a `SpineAnimBridge` maps the module's FSM states to Spine skeleton animations, allowing 2D skeletal animations to be controlled through the same uniform interface.

Finally, the module generates textured draw commands from active frame quads via the `render` utilities, tightly integrating with the engine's graphics pipeline. Lua bindings expose `LAnimation:draw` and `LAnimStateMachine:draw` as ergonomic helpers over the same current-frame rectangle returned by `getQuad`; these helpers queue one draw command when a frame is active, return `false` without mutating playback when no frame is active, and leave broader `lurek.render.draw` polymorphism unchanged. Both `:draw` methods accept two call forms: `draw(image, x, y, opts)` for explicit atlas passing and `draw(x, y, opts)` when a spritesheet has been stored in advance with `:setImage(image)`. The API is thoroughly exposed to Lua via the `lurek.animation` namespace, providing script developers with constructors for state machines, curves, blend layers, and synchronization groups, along with methods to advance playback and poll animation events. By importing only the `math` module and avoiding cyclic dependencies, the animation runtime remains fully headless-testable and architecturally isolated within the Feature Systems group.

## Files

### aseprite.rs

- Parses Aseprite export data into engine-ready frame geometry, timing, and clip-tag metadata.
- Supports multiple JSON frame layout variants while enforcing deterministic playback ordering.
- Validates structural assumptions early so malformed exports fail before runtime animation usage.
- Extracts frame rectangles and durations into normalized data consumable by controller pipelines.
- Serves as the import boundary between external authoring output and internal animation contracts.

### blend.rs

- Implements layered animation blending where multiple clip outputs combine into one final pose.
- Applies per-layer influence weights to shape how strongly each source contributes over time.
- Supports optional bone masks for partial-body mixing without disturbing unrelated motion regions.
- Maintains ordered layer stacking so blend precedence stays explicit and predictable.
- Serves as the composition core for expressive multi-source character animation behavior.

### clip.rs

- Defines reusable animation clip metadata over frame spans, playback direction, and loop policy.
- Carries baseline timing settings that playback systems use when frame durations are unspecified.
- Serves as a compact contract shared by controller, state-machine, and blend-layer orchestration.

### controller.rs

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

### curve.rs

- Implements keyframed property timelines that interpolate numeric animation parameters over time.
- Supports stepped, linear, eased, and callback-defined transitions for authored motion behavior.
- Evaluates sparse named tracks into sampled property values at arbitrary timeline positions.
- Provides both single-property reads and full snapshot sampling for synchronized consumers.
- Keeps interpolation semantics explicit so authored curves remain predictable across runtime contexts.
- Serves as the parameter animation layer beneath higher-level state and clip orchestration.

### event.rs

- Defines the event payload contract emitted by animation playback state transitions.
- Captures completion, loop, and frame-change signals as stable timeline reaction points.
- Serves gameplay and scripting systems that listen to animation progression milestones.

### frame.rs

- Defines the minimal frame payload of source rectangle and optional per-frame timing override.
- Supports clip timing fallback by allowing zero-duration frames to inherit clip-level FPS behavior.
- Serves as the shared frame unit across import, playback, preview, and rendering pathways.

### mod.rs

- Defines the animation module boundary that unifies playback, blending, transitions, and render bridging.
- Groups import, curve, event, sync, and state-control subsystems into one coherent runtime surface.
- Keeps frame-based and bridge-based animation features accessible through a consistent composition root.
- Serves as the high-level integration entry for character animation behavior in engine runtime.

### render.rs

- Converts active animation frame state into renderer-ready textured draw command payloads.
- Bundles atlas identity and transform inputs so frame sampling maps cleanly to render execution.
- Keeps rendering adaptation lightweight while preserving consistent frame-to-visual translation.
- Serves as the bridge between animation runtime output and command-stream based rendering.

### spine_bridge.rs

- Bridges animation state-machine transitions to Spine clip playback through explicit state mapping.
- Owns skeleton progression and transform refresh so Spine output remains time-synchronized.
- Keeps external state changes aligned with internal skeleton animation updates each frame.
- Serves as the integration layer between engine animation logic and Spine runtime evaluation.

### state_machine.rs

- Implements animation finite-state control with typed parameters and condition-driven transitions.
- Evaluates transition rules each frame to move between clip-bound states deterministically.
- Parses authored condition expressions into executable checks used during state progression.
- Activates destination clips immediately on state change to keep visual intent synchronized.
- Provides parameterized graph control for expressive authored animation behavior.
- Serves as the transition-governance layer above raw clip playback execution.

### sync_group.rs

- Defines synchronization groups for animation instances that must maintain shared playback phase.
- Tracks unique membership so timing alignment stays stable across coordinated animated entities.
- Serves as lightweight grouping state for systems that enforce multi-entity animation sync.

## Lua API Ref

- Binding: `src/lua_api/animation_api.rs`
- Namespace: `lurek.animation`

### Functions

- `lurek.animation.buildCharacter`: Builds a character animation bundle from grid frame and clip configuration.
- `lurek.animation.fromAseprite`: Loads an animation from an Aseprite JSON export string.
- `lurek.animation.new`: Creates an empty animation with no frames or clips.
- `lurek.animation.newBlendLayerSet`: Creates an empty blend layer set for layered animation playback.
- `lurek.animation.newCurve`: Creates an empty animation curve. This function is exposed to Lua scripts.
- `lurek.animation.newStateMachine`: Creates an animation state machine by consuming an animation handle.
- `lurek.animation.newSyncGroup`: Creates an empty animation synchronization group.

### Enums

- No documented module-level enums/constants.

### Types

#### LAnimCurve Type

- Lua-side animation curve with keyframes and optional custom easing callback.

##### Fields

- No documented fields.

##### Methods

- `LAnimCurve:addKeyframe`: Adds a keyframe to the curve. This method is available to Lua scripts.
- `LAnimCurve:clear`: Removes all keyframes from this curve.
- `LAnimCurve:eval`: Evaluates the curve at a time or normalized position.
- `LAnimCurve:keyframeCount`: Returns the number of keyframes stored in this curve.
- `LAnimCurve:setCustomEasing`: Sets or clears a Lua callback used to evaluate custom easing.
- `LAnimCurve:setEasing`: Sets the built-in easing mode used between keyframes.
- `LAnimCurve:type`: Returns the Lua-visible type name for this animation curve handle.
- `LAnimCurve:typeOf`: Returns whether this animation curve handle matches a supported type name.

#### LAnimStateMachine Type

- Lua-side animation state machine that switches clips from named states and parameters.

##### Fields

- No documented fields.

##### Methods

- `LAnimStateMachine:addState`: Adds a state that plays a named animation clip.
- `LAnimStateMachine:addTransition`: Adds a named-condition transition between two animation states.
- `LAnimStateMachine:draw`: Draws the current state-machine animation frame without advancing playback.
- `LAnimStateMachine:forceState`: Forces the state machine into a named state.
- `LAnimStateMachine:getQuad`: Returns the current frame rectangle from the state machine's owned animation.
- `LAnimStateMachine:getState`: Returns the current animation state name.
- `LAnimStateMachine:setImage`: Stores a spritesheet image on this state machine so draw can be called without an explicit image argument.
- `LAnimStateMachine:setParam`: Sets a boolean, integer, or numeric state machine parameter.
- `LAnimStateMachine:type`: Returns the Lua-visible type name for this animation state machine handle.
- `LAnimStateMachine:typeOf`: Returns whether this animation state machine handle matches a supported type name.
- `LAnimStateMachine:update`: Advances the animation state machine and its owned animation playback.

#### LAnimSyncGroup Type

- Lua-side animation synchronization group for coordinating multiple animation handles.

##### Fields

- No documented fields.

##### Methods

- `LAnimSyncGroup:add`: Adds an animation-like handle to the sync group.
- `LAnimSyncGroup:clear`: Removes all members from the sync group.
- `LAnimSyncGroup:memberCount`: Returns the number of handles tracked by the sync group.
- `LAnimSyncGroup:remove`: Removes an animation-like handle from the sync group.
- `LAnimSyncGroup:type`: Returns the Lua-visible type name for this animation sync group handle.
- `LAnimSyncGroup:typeOf`: Returns whether this animation sync group handle matches a supported type name.

#### LAnimation Type

- Lua-side animation object containing frame rectangles, named clips, playback state, and blend state.

##### Fields

- No documented fields.

##### Methods

- `LAnimation:addClip`: Adds a named clip using existing frame indices.
- `LAnimation:addClipFromGrid`: Adds frames from a texture grid and creates a clip that references the new frames.
- `LAnimation:addFrame`: Adds one frame rectangle to this animation.
- `LAnimation:addFramesFromGrid`: Adds frames by slicing a texture grid.
- `LAnimation:addFramesFromRects`: Adds frames from an array of rectangle tables.
- `LAnimation:crossfade`: Starts a crossfade from the current clip to another clip.
- `LAnimation:draw`: Draws the current animation frame without advancing playback.
- `LAnimation:drawPreviewGrid`: Rasterizes all animation frames into a preview grid image.
- `LAnimation:drawToImage`: Rasterizes the current animation frame into an image userdata.
- `LAnimation:getBlendState`: Returns current crossfade rectangles and blend factor when a crossfade is active.
- `LAnimation:getClip`: Returns the current clip name when a clip is active.
- `LAnimation:getClipCount`: Returns the number of named clips stored in this animation.
- `LAnimation:getClipMode`: Returns the playback mode name for a clip when it exists.
- `LAnimation:getCurrentFrame`: Returns the current frame index. This method is available to Lua scripts.
- `LAnimation:getFrameCount`: Returns the number of frame rectangles stored in this animation.
- `LAnimation:getQuad`: Returns the current frame rectangle as a table.
- `LAnimation:getSpeed`: Returns the animation playback speed multiplier.
- `LAnimation:isLooping`: Returns whether the current clip loops.
- `LAnimation:isPlaying`: Returns whether this animation is currently playing.
- `LAnimation:pause`: Pauses animation playback without changing the current clip.
- `LAnimation:play`: Starts playback of a named clip. This method is available to Lua scripts.
- `LAnimation:pollEvents`: Drains animation events produced since the previous poll.
- `LAnimation:resume`: Resumes playback of a paused animation.
- `LAnimation:setClipMode`: Changes the playback mode for an existing clip.
- `LAnimation:setFrame`: Sets the current frame index directly.
- `LAnimation:setImage`: Stores a spritesheet image on this animation so draw can be called without an explicit image argument.
- `LAnimation:setSpeed`: Sets the animation playback speed multiplier.
- `LAnimation:stop`: Stops playback and resets animation playback state.
- `LAnimation:type`: Returns the Lua-visible type name for this animation handle.
- `LAnimation:typeOf`: Returns whether this animation handle matches a supported type name.
- `LAnimation:update`: Advances animation playback and records any frame or clip events.

#### LAnimationBuildCharacterResult Type

- Generated result shape from @field tags.

##### Fields

- `animation` (`LAnimation`): Animation handle.
- `stateMachine` (`LStateMachine`): State machine handle.

##### Methods

- No documented methods.

#### LAnimationPollEventsResult Type

- Generated result shape from @field tags.

##### Fields

- `frame` (`integer?`): Frame index when available.
- `type` (`string`): Event type name.

##### Methods

- No documented methods.

#### LBlendLayerSet Type

- Lua-side blend layer set used to combine animation clips with weights and bone masks.

##### Fields

- No documented fields.

##### Methods

- `LBlendLayerSet:addLayer`: Adds a weighted animation blend layer with an optional bone mask.
- `LBlendLayerSet:getWeight`: Returns the weight for a blend layer when it exists.
- `LBlendLayerSet:len`: Returns the number of blend layers.
- `LBlendLayerSet:listLayers`: Returns all blend layers with names, clip names, weights, and bone masks.
- `LBlendLayerSet:removeLayer`: Removes a blend layer by name. This method is available to Lua scripts.
- `LBlendLayerSet:setMask`: Replaces a layer bone mask from a table of bone names.
- `LBlendLayerSet:setWeight`: Sets the blend weight for an existing layer.
- `LBlendLayerSet:type`: Returns the Lua-visible type name for this blend layer set handle.
- `LBlendLayerSet:typeOf`: Returns whether this blend layer set handle matches a supported type name.

#### LBlendLayerSetListLayersResult Type

- Generated result shape from @field tags.

##### Fields

- `bones` (`string[]`): Bone mask names.
- `clip_name` (`string`): Clip name.
- `name` (`string`): Layer name.
- `weight` (`number`): Blend weight.

##### Methods

- No documented methods.

## References

- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `spine`: Imports or references `src/spine/`. Dependency stays inside `Feature Systems` and should remain acyclic.
