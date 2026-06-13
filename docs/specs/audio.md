# audio

## TL;DR

- Plays static and streaming sound via voice pools and mixing buses.
- Controls priority ducking, spatial panning, and Doppler shifts.
- Provides beat clocks for rhythmic scheduling and timing checks.
- Synthesizes MIDI tracks and applies lowpass/highpass filters.

## General Info

- Module group: `Platform Services`
- Source path: `src/audio/`
- Binding: `src/lua_api/audio_api.rs`
- Namespace: `lurek.audio`
- Lua API surface: `94` functions, `7` types, `157` methods
- Rust test path(s): tests/rust/unit/audio_tests.rs, tests/rust/unit/audio_sound_tests.rs
- Lua test path(s): tests/lua/unit/test_audio.lua, tests/lua/unit/test_audio_bus.lua, tests/lua/unit/test_audio_dsp.lua, tests/lua/integration/test_audio_timer.lua, tests/lua/integration/test_audio_event.lua, tests/lua/evidence/test_evidence_audio.lua, tests/lua/evidence/test_evidence_audio_bus.lua

## Summary

- Lets gameplay scripts play one-shot effects, looped ambience, dialogue, and long-form music from one runtime surface.
- Gives designers two practical loading paths: instant static sounds for low-latency triggers and streaming queues for long tracks.
- Supports robust voice management so repeated events do not cut each other off during combat, UI spam, or particle-heavy scenes.
- Exposes fade-in, crossfade, seek, and stop controls that make scene transitions feel polished instead of abrupt.
- Provides source routing through named buses so teams can control music, SFX, VO, and ambience as separate loudness groups.
- Enables sidechain ducking workflows where critical channels stay audible while background layers automatically step down.
- Offers metering outputs for peak and RMS so HUD widgets and dev overlays can react to real loudness values.
- Adds spatial placement in 2D/3D so players hear direction, distance, and movement cues instead of flat stereo playback.
- Lets games tune attenuation models and Doppler intensity to match arcade, cinematic, or simulation-style movement feel.
- Gives scripts listener positioning APIs that tie audio perspective directly to camera, character, or spectator modes.
- Includes a beat-clock workflow for rhythm timing, beat callbacks, and judgment windows for music-driven gameplay loops.
- Supports tempo ramps and sync-safe scheduling so timeline events remain musically aligned during speed changes.
- Includes MIDI playback and SoundFont control for adaptive scoring without shipping large rendered audio stems.
- Allows per-track muting and tempo scaling so music can react to game states, difficulty, and encounter phases.
- Exposes lowpass/highpass controls for occlusion-like effects, underwater states, and menu muffling transitions.
- Supports stereo width and random pitch variation to reduce repetition fatigue in rapidly repeated sound effects.
- Provides a queueable PCM path for generated audio, voice streaming, and other runtime-produced sample content.
- Lets scripts inspect and edit sample buffers for procedural synthesis, waveform tools, or offline preprocessing.
- Includes buffer mixing helpers that simplify layering and signal baking without external audio middleware.
- Supports WAV export for captured takes, generated assets, and automated content pipelines.
- Keeps device selection scriptable so QA can reproduce issues against specific output hardware.
- Exposes global mute and master volume controls for user settings menus and accessibility presets.
- Reports active and total source counts, helping teams budget channel usage under stress.
- Enables pooled playback patterns that keep trigger latency stable during bursty gameplay.
- Works as the user-facing audio control plane while deeper DSP modules handle specialized processing.
- Gives one coherent API for sound effects, music systems, rhythm mechanics, and runtime audio diagnostics.
- Reduces ad-hoc audio glue code by centralizing lifecycle, routing, timing, and spatial behavior in one module.
- Helps teams ship mix-consistent experiences across scenes by standardizing bus-level and source-level controls.
- Improves iteration speed because gameplay scripts can tweak sonic behavior live without engine restarts.
- Scales from small 2D projects to content-heavy games that need layered, reactive, and inspectable audio behavior.
- Delivers a practical bridge between creative audio authoring intent and deterministic runtime playback control.
- Keeps advanced capabilities optional so simple projects can start with play/stop and grow into full mixing workflows.
- Supports robust testing by exposing deterministic timing and state query surfaces used by automation and QA.
- Helps user-facing features like subtitles timing and hit feedback stay synchronized with actual playback state.
- Serves as the core module for making game audio responsive, legible, and production-ready from script level.

