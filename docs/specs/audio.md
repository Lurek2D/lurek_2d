# audio

## TL;DR

- The `audio` module is the main sound runtime for loading, routing, playing, and controlling audio, with buses, spatial controls, streaming, timing tools, and Lua-facing playback APIs.

## General Info

- Module group: `Platform Services`
- Source path: `src/audio/`
- Binding: `src/lua_api/audio_api.rs`
- Namespace: `lurek.audio`
- Lua API surface: `88` functions, `7` types, `157` methods
- Rust test path(s): tests/rust/unit/audio_tests.rs, tests/rust/unit/audio_sound_tests.rs
- Lua test path(s): tests/lua/unit/test_audio.lua, tests/lua/unit/test_audio_bus.lua, tests/lua/unit/test_audio_dsp.lua, tests/lua/integration/test_audio_timer.lua, tests/lua/integration/test_audio_event.lua, tests/lua/evidence/test_evidence_audio.lua, tests/lua/evidence/test_evidence_audio_bus.lua

## Summary

The `audio` module is the central runtime for sound behavior in Lurek2D. It manages source lifecycle, playback state, routing, and control so game systems can treat sound as a predictable service. In practice, it gives one place to start, stop, inspect, and shape audio during live gameplay.

Its mixer and bus model make project-wide control easier. Sources can be grouped, routed, and adjusted through shared bus rules for volume, pitch, pause, and ducking. This allows teams to manage complex mixes with clear structure instead of scattered per-source overrides.

The module also supports different playback patterns. It handles normal sources, queueable streaming, pool-based repeated playback, and cloned voices. This makes it suitable for music, effects, reactive one-shots, and high-frequency events without forcing one playback style for every case.

Spatial and timing features are built into the runtime surface. Listener and source transforms, distance and doppler controls, and beat-clock utilities support both positional sound and rhythm-aware gameplay. Functionally, this keeps audio decisions close to game state and player timing.

Sound data workflows are practical for both authored and procedural content. Decode paths, in-memory sample containers, basic transforms, and WAV export support quick iteration and tooling scenarios. At the same time, advanced DSP and MIDI concerns remain in dedicated modules, keeping boundaries clear.

Overall, the module provides a complete operational contract for audio: load or stream sound, route it, schedule it, control it, and monitor it through one Lua-facing API. This consistency improves maintainability as projects grow in content and runtime complexity.

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

