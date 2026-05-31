# animation

## TL;DR

- Orchestrates sprite animation playback and processes Aseprite JSON imports.
- Manages parameter state networks with crossfading and Spine skeletons.
- Controls layered weighted blending, keyframe curves, and phase sync.

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

## Imports

- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `spine`: Imports or references `src/spine/`. Dependency stays inside `Feature Systems` and should remain acyclic.

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

### Functions

- `lurek.animation.buildCharacter(cfg) -> table`: Builds a character animation bundle from grid frame and clip configuration.
- `lurek.animation.fromAseprite(json_str) -> LuaValue`: Loads an animation from an Aseprite JSON export string.
- `lurek.animation.new() -> LAnimation`: Creates an empty animation with no frames or clips.
- `lurek.animation.newBlendLayerSet() -> LBlendLayerSet`: Creates an empty blend layer set for layered animation playback.
- `lurek.animation.newCurve() -> LAnimCurve`: Creates an empty animation curve. This function is exposed to Lua scripts.
- `lurek.animation.newStateMachine(anim_ud, initial) -> LAnimStateMachine`: Creates an animation state machine by consuming an animation handle.
- `lurek.animation.newSyncGroup() -> LAnimSyncGroup`: Creates an empty animation synchronization group.

### Callbacks

- `LAnimCurve:setCustomEasing` param `func` (`function`): Function used as custom easing callback, or nil to clear custom easing.

### Enums

- No documented module-level enums/constants.

### Types

#### LAnimCurve Type

- Lua-side animation curve with keyframes and optional custom easing callback.

##### Fields

- No documented fields.

##### Methods

- `LAnimCurve:addKeyframe(t, v) -> nil`: Adds a keyframe to the curve. This method is available to Lua scripts.
- `LAnimCurve:clear() -> nil`: Removes all keyframes from this curve.
- `LAnimCurve:eval(t) -> number`: Evaluates the curve at a time or normalized position.
- `LAnimCurve:keyframeCount() -> integer`: Returns the number of keyframes stored in this curve.
- `LAnimCurve:setCustomEasing(func) -> nil`: Sets or clears a Lua callback used to evaluate custom easing.
- `LAnimCurve:setEasing(mode) -> nil`: Sets the built-in easing mode used between keyframes.
- `LAnimCurve:type() -> string`: Returns the Lua-visible type name for this animation curve handle.
- `LAnimCurve:typeOf(name) -> boolean`: Returns whether this animation curve handle matches a supported type name.

#### LAnimStateMachine Type

- Lua-side animation state machine that switches clips from named states and parameters.

##### Fields

- No documented fields.

##### Methods

- `LAnimStateMachine:addState(name, clip, looping) -> nil`: Adds a state that plays a named animation clip.
- `LAnimStateMachine:addTransition(from_state, to_state, condition) -> nil`: Adds a named-condition transition between two animation states.
- `LAnimStateMachine:draw(image?, x?, y?, opts?) -> boolean`: Draws the current state-machine animation frame without advancing playback.
- `LAnimStateMachine:forceState(name) -> boolean`: Forces the state machine into a named state.
- `LAnimStateMachine:getQuad() -> LuaValue`: Returns the current frame rectangle from the state machine's owned animation.
- `LAnimStateMachine:getState() -> string`: Returns the current animation state name.
- `LAnimStateMachine:setImage(image) -> nil`: Stores a spritesheet image on this state machine so draw can be called without an explicit image argument.
- `LAnimStateMachine:setParam(name, value) -> nil`: Sets a boolean, integer, or numeric state machine parameter.
- `LAnimStateMachine:type() -> string`: Returns the Lua-visible type name for this animation state machine handle.
- `LAnimStateMachine:typeOf(name) -> boolean`: Returns whether this animation state machine handle matches a supported type name.
- `LAnimStateMachine:update(dt) -> nil`: Advances the animation state machine and its owned animation playback.

#### LAnimSyncGroup Type

- Lua-side animation synchronization group for coordinating multiple animation handles.

##### Fields

- No documented fields.

##### Methods

- `LAnimSyncGroup:add(handle) -> nil`: Adds an animation-like handle to the sync group.
- `LAnimSyncGroup:clear() -> nil`: Removes all members from the sync group.
- `LAnimSyncGroup:memberCount() -> integer`: Returns the number of handles tracked by the sync group.
- `LAnimSyncGroup:remove(handle) -> nil`: Removes an animation-like handle from the sync group.
- `LAnimSyncGroup:type() -> string`: Returns the Lua-visible type name for this animation sync group handle.
- `LAnimSyncGroup:typeOf(name) -> boolean`: Returns whether this animation sync group handle matches a supported type name.

#### LAnimation Type

- Lua-side animation object containing frame rectangles, named clips, playback state, and blend state.