This module primarily collaborates with `dsp`, `image`, `midi`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Imports

- `dsp`: Imports or references `src/dsp/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `midi`: Imports or references `src/midi/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### beat_clock.rs

- Implements musical time tracking that maps wall-clock progression to beats, bars, and pulses.
- Supports tempo and meter changes while preserving coherent phase continuity over runtime updates.
- Provides tap-tempo and quantized scheduling utilities for rhythm-aware gameplay coordination.
- Applies latency and swing parameters to shape musical timing feel without audio-thread coupling.
- Exposes deterministic query surfaces for beat index, measure position, and subdivision boundaries.
- Keeps timing logic pure and playback-agnostic so multiple systems can consume one clock source.
- Serves rhythm, sequencing, and procedural trigger systems that require stable musical time.
- Functions as the temporal backbone for Lua callbacks aligned to musical structure.

### bus.rs

- Implements named audio routing channels that apply shared gain, pitch, pause, and ducking control.
- Maintains per-bus processing parameters and effect-chain references for downstream mixer application.
- Supports duck-target relationships so one bus can attenuate others during priority playback.
- Enforces bounded parameter updates to keep runtime routing behavior stable and predictable.

### decoder.rs

- Implements full-file PCM decode for supported audio formats into a seekable in-memory sample buffer.
- Provides random-access cursor movement for rewind, seek, and chunked iteration workflows.
- Exposes duration and playback-position metrics derived from decoded sample metadata.
- Serves as the decode bridge between file assets and streaming or buffered playback paths.

### facade.rs

- Provides the audio device facade used for output listing and active-device selection hooks.
- Exposes a stable API surface while backend-specific device enumeration remains minimal.
- Validates requested device names against known outputs before accepting selection changes.

### mixer.rs

- Implements the central audio mixer registry that owns sources, buses, streams, and listener state.
- Manages output stream lifecycle with graceful fallback behavior when device initialization is unavailable.
- Controls source playback lifecycle including load, play, pause, stop, seek, clone, and release flows.
- Applies per-source parameters for gain, pitch, panning, looping, filters, and transition shaping.
- Integrates bus routing so grouped sources share higher-level volume, pitch, pause, and effect behavior.
- Supports queueable streaming sources with bounded buffer slots and free-space tracking semantics.
- Maintains spatial-audio state for listener and source transforms used in attenuation and motion cues.
- Applies distance-model and doppler controls for runtime spatialization consistency.
- Tracks metering data across source, bus, and master levels for diagnostics and gameplay feedback.
- Provides utility controls for stereo width, random pitch spread, crossfade behavior, and pooled playback.
- Preserves stable key-based lookup so script calls map deterministically to mixer-owned runtime entities.
- Coordinates effect processing boundaries while leaving advanced DSP behavior to dedicated modules.
- Centralizes audio concurrency decisions so frame systems interact through one coherent control plane.
- Serves as the primary engine-side audio execution surface behind Lua-facing playback APIs.
- Anchors all real-time audio state mutation under a deterministic, runtime-safe ownership model.

### mod.rs

- Defines the audio module boundary that groups playback, routing, decode, and source-data primitives.
- Exposes coherent core audio contracts while delegating specialized processing to adjacent modules.
- Serves as the composition entry for engine-side runtime audio behavior and shared types.

### pool.rs

- Implements round-robin voice pooling for low-latency repeated playback of one sound asset.
- Cycles preloaded source keys to distribute trigger load across reusable playback voices.
- Stores per-pool gain and optional bus assignment for grouped routing behavior.
- Validates pool integrity so empty or invalid voice sets are rejected early.

### sound_data.rs

