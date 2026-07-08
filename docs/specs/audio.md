<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/audio.md or source docstrings instead. -->

# audio

## TL;DR

- Plays static and streaming sound via voice pools and mixing buses.
- Controls priority ducking, spatial panning, and Doppler shifts.
- Provides beat clocks for rhythmic scheduling and timing checks.
- Applies lowpass/highpass filters and manages source-level playback state.

## General Info

- Module group: `Platform Services`
- Source path: `src/audio`
- Binding: `src/lua_api/audio_api.rs`
- Namespace: `lurek.audio`
- Lua API surface: `90` functions, `6` types, `108` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `audio` module is the engine's main runtime sound system for users who need playback, routing, source state, timing, and mix control to live under one API.
- It covers the full everyday audio workflow: loading or decoding sound assets, creating reusable sound data, instantiating live voices, tracking listener state, and managing mixer-facing behavior without splitting those jobs across unrelated helpers.
- Named buses are one of the core abstractions because projects usually want music, effects, voice, ambience, and UI to be grouped, muted, paused, ducked, or rebalanced as categories instead of as isolated sounds.
- Source lifecycle and inspectable runtime state make the module practical for reactive gameplay cues, debugging, and longer sequences where scripts need to know what is playing, stopped, fading, pooled, or otherwise active.
- Sound pools give repeated effects such as footsteps, shots, and impacts a structured reuse path, while beat-clock support lets rhythm-aware gameplay or presentation synchronize against shared musical timing.
- The same subsystem therefore serves both simple one-shot playback and more deliberate mix orchestration, which is important for projects that start small and later grow into layered, routing-heavy sound design.
- Mixer control keeps overall gain policy and category coordination in one place, and deterministic timing helpers make live audio behavior easier to reason about during testing or tuning.
- Those timing and routing semantics are especially valuable when several playback categories must coexist coherently.
- They are also what keep music changes, ambience, voice, and reactive effects readable as parts of one shared mix.
- Asset-facing loading is also a major part of the value. Imported files become runtime-ready sound objects through engine-owned decoding and preparation rules instead of requiring every caller to reinvent codec handling, caching, or source setup.
- That content workflow matters because audio systems often fail not at playback itself but at all the surrounding decisions: how assets are reused, how transient voices are pooled, how categories stay legible, and how stateful transitions are coordinated over longer sessions.
- The module therefore gives projects a stable answer to both "play this now" and "manage the whole current mix." Those are different needs, but they have to coexist if a game wants reactive effects, adaptive music, voiced UI, and ambient layers to remain understandable together.
- Buses and mixer policy are the main reason the subsystem scales. A small prototype may only play a few sounds, but a larger project needs volume hierarchy, pause semantics, ducking rules, mute groups, and category-level tuning that remain visible rather than being buried in ad hoc script conventions.
- Listener-facing state broadens the feature from raw playback into world-aware audio behavior. Even when neighboring modules provide the scene, `audio` owns how sources and listener context become heard spatial or positional results.
- This is why the module stays useful across both live gameplay and tool-driven verification: it keeps playback, routing, timing, and category policy visible enough to inspect instead of hiding sound behavior behind fire-and-forget calls.
- It keeps mix policy legible as projects scale.
- `dsp` specializes lower-level signal processing, but `audio` owns the user-facing contract for how sounds are loaded, instantiated, routed, timed, and heard at runtime.

This module primarily collaborates with `dsp`, `image`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/audio`
- Owning tier: `Platform Services`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/audio_api.rs`
- Referenced engine modules: `dsp`, `image`, `runtime`

## Imports

