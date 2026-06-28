<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/cinematic.md or source docstrings instead. -->

# cinematic

## TL;DR

- Multi-track timeline system for orchestrating game sequences.
- Supports Tween, Camera, Audio, and Signal track types with frame-accurate scheduling.

## General Info

- Module group: `Feature Systems`
- Source path: `src/cinematic`
- Binding: `src/lua_api/cinematic_api.rs`
- Namespace: `lurek.cinematic`
- Lua API surface: `2` functions, `2` types, `23` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

The `cinematic` module is the timeline authoring surface for cutscenes, scripted reveals, and other multi-system sequences. It lets motion, camera, audio, tween, and signal tracks advance against one playhead so designers can choreograph timing instead of hand-synchronizing callbacks. Playback controls such as play, pause, seek, loop, labels, and branching keep the same timeline useful for both fixed sequences and reactive presentation logic. It gives multi-system presentation one explicit sequencing surface inside the engine.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/cinematic`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/cinematic_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### cinematic_legacy.rs

- `src/cinematic/cinematic_legacy.rs` owns the older cut-based cinematic API kept for backward-compatible sequences.
- It defines `Cut` and `Cinematic`, storing ordered descriptive events without richer multi-track timeline behavior.
- Playback here is intentionally minimal and descriptive, keeping compatibility semantics separate from timeline features.
- Read this file when legacy cut storage or compatibility behavior must change, not when extending timeline playback.

### mod.rs

- `src/cinematic/mod.rs` is the module index that exposes both the legacy cut API and the newer timeline system.
- It reexports `Cinematic`, `Cut`, `CinematicTimeline`, `ClipType`, `Track`, and `TimelineState` in one surface.
- No active playback state lives here; this file only declares child modules and defines public cinematic symbols.
- Read this index when wiring sequence features, because it shows where legacy support ends and timeline playback begins.
- Changes here reshape the cinematic boundary, since reexports decide what runtime code may import without deep paths.
- This module keeps the simple legacy cut model separate from the multi-track timeline owner for newer cinematic flows.

### timeline.rs

- `src/cinematic/timeline.rs` owns the multi-track cinematic timeline used for timed clips, playback state, and branching.
- It defines `CinematicClip`, `ClipType`, `Track`, `TimelineState`, and `CinematicTimeline` under one playback owner.
- Track creation, clip insertion, duration recalculation, play or pause control, seeking, and completion checks live here.
- Label storage and branch jumps also live here, keeping authored timeline flow control next to the state it manipulates.
- Active-clip queries also live here, so runtime systems can inspect which camera, audio, tween, or signal apply.
- Read this file when timeline scheduling, clip categories, branching semantics, or playback-state behavior changes.



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
- `LCinematicTimeline:addTrack(name) -> nil`: Adds a named track to this cinematic timeline.
- `LCinematicTimeline:branch(label) -> boolean`: Jumps playback to a named label position.
- `LCinematicTimeline:getDuration() -> number`: Returns the total duration of the timeline.
- `LCinematicTimeline:getState() -> string`: Returns the playback state as a string.
- `LCinematicTimeline:getTime() -> number`: Returns the current playback time.
- `LCinematicTimeline:isComplete() -> boolean`: Checks if playback has reached the end.
- `LCinematicTimeline:isPlaying() -> boolean`: Checks if the timeline is currently playing.
- `LCinematicTimeline:pause() -> nil`: Pauses playback without resetting time.
- `LCinematicTimeline:play() -> nil`: Starts playback from the current time.
- `LCinematicTimeline:seek(time) -> nil`: Jumps playback to a specific timeline time.
- `LCinematicTimeline:skipToEnd() -> nil`: Instantly jumps to the end of the timeline.
- `LCinematicTimeline:stop() -> nil`: Stops playback and resets to time 0.
- `LCinematicTimeline:type() -> string`: Returns the Lua-visible type name.
- `LCinematicTimeline:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LCinematicTimeline:update(dt) -> nil`: Advances time by dt (only if playing).

## Examples

- `content/examples/cinematic.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