- Implements in-memory interleaved PCM storage with metadata-aware sample access and mutation.
- Supports decode from file and direct buffer creation for generated or procedural audio content.
- Provides waveform synthesis helpers for common tonal and noise signal generation workflows.
- Applies lightweight in-place transforms such as filtering, gain, and buffer mixing operations.
- Exposes encode paths for export-ready WAV byte output from runtime sample data.
- Supplies duration and shape queries for tools, previews, and script-side audio reasoning.
- Bridges sample data to visual workflows through waveform drawing integration points.
- Serves as the core raw sound-data container for playback and preprocessing pipelines.

### source.rs

- Defines source-level audio metadata and spatial attributes used by mixer-side playback control.
- Encapsulates position, velocity, and orientation state for positional and motion-aware rendering.
- Stores identity and basic playback defaults that classify each loaded runtime source.
- Serves as the foundational source contract shared across routing, playback, and spatialization paths.



## Lua API Ref

### Functions

- `lurek.audio.beatClockFromSource(source, bpm, opts?) -> LBeatClock`: Creates a new beat clock and synchronizes it to an audio source position.
- `lurek.audio.clearFilter(source) -> nil`: Removes all frequency filters from a source.
- `lurek.audio.clearMidiSoundFont() -> nil`: Clears the loaded SoundFont and reverts MIDI synthesis to default.
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
- `lurek.audio.hasMidiSoundFont() -> boolean`: Returns whether a SoundFont file has been loaded for MIDI synthesis.
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
- `lurek.audio.newMidiPlayer(path?) -> LMidiPlayer`: Creates a new MIDI player instance, optionally loading a file immediately.
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
- `lurek.audio.setMidiSoundFont(path) -> nil`: Sets the SoundFont file used for MIDI synthesis.
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
- `LMidiPlayer:setOnEnd` param `cb` (`function?`): Callback function or nil to clear.
- `LMidiPlayer:setOnNoteOff` param `cb` (`function?`): Callback function or nil to clear.
- `LMidiPlayer:setOnNoteOn` param `cb` (`function?`): Callback function or nil to clear.

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

#### LMidiPlayer Type

- Lua-side wrapper around a MIDI file player with per-channel control and tempo scaling.

##### Fields

- No documented fields.

##### Methods

