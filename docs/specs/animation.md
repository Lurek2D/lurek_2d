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

- Use `lurek.animation` when runtime animation needs to be controlled as a system, not frame swapping.
- The module turns authored timelines into deterministic playback and transition behavior.
- It supports frame clips, state-machine switching, blend layers, and Spine bridging in one API.
- Clip sources include grid slicing, explicit frame rectangles, and Aseprite JSON imports.
- Imported durations, tags, and clip metadata map directly to runtime controllers.
- Playback supports loop, reverse, ping-pong, pause, restart, and one-shot modes.
- Timeline milestones emit events for gameplay synchronization points.
- This makes animation useful for combat timing, effects, and state transitions, not only visuals.
- State-machine control supports named states and parameter-driven transition rules.
- Crossfades smooth clip handoffs and preserve readability during fast state changes.
- Blend layers allow multiple animation streams to compose into one result.
- Bone masks support partial-body overrides like upper-body aim and additive reactions.
- Curves provide keyed numeric animation beyond sprite frames.
- Interpolation modes include stepped, linear, eased, and custom callback-driven easing.
- Sync groups keep multiple instances phase-aligned for crowds and linked props.
- The module owns playback, transition governance, blending, import normalization, and frame sampling.
- It collaborates with image/render/runtime/spine, but animation state policy lives here.
- Use it when animation must be authorable, queryable, synchronized, and blendable at runtime.

This module primarily collaborates with `image`, `math`, `render`, `runtime`, `spine`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `spine`: Imports or references `src/spine/`. Dependency stays inside `Feature Systems` and should remain acyclic.

## Files

### aseprite.rs

- Parses Aseprite export data into engine-ready frame geometry, timing, and clip-tag metadata. `animation/aseprite` delivers the aseprite implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports multiple JSON frame layout variants while enforcing deterministic playback ordering. The file owns or coordinates data contracts including `AsepriteFrameData`, `AsepriteDirection`, `AsepriteTagData`, `AsepriteParsed`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Validates structural assumptions early so malformed exports fail before runtime animation usage. Public callable behavior is centered on `load_aseprite_json`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Extracts frame rectangles and durations into normalized data consumable by controller pipelines. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### blend.rs

- Implements layered animation blending where multiple clip outputs combine into one final pose. `animation/blend` delivers the blend implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Applies per-layer influence weights to shape how strongly each source contributes over time. The file owns or coordinates data contracts including `BlendMask`, `BlendLayer`, `BlendLayerSet`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports optional bone masks for partial-body mixing without disturbing unrelated motion regions. Public callable behavior is centered on no named public items, while method-level behavior such as `all`, `from_bones`, `includes`, `new`, `len`, `is_empty`, and 7 more stays attached to the local data model and invariants.
- Maintains ordered layer stacking so blend precedence stays explicit and predictable. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### clip.rs

- Defines reusable animation clip metadata over frame spans, playback direction, and loop policy. `animation/clip` delivers the clip implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### controller.rs

