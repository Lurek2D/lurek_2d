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

- Loads Aseprite JSON exports into engine animation metadata.
- Extracts sheet frame rectangles, per-frame durations, and sheet size.
- Parses frame tags into named clip ranges with forward, reverse, or ping-pong playback.
- Accepts both array and object `frames` layouts and normalizes object order into playback order.
- Validates required metadata fields and returns explicit parse errors when the export is incomplete.

### blend.rs

- Defines blend masks and named blend layers for multi-clip animation mixing.
- Stores per-layer clip assignment, clamped blend weight, and optional bone filtering.
- Manages an ordered layer set with add, remove, lookup, weight update, and mask replacement.
- Provides the layer data higher animation systems use to build partial-body or weighted blends.

### clip.rs

- Defines named animation clips as reusable frame-index ranges.
- Stores playback direction, looping state, and fallback FPS for clips that do not rely on per-frame timing.
- Gives higher animation systems a compact clip descriptor they can switch, reuse, and combine by name.

### controller.rs

- Owns the runtime animation player for frame-based clips.
- Stores loaded frames, named clips, active playback state, pending animation events, and crossfade state.
- Builds clip data from grids, explicit rectangles, and parsed Aseprite metadata.
- Advances playback with forward, reverse, and ping-pong modes, including looping, stopping, pausing, and speed scaling.
- Exposes the current quad, event drain, crossfade blend state, and simple preview images for the active frame set.

### curve.rs

- Defines keyed numeric curves and sparse multi-property timelines for animation data.
- Stores sorted keyframes for single values and named property tracks.
- Supports step, linear, ease-in, ease-out, ease-in-out, and callback-backed easing modes.
- Evaluates one curve, one property, or a full property snapshot at an arbitrary time.
- Provides the interpolation layer used by higher animation systems for parameter driving over time.

### event.rs

- Defines the animation events emitted while clip playback advances.
- Carries the state changes higher layers react to: finish, loop, and frame switch.
- Stores the optional frame index payload for frame-change notifications.
- Provides a stable event name and a small accessor surface for consumers of runtime playback events.

### frame.rs

- Defines the single-frame record used by the animation runtime to pair a source rectangle with optional per-frame timing.
- Keeps the minimal frame payload shared by clips, controllers, previews, and imported metadata.
- Preserves the older public alias so existing code can keep referring to the same frame type through its legacy name.

### mod.rs

- Provides frame-based sprite animation with clips, playback modes, and named events.
- Supports Aseprite JSON import, blend layers, property curves, and state machine transitions.
- Offers Spine skeleton bridge, sync groups, and render-command generation for active frames.
- Re-exports all primary types so dependents can import from `animation::` directly.

### render.rs

- Converts the current animation frame quad into a textured draw command.
- Stores atlas reference, position, rotation, and scale in `AnimRenderParams`.
- Provides a standalone `quad_to_draw_command` helper reusable outside the controller.

### spine_bridge.rs

- Bridges a Spine skeleton to an animation state machine via name mapping.
- Plays mapped Spine clips automatically when the FSM transitions to a new state.
- Owns the skeleton instance and advances its animation and world transforms each frame.
- Exposes read and write access to the skeleton and the last applied FSM state.

### state_machine.rs

- Implements a named-state animation FSM driven by typed parameters and parsed conditions.
- Registers states with clip bindings and transitions with string-based condition expressions.
- Evaluates transition chains each frame and force-plays the target clip on state change.
- Supports float, int, and bool parameters compared with standard relational operators.
- Provides the condition parser and numeric comparison utilities used by transition evaluation.

### sync_group.rs

- Groups animation slot-map keys that should stay synchronised during playback.
- Stores a deduplicated member list with add, remove, clear, and query operations.
- Provides the membership data higher systems use to align animation timers.

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


#### LBlendLayerSet Type


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

## References

- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `spine`: Imports or references `src/spine/`. Dependency stays inside `Feature Systems` and should remain acyclic.