- `lurek.audio.beatClockFromSource`: Creates a new beat clock and synchronizes it to an audio source position.
- `lurek.audio.clearFilter`: Removes all frequency filters from a source.
- `lurek.audio.clearMidiSoundFont`: Clears the loaded SoundFont and reverts MIDI synthesis to default.
- `lurek.audio.clearRandomPitch`: Clears any random pitch range previously set on the source.
- `lurek.audio.clone`: Creates an independent copy of a source sharing the same audio data.
- `lurek.audio.create_bus`: Creates a named audio bus, optionally parented to another bus.
- `lurek.audio.crossfade`: Crossfades from one audio source to another over the given duration.
- `lurek.audio.fadeIn`: Sets the fade-in duration for a source so it ramps from silence on play.
- `lurek.audio.getActiveSourceCount`: Returns the number of sources currently playing audio.
- `lurek.audio.getBusPeak`: Returns the peak amplitude of the named audio bus over the last processing frame.
- `lurek.audio.getBusRms`: Returns the RMS (root mean square) amplitude of the named audio bus over the last processing frame.
- `lurek.audio.getDistanceModel`: Returns the current distance attenuation model name.
- `lurek.audio.getDopplerScale`: Returns the current global Doppler effect scale.
- `lurek.audio.getDuration`: Returns the total duration of a source in seconds.
- `lurek.audio.getFadeIn`: Returns the configured fade-in duration of a source.
- `lurek.audio.getFreeBufferCount`: Returns the number of free (available) buffer slots on a queueable source.
- `lurek.audio.getHighpass`: Returns the current highpass filter cutoff of a source.
- `lurek.audio.getJudgementWindows`: Returns global default timing windows used by beat-clock judgement.
- `lurek.audio.getListener`: Returns the current 3D listener position.
- `lurek.audio.getListener2D`: Returns the current 2D listener position.
- `lurek.audio.getLowpass`: Returns the current lowpass filter cutoff of a source.
- `lurek.audio.getMasterVolume`: Returns the current global master volume level.
- `lurek.audio.getMaxSources`: Returns the maximum number of simultaneous audio sources supported.
- `lurek.audio.getMeter`: Returns the current master peak level for VU-meter displays.
- `lurek.audio.getOrientation`: Returns the orientation vectors of a source.
- `lurek.audio.getPan`: Returns the current stereo pan position of a source.
- `lurek.audio.getPitch`: Returns the current pitch multiplier of a source.
- `lurek.audio.getPlaybackDevice`: Returns the name of the currently active audio playback device.
- `lurek.audio.getPlaybackDevices`: Returns a list of available audio playback device names.
- `lurek.audio.getPosition`: Returns the 3D position of a source.
- `lurek.audio.getSourceBus`: Returns the bus a source is routed through.
- `lurek.audio.getSourceCount`: Returns the total number of loaded audio sources (playing or idle).
- `lurek.audio.getSourceType`: Returns whether a source is static or streaming.
- `lurek.audio.getStereoWidth`: Returns the current stereo width factor of an audio source.
- `lurek.audio.getVelocity`: Returns the velocity vector of a source.
- `lurek.audio.getVolume`: Returns the current volume of a source.
- `lurek.audio.hasMidiSoundFont`: Returns whether a SoundFont file has been loaded for MIDI synthesis.
- `lurek.audio.isLooping`: Returns whether a source has looping enabled.
- `lurek.audio.isPaused`: Returns whether a source is currently paused.
- `lurek.audio.isPlaying`: Returns whether a source is currently playing.
- `lurek.audio.isStopped`: Returns whether a source is currently stopped.
- `lurek.audio.judgeBeat`: Judges timing against the nearest beat grid for a beat clock.
- `lurek.audio.mixInto`: Mixes the samples of `src` into `dest` in-place (both must have the same format).
- `lurek.audio.newBeatClock`: Creates a musical beat clock for rhythm-game timing, tap-tempo, and beat scheduling.
- `lurek.audio.newBus`: Creates a new audio mixing bus for grouping and controlling sources.
- `lurek.audio.newDecoder`: Creates a streaming audio decoder for the given file. The file is opened relative to the game directory.
- `lurek.audio.newMidiPlayer`: Creates a new MIDI player instance, optionally loading a file immediately.
- `lurek.audio.newPool`: Creates a polyphonic sound pool that allows the same audio file to play on multiple simultaneous voices.
- `lurek.audio.newQueueableSource`: Creates a new queueable audio source for streaming PCM data buffer by buffer.
- `lurek.audio.newSoundData`: Creates a new SoundData object from a file path or blank buffer for procedural audio.
- `lurek.audio.newSource`: Creates a new audio source from a file path, either fully loaded or streaming.
- `lurek.audio.pause`: Pauses playback of a source at its current position.
- `lurek.audio.pauseAll`: Pauses all currently playing audio sources.
- `lurek.audio.play`: Starts playback of a source by handle, optionally routing through a named bus.
- `lurek.audio.playLooping`: Starts playback of a source with looping enabled in one call.
- `lurek.audio.playQueueable`: Starts playback of a queueable audio source.
- `lurek.audio.queueSource`: Queues a decoded audio chunk for playback on a queueable source.
- `lurek.audio.release`: Releases an audio source, freeing its memory and stopping playback.
- `lurek.audio.resume`: Resumes playback of a paused source.
- `lurek.audio.resumeAll`: Resumes all paused audio sources. This function is exposed to Lua scripts.
- `lurek.audio.saveWAV`: Encodes the sound data as a WAV file and saves it to the given path (relative to game dir).
- `lurek.audio.seek`: Seeks a source to a specific position in seconds.
- `lurek.audio.setDistanceModel`: Sets the distance attenuation model for spatial audio.
- `lurek.audio.setDopplerScale`: Sets the global Doppler effect intensity multiplier.
- `lurek.audio.setHighpass`: Applies a highpass filter to a source, attenuating low frequencies.
- `lurek.audio.setJudgementWindows`: Sets global default timing windows used by beat-clock judgement.
- `lurek.audio.setListener`: Sets the 3D listener position for spatial audio (Z defaults to 0 for 2D games).
- `lurek.audio.setListener2D`: Sets the 2D listener position for spatial audio calculations.
- `lurek.audio.setLooping`: Enables or disables looping for a source.
- `lurek.audio.setLowpass`: Applies a lowpass filter to a source, attenuating high frequencies.
- `lurek.audio.setMasterVolume`: Sets the global master volume affecting all audio output.
- `lurek.audio.setMeter`: Sets the master peak level for metering purposes.
- `lurek.audio.setMidiSoundFont`: Sets the SoundFont file used for MIDI synthesis.
- `lurek.audio.setOrientation`: Sets the orientation of a source using forward and up vectors.
- `lurek.audio.setPan`: Sets the stereo panning of a source.
- `lurek.audio.setPitch`: Sets the pitch multiplier of a source, affecting playback speed and tone.
- `lurek.audio.setPlaybackDevice`: Sets the active audio playback device by name.
- `lurek.audio.setPosition`: Sets the 3D position of a source for spatial audio panning and attenuation.
- `lurek.audio.setRandomPitch`: Sets a random pitch range for a source; each play picks a random pitch between min and max.
- `lurek.audio.setSourceBus`: Routes a source through a specific audio bus for grouped mixing.
- `lurek.audio.setStereoWidth`: Sets the stereo width of an audio source (0.0 = mono, 1.0 = full stereo).
- `lurek.audio.setVelocity`: Sets the velocity of a source for Doppler effect calculations.
- `lurek.audio.setVolume`: Sets the volume of a source by handle.
- `lurek.audio.set_bus_volume`: Sets the volume of a named audio bus.
- `lurek.audio.stop`: Stops playback of a source and resets its position to the beginning.
- `lurek.audio.stopAll`: Stops all audio sources and resets their positions.
- `lurek.audio.stopQueueable`: Stops playback of a queueable audio source.
- `lurek.audio.tell`: Returns the current playback position of a source in seconds.

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