- `dsp`: Imports or references `src/dsp/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `image`: Imports or references `src/image/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Platform Services` into `Core Runtime`.

## Source Files

### beat_clock.rs

- This file owns `BeatClock` and its support types, the pure musical-timing model used across rhythm features.
- It stores BPM, meter, elapsed beat position, tap-tempo history, ramps, swing, latency, and scheduled beat markers.
- Options and judgement structs define default subdivision, hit windows, and the typed results returned by timing checks.
- Tick and update helpers advance the clock, emit beat and bar crossings, and preserve continuity across BPM ramps.
- Query helpers expose beat, bar, phase, nearest grid points, time remaining, and effective beat after compensation.
- Judgement, quantisation, crossed-step, and scheduling helpers support rhythm gameplay without coupling to playback I/O.
- The file stays playback-agnostic, acting as a shared timing source instead of owning audio streams or sinks.
- Open it when music-time semantics change; decode, buses, and actual playback routing live in sibling files.

### bus.rs

- This file owns `Bus`, the named routing channel that groups sources under shared mix controls and effects.
- It stores bus name, volume, pitch, paused state, DSP effect chain, and optional duck target for suppression.
- Mutation helpers clamp gain and pitch, toggle pause state, and configure or clear ducking relationships.
- Open it when shared routing semantics change; source playback and device output are managed in sibling files.

### decoder.rs

- This file owns `Decoder`, the full-file decode bridge from audio assets to seekable PCM chunk iteration.
- It decodes supported files into interleaved i16 PCM, tracks cursor position, and returns fixed-size sample chunks.
- Duration, seek, tell, and rewind helpers keep file-backed playback metadata local to one decode owner.
- Open this file when import semantics change; runtime sinks and in-memory f32 buffers live in sibling modules.

### facade.rs

- This file owns the playback-device facade that lists outputs and validates active-device selection requests.
- It currently exposes a simple default-device surface rather than a full backend-specific device enumeration layer.
- Open this file when output-device semantics change; routing, decode, and mixer playback live in sibling modules.

### mixer.rs

- This file owns `Mixer`, `QueueableSource`, `SourceType`, and `PlayState`, the central runtime audio registry.
- It stores the rodio stream handle, loaded source entries, master volume, named buses, listener state, and meters.
- Per-source entries keep playback state, cached bytes, sink handles, gain, pitch, looping, filters, and spatial data.
- Load and play helpers create source entries, build sinks, cache static bytes, and apply bus-aware playback settings.
- Transport helpers cover stop, pause, resume, seek, clone, release, loop, tell, and active-source counting.
- Routing helpers create buses, assign them to sources, read bus metrics, and propagate shared volume or pitch intent.
- Filter and transition helpers manage low-pass, high-pass, fade-in, crossfade, random pitch, and stereo width state.
- Spatial helpers own listener and source transforms, doppler scale, distance model, and pan updates from positions.
- Queueable-source helpers manage push-buffer streaming slots, free-buffer accounting, and queueable lifecycle control.
- The mixer also owns pool creation and peak metering, making it the integration point for most runtime audio control.
- Open this file when playback orchestration changes; decode, pools, buses, and pure timing models live in siblings.

### mod.rs

- This module re-exports the audio subsystem for buses, decode, playback, sound buffers, pools, devices, and beat time.
- It is the navigation map for source playback, routing owners, import helpers, and music-timing support types.
- `mixer.rs` owns runtime playback and routing, while `bus.rs`, `source.rs`, and `pool.rs` hold focused audio data.
- `decoder.rs` and `sound_data.rs` cover decode, PCM buffers, synthesis, transforms, and export-ready sample output.
- `facade.rs` exposes playback device queries, and `beat_clock.rs` provides tempo, judgement, and quantized timing tools.
- Change this file when public audio exports move; change sibling files when playback or timing semantics change.

### pool.rs

- This file owns `SoundPool`, the round-robin voice pool used for repeated playback of one preloaded sound asset.
- It stores voice keys, next-voice cursor, source path, pool-level gain, and optional bus assignment for routing.
- Helpers expose pool metadata, rotate voices deterministically, and clamp volume at the pool entry point.
- Open this file when pooled playback semantics change; source registration and mixing live in sibling modules.

### sound_data.rs

- This file owns `SoundData`, the in-memory interleaved PCM buffer used for generated and imported sample data.
- It stores f32 samples with sample-rate, channel, and bit-depth metadata, then exposes random-access mutation.
- Construction helpers allocate silence, import from files, or build buffers from raw samples and Lua-facing args.
- Synthesis helpers generate sine, square, sawtooth, triangle, and deterministic white-noise waveforms.
- Transform helpers apply gain, low-pass, high-pass, band-pass, ADSR envelopes, and in-place buffer mixing.
- Analysis helpers compute duration, RMS, peak, bounded DFT bins, and waveform drawing for tools or previews.
- Export helpers encode WAV bytes so runtime sample buffers can leave the engine without using the live mixer.

### source.rs

- This file owns `SpatialState` and `AudioSource`, the basic source metadata used by the audio runtime.
- It stores source identity, asset path, default volume, looping intent, plus 3D position, velocity, and orientation.
- The file is purely data-oriented; active playback, sinks, buses, and listener state are owned by the mixer.
- Open it when per-source metadata semantics change; runtime routing and queueing live in sibling audio files.



## Lua API Ref

### Functions

- `lurek.audio.beatClockFromSource(source, bpm, opts?) -> LBeatClock`: Creates a new beat clock and synchronizes it to an audio source position.
- `lurek.audio.clearFilter(source) -> nil`: Removes all frequency filters from a source.
- `lurek.audio.clearRandomPitch(src_ud) -> nil`: Clears any random pitch range previously set on the source.
- `lurek.audio.clone(source) -> LSource`: Creates an independent copy of a source sharing the same audio data.
- `lurek.audio.create_bus(name, parent_name?) -> nil`: Creates a named audio bus, optionally parented to another bus.
- `lurek.audio.crossfade(from_ud, to_ud, duration) -> nil`: Crossfades from one audio source to another over the given duration.
- `lurek.audio.fadeIn(source, dur) -> nil`: Sets the fade-in duration for a source so it ramps from silence on play.
- `lurek.audio.getActiveSourceCount() -> integer`: Returns the number of sources currently playing audio.
- `lurek.audio.getBusPeak(bus_name) -> number`: Returns the peak amplitude of the named audio bus over the last processing frame.
- `lurek.audio.getBusRms(bus_name) -> number`: Returns the RMS (root mean square) amplitude of the named audio bus over the last processing frame.
- `lurek.audio.getDistanceModel() -> string`: Returns the current distance attenuation model name.
- `lurek.audio.getDopplerScale() -> number`: Returns the current global Doppler effect scale.
- `lurek.audio.getDuration(source) -> number`: Returns the total duration of a source in seconds.
- `lurek.audio.getFadeIn(source) -> number`: Returns the configured fade-in duration of a source.
- `lurek.audio.getFreeBufferCount(qsource_id) -> integer`: Returns the number of free (available) buffer slots on a queueable source.
- `lurek.audio.getHighpass(source) -> integer`: Returns the current highpass filter cutoff of a source.
- `lurek.audio.getJudgementWindows() -> table`: Returns global default timing windows used by beat-clock judgement.
- `lurek.audio.getListener() -> number, number, number`: Returns the current 3D listener position.
- `lurek.audio.getListener2D() -> number, number`: Returns the current 2D listener position.
- `lurek.audio.getLowpass(source) -> integer`: Returns the current lowpass filter cutoff of a source.
- `lurek.audio.getMasterVolume() -> number`: Returns the current global master volume level.
- `lurek.audio.getMaxSources() -> integer`: Returns the maximum number of simultaneous audio sources supported.
- `lurek.audio.getMeter() -> number`: Returns the current master peak level for VU-meter displays.
- `lurek.audio.getOrientation(source) -> number, number, number, number, number, number`: Returns the orientation vectors of a source.
- `lurek.audio.getPan(source) -> number`: Returns the current stereo pan position of a source.
- `lurek.audio.getPitch(source) -> number`: Returns the current pitch multiplier of a source.
- `lurek.audio.getPlaybackDevice() -> string`: Returns the name of the currently active audio playback device.
- `lurek.audio.getPlaybackDevices() -> string[]`: Returns a list of available audio playback device names.
- `lurek.audio.getPosition(source) -> number, number, number`: Returns the 3D position of a source.
- `lurek.audio.getSourceBus(source) -> LBus`: Returns the bus a source is routed through.
- `lurek.audio.getSourceCount() -> integer`: Returns the total number of loaded audio sources (playing or idle).
- `lurek.audio.getSourceType(source) -> string`: Returns whether a source is static or streaming.
- `lurek.audio.getStereoWidth(src_ud) -> number`: Returns the current stereo width factor of an audio source.
- `lurek.audio.getVelocity(source) -> number, number, number`: Returns the velocity vector of a source.
- `lurek.audio.getVolume(source) -> number`: Returns the current volume of a source.
- `lurek.audio.isLooping(source) -> boolean`: Returns whether a source has looping enabled.
- `lurek.audio.isMuted() -> boolean`: Returns whether global audio is currently muted.
- `lurek.audio.isPaused(source) -> boolean`: Returns whether a source is currently paused.
- `lurek.audio.isPlaying(source) -> boolean`: Returns whether a source is currently playing.
- `lurek.audio.isStopped(source) -> boolean`: Returns whether a source is currently stopped.
- `lurek.audio.judgeBeat(clock, division?, hit_offset?) -> string`: Judges timing against the nearest beat grid for a beat clock.
- `lurek.audio.manager.pauseAll() -> nil`: Pauses every currently active audio source.
- `lurek.audio.manager.resumeAll() -> nil`: Resumes every currently paused audio source.
- `lurek.audio.mixInto(dest_ud, src_ud) -> nil`: Mixes the samples of `src` into `dest` in-place (both must have the same format).
- `lurek.audio.newBeatClock(bpm, beats_per_bar_or_opts, opts?) -> LBeatClock`: Creates a musical beat clock for rhythm-game timing, tap-tempo, and beat scheduling.
- `lurek.audio.newBus(name) -> LBus`: Creates a new audio mixing bus for grouping and controlling sources.
- `lurek.audio.newDecoder(source, buffersize?) -> LDecoder`: Creates a streaming audio decoder for the given file. The file is opened relative to the game directory.
- `lurek.audio.newPool(file_path, voice_count) -> LSoundPool`: Creates a polyphonic sound pool that allows the same audio file to play on multiple simultaneous voices.
- `lurek.audio.newQueueableSource(sample_rate, bit_depth, channels, buffer_count?) -> integer`: Creates a new queueable audio source for streaming PCM data buffer by buffer.
- `lurek.audio.newSoundData(pathOrCount, sampleRate, channels?) -> LSoundData`: Creates a new SoundData object from a file path or blank buffer for procedural audio.
- `lurek.audio.newSource(path, sourceType?) -> LSource`: Creates a new audio source from a file path, either fully loaded or streaming.
- `lurek.audio.pause(source) -> nil`: Pauses playback of a source at its current position.
- `lurek.audio.pauseAll() -> nil`: Pauses all currently playing audio sources.
- `lurek.audio.play(source, options?) -> integer`: Starts playback of a source by handle, optionally routing through a named bus.
- `lurek.audio.playLooping(source) -> nil`: Starts playback of a source with looping enabled in one call.
- `lurek.audio.playQueueable(qsource_id) -> nil`: Starts playback of a queueable audio source.
- `lurek.audio.playSfx(path, opts?) -> LSource`: Plays a one-shot sound effect from a file path with optional settings.
- `lurek.audio.queueSource(qsource_id, sd) -> nil`: Queues a decoded audio chunk for playback on a queueable source.
- `lurek.audio.release(source) -> boolean`: Releases an audio source, freeing its memory and stopping playback.
- `lurek.audio.resume(source) -> nil`: Resumes playback of a paused source.
- `lurek.audio.resumeAll() -> nil`: Resumes all paused audio sources. This function is exposed to Lua scripts.
- `lurek.audio.saveWAV(sd_ud, filename) -> nil`: Encodes the sound data as a WAV file and saves it to the given path (relative to game dir).
- `lurek.audio.seek(source, pos) -> nil`: Seeks a source to a specific position in seconds.
- `lurek.audio.setDistanceModel(model) -> nil`: Sets the distance attenuation model for spatial audio.
- `lurek.audio.setDopplerScale(scale) -> nil`: Sets the global Doppler effect intensity multiplier.
- `lurek.audio.setHighpass(source, cutoff_hz) -> nil`: Applies a highpass filter to a source, attenuating low frequencies.
- `lurek.audio.setJudgementWindows(windows) -> nil`: Sets global default timing windows used by beat-clock judgement.
- `lurek.audio.setListener(x, y, z?) -> nil`: Sets the 3D listener position for spatial audio (Z defaults to 0 for 2D games).
- `lurek.audio.setListener2D(x, y) -> nil`: Sets the 2D listener position for spatial audio calculations.
- `lurek.audio.setLooping(source, looping) -> nil`: Enables or disables looping for a source.
- `lurek.audio.setLowpass(source, cutoff_hz) -> nil`: Applies a lowpass filter to a source, attenuating high frequencies.
- `lurek.audio.setMasterVolume(vol) -> nil`: Sets the global master volume affecting all audio output.
- `lurek.audio.setMeter(level) -> nil`: Sets the master peak level for metering purposes.
- `lurek.audio.setMuted(muted) -> nil`: Globally mutes all audio (pauses all sources without stopping them).
- `lurek.audio.setOrientation(source, fx, fy, fz, ux, uy, uz) -> nil`: Sets the orientation of a source using forward and up vectors.
- `lurek.audio.setPan(source, pan) -> nil`: Sets the stereo panning of a source.
- `lurek.audio.setPitch(source, pitch) -> nil`: Sets the pitch multiplier of a source, affecting playback speed and tone.
- `lurek.audio.setPlaybackDevice(name) -> nil`: Sets the active audio playback device by name.
- `lurek.audio.setPosition(source, x, y, z?) -> nil`: Sets the 3D position of a source for spatial audio panning and attenuation.
- `lurek.audio.setRandomPitch(src_ud, min, max) -> nil`: Sets a random pitch range for a source; each play picks a random pitch between min and max.
- `lurek.audio.setSourceBus(source, bus) -> nil`: Routes a source through a specific audio bus for grouped mixing.
- `lurek.audio.setStereoWidth(src_ud, width) -> nil`: Sets the stereo width of an audio source (0.0 = mono, 1.0 = full stereo).
- `lurek.audio.setVelocity(source, x, y, z?) -> nil`: Sets the velocity of a source for Doppler effect calculations.
- `lurek.audio.setVolume(source, vol) -> nil`: Sets the volume of a source by handle.
- `lurek.audio.set_bus_volume(name, volume) -> nil`: Sets the volume of a named audio bus.
- `lurek.audio.stop(source) -> nil`: Stops playback of a source and resets its position to the beginning.
- `lurek.audio.stopAll() -> nil`: Stops all audio sources and resets their positions.
- `lurek.audio.stopMusic(fade_duration?) -> nil`: Stops all music sources with optional fade-out.
- `lurek.audio.stopQueueable(qsource_id) -> nil`: Stops playback of a queueable audio source.
- `lurek.audio.tell(source) -> number`: Returns the current playback position of a source in seconds.

### Callbacks

- `LBeatClock:at` param `fn` (`function`): Callback receiving the scheduled beat.
- `LBeatClock:every` param `fn` (`function`): Callback receiving `step_index`.
- `LBeatClock:pattern` param `fn` (`function`): Callback receiving 1-based pattern step index.

### Enums

- No documented module-level enums/constants.

### Types

#### LBeatClock Type

- Lua-side wrapper for a musical beat clock.

##### Fields

- No documented fields.

##### Methods

- `LBeatClock:at(beat, fn) -> table`: Registers a one-shot callback fired when `beat` is crossed.
- `LBeatClock:beatTimeRemaining(division?) -> number`: Returns seconds until the next division boundary.
- `LBeatClock:beatsPerBar() -> integer`: Returns the number of beats per bar.
- `LBeatClock:bpm() -> number`: Returns the current tempo as beats-per-minute for this clock.
- `LBeatClock:cancel(handle) -> boolean`: Cancels a scheduled callback handle.
- `LBeatClock:cancelAll() -> boolean`: Cancels all scheduled callback handles registered on this clock.
- `LBeatClock:drainFired() -> table`: Returns and removes all scheduled beats that have now passed.
- `LBeatClock:dump() -> table`: Returns a snapshot of clock state for debug and HUDs.
- `LBeatClock:every(division, fn) -> table`: Registers a callback fired on each crossed step of `division`.
- `LBeatClock:getBar() -> number`: Returns the current fractional bar position across elapsed musical time.
- `LBeatClock:getBeat() -> number`: Returns fractional beat position.
- `LBeatClock:getBpm() -> number`: Returns the current tempo as beats-per-minute for this clock.
- `LBeatClock:getPhase(division?) -> number`: Returns phase within the current division in [0, 1).
- `LBeatClock:isOnBeat(division?, tolerance?) -> boolean`: Returns true when the clock is near a beat boundary.
- `LBeatClock:isRunning() -> boolean`: Returns true when the clock is running.
- `LBeatClock:judge(division?, hit_offset?, windows?) -> table`: Judges timing against the nearest beat grid and returns a detailed result table.
- `LBeatClock:nearestBeat(division?) -> number, number`: Returns nearest beat and signed timing error in seconds.
- `LBeatClock:pattern(pattern, fn) -> table`: Registers a repeating pattern callback where `x` triggers and `.` skips.
- `LBeatClock:position() -> table`: Returns the current beat position.
- `LBeatClock:quantise(beat, grid) -> number`: Quantises `beat` to the nearest `grid` beat grid (static utility).
- `LBeatClock:rampBpm(target, seconds) -> nil`: Ramps BPM linearly to a target value over time.
- `LBeatClock:reset() -> nil`: Resets elapsed time to zero without changing running state.
- `LBeatClock:scheduleAt(beat) -> boolean`: Schedules a one-shot event at `beat`. Returns true when the beat is in the future.
- `LBeatClock:secondsPerBeat() -> number`: Returns seconds-per-beat at the current BPM.
- `LBeatClock:secondsToNextBeat() -> number`: Returns seconds until the next whole beat boundary.
- `LBeatClock:setBeatsPerBar(beats) -> nil`: Changes the time-signature beats-per-bar.
- `LBeatClock:setBpm(bpm) -> nil`: Sets a new BPM. Elapsed time is preserved.
- `LBeatClock:setSwing(amount) -> nil`: Sets rhythmic swing amount in `[0.0, 0.5]` for off-beat timing feel.
- `LBeatClock:start() -> nil`: Starts beat-clock playback so scheduled beat callbacks can begin firing.
- `LBeatClock:stop() -> nil`: Stops beat-clock playback while preserving the current musical position.
- `LBeatClock:syncToSource(source) -> nil`: Synchronizes beat position to an audio source playback position.
- `LBeatClock:tap(wall_time_secs) -> number`: Records a tap-tempo tap at `wall_time_secs`. Returns the estimated BPM (0.0 when fewer than 2 taps).
- `LBeatClock:tick(dt) -> table`: Advances the clock by `dt` seconds. Returns an array of whole-beat crossings.
- `LBeatClock:type() -> string`: Returns the Lua-visible type name.
- `LBeatClock:typeOf(name) -> boolean`: Returns whether this handle matches the given type name.
- `LBeatClock:update(dt) -> table`: Advances the clock by `dt` seconds and returns beat/bar transitions.

#### LBus Type

- Lua-side wrapper around an audio mixing bus for grouped volume and effect control.

##### Fields

- No documented fields.

##### Methods

- `LBus:clearDuck() -> nil`: Removes the ducking configuration from this bus.
- `LBus:getName() -> string`: Returns the name of this audio bus. This method is available to Lua scripts.
- `LBus:getPeak() -> number`: Returns the current peak amplitude level of this bus for VU-meter displays.
- `LBus:getPitch() -> number`: Returns the current pitch multiplier of this bus.
- `LBus:getVolume() -> number`: Returns the current volume multiplier of this bus.
- `LBus:isPaused() -> boolean`: Returns whether this bus is currently paused.
- `LBus:pause() -> nil`: Pauses all sources routed through this bus.
- `LBus:resume() -> nil`: Resumes all sources routed through this bus that were paused.
- `LBus:setDuckTarget(target_name, duck_vol) -> nil`: Configures ducking so this bus lowers the volume of a target bus when active.
- `LBus:setPitch(pitch) -> nil`: Sets the pitch multiplier applied to all sources routed through this bus.
- `LBus:setVolume(vol) -> nil`: Sets the volume multiplier for all sources routed through this bus.
- `LBus:type() -> string`: Returns the type name of this object for runtime type-checking.
- `LBus:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LDecoder Type

