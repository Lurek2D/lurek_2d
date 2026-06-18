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

- The `animation` module is the engine's time-based motion system for users who need sprites, poses, and related visual states to advance through structured runtime playback.
- Clips, frames, controllers, state machines, sync groups, events, blending, and curve handling live together here so simple loops and richer motion behavior share one model.
- This matters because animation is not only frame stepping; it also needs transitions, timing hooks, authored state changes, and gameplay-aware playback control.
- Runtime events make the module useful beyond visuals, since footsteps, attack windows, cutscene timing, and other logic often need to fire from the animation timeline.
- Aseprite import and Spine bridging keep the feature aligned with common art pipelines instead of forcing everything into one internal-only format.
- Blend and sync-group support matter because animated systems often need continuity across states or coordinated playback across several visual parts instead of abrupt clip swaps.
- The module therefore works as both a playback layer and a timing surface for game logic that needs authored motion to remain inspectable and deterministic enough for tools and debugging.
- This is especially useful for gameplay-driven animation, where movement, combat, cutscene timing, and feedback effects all want to share the same authored motion surface instead of fighting several parallel playback hacks.
- `render` shows the result and `spine` specializes skeletal rigs, but `animation` owns clip selection, synchronization, transitions, and timeline advancement.
- Read `animation` as the owner of animation sequencing and playback semantics across the engine.


## Imports

- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `spine`: Imports or references `src/spine/`. Dependency stays inside `Feature Systems` and should remain acyclic.

## Files

### aseprite.rs

- This file owns Aseprite JSON parsing that turns sheet exports into frame rectangles, timing, and clip tags.
- `AsepriteParsed` stores normalized frame and tag metadata, while helpers validate numeric fields and layout.
- Import logic accepts array and object frame layouts, derives sheet size, and preserves deterministic ordering.
- Tag parsing normalizes forward, reverse, and ping-pong directions for later clip creation in the controller.
- Open it when authored import semantics change; runtime playback and rendering live in sibling animation files.

### blend.rs

- This file owns blend-layer data used to combine multiple animation clips into one ordered composite pose.
- `BlendMask` restricts layers to named bones, while `BlendLayer` stores clip name, weight, and mask state.
- `BlendLayerSet` centralizes ordered layer storage, uniqueness checks, weight changes, and mask replacement.
- It is data-oriented rather than evaluative, leaving actual pose mixing to downstream systems that consume layers.
- Open it when layer or mask semantics change; playback and render export live in sibling animation files.

### clip.rs

- This file owns clip metadata that names frame spans, default FPS, looping intent, and playback direction.
- `AnimClip` stores frame indices and policy, while `ClipPlaybackMode` selects forward, reverse, or ping-pong flow.
- Open it when authored clip semantics change; frame storage and live playback logic live in sibling files.

### controller.rs

- This file owns `Animation`, the runtime controller that stores frames, clips, timers, events, and blend state.
- It manages clip libraries, current clip selection, frame position, playback speed, pause state, and ping-pong flow.
- Frame builders load quads from grids, explicit rectangles, and parsed Aseprite metadata into one frame store.
- Clip registration validates frame references, FPS, looping, and playback mode before data enters runtime use.
- Update logic advances timers, applies frame-duration overrides, emits loop and finish events, and stops cleanly.
- Crossfade helpers capture outgoing quads and expose blend state so render-facing callers can mix transitions.
- Preview helpers draw the current frame or a grid of all frames into `ImageData` for tools and inspection paths.
- Render integration stays read-only here through current-quad sampling, leaving draw-command mapping to siblings.
- Open it when playback semantics change; clips, frames, imports, and FSM control all depend on this owner file.

### curve.rs

- This file owns numeric animation curves and sparse property timelines used to sample values over time.
- `AnimCurve` stores sorted keyframes plus easing, while `AnimPropertyTimeline` groups named property tracks.
- Evaluation helpers support stepped, linear, quadratic, and custom-id easing across arbitrary sample times.
- Timeline insertion backfills missing property values so snapshots remain defined across uneven keyframe sets.
- Sampling helpers return one property or all properties, making the file the owner of interpolation semantics.
- Open it when authored curve math changes; clip stepping and render export live in sibling animation files.

### event.rs

- This file owns `AnimEvent`, the playback signal set emitted when clips finish, loop, or advance frames.
- Helper accessors expose stable event names and optional frame indices for consumers reacting to timeline changes.
- Open it when animation event semantics change; the controller owns event emission and queue draining nearby.

### frame.rs

- This file owns `AnimFrame`, the minimal frame payload of source quad plus optional per-frame duration override.
- It keeps authored geometry and timing local so clips can reference frame data without duplicating rectangle state.
- Open it when frame payload semantics change; clip policy and playback progression live in sibling files.

### mod.rs

- This module is the animation index, re-exporting clips, frames, playback, curves, state control, and render glue.
- It is the navigation point for authored imports, runtime playback, event flow, blending, and synchronization.
- `controller.rs` owns the live playback controller, while `clip.rs` and `frame.rs` hold core timeline data.
- `curve.rs` and `state_machine.rs` cover property interpolation and condition-driven state transitions.
- `blend.rs` owns layer and mask data, while `render.rs` converts current quads into renderer draw commands.
- `aseprite.rs` imports authored sheets, `event.rs` defines playback signals, and `sync_group.rs` coordinates peers.
- `spine_bridge.rs` connects FSM state to Spine playback when that feature is enabled for the runtime build.
- Change this file when public animation exports move; change siblings when playback or import rules change.

### render.rs

- This file owns animation-to-render helpers that convert the current frame quad into renderer draw commands.
- `AnimRenderParams` bundles atlas and transform inputs, while helpers produce stable quad draw payloads.
- It reads current playback state without owning animation stepping, keeping visual export separate from timing.
- Open it when draw-command mapping changes; frame advancement and clip state live in the controller file.

### spine_bridge.rs

- This file owns the Spine bridge that maps animation FSM states onto skeleton clip playback and updates.
- It stores the owned skeleton, state-to-clip mappings, looping overrides, and the last applied FSM state.
- Update logic advances the FSM, swaps Spine clips on state changes, and refreshes world transforms each tick.
- Open it when Spine integration changes; generic animation state control lives in sibling subsystem files.

### state_machine.rs

- This file owns animation FSM control with typed parameters, parsed conditions, and clip-bound named states.
- `AnimStateMachine` stores states, transitions, params, and an owned `Animation` controller for visual output.
- Condition parsing and comparison helpers turn authored strings into executable numeric or boolean checks.
- Update logic advances the inner animation, then processes bounded transition chains from the current state.
- State changes immediately play destination clips and apply looping policy, keeping visuals aligned with graph flow.
- Open it when authored graph semantics change; low-level clip playback and frames live in sibling files.

### sync_group.rs

- This file owns `AnimSyncGroup`, the membership list used to keep multiple animation instances phase-aligned.
- It stores unique slotmap keys and exposes small mutation helpers so synchronization systems share one contract.
- Open it when coordination-group semantics change; actual playback state and stepping live in sibling files.



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

## References

- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `spine`: Imports or references `src/spine/`. Dependency stays inside `Feature Systems` and should remain acyclic.

## Notes

- No additional module-specific notes.