- `LBeatClock:at`: Registers a one-shot callback fired when `beat` is crossed.
- `LBeatClock:beatTimeRemaining`: Returns seconds until the next division boundary.
- `LBeatClock:beatsPerBar`: Returns the number of beats per bar.
- `LBeatClock:bpm`: Returns the current tempo as beats-per-minute for this clock.
- `LBeatClock:cancel`: Cancels a scheduled callback handle.
- `LBeatClock:cancelAll`: Cancels all scheduled callback handles registered on this clock.
- `LBeatClock:drainFired`: Returns and removes all scheduled beats that have now passed.
- `LBeatClock:dump`: Returns a snapshot of clock state for debug and HUDs.
- `LBeatClock:every`: Registers a callback fired on each crossed step of `division`.
- `LBeatClock:getBar`: Returns the current fractional bar position across elapsed musical time.
- `LBeatClock:getBeat`: Returns fractional beat position.
- `LBeatClock:getBpm`: Returns the current tempo as beats-per-minute for this clock.
- `LBeatClock:getPhase`: Returns phase within the current division in [0, 1).
- `LBeatClock:isOnBeat`: Returns true when the clock is near a beat boundary.
- `LBeatClock:isRunning`: Returns true when the clock is running.
- `LBeatClock:nearestBeat`: Returns nearest beat and signed timing error in seconds.
- `LBeatClock:pattern`: Registers a repeating pattern callback where `x` triggers and `.` skips.
- `LBeatClock:position`: Returns the current beat position.
- `LBeatClock:quantise`: Quantises `beat` to the nearest `grid` beat grid (static utility).
- `LBeatClock:rampBpm`: Ramps BPM linearly to a target value over time.
- `LBeatClock:reset`: Resets elapsed time to zero without changing running state.
- `LBeatClock:scheduleAt`: Schedules a one-shot event at `beat`. Returns true when the beat is in the future.
- `LBeatClock:secondsPerBeat`: Returns seconds-per-beat at the current BPM.
- `LBeatClock:secondsToNextBeat`: Returns seconds until the next whole beat boundary.
- `LBeatClock:setBeatsPerBar`: Changes the time-signature beats-per-bar.
- `LBeatClock:setBpm`: Sets a new BPM. Elapsed time is preserved.
- `LBeatClock:setSwing`: Sets rhythmic swing amount in `[0.0, 0.5]` for off-beat timing feel.
- `LBeatClock:start`: Starts beat-clock playback so scheduled beat callbacks can begin firing.
- `LBeatClock:stop`: Stops beat-clock playback while preserving the current musical position.
- `LBeatClock:syncToSource`: Synchronizes beat position to an audio source playback position.
- `LBeatClock:tap`: Records a tap-tempo tap at `wall_time_secs`. Returns the estimated BPM (0.0 when fewer than 2 taps).
- `LBeatClock:tick`: Advances the clock by `dt` seconds. Returns an array of whole-beat crossings.
- `LBeatClock:type`: Returns the Lua-visible type name.
- `LBeatClock:typeOf`: Returns whether this handle matches the given type name.
- `LBeatClock:update`: Advances the clock by `dt` seconds and returns beat/bar transitions.

