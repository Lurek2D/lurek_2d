# animation

## General Info

- Module group: `Feature Systems`
- Source path: `src/animation/`
- Lua API path(s): `src/lua_api/animation_api.rs`
- Primary Lua namespace: `lurek.animation`
- Rust test path(s): tests/rust/unit/animation_tests.rs
- Lua test path(s): tests/lua/unit/test_animation.lua, tests/lua/stress/test_animation_stress.lua, tests/lua/integration/test_tween_animation.lua, tests/lua/integration/test_graphics_animation.lua, tests/lua/integration/test_animation_timer.lua, tests/lua/golden/test_animation_golden.lua

## Summary

The animation module owns frame-based sprite playback. It stores reusable frame definitions, named clips, playback state, speed control, and emitted animation events while staying independent from scene ownership, textures, and gameplay rules.

This module exists to answer one narrow question well: given frames and clips, which frame should be active now and what events should fire as playback advances. Rendering integration lives in helper methods that turn the current frame into render-command data, but the module does not own GPU work, sprite assets, or non-frame-based animation systems such as tweening or skeletal animation.

**Scope boundary**: This module currently depends on `math`, `render`, `runtime`. It stays within the Feature Systems responsibility boundary defined in the architecture docs.

## Files

- `clip.rs`: Defines AnimClip, the named sequence of frame indices with clip FPS and looping behavior.
- `controller.rs`: Defines Animation, the main playback controller for frames, clips, speed, current state, and pending events.
- `event.rs`: Defines AnimEvent, the event enum emitted for frame changes, loops, and completion.
- `frame.rs`: Defines AnimFrame plus the AnimationFrame compatibility alias.
- `mod.rs`: Declares the animation submodules and re-exports the public frame, clip, controller, event, and render parameter types.
- `render.rs`: Converts the current animation frame into renderer-facing DrawQuad command data.

## Types

- `AnimClip` (`struct`, `clip.rs`): Named ordered frame sequence with clip-local FPS and looping configuration.
- `Animation` (`struct`, `controller.rs`): Main playback controller that owns frames, clips, speed, timers, and pending events.
- `AnimEvent` (`enum`, `event.rs`): Playback event enum used to report frame changes, loops, and finished clips.
- `AnimFrame` (`struct`, `frame.rs`): One source rectangle plus an optional per-frame duration override.
- `AnimationFrame` (`type`, `frame.rs`): Backward-compatible alias for [`AnimFrame`].
- `AnimRenderParams` (`struct`, `render.rs`): Caller-supplied texture and transform bundle used when generating render commands.

## Functions

- `Animation::new` (`controller.rs`): Creates a new, empty animation with no frames or clips.
- `Animation::add_frame` (`controller.rs`): Adds a single frame and returns its 0-based index.
- `Animation::add_frames_from_grid` (`controller.rs`): Slices a sprite-sheet grid into frames and appends them.
- `Animation::add_clip` (`controller.rs`): Registers a named clip.
- `Animation::add_clip_from_grid` (`controller.rs`): Convenience method: adds grid-sliced frames then creates a clip referencing them.
- `Animation::play` (`controller.rs`): Starts playing a clip by name.
- `Animation::stop` (`controller.rs`): Stops playback and resets to frame 0.
- `Animation::pause` (`controller.rs`): Pauses playback at the current frame.
- `Animation::resume` (`controller.rs`): Resumes playback from the current frame.
- `Animation::update` (`controller.rs`): Advances the animation by `dt` seconds (scaled by [`speed`](Self::get_speed)).
- `Animation::current_quad` (`controller.rs`): Returns the source rectangle of the current frame, or `None` if no clip is active or the frame pool is empty.
- `Animation::current_frame` (`controller.rs`): Returns the current position within the active clip's frame list (0-based).
- `Animation::get_current_clip` (`controller.rs`): Returns the name of the currently active clip, if any.
- `Animation::is_playing` (`controller.rs`): Returns `true` if the animation is currently playing.
- `Animation::is_looping` (`controller.rs`): Returns `true` if the current clip is set to loop.
- `Animation::get_speed` (`controller.rs`): Returns the playback speed multiplier.
- `Animation::set_speed` (`controller.rs`): Sets the playback speed multiplier.
- `Animation::get_frame_count` (`controller.rs`): Returns the total number of frames in the animation's frame pool.
- `Animation::get_clip_count` (`controller.rs`): Returns the number of registered clips.
- `Animation::drain_events` (`controller.rs`): Returns and clears all pending animation events.
- `Animation::set_frame` (`controller.rs`): Sets the playback position within the current clip.
- `AnimEvent::type_name` (`event.rs`): Returns the event type as a Lua-friendly string.
- `AnimEvent::frame_index` (`event.rs`): Returns the frame index for `FrameChanged` events, or `None`.
- `Animation::generate_render_command` (`render.rs`): Produces a single `DrawQuad` render command for the current frame.
- `quad_to_draw_command` (`render.rs`): Converts a source quad and render parameters into a `DrawQuad` command.

## Lua API Reference

- Binding path(s): `src/lua_api/animation_api.rs`
- Namespace: `lurek.animation`

### Module Functions
- `lurek.animation.new`: Creates a new, empty Animation controller.

### `Animation` Methods
- `Animation:addFrame`: Adds a single frame to the frame pool by source rectangle.
- `Animation:addFramesFromGrid`: Slices a sprite-sheet grid into frames and appends them.
- `Animation:addClip`: Adds a named clip from explicit frame indices.
- `Animation:addClipFromGrid`: Adds a named clip sliced from a sprite-sheet grid.
- `Animation:play`: Starts playback of the named clip.
- `Animation:stop`: Stops playback and resets to frame 0.
- `Animation:pause`: Pauses playback at the current frame.
- `Animation:resume`: Resumes playback from the current frame.
- `Animation:update`: Advances the animation by dt seconds.
- `Animation:getQuad`: Returns the source quad (x, y, w, h) for the current frame, or nil.
- `Animation:pollEvents`: Drains and returns all pending animation events as a table.
- `Animation:isPlaying`: Returns true if a clip is currently playing.
- `Animation:isLooping`: Returns true if the current clip is set to loop.
- `Animation:getClip`: Returns the name of the currently playing clip, or nil.
- `Animation:getSpeed`: Returns the playback speed multiplier.
- `Animation:setSpeed`: Sets the playback speed multiplier.
- `Animation:getFrameCount`: Returns the total number of frames in the frame pool.
- `Animation:getClipCount`: Returns the number of registered clips.
- `Animation:getCurrentFrame`: Returns the current position within the active clip (0-based).
- `Animation:setFrame`: Sets the playback position within the current clip.

## References

- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/animation/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