- `LMidiPlayer:getBus() -> LBus`: Returns the audio bus this MIDI player is routed through.
- `LMidiPlayer:getChannelCount() -> integer`: Returns the number of active MIDI channels in the loaded file.
- `LMidiPlayer:getChannelInstrument(ch) -> integer`: Returns the current GM instrument program for a channel.
- `LMidiPlayer:getChannelVolume(ch) -> number`: Returns the volume of a specific MIDI channel.
- `LMidiPlayer:getChannels() -> integer`: Returns the number of output audio channels for MIDI synthesis.
- `LMidiPlayer:getDuration() -> number`: Returns the total duration of the loaded MIDI file in seconds.
- `LMidiPlayer:getFilePath() -> string`: Returns the file path of the currently loaded MIDI file.
- `LMidiPlayer:getNoteCount() -> integer`: Returns the total number of note events in the loaded MIDI file.
- `LMidiPlayer:getOriginalTempo() -> number`: Returns the original tempo of the MIDI file as authored.
- `LMidiPlayer:getSampleRate() -> integer`: Returns the output sample rate used for MIDI synthesis.
- `LMidiPlayer:getSoundFontPath() -> string`: Returns the path of the currently set SoundFont (stub, not yet implemented).
- `LMidiPlayer:getTempo() -> number`: Returns the current effective tempo in beats per minute.
- `LMidiPlayer:getTempoScale() -> number`: Returns the current tempo scale multiplier.
- `LMidiPlayer:getTicksPerBeat() -> integer`: Returns the MIDI file's resolution in ticks per beat (PPQN).
- `LMidiPlayer:getTrackCount() -> integer`: Returns the number of tracks in the loaded MIDI file.
- `LMidiPlayer:getTrackName(idx) -> string`: Returns the name of a MIDI track by 1-based index.
- `LMidiPlayer:getVolume() -> number`: Returns the current master volume of the MIDI player.
- `LMidiPlayer:isChannelMuted(ch) -> boolean`: Returns whether a specific MIDI channel is muted.
- `LMidiPlayer:isLoaded() -> boolean`: Returns whether a MIDI file is currently loaded and ready to play.
- `LMidiPlayer:isLooping() -> boolean`: Returns whether MIDI looping is enabled.
- `LMidiPlayer:isPaused() -> boolean`: Returns whether the MIDI player is currently paused.
- `LMidiPlayer:isPlaying() -> boolean`: Returns whether the MIDI player is currently playing.
- `LMidiPlayer:isTrackMuted(idx) -> boolean`: Returns whether a specific MIDI track is muted.
- `LMidiPlayer:load(path) -> boolean`: Loads a MIDI file from the given path relative to the game directory.
- `LMidiPlayer:loadData(data) -> boolean`: Loads MIDI data from a raw byte string in memory.
- `LMidiPlayer:pause() -> nil`: Pauses MIDI playback at the current position.
- `LMidiPlayer:play() -> nil`: Starts MIDI playback from the current position using the audio output stream.
- `LMidiPlayer:seek(secs) -> nil`: Seeks to a specific position in the MIDI file.
- `LMidiPlayer:setBus(bus?) -> nil`: Routes this MIDI player's output through the specified audio bus.
- `LMidiPlayer:setChannelInstrument(ch, inst) -> nil`: Sets the General MIDI instrument program for a channel.
- `LMidiPlayer:setChannelMuted(ch, muted) -> nil`: Mutes or unmutes a specific MIDI channel.
- `LMidiPlayer:setChannelVolume(ch, vol) -> nil`: Sets the volume for a specific MIDI channel (1-16).
- `LMidiPlayer:setChannels(channels) -> nil`: Sets the number of output audio channels for MIDI synthesis.
- `LMidiPlayer:setLooping(looping) -> nil`: Enables or disables looping for MIDI playback.
- `LMidiPlayer:setOnEnd(cb?) -> nil`: Registers a callback invoked when MIDI playback finishes (stub, not yet implemented).
- `LMidiPlayer:setOnNoteOff(cb?) -> nil`: Registers a callback for MIDI note-off events (stub, not yet implemented).
- `LMidiPlayer:setOnNoteOn(cb?) -> nil`: Registers a callback for MIDI note-on events (stub, not yet implemented).
- `LMidiPlayer:setSampleRate(rate) -> nil`: Sets the output sample rate for MIDI synthesis.
- `LMidiPlayer:setSoundFont(path) -> nil`: Sets a custom SoundFont file for MIDI synthesis (stub, not yet implemented).
- `LMidiPlayer:setTempo(bpm) -> nil`: Sets the playback tempo in beats per minute.
- `LMidiPlayer:setTempoScale(scale) -> nil`: Sets a tempo multiplier relative to the original speed.
- `LMidiPlayer:setTrackMuted(idx, muted) -> nil`: Mutes or unmutes a specific MIDI track.
- `LMidiPlayer:setVolume(vol) -> nil`: Sets the master volume for MIDI playback.
- `LMidiPlayer:soloChannel(ch) -> nil`: Solos a specific MIDI channel, muting all others.
- `LMidiPlayer:stop() -> nil`: Stops MIDI playback and resets position to the beginning.
- `LMidiPlayer:tell() -> number`: Returns the current playback position of the MIDI player in seconds.
- `LMidiPlayer:type() -> string`: Returns the type name of this object for runtime type-checking.
- `LMidiPlayer:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LMidiPlayer:unsoloAll() -> nil`: Removes solo from all channels, restoring normal playback.
- `LMidiPlayer:useDefaultSoundFont() -> nil`: Reverts to the built-in default SoundFont (stub, not yet implemented).

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

## References

- `dsp`: Imports or references `src/dsp/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `midi`: Imports or references `src/midi/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