#### LBus Type

- Lua-side wrapper around an audio mixing bus for grouped volume and effect control.

##### Fields

- No documented fields.

##### Methods

- `LBus:clearDuck`: Removes the ducking configuration from this bus.
- `LBus:getName`: Returns the name of this audio bus. This method is available to Lua scripts.
- `LBus:getPeak`: Returns the current peak amplitude level of this bus for VU-meter displays.
- `LBus:getPitch`: Returns the current pitch multiplier of this bus.
- `LBus:getVolume`: Returns the current volume multiplier of this bus.
- `LBus:isPaused`: Returns whether this bus is currently paused.
- `LBus:pause`: Pauses all sources routed through this bus.
- `LBus:resume`: Resumes all sources routed through this bus that were paused.
- `LBus:setDuckTarget`: Configures ducking so this bus lowers the volume of a target bus when active.
- `LBus:setPitch`: Sets the pitch multiplier applied to all sources routed through this bus.
- `LBus:setVolume`: Sets the volume multiplier for all sources routed through this bus.
- `LBus:type`: Returns the type name of this object for runtime type-checking.
- `LBus:typeOf`: Checks whether this object matches the given type name.

#### LDecoder Type

- Lua-side wrapper around a streaming audio decoder for incremental PCM extraction.

##### Fields

- No documented fields.

##### Methods

- `LDecoder:decode`: Decodes the next chunk of audio data and returns it as a LSoundData object.
- `LDecoder:getBitDepth`: Returns the bit depth of the source audio file.
- `LDecoder:getChannelCount`: Returns the number of audio channels in the source file.
- `LDecoder:getDuration`: Returns the total duration of the source audio file in seconds.
- `LDecoder:getSampleRate`: Returns the sample rate of the source audio file.
- `LDecoder:isSeekable`: Returns whether this decoder supports seeking.
- `LDecoder:release`: Releases decoder resources (no-op, kept for API symmetry).
- `LDecoder:rewind`: Rewinds the decoder back to the beginning of the audio stream.
- `LDecoder:seek`: Seeks to a specific position in the audio stream.
- `LDecoder:tell`: Returns the current read position in the audio stream in seconds.
- `LDecoder:type`: Returns the type name of this object for runtime type-checking.
- `LDecoder:typeOf`: Checks whether this object matches the given type name.

#### LMidiPlayer Type

- Lua-side wrapper around a MIDI file player with per-channel control and tempo scaling.

##### Fields

- No documented fields.

##### Methods