##### Fields

- No documented fields.

##### Methods

- `LAnimation:addClip(name, indices_tbl, fps, looping, mode?) -> nil`: Adds a named clip using existing frame indices.
- `LAnimation:addClipFromGrid(name, tw, th, fw, fh, start, count, fps, looping) -> nil`: Adds frames from a texture grid and creates a clip that references the new frames.
- `LAnimation:addFrame(x, y, w, h) -> integer`: Adds one frame rectangle to this animation.
- `LAnimation:addFramesFromGrid(tw, th, fw, fh, start, count) -> integer`: Adds frames by slicing a texture grid.
- `LAnimation:addFramesFromRects(rects) -> integer`: Adds frames from an array of rectangle tables.
- `LAnimation:crossfade(clip_name, duration) -> boolean`: Starts a crossfade from the current clip to another clip.
- `LAnimation:draw(image?, x?, y?, opts?) -> boolean`: Draws the current animation frame without advancing playback.
- `LAnimation:drawPreviewGrid(columns, cell_size) -> LImageData`: Rasterizes all animation frames into a preview grid image.
- `LAnimation:drawToImage(w, h) -> LImageData`: Rasterizes the current animation frame into an image userdata.
- `LAnimation:getBlendState() -> LuaValue`: Returns current crossfade rectangles and blend factor when a crossfade is active.
- `LAnimation:getClip() -> LuaValue`: Returns the current clip name when a clip is active.
- `LAnimation:getClipCount() -> integer`: Returns the number of named clips stored in this animation.
- `LAnimation:getClipMode(name) -> LuaValue`: Returns the playback mode name for a clip when it exists.
- `LAnimation:getCurrentFrame() -> integer`: Returns the current frame index. This method is available to Lua scripts.
- `LAnimation:getFrameCount() -> integer`: Returns the number of frame rectangles stored in this animation.
- `LAnimation:getQuad() -> LuaValue`: Returns the current frame rectangle as a table.
- `LAnimation:getSpeed() -> number`: Returns the animation playback speed multiplier.
- `LAnimation:isLooping() -> boolean`: Returns whether the current clip loops.
- `LAnimation:isPlaying() -> boolean`: Returns whether this animation is currently playing.
- `LAnimation:pause() -> nil`: Pauses animation playback without changing the current clip.
- `LAnimation:play(name) -> boolean`: Starts playback of a named clip. This method is available to Lua scripts.
- `LAnimation:pollEvents() -> table`: Drains animation events produced since the previous poll.
- `LAnimation:resume() -> nil`: Resumes playback of a paused animation.
- `LAnimation:setClipMode(name, mode) -> boolean`: Changes the playback mode for an existing clip.
- `LAnimation:setFrame(index) -> nil`: Sets the current frame index directly.
- `LAnimation:setImage(image) -> nil`: Stores a spritesheet image on this animation so draw can be called without an explicit image argument.
- `LAnimation:setSpeed(speed) -> nil`: Sets the animation playback speed multiplier.
- `LAnimation:stop() -> nil`: Stops playback and resets animation playback state.
- `LAnimation:type() -> string`: Returns the Lua-visible type name for this animation handle.
- `LAnimation:typeOf(name) -> boolean`: Returns whether this animation handle matches a supported type name.
- `LAnimation:update(dt) -> nil`: Advances animation playback and records any frame or clip events.

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

- `LBlendLayerSet:addLayer(name, clip_name, weight, bones?) -> boolean`: Adds a weighted animation blend layer with an optional bone mask.
- `LBlendLayerSet:getWeight(name) -> LuaValue`: Returns the weight for a blend layer when it exists.
- `LBlendLayerSet:len() -> integer`: Returns the number of blend layers.
- `LBlendLayerSet:listLayers() -> table`: Returns all blend layers with names, clip names, weights, and bone masks.
- `LBlendLayerSet:removeLayer(name) -> boolean`: Removes a blend layer by name. This method is available to Lua scripts.
- `LBlendLayerSet:setMask(name, bones) -> boolean`: Replaces a layer bone mask from a table of bone names.
- `LBlendLayerSet:setWeight(name, weight) -> boolean`: Sets the blend weight for an existing layer.
- `LBlendLayerSet:type() -> string`: Returns the Lua-visible type name for this blend layer set handle.
- `LBlendLayerSet:typeOf(name) -> boolean`: Returns whether this blend layer set handle matches a supported type name.

#### LBlendLayerSetListLayersResult Type

- Generated result shape from @field tags.

##### Fields

- `bones` (`string[]`): Bone mask names.
- `clip_name` (`string`): Clip name.
- `name` (`string`): Layer name.
- `weight` (`number`): Blend weight.

##### Methods

- No documented methods.