- Lua-side wrapper around a streaming audio decoder for incremental PCM extraction.

##### Fields

- No documented fields.

##### Methods

- `LDecoder:decode() -> LSoundData`: Decodes the next chunk of audio data and returns it as a LSoundData object.
- `LDecoder:getBitDepth() -> integer`: Returns the bit depth of the source audio file.
- `LDecoder:getChannelCount() -> integer`: Returns the number of audio channels in the source file.
- `LDecoder:getDuration() -> number`: Returns the total duration of the source audio file in seconds.
- `LDecoder:getSampleRate() -> integer`: Returns the sample rate of the source audio file.
- `LDecoder:isSeekable() -> boolean`: Returns whether this decoder supports seeking.
- `LDecoder:release() -> nil`: Releases decoder resources (no-op, kept for API symmetry).
- `LDecoder:rewind() -> nil`: Rewinds the decoder back to the beginning of the audio stream.
- `LDecoder:seek(offset) -> nil`: Seeks to a specific position in the audio stream.
- `LDecoder:tell() -> number`: Returns the current read position in the audio stream in seconds.
- `LDecoder:type() -> string`: Returns the type name of this object for runtime type-checking.
- `LDecoder:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LSoundData Type

- Represents the Lua-visible LSoundData object exposed by this module.

##### Fields

- No documented fields.

##### Methods

- `LSoundData:drawWaveform(target, x, y, w, h, r, g, b, a) -> nil`: Draws this sound buffer as a waveform into an image buffer.
- `LSoundData:getBitDepth() -> integer`: Returns the sample bit depth of this sound buffer.
- `LSoundData:getChannelCount() -> integer`: Returns the number of audio channels stored in this sound buffer.
- `LSoundData:getDuration() -> number`: Returns the approximate playback duration of this sound buffer.
- `LSoundData:getSample(index) -> number`: Returns the sample value at the given zero-based sample index.
- `LSoundData:getSampleCount() -> integer`: Returns the total number of samples stored in this sound buffer.
- `LSoundData:getSampleRate() -> integer`: Returns the playback sample rate of this sound buffer.
- `LSoundData:setSample(index, value) -> nil`: Overwrites the sample value at the given zero-based sample index.
- `LSoundData:type() -> string`: Returns the type name of this object for runtime type-checking.
- `LSoundData:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LSoundPool Type