- `LMidiPlayer:getBus`: Returns the audio bus this MIDI player is routed through.
- `LMidiPlayer:getChannelCount`: Returns the number of active MIDI channels in the loaded file.
- `LMidiPlayer:getChannelInstrument`: Returns the current GM instrument program for a channel.
- `LMidiPlayer:getChannelVolume`: Returns the volume of a specific MIDI channel.
- `LMidiPlayer:getChannels`: Returns the number of output audio channels for MIDI synthesis.
- `LMidiPlayer:getDuration`: Returns the total duration of the loaded MIDI file in seconds.
- `LMidiPlayer:getFilePath`: Returns the file path of the currently loaded MIDI file.
- `LMidiPlayer:getNoteCount`: Returns the total number of note events in the loaded MIDI file.
- `LMidiPlayer:getOriginalTempo`: Returns the original tempo of the MIDI file as authored.
- `LMidiPlayer:getSampleRate`: Returns the output sample rate used for MIDI synthesis.
- `LMidiPlayer:getSoundFontPath`: Returns the path of the currently set SoundFont (stub, not yet implemented).
- `LMidiPlayer:getTempo`: Returns the current effective tempo in beats per minute.
- `LMidiPlayer:getTempoScale`: Returns the current tempo scale multiplier.
- `LMidiPlayer:getTicksPerBeat`: Returns the MIDI file's resolution in ticks per beat (PPQN).
- `LMidiPlayer:getTrackCount`: Returns the number of tracks in the loaded MIDI file.
- `LMidiPlayer:getTrackName`: Returns the name of a MIDI track by 1-based index.
- `LMidiPlayer:getVolume`: Returns the current master volume of the MIDI player.
- `LMidiPlayer:isChannelMuted`: Returns whether a specific MIDI channel is muted.
- `LMidiPlayer:isLoaded`: Returns whether a MIDI file is currently loaded and ready to play.
- `LMidiPlayer:isLooping`: Returns whether MIDI looping is enabled.
- `LMidiPlayer:isPaused`: Returns whether the MIDI player is currently paused.
- `LMidiPlayer:isPlaying`: Returns whether the MIDI player is currently playing.
- `LMidiPlayer:isTrackMuted`: Returns whether a specific MIDI track is muted.
- `LMidiPlayer:load`: Loads a MIDI file from the given path relative to the game directory.
- `LMidiPlayer:loadData`: Loads MIDI data from a raw byte string in memory.
- `LMidiPlayer:pause`: Pauses MIDI playback at the current position.
- `LMidiPlayer:play`: Starts MIDI playback from the current position using the audio output stream.
- `LMidiPlayer:seek`: Seeks to a specific position in the MIDI file.
- `LMidiPlayer:setBus`: Routes this MIDI player's output through the specified audio bus.
- `LMidiPlayer:setChannelInstrument`: Sets the General MIDI instrument program for a channel.
- `LMidiPlayer:setChannelMuted`: Mutes or unmutes a specific MIDI channel.
- `LMidiPlayer:setChannelVolume`: Sets the volume for a specific MIDI channel (1-16).
- `LMidiPlayer:setChannels`: Sets the number of output audio channels for MIDI synthesis.
- `LMidiPlayer:setLooping`: Enables or disables looping for MIDI playback.
- `LMidiPlayer:setOnEnd`: Registers a callback invoked when MIDI playback finishes (stub, not yet implemented).
- `LMidiPlayer:setOnNoteOff`: Registers a callback for MIDI note-off events (stub, not yet implemented).
- `LMidiPlayer:setOnNoteOn`: Registers a callback for MIDI note-on events (stub, not yet implemented).
- `LMidiPlayer:setSampleRate`: Sets the output sample rate for MIDI synthesis.
- `LMidiPlayer:setSoundFont`: Sets a custom SoundFont file for MIDI synthesis (stub, not yet implemented).
- `LMidiPlayer:setTempo`: Sets the playback tempo in beats per minute.
- `LMidiPlayer:setTempoScale`: Sets a tempo multiplier relative to the original speed.
- `LMidiPlayer:setTrackMuted`: Mutes or unmutes a specific MIDI track.
- `LMidiPlayer:setVolume`: Sets the master volume for MIDI playback.
- `LMidiPlayer:soloChannel`: Solos a specific MIDI channel, muting all others.
- `LMidiPlayer:stop`: Stops MIDI playback and resets position to the beginning.
- `LMidiPlayer:tell`: Returns the current playback position of the MIDI player in seconds.
- `LMidiPlayer:type`: Returns the type name of this object for runtime type-checking.
- `LMidiPlayer:typeOf`: Checks whether this object matches the given type name.
- `LMidiPlayer:unsoloAll`: Removes solo from all channels, restoring normal playback.
- `LMidiPlayer:useDefaultSoundFont`: Reverts to the built-in default SoundFont (stub, not yet implemented).

#### LSoundData Type

- Represents the Lua-visible LSoundData object exposed by this module.

