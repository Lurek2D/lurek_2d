# cinematic

## TL;DR

- Multi-track timeline system for orchestrating game sequences.
- Supports Tween, Camera, Audio, and Signal track types with frame-accurate scheduling.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/cinematic/`
- Binding: `src/lua_api/cinematic_api.rs`
- Namespace: `lurek.cinematic`
- Lua API surface: `2` functions, `2` types, `23` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): tests/lua/unit/test_cinematic_timeline_unit.lua

## Summary

- The cinematic module provides scriptable timelines for cutscenes and other authored sequences.
- It supports parallel tracks so motion, camera movement, audio, and signal events can progress together.
- Tween tracks animate Lua object properties over time with easing functions.
- Camera tracks move and zoom cameras along scripted paths.
- Audio tracks schedule music and sound effects with precise timing.
- Signal tracks fire named events at specific times for gameplay triggers and branching logic.
- Playback can be played, paused, seeked, looped, and branched through labels.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### cinematic_legacy.rs

- Legacy cut-based cinematic timeline.
- Provides backward compatibility for the simple cut-based API.
- New code should use CinematicTimeline from timeline.rs instead.

### mod.rs

- File: src/cinematic/mod.rs
- Cinematic engine module — pure Rust logic, no Lua dependencies.
- Provides two APIs:
- Legacy Cut-based timeline (Cinematic struct) for backward compatibility
- Modern multi-track timeline (CinematicTimeline) with Tween/Camera/Audio/Signal tracks
- Lua bindings live in `src/lua_api/cinematic_api.rs`.

### timeline.rs

- Cinematic timeline system with multi-track support.
- Provides a scriptable timeline of clips and tracks that can be played, paused, scrubbed, and looped.
- Supports Tween, Camera, Audio, and Signal track types with frame-accurate scheduling.
- Clips are applied in time order, and playback state is driven by update(dt) each frame.

## Lua API Ref

### Functions

- `lurek.cinematic.new() -> LCinematic`: Creates a new empty cinematic timeline handle (legacy cut-based API).
- `lurek.cinematic.newTimeline() -> LCinematicTimeline`: Creates a new multi-track timeline for modern cinematic support.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LCinematic Type

- Lua userdata handle wrapping a [`Cinematic`] timeline.

##### Fields

- No documented fields.

##### Methods

- `LCinematic:addCut(time, description) -> nil`: Appends a timed cut to the cinematic timeline.
- `LCinematic:clear() -> nil`: Removes all cuts from the timeline.
- `LCinematic:cutCount() -> integer`: Returns the number of cuts in the timeline.
- `LCinematic:play() -> nil`: Plays back the timeline by firing all cuts in order.
- `LCinematic:type() -> string`: Returns the Lua-visible type name.
- `LCinematic:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LCinematicTimeline Type

- Lua userdata handle wrapping a [`CinematicTimeline`] for multi-track playback.

##### Fields

- No documented fields.

##### Methods

- `LCinematicTimeline:addClip(track_name, at, duration, clip_table) -> nil`: Adds a clip to a named track (creates track if missing).
- `LCinematicTimeline:addLabel(name, time) -> nil`: Registers a named time position for branching.
- `LCinematicTimeline:addTrack(name) -> nil`: Adds a new track to the timeline.
- `LCinematicTimeline:branch(label) -> boolean`: Jumps to a named label position.
- `LCinematicTimeline:getDuration() -> number`: Returns the total duration of the timeline.
- `LCinematicTimeline:getState() -> string`: Returns the playback state as a string.
- `LCinematicTimeline:getTime() -> number`: Returns the current playback time.
- `LCinematicTimeline:isComplete() -> boolean`: Checks if playback has reached the end.
- `LCinematicTimeline:isPlaying() -> boolean`: Checks if the timeline is currently playing.
- `LCinematicTimeline:pause() -> nil`: Pauses playback without resetting time.
- `LCinematicTimeline:play() -> nil`: Starts playback from the current time.
- `LCinematicTimeline:seek(time) -> nil`: Jumps to a specific time.
- `LCinematicTimeline:skipToEnd() -> nil`: Instantly jumps to the end of the timeline.
- `LCinematicTimeline:stop() -> nil`: Stops playback and resets to time 0.
- `LCinematicTimeline:type() -> string`: Returns the Lua-visible type name.
- `LCinematicTimeline:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LCinematicTimeline:update(dt) -> nil`: Advances time by dt (only if playing).