- Lua-side wrapper around a pre-allocated pool of identical sound voices for rapid fire effects.

##### Fields

- No documented fields.

##### Methods

- `LSoundPool:getVoiceCount() -> integer`: Returns the number of pre-allocated voices in this pool.
- `LSoundPool:play() -> integer`: Plays the next available voice from the pool in round-robin order.
- `LSoundPool:release() -> nil`: Releases all voices and frees audio resources held by this pool.
- `LSoundPool:setBus(name) -> nil`: Routes all voices in this pool through the named audio bus.
- `LSoundPool:setVolume(vol) -> nil`: Sets the volume for all voices in this pool.
- `LSoundPool:stopAll() -> nil`: Stops all voices in this sound pool immediately.
- `LSoundPool:type() -> string`: Returns the type name of this object for runtime type-checking.
- `LSoundPool:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LSource Type

- Lua-side wrapper around a loaded audio source (sound effect or music stream).

##### Fields

- No documented fields.

##### Methods

- `LSource:clearFilter() -> nil`: Removes all frequency filters (lowpass and highpass) from this source.
- `LSource:clone() -> LSource`: Creates an independent copy of this source sharing the same audio data.
- `LSource:fadeIn(dur) -> nil`: Sets the fade-in duration so the source ramps from silence to full volume on play.
- `LSource:getDuration() -> number`: Returns the total duration of this audio source in seconds.
- `LSource:getFadeIn() -> number`: Returns the configured fade-in duration for this source.
- `LSource:getHighpass() -> integer`: Returns the current highpass filter cutoff frequency in Hertz.
- `LSource:getLowpass() -> integer`: Returns the current lowpass filter cutoff frequency in Hertz.
- `LSource:getPan() -> number`: Returns the current stereo panning position of this source.
- `LSource:getPitch() -> number`: Returns the current pitch multiplier of this audio source.
- `LSource:getType() -> string`: Returns whether this source was loaded as static (fully in memory) or streaming.
- `LSource:getVolume() -> number`: Returns the current volume level of this audio source.
- `LSource:isLooping() -> boolean`: Returns whether this source is set to loop continuously.
- `LSource:isPaused() -> boolean`: Returns whether this source is currently paused.
- `LSource:isPlaying() -> boolean`: Returns whether this source is currently playing audio.
- `LSource:isStopped() -> boolean`: Returns whether this source is currently stopped (not playing or paused).
- `LSource:pause() -> nil`: Pauses playback at the current position, allowing later resumption.
- `LSource:play() -> nil`: Starts playback of this audio source from the current position.
- `LSource:resume() -> nil`: Resumes playback from the position where the source was paused.
- `LSource:seek(pos) -> nil`: Seeks to a specific position in seconds within this audio source.
- `LSource:setHighpass(cutoff_hz) -> nil`: Applies a highpass filter that attenuates frequencies below the cutoff.
- `LSource:setLooping(looping) -> nil`: Enables or disables looping so the source restarts automatically after finishing.
- `LSource:setLowpass(cutoff_hz) -> nil`: Applies a lowpass filter that attenuates frequencies above the cutoff.
- `LSource:setPan(pan) -> nil`: Sets the stereo panning position of this source.
- `LSource:setPitch(pitch) -> nil`: Sets the playback speed multiplier, affecting both pitch and duration.
- `LSource:setVolume(vol) -> nil`: Sets the volume level of this source where 0.0 is silent and 1.0 is full volume.
- `LSource:stop() -> nil`: Stops playback and resets the source position to the beginning.
- `LSource:tell() -> number`: Returns the current playback position of this source in seconds.
- `LSource:type() -> string`: Returns the type name of this object for runtime type-checking.
- `LSource:typeOf(name) -> boolean`: Checks whether this object is of the given type name or a parent type.

## Examples

- `content/examples/audio.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