##### Fields

- No documented fields.

##### Methods

- `LSoundData:drawWaveform`: Draws this sound buffer as a waveform into an image buffer.
- `LSoundData:getBitDepth`: Returns the sample bit depth of this sound buffer.
- `LSoundData:getChannelCount`: Returns the number of audio channels stored in this sound buffer.
- `LSoundData:getDuration`: Returns the approximate playback duration of this sound buffer.
- `LSoundData:getSample`: Returns the sample value at the given zero-based sample index.
- `LSoundData:getSampleCount`: Returns the total number of samples stored in this sound buffer.
- `LSoundData:getSampleRate`: Returns the playback sample rate of this sound buffer.
- `LSoundData:setSample`: Overwrites the sample value at the given zero-based sample index.
- `LSoundData:type`: Returns the type name of this object for runtime type-checking.
- `LSoundData:typeOf`: Checks whether this object matches the given type name.

#### LSoundPool Type

- Lua-side wrapper around a pre-allocated pool of identical sound voices for rapid fire effects.

##### Fields

- No documented fields.

##### Methods

- `LSoundPool:getVoiceCount`: Returns the number of pre-allocated voices in this pool.
- `LSoundPool:play`: Plays the next available voice from the pool in round-robin order.
- `LSoundPool:release`: Releases all voices and frees audio resources held by this pool.
- `LSoundPool:setBus`: Routes all voices in this pool through the named audio bus.
- `LSoundPool:setVolume`: Sets the volume for all voices in this pool.
- `LSoundPool:stopAll`: Stops all voices in this sound pool immediately.
- `LSoundPool:type`: Returns the type name of this object for runtime type-checking.
- `LSoundPool:typeOf`: Checks whether this object matches the given type name.

#### LSource Type

- Lua-side wrapper around a loaded audio source (sound effect or music stream).

##### Fields

- No documented fields.

##### Methods

- `LSource:clearFilter`: Removes all frequency filters (lowpass and highpass) from this source.
- `LSource:clone`: Creates an independent copy of this source sharing the same audio data.
- `LSource:fadeIn`: Sets the fade-in duration so the source ramps from silence to full volume on play.
- `LSource:getDuration`: Returns the total duration of this audio source in seconds.
- `LSource:getFadeIn`: Returns the configured fade-in duration for this source.
- `LSource:getHighpass`: Returns the current highpass filter cutoff frequency in Hertz.
- `LSource:getLowpass`: Returns the current lowpass filter cutoff frequency in Hertz.
- `LSource:getPan`: Returns the current stereo panning position of this source.
- `LSource:getPitch`: Returns the current pitch multiplier of this audio source.
- `LSource:getType`: Returns whether this source was loaded as static (fully in memory) or streaming.
- `LSource:getVolume`: Returns the current volume level of this audio source.
- `LSource:isLooping`: Returns whether this source is set to loop continuously.
- `LSource:isPaused`: Returns whether this source is currently paused.
- `LSource:isPlaying`: Returns whether this source is currently playing audio.
- `LSource:isStopped`: Returns whether this source is currently stopped (not playing or paused).
- `LSource:pause`: Pauses playback at the current position, allowing later resumption.
- `LSource:play`: Starts playback of this audio source from the current position.
- `LSource:resume`: Resumes playback from the position where the source was paused.
- `LSource:seek`: Seeks to a specific position in seconds within this audio source.
- `LSource:setHighpass`: Applies a highpass filter that attenuates frequencies below the cutoff.
- `LSource:setLooping`: Enables or disables looping so the source restarts automatically after finishing.
- `LSource:setLowpass`: Applies a lowpass filter that attenuates frequencies above the cutoff.
- `LSource:setPan`: Sets the stereo panning position of this source.
- `LSource:setPitch`: Sets the playback speed multiplier, affecting both pitch and duration.
- `LSource:setVolume`: Sets the volume level of this source where 0.0 is silent and 1.0 is full volume.
- `LSource:stop`: Stops playback and resets the source position to the beginning.
- `LSource:tell`: Returns the current playback position of this source in seconds.
- `LSource:type`: Returns the type name of this object for runtime type-checking.
- `LSource:typeOf`: Checks whether this object is of the given type name or a parent type.