- Implements the central frame-animation runtime that owns clips, frames, cursor state, and event flow. `animation/controller` delivers the controller implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Advances playback through forward, reverse, ping-pong, looped, and paused progression modes. The file owns or coordinates data contracts including `Animation`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Applies speed scaling and transition blending so timing and clip handoff remain artistically controllable. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_frame`, `add_frames_from_grid`, `add_frames_from_rects`, `add_clip`, `add_clip_with_mode`, and 26 more stays attached to the local data model and invariants.
- Builds runtime clip libraries from grids, explicit frame data, and imported authoring metadata. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `math`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Emits timeline events for frame changes and lifecycle boundaries to drive gameplay synchronization. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Exposes current frame sampling for render-facing systems that require stable quad lookup each tick. The file boundary separates animation implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### curve.rs

- Implements keyframed property timelines that interpolate numeric animation parameters over time. `animation/curve` delivers the curve implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports stepped, linear, eased, and callback-defined transitions for authored motion behavior. The file owns or coordinates data contracts including `EasingKind`, `AnimCurve`, `AnimPropertyTimeline`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Evaluates sparse named tracks into sampled property values at arbitrary timeline positions. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `with_easing`, `add_keyframe`, `keyframe_count`, `clear`, `eval`, and 3 more stays attached to the local data model and invariants.
- Provides both single-property reads and full snapshot sampling for synchronized consumers. Runtime integration reaches sibling engine areas through crate modules `math`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Keeps interpolation semantics explicit so authored curves remain predictable across runtime contexts. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### event.rs

- Defines the event payload contract emitted by animation playback state transitions. `animation/event` delivers the event implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Captures completion, loop, and frame-change signals as stable timeline reaction points. The file owns or coordinates data contracts including `AnimEvent`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Serves gameplay and scripting systems that listen to animation progression milestones. Public callable behavior is centered on no named public items, while method-level behavior such as `type_name`, `frame_index` stays attached to the local data model and invariants.

### frame.rs

- Defines the minimal frame payload of source rectangle and optional per-frame timing override. `animation/frame` delivers the frame implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### mod.rs

- Defines the animation module boundary that unifies playback, blending, transitions, and render bridging. `animation/mod` is the animation module index, declaring `aseprite`, `blend`, `clip`, `controller`, `curve`, and 6 more so agents can identify which files own each feature slice before opening implementation code.
- Groups import, curve, event, sync, and state-control subsystems into one coherent runtime surface. `src/animation/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `aseprite::{ load_aseprite_json, AsepriteDirection, AsepriteFrameData, AsepriteParsed, AsepriteTagData, }`, `blend::{BlendLayer, BlendLayerSet, BlendMask}`, `clip::{AnimClip, ClipPlaybackMode}`, `controller::Animation`, and 7 more centralized for the animation subsystem.
- Keeps frame-based and bridge-based animation features accessible through a consistent composition root. The file documents how animation submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- Serves as the high-level integration entry for character animation behavior in engine runtime. Agents should read this index to choose the narrow owner file first, because it maps names such as `aseprite`, `blend`, `clip`, `controller`, `curve`, and 6 more to concrete implementation responsibilities.
- `animation/mod` is the animation module index, declaring `aseprite`, `blend`, `clip`, `controller`, `curve`, and 6 more so agents can identify which files own each feature slice before opening implementation code.
- `src/animation/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `aseprite::{ load_aseprite_json, AsepriteDirection, AsepriteFrameData, AsepriteParsed, AsepriteTagData, }`, `blend::{BlendLayer, BlendLayerSet, BlendMask}`, `clip::{AnimClip, ClipPlaybackMode}`, `controller::Animation`, and 7 more centralized for the animation subsystem.

### render.rs

- Converts active animation frame state into renderer-ready textured draw command payloads. `animation/render` delivers the rendering adapter and draw-command integration for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Bundles atlas identity and transform inputs so frame sampling maps cleanly to render execution. The file owns or coordinates data contracts including `AnimRenderParams`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Keeps rendering adaptation lightweight while preserving consistent frame-to-visual translation. Public callable behavior is centered on `quad_to_draw_command`, while method-level behavior such as `generate_render_command` stays attached to the local data model and invariants.

### spine_bridge.rs

- Bridges animation state-machine transitions to Spine clip playback through explicit state mapping. `animation/spine_bridge` delivers the spine bridge implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Owns skeleton progression and transform refresh so Spine output remains time-synchronized. The file owns or coordinates data contracts including `SpineAnimBridge`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Keeps external state changes aligned with internal skeleton animation updates each frame. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `map`, `map_looping`, `update`, `skeleton`, `skeleton_mut`, and 2 more stays attached to the local data model and invariants.

### state_machine.rs

- Implements animation finite-state control with typed parameters and condition-driven transitions. `animation/state_machine` delivers the state machine implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Evaluates transition rules each frame to move between clip-bound states deterministically. The file owns or coordinates data contracts including `AnimParamValue`, `ConditionOp`, `ConditionValue`, `TransitionCondition`, `AnimTransition`, and 2 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Parses authored condition expressions into executable checks used during state progression. Public callable behavior is centered on `compare_nums`, `parse_condition`, while method-level behavior such as `new`, `add_state`, `add_transition`, `set_param_float`, `set_param_bool`, `set_param_int`, and 6 more stays attached to the local data model and invariants.
- Activates destination clips immediately on state change to keep visual intent synchronized. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Provides parameterized graph control for expressive authored animation behavior. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### sync_group.rs

- Defines synchronization groups for animation instances that must maintain shared playback phase. `animation/sync_group` delivers the sync group implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Tracks unique membership so timing alignment stays stable across coordinated animated entities. The file owns or coordinates data contracts including `AnimSyncGroup`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Serves as lightweight grouping state for systems that enforce multi-entity animation sync. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add`, `remove`, `clear`, `member_count`, `members` stays attached to the local data model and invariants.



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
