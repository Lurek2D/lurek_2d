# audio

## General Info

- Module group: `Platform Services`
- Source path: `src/audio/`
- Lua API path(s): `src/lua_api/audio_api.rs`
- Primary Lua namespace: `lurek.audio`
- Rust test path(s): tests/rust/unit/audio_tests.rs, tests/rust/unit/audio_sound_tests.rs
- Lua test path(s): tests/lua/unit/test_audio.lua, tests/lua/unit/test_audio_bus.lua, tests/lua/unit/test_audio_dsp.lua, tests/lua/integration/test_audio_timer.lua, tests/lua/integration/test_audio_event.lua, tests/lua/evidence/test_evidence_audio.lua, tests/lua/evidence/test_evidence_audio_bus.lua

## Summary

The audio module is Lurek2D's playback and mixing backend. It owns sound loading and decoding, per-source playback state, bus routing, master volume, spatial audio state, queueable PCM playback, and the DSP chain used to apply filters and other real-time effects to audio sources and buses.

This module exists so gameplay code can treat sound as engine-managed resources instead of juggling raw backend handles. `Mixer` is the operational center, `Bus` provides grouped control over multiple sources, `SoundData` exposes editable PCM data to Lua, and the DSP types make effect updates safe to push from the main thread while playback continues on the audio thread.

It intentionally does not own filesystem sandboxing, frame timing, or scripting registration. Audio files still come through `filesystem`, the app loop decides when scripts call playback functions, and `src/lua_api/audio_api.rs` decides how the audio surface is exposed to Lua. It also does not currently provide a full multi-device backend or a finished MIDI pipeline; MIDI support is partially present in code but currently constrained by missing parsing dependencies.

**Scope boundary**: This module currently depends on `runtime`. It stays within the Platform Services responsibility boundary defined in the architecture docs.

## Files

- `bus.rs`: Named audio bus for grouping sources under shared volume, pitch, and pause controls.
- `decoder.rs`: Streaming audio decoder for chunked PCM reading.
- `dsp.rs`: Digital signal processing effects for the Lurek2D audio pipeline.
- `midi.rs`: MIDI SoundFont state management.
- `midi_player.rs`: Software MIDI synthesizer: parses MIDI with `midly`, renders to PCM via sine-additive synthesis, and plays through a rodio `Sink`.
- `mixer.rs`: Core audio mixer that owns every loaded sound and drives playback through rodio.
- `mod.rs`: Audio subsystem for Lurek2D games.
- `sound_data.rs`: Decoded PCM audio sample buffer with per-sample read/write access.
- `source.rs`: Audio source type and playback state enums for the audio subsystem.

## Types

- `Bus` (`struct`, `bus.rs`): A named audio bus that applies volume, pitch, and pause overrides to all sources assigned to it.
- `Decoder` (`struct`, `decoder.rs`): Streaming audio decoder that reads PCM in fixed-size chunks.
- `AtomicParam` (`struct`, `dsp.rs`): Thread-safe atomic `f32` parameter backed by an `AtomicU32` bit-cast.
- `EffectType` (`enum`, `dsp.rs`): Category of DSP audio effect applied to a sound source.
- `EffectParams` (`struct`, `dsp.rs`): Shared configuration for a single DSP effect slot.
- `ActiveEffect` (`struct`, `dsp.rs`): Per-stream instantiation of an `EffectParams` slot, holding the filter state for a single audio stream.
- `SharedEffectGraph` (`struct`, `dsp.rs`): Shared, thread-safe graph of active DSP effects owned by a sound source.
- `DynamicEffectSource` (`struct`, `dsp.rs`): A rodio `Source` wrapper that applies a dynamic chain of DSP effects to an inner audio source.
- `MidiState` (`struct`, `midi.rs`): MIDI SoundFont state.
- `MidiData` (`struct`, `midi_player.rs`): Pre-parsed MIDI metadata extracted during `load()`.
- `MidiPlayer` (`struct`, `midi_player.rs`): Software MIDI player with sine-additive synthesis.
- `SourceType` (`enum`, `mixer.rs`): Type of audio source.
- `PlayState` (`enum`, `mixer.rs`): Playback state of an audio source.
- `QueueableSource` (`struct`, `mixer.rs`): A manually-fed streaming audio source that accepts raw f32 PCM data pushed buffer-by-buffer.
- `Mixer` (`struct`, `mixer.rs`): The `Mixer` is the single point of entry for all audio operations in Lurek2D.
- `SoundData` (`struct`, `sound_data.rs`): Decoded audio samples in f32 PCM format.
- `SpatialState` (`struct`, `source.rs`): 3D spatial audio state for an audio source.
- `AudioSource` (`struct`, `source.rs`): Handle for a loaded audio asset (legacy compatibility shim).

## Functions

- `Bus::new` (`bus.rs`): Creates a new bus with the given name, volume `1.0`, pitch `1.0`, and not paused.
- `Bus::name` (`bus.rs`): Returns the bus name.
- `Bus::volume` (`bus.rs`): Returns the bus volume (always `>= 0.0`).
- `Bus::set_volume` (`bus.rs`): Sets the bus volume, clamped to `>= 0.0`.
- `Bus::pitch` (`bus.rs`): Returns the bus pitch multiplier (always `>= 0.0`).
- `Bus::set_pitch` (`bus.rs`): Sets the bus pitch multiplier, clamped to `>= 0.0`.
- `Bus::pause` (`bus.rs`): Pauses the bus.
- `Bus::resume` (`bus.rs`): Resumes the bus.
- `Bus::is_paused` (`bus.rs`): Returns whether the bus is paused.
- `Bus::add_effect` (`bus.rs`): Adds a DSP effect to this audio bus.
- `Bus::remove_effect` (`bus.rs`): Removes a DSP effect from this audio bus by ID.
- `Decoder::from_file` (`decoder.rs`): Load an audio file and prepare it for chunked decoding.
- `Decoder::decode` (`decoder.rs`): Return the next chunk of samples, or `None` at EOF.
- `Decoder::get_duration` (`decoder.rs`): Return the total duration in seconds.
- `Decoder::seek` (`decoder.rs`): Seek to a time offset in seconds.
- `Decoder::tell` (`decoder.rs`): Return the current playback position in seconds.
- `Decoder::is_seekable` (`decoder.rs`): Returns whether this decoder supports seeking.
- `Decoder::rewind` (`decoder.rs`): Reset playback to the beginning.
- `AtomicParam::new` (`dsp.rs`): Creates a new `AtomicParam` initialised to `val`.
- `AtomicParam::get` (`dsp.rs`): Returns the current value, loaded with `Relaxed` ordering.
- `AtomicParam::set` (`dsp.rs`): Stores a new value with `Relaxed` ordering.
- `EffectParams::new` (`dsp.rs`): Creates a new `EffectParams` with the given slot ID and effect type.
- `EffectParams::set_param` (`dsp.rs`): Sets an effect parameter by name using lock-free atomic writes.
- `ActiveEffect::new` (`dsp.rs`): Creates a new `ActiveEffect` for the given effect configuration.
- `ActiveEffect::process` (`dsp.rs`): Applies this effect's DSP algorithm to a single PCM sample.
- `SharedEffectGraph::new` (`dsp.rs`): Creates an empty `SharedEffectGraph` with no effects in the chain.
- `new` (`dsp.rs`): Wraps an inner audio source with a dynamic DSP effect chain.
- `MidiState::new` (`midi.rs`): Create a new empty MidiState with no SoundFont loaded.
- `MidiState::set_soundfont` (`midi.rs`): Load a SoundFont from raw SF2 data.
- `MidiState::has_soundfont` (`midi.rs`): Check whether a SoundFont is currently loaded.
- `MidiState::clear_soundfont` (`midi.rs`): Clear the loaded SoundFont, freeing its memory.
- `MidiState::soundfont_path` (`midi.rs`): Get the path of the loaded SoundFont, if any.
- `MidiState::soundfont_data` (`midi.rs`): Get a reference to the raw SoundFont data, if loaded.
- `MidiPlayer::new` (`midi_player.rs`): Creates a new MidiPlayer with default settings.
- `MidiPlayer::load` (`midi_player.rs`): Loads and parses a MIDI file from the given path.
- `MidiPlayer::load_data` (`midi_player.rs`): Loads MIDI from raw bytes (e.g., embedded data).
- `MidiPlayer::is_loaded` (`midi_player.rs`): Returns whether a MIDI file is currently loaded.
- `MidiPlayer::file_path` (`midi_player.rs`): Returns the file path of the loaded MIDI, if any.
- `MidiPlayer::play` (`midi_player.rs`): Plays the loaded MIDI through the given output stream handle.
- `MidiPlayer::stop` (`midi_player.rs`): Stops playback and resets position to 0.
- `MidiPlayer::pause` (`midi_player.rs`): Pauses playback.
- `MidiPlayer::resume` (`midi_player.rs`): Resumes paused playback.
- `MidiPlayer::is_playing` (`midi_player.rs`): Returns whether the player is currently playing.
- `MidiPlayer::is_paused` (`midi_player.rs`): Returns whether the player is paused.
- `MidiPlayer::seek` (`midi_player.rs`): Seeks to a position in seconds.
- `MidiPlayer::tell` (`midi_player.rs`): Returns the current playback position in seconds.
- `MidiPlayer::duration` (`midi_player.rs`): Returns the duration of the loaded MIDI in seconds.
- `MidiPlayer::set_volume` (`midi_player.rs`): Sets the master volume (0.0 = silent, values above 1.0 amplify).
- `MidiPlayer::volume` (`midi_player.rs`): Returns the master volume.
- `MidiPlayer::set_looping` (`midi_player.rs`): Sets whether playback should loop.
- `MidiPlayer::is_looping` (`midi_player.rs`): Returns whether playback is set to loop.
- `MidiPlayer::set_tempo_scale` (`midi_player.rs`): Sets the tempo scale factor (minimum 0.01).
- `MidiPlayer::tempo_scale` (`midi_player.rs`): Returns the current tempo scale factor.
- `MidiPlayer::current_bpm` (`midi_player.rs`): Returns the current effective BPM.
- `MidiPlayer::original_tempo` (`midi_player.rs`): Returns the original tempo in BPM from the MIDI file.
- `MidiPlayer::ticks_per_beat` (`midi_player.rs`): Returns the ticks-per-beat value from the MIDI header.
- `MidiPlayer::set_channel_volume` (`midi_player.rs`): Sets the volume for a specific MIDI channel (0-15).
- `MidiPlayer::channel_volume` (`midi_player.rs`): Returns the volume for a specific MIDI channel (0-15).
- `MidiPlayer::set_channel_muted` (`midi_player.rs`): Sets the mute state for a specific MIDI channel (0-15).
- `MidiPlayer::is_channel_muted` (`midi_player.rs`): Returns whether a specific MIDI channel (0-15) is muted.
- `MidiPlayer::set_channel_instrument` (`midi_player.rs`): Sets the instrument (program number) for a MIDI channel (0-15).
- `MidiPlayer::channel_instrument` (`midi_player.rs`): Returns the instrument (program number) for a MIDI channel (0-15).
- `MidiPlayer::channel_count` (`midi_player.rs`): Returns the number of unique MIDI channels used in the loaded file.
- `MidiPlayer::solo_channel` (`midi_player.rs`): Solos a channel (mutes all others).
- `MidiPlayer::unsolo_all` (`midi_player.rs`): Un-solos all channels (unmutes all).
- `MidiPlayer::track_count` (`midi_player.rs`): Returns the number of tracks in the loaded MIDI file.
- `MidiPlayer::track_name` (`midi_player.rs`): Returns the name of a track by index, if it has one.
- `MidiPlayer::set_track_muted` (`midi_player.rs`): Sets the mute state for a specific track by index.
- `MidiPlayer::is_track_muted` (`midi_player.rs`): Returns whether a specific track is muted.
- `MidiPlayer::note_count` (`midi_player.rs`): Returns the total number of NoteOn events in the loaded MIDI.
- `MidiPlayer::set_bus_key` (`midi_player.rs`): Sets the audio bus key for mixer routing.
- `MidiPlayer::bus_key` (`midi_player.rs`): Returns the audio bus key, if assigned.
- `MidiPlayer::play_state` (`midi_player.rs`): Returns the current playback state.
- `QueueableSource::new` (`mixer.rs`): Creates a new `QueueableSource` with all buffer slots free.
- `QueueableSource::queue_buffer` (`mixer.rs`): Pushes a buffer of f32 PCM samples into the queue.
- `QueueableSource::free_buffer_count` (`mixer.rs`): Returns the number of buffer slots currently available.
- `Mixer::new` (`mixer.rs`): Creates a new `Mixer`, attempting to open the default system audio output.
- `Mixer::stream_handle` (`mixer.rs`): Returns a reference to the output stream handle, if available.
- `Mixer::load_source` (`mixer.rs`): Registers a new audio file path with the given source type and returns its key.
- `Mixer::play` (`mixer.rs`): Plays the audio source identified by `key`, loading and decoding the file on demand.
- `Mixer::stop` (`mixer.rs`): Stops playback of a sound and resets its position to the beginning.
- `Mixer::set_volume` (`mixer.rs`): Sets the per-source playback volume, clamped to `[0.0, 2.0]`.
- `Mixer::get_volume` (`mixer.rs`): Returns the per-source playback volume.
- `Mixer::pause` (`mixer.rs`): Pauses playback of the audio source identified by \key\.
- `Mixer::resume` (`mixer.rs`): Resumes playback of a paused audio source identified by \key\.
- `Mixer::set_pitch` (`mixer.rs`): Sets the playback speed (pitch) for the source, clamped to `[0.1, 4.0]`.
- `Mixer::get_pitch` (`mixer.rs`): Returns the pitch (playback speed) for the source.
- `Mixer::set_speed` (`mixer.rs`): Sets the playback speed (pitch) for the source, clamped to `[0.1, 4.0]`.
- `Mixer::is_playing` (`mixer.rs`): Returns whether the audio source is currently playing (not paused and not empty).
- `Mixer::get_play_state` (`mixer.rs`): Returns the playback state of the source, synced with the underlying sink.
- `Mixer::is_paused` (`mixer.rs`): Returns whether the source is paused.
- `Mixer::is_stopped` (`mixer.rs`): Returns whether the source is stopped.
- `Mixer::set_looping` (`mixer.rs`): Sets the looping flag for the source.
- `Mixer::is_looping` (`mixer.rs`): Returns whether the source is set to loop.
- `Mixer::play_looping` (`mixer.rs`): Plays the audio source in an infinite loop.
- `Mixer::set_pan` (`mixer.rs`): Sets the stereo pan for the source, clamped to `[-1.0, 1.0]`.
- `Mixer::get_pan` (`mixer.rs`): Returns the stereo pan for the source.
- `Mixer::set_master_volume` (`mixer.rs`): Sets the master volume applied to all sources, clamped to `[0.0, 1.0]`.
- `Mixer::get_master_volume` (`mixer.rs`): Returns the master volume.
- `Mixer::get_source_type` (`mixer.rs`): Returns the source type for the given key.
- `Mixer::get_active_source_count` (`mixer.rs`): Returns the number of actively playing (not paused, not empty) sources.
- `Mixer::get_source_count` (`mixer.rs`): Returns the total number of loaded sources.
- `Mixer::contains_source` (`mixer.rs`): Returns whether the given source key still refers to a loaded audio source.
- `Mixer::pause_all` (`mixer.rs`): Pauses all currently playing sources.
- `Mixer::stop_all` (`mixer.rs`): Stops all sources and drops their sinks.
- `Mixer::resume_all` (`mixer.rs`): Resumes all paused sources.
- `Mixer::clone_source` (`mixer.rs`): Clones a source, sharing cached decoded data (for static sources).
- `Mixer::release` (`mixer.rs`): Stops and removes the audio source identified by `key`.
- `Mixer::new_bus` (`mixer.rs`): Creates a new named bus and returns its key.
- `Mixer::get_bus_by_name` (`mixer.rs`): Returns an immutable reference to the bus, if it exists.
- `Mixer::get_bus` (`mixer.rs`): Gets a bus by key.
- `Mixer::get_bus_mut` (`mixer.rs`): Returns a mutable reference to the bus, if it exists.
- `Mixer::set_source_bus` (`mixer.rs`): Assigns a source to a bus.
- `Mixer::get_source_bus` (`mixer.rs`): Returns the bus key assigned to a source, if any.
- `Mixer::get_duration` (`mixer.rs`): Returns the cached duration of the audio source in seconds, if known.
- `Mixer::get_tell` (`mixer.rs`): Returns the approximate current playback position in seconds.
- `Mixer::seek` (`mixer.rs`): Seeks the source to `position_secs` by rebuilding the sink from the new offset.
- `Mixer::set_lowpass` (`mixer.rs`): Sets a lowpass filter cutoff in Hz.
- `Mixer::clear_lowpass` (`mixer.rs`): Removes the lowpass filter from the source.
- `Mixer::set_highpass` (`mixer.rs`): Sets a highpass filter cutoff in Hz.
- `Mixer::clear_highpass` (`mixer.rs`): Removes the highpass filter from the source.
- `Mixer::clear_filter` (`mixer.rs`): Removes all filters (lowpass and highpass) from the source.
- `Mixer::get_lowpass` (`mixer.rs`): Returns the lowpass cutoff frequency in Hz, if set.
- `Mixer::get_highpass` (`mixer.rs`): Returns the highpass cutoff frequency in Hz, if set.
- `Mixer::set_fade_in` (`mixer.rs`): Sets the fade-in duration in seconds.
- `Mixer::clear_fade_in` (`mixer.rs`): Removes the fade-in setting from the source.
- `Mixer::get_fade_in` (`mixer.rs`): Returns the fade-in duration in seconds, if set.
- `Mixer::set_source_position` (`mixer.rs`): Sets the 3D spatial position of an audio source.
- `Mixer::get_source_position` (`mixer.rs`): Returns the 3D spatial position of an audio source.
- `Mixer::set_source_velocity` (`mixer.rs`): Sets the spatial velocity of an audio source (used for Doppler calculation).
- `Mixer::get_source_velocity` (`mixer.rs`): Returns the spatial velocity of an audio source.
- `Mixer::set_source_orientation` (`mixer.rs`): Sets the spatial orientation of an audio source.
- `Mixer::get_source_orientation` (`mixer.rs`): Returns the spatial orientation of an audio source.
- `Mixer::set_listener_position` (`mixer.rs`): Sets the 3D listener position for spatial audio.
- `Mixer::get_listener_position` (`mixer.rs`): Returns the 3D listener position.
- `Mixer::set_listener_orientation` (`mixer.rs`): Sets the listener orientation (forward + up vectors).
- `Mixer::get_listener_orientation` (`mixer.rs`): Returns the listener orientation (forward xyz + up xyz).
- `Mixer::set_listener_velocity` (`mixer.rs`): Sets the listener velocity for Doppler calculation.
- `Mixer::get_listener_velocity` (`mixer.rs`): Returns the listener velocity.
- `Mixer::set_doppler_scale` (`mixer.rs`): Sets the global Doppler effect scale.
- `Mixer::get_doppler_scale` (`mixer.rs`): Returns the global Doppler effect scale.
- `Mixer::set_distance_model` (`mixer.rs`): Sets the distance attenuation model.
- `Mixer::get_distance_model` (`mixer.rs`): Returns the current distance attenuation model name.
- `Mixer::new_queueable` (`mixer.rs`): Creates a new queueable source and returns its key.
- `Mixer::queue_buffer` (`mixer.rs`): Pushes a buffer of f32 PCM samples into a queueable source.
- `Mixer::queueable_free_buffer_count` (`mixer.rs`): Returns the number of free buffer slots for a queueable source.
- `Mixer::play_queueable` (`mixer.rs`): Marks a queueable source as playing (state bookkeeping only; actual PCM playback is driven by game code dequeuing buffers via `queue_buffer`).
- `Mixer::stop_queueable` (`mixer.rs`): Stops a queueable source, draining all queued buffers.
- `Mixer::release_queueable` (`mixer.rs`): Releases a queueable source, removing it from the slot-map.
- `get_playback_devices` (`mod.rs`): Returns the names of all available audio output devices.
- `get_playback_device` (`mod.rs`): Returns the name of the currently active audio output device.
- `set_playback_device` (`mod.rs`): Selects the audio output device by name.
- `SoundData::new` (`sound_data.rs`): Create a silent buffer with the given number of samples.
- `SoundData::from_samples` (`sound_data.rs`): Create a `SoundData` from an existing f32 sample buffer.
- `SoundData::from_lua_args` (`sound_data.rs`): Creates `SoundData` from Lua-originated arguments, supporting both file loading and silent buffer creation.
- `SoundData::from_file` (`sound_data.rs`): Decode an audio file to SoundData.
- `SoundData::get_sample` (`sound_data.rs`): Get a sample at the given index (interleaved).
- `SoundData::samples` (`sound_data.rs`): Returns the full interleaved f32 sample buffer as a slice.
- `SoundData::set_sample` (`sound_data.rs`): Set a sample at the given index (clamped to [-1.0, 1.0]).
- `SoundData::sample_count` (`sound_data.rs`): Get the number of samples per channel.
- `SoundData::sample_rate` (`sound_data.rs`): Get the sample rate in Hz.
- `SoundData::channel_count` (`sound_data.rs`): Get the number of audio channels.
- `SoundData::bit_depth` (`sound_data.rs`): Get the bit depth.
- `SoundData::duration` (`sound_data.rs`): Get the duration in seconds.
- `SoundData::as_samples` (`sound_data.rs`): Get a reference to the raw samples.
- `SoundData::encode_wav` (`sound_data.rs`): Encode the audio data as a WAV byte buffer (16-bit PCM).
- `AudioSource::new` (`source.rs`): Creates a new `AudioSource` with default volume (1.0) and looping disabled.

## Lua API Reference

- Binding path(s): `src/lua_api/audio_api.rs`
- Namespace: `lurek.audio`

### Module Functions
- `lurek.audio.newSource`: Loads an audio file and returns a Source handle.
- `lurek.audio.play`: Plays a source, with optional bus routing via options table.
- `lurek.audio.stop`: Stops playback and resets seek position.
- `lurek.audio.setVolume`: Sets source playback volume.
- `lurek.audio.getVolume`: Returns the source volume.
- `lurek.audio.pause`: Pauses playback at the current position.
- `lurek.audio.resume`: Resumes playback from pause.
- `lurek.audio.setPitch`: Sets source pitch multiplier.
- `lurek.audio.getPitch`: Returns the source pitch multiplier.
- `lurek.audio.isPlaying`: Returns true if the source is playing.
- `lurek.audio.isPaused`: Returns true if the source is paused.
- `lurek.audio.isStopped`: Returns true if the source is stopped.
- `lurek.audio.setLooping`: Enables or disables looping.
- `lurek.audio.isLooping`: Returns true if looping is enabled.
- `lurek.audio.playLooping`: Plays the source in a continuous loop.
- `lurek.audio.setPan`: Sets stereo panning (-1.0 left to 1.0 right).
- `lurek.audio.getPan`: Returns the source stereo panning.
- `lurek.audio.setMasterVolume`: Sets the global master volume.
- `lurek.audio.getMasterVolume`: Returns the global master volume.
- `lurek.audio.getActiveSourceCount`: Returns the number of currently playing sources.
- `lurek.audio.getSourceCount`: Returns the total number of registered sources.
- `lurek.audio.getSourceType`: Returns the type string ("static" or "stream") of a source.
- `lurek.audio.clone`: Creates an independent copy of a source.
- `lurek.audio.pauseAll`: Pauses all currently playing sources.
- `lurek.audio.stopAll`: Stops all currently playing sources.
- `lurek.audio.resumeAll`: Resumes all paused sources.
- `lurek.audio.release`: Releases a source and frees its memory.
- `lurek.audio.newBus`: Creates a named audio bus for grouping sources.
- `lurek.audio.setSourceBus`: Assigns a source to a bus.
- `lurek.audio.getSourceBus`: Returns the bus a source is assigned to, or nil.
- `lurek.audio.getMaxSources`: Returns the maximum number of simultaneous sources.
- `lurek.audio.getDuration`: Returns the total duration of a source in seconds.
- `lurek.audio.tell`: Returns the current playback position in seconds.
- `lurek.audio.seek`: Seeks to a time position in seconds.
- `lurek.audio.setLowpass`: Applies a low-pass filter to a source.
- `lurek.audio.setHighpass`: Applies a high-pass filter to a source.
- `lurek.audio.getLowpass`: Returns the low-pass filter cutoff of a source.
- `lurek.audio.getHighpass`: Returns the high-pass filter cutoff of a source.
- `lurek.audio.clearFilter`: Removes any active filter from a source.
- `lurek.audio.fadeIn`: Fades a source in from silence over the given duration.
- `lurek.audio.getFadeIn`: Returns the fade-in duration of a source.
- `lurek.audio.setListener2D`: Sets the 2D listener position for spatial audio.
- `lurek.audio.getListener2D`: Returns the 2D listener position (x, y).
- `lurek.audio.setListener`: Sets the 3D listener position.
- `lurek.audio.getListener`: Returns the 3D listener position (x, y, z).
- `lurek.audio.setPosition`: Sets the 3D position of a source.
- `lurek.audio.getPosition`: Returns the 3D position of a source (x, y, z).
- `lurek.audio.setVelocity`: Sets the velocity of a source for Doppler.
- `lurek.audio.getVelocity`: Returns the velocity of a source (x, y, z).
- `lurek.audio.setOrientation`: Sets the 6-component orientation of a source.
- `lurek.audio.getOrientation`: Returns the 6-component orientation of a source.
- `lurek.audio.setDopplerScale`: Sets the global Doppler effect scale.
- `lurek.audio.getDopplerScale`: Returns the current Doppler scale.
- `lurek.audio.setDistanceModel`: Sets the distance attenuation model.
- `lurek.audio.getDistanceModel`: Returns the current distance model name.
- `lurek.audio.setMeter`: Sets the metering scale (stub).
- `lurek.audio.getMeter`: Returns the current peak level (stub).
- `lurek.audio.newMidiPlayer`: Creates a MIDI player, optionally loading a file.
- `lurek.audio.newSoundData`: Creates a SoundData from a file or as a silent buffer.
- `lurek.audio.setMidiSoundFont`: Sets the global SoundFont for MIDI synthesis.
- `lurek.audio.hasMidiSoundFont`: Returns true if a SoundFont is loaded.
- `lurek.audio.clearMidiSoundFont`: Unloads the active SoundFont.
- `lurek.audio.newDecoder`: Creates a streaming audio decoder.
- `lurek.audio.newQueueableSource`: Creates a queueable source for manual PCM buffering.
- `lurek.audio.queueSource`: Pushes a SoundData buffer into a queueable source.
- `lurek.audio.getFreeBufferCount`: Returns the free buffer slots in a queueable source.
- `lurek.audio.playQueueable`: Starts playback of a queueable source.
- `lurek.audio.stopQueueable`: Stops a queueable source and drains its buffers.
- `lurek.audio.getPlaybackDevices`: Returns a table of available audio output device names.
- `lurek.audio.getPlaybackDevice`: Returns the current audio output device name.
- `lurek.audio.setPlaybackDevice`: Selects an audio output device by name.
- `lurek.audio.create_bus`: Creates a bus by name (functional style).
- `lurek.audio.set_bus_volume`: Sets a bus volume by name.
- `lurek.audio.add_effect`: Adds a DSP effect to a bus.
- `lurek.audio.remove_effect`: Removes a DSP effect from a bus.
- `lurek.audio.set_effect_param`: Sets a parameter on a DSP effect.
- `lurek.audio.saveWAV`: Saves a SoundData as a 16-bit PCM WAV file at the given path.

### `Bus` Methods
- `Bus:getName`: Returns the bus name.
- `Bus:setVolume`: Sets the volume for all sources on this bus.
- `Bus:getVolume`: Returns the bus volume.
- `Bus:setPitch`: Sets the pitch multiplier for all sources on this bus.
- `Bus:getPitch`: Returns the bus pitch multiplier.
- `Bus:pause`: Pauses all sources on this bus.
- `Bus:resume`: Resumes all sources on this bus.
- `Bus:isPaused`: Returns true if this bus is paused.
- `Bus:type`: Returns the type name of this object.
- `Bus:typeOf`: Returns true if this object is of the given type.

### `Decoder` Methods
- `Decoder:decode`: Decodes the next chunk of samples, or nil at EOF.
- `Decoder:getChannelCount`: Returns the number of audio channels.
- `Decoder:getBitDepth`: Returns the bit depth.
- `Decoder:getSampleRate`: Returns the sample rate in Hz.
- `Decoder:getDuration`: Returns the total duration in seconds.
- `Decoder:seek`: Seeks to a time offset in seconds.
- `Decoder:rewind`: Rewinds to the beginning.
- `Decoder:tell`: Returns the current position in seconds.
- `Decoder:isSeekable`: Returns true if seeking is supported.
- `Decoder:release`: Releases the decoder (no-op).

### `MidiPlayer` Methods
- `MidiPlayer:load`: Loads a MIDI file from the given path.
- `MidiPlayer:loadData`: Loads MIDI data from a Lua string.
- `MidiPlayer:isLoaded`: Returns true if a MIDI sequence is loaded.
- `MidiPlayer:getFilePath`: Returns the file path of the loaded MIDI, or nil.
- `MidiPlayer:setSoundFont`: Loads a SoundFont file into this player (stub).
- `MidiPlayer:getSoundFontPath`: Returns the SoundFont file path, or nil (stub).
- `MidiPlayer:useDefaultSoundFont`: Reverts to the built-in default SoundFont (stub).
- `MidiPlayer:play`: Starts MIDI playback.
- `MidiPlayer:pause`: Pauses MIDI playback.
- `MidiPlayer:stop`: Stops MIDI playback.
- `MidiPlayer:isPlaying`: Returns true if MIDI is currently playing.
- `MidiPlayer:isPaused`: Returns true if MIDI playback is paused.
- `MidiPlayer:seek`: Seeks to a time position in seconds.
- `MidiPlayer:tell`: Returns the current playback position in seconds.
- `MidiPlayer:getDuration`: Returns the total MIDI duration in seconds.
- `MidiPlayer:setLooping`: Enables or disables looping.
- `MidiPlayer:isLooping`: Returns true if looping is enabled.
- `MidiPlayer:setVolume`: Sets MIDI playback volume.
- `MidiPlayer:getVolume`: Returns the current MIDI volume.
- `MidiPlayer:setBus`: Routes MIDI output through a bus (or nil to clear).
- `MidiPlayer:getBus`: Returns the assigned bus, or nil.
- `MidiPlayer:setTempo`: Sets playback tempo in BPM.
- `MidiPlayer:getTempo`: Returns the current tempo in BPM.
- `MidiPlayer:getOriginalTempo`: Returns the original MIDI file tempo in BPM.
- `MidiPlayer:setTempoScale`: Sets the tempo scale factor (1.0 = original speed).
- `MidiPlayer:getTempoScale`: Returns the current tempo scale factor.
- `MidiPlayer:getTicksPerBeat`: Returns the PPQ resolution from the MIDI header.
- `MidiPlayer:setChannelVolume`: Sets volume for a MIDI channel (1-indexed).
- `MidiPlayer:getChannelVolume`: Returns the volume for a MIDI channel (1-indexed).
- `MidiPlayer:setChannelMuted`: Mutes or unmutes a MIDI channel (1-indexed).
- `MidiPlayer:isChannelMuted`: Returns true if a MIDI channel is muted (1-indexed).
- `MidiPlayer:getChannelInstrument`: Returns the GM instrument for a MIDI channel (1-indexed).
- `MidiPlayer:getChannelCount`: Returns the number of MIDI channels.
- `MidiPlayer:soloChannel`: Solos a MIDI channel (1-indexed).
- `MidiPlayer:unsoloAll`: Clears solo on all channels.
- `MidiPlayer:getTrackCount`: Returns the number of tracks in the MIDI sequence.
- `MidiPlayer:getTrackName`: Returns the name of a MIDI track (1-indexed), or nil.
- `MidiPlayer:setTrackMuted`: Mutes or unmutes a track (1-indexed).
- `MidiPlayer:isTrackMuted`: Returns true if a track is muted (1-indexed).
- `MidiPlayer:getNoteCount`: Returns the total note count in the MIDI sequence.
- `MidiPlayer:setOnNoteOn`: Registers a note-on callback (stub).
- `MidiPlayer:setOnNoteOff`: Registers a note-off callback (stub).
- `MidiPlayer:setOnEnd`: Registers a playback-end callback (stub).
- `MidiPlayer:type`: Returns the type name of this object.
- `MidiPlayer:typeOf`: Returns true if this object is of the given type.

### `Source` Methods
- `Source:play`: Starts or resumes playback.
- `Source:stop`: Stops playback and resets seek position.
- `Source:pause`: Pauses playback at the current position.
- `Source:resume`: Resumes playback from the paused position.
- `Source:setVolume`: Sets playback volume (0.0 = silent, 1.0 = full).
- `Source:getVolume`: Returns the current volume multiplier.
- `Source:setPitch`: Sets the pitch multiplier (1.0 = normal).
- `Source:getPitch`: Returns the current pitch multiplier.
- `Source:setLooping`: Enables or disables looping playback.
- `Source:isLooping`: Returns true if looping is enabled.
- `Source:isPlaying`: Returns true if currently playing.
- `Source:isPaused`: Returns true if playback is paused.
- `Source:isStopped`: Returns true if playback has stopped.
- `Source:setPan`: Sets stereo panning (-1.0 left to 1.0 right).
- `Source:getPan`: Returns the current stereo panning value.
- `Source:clone`: Creates an independent copy of this source.
- `Source:getType`: Returns the source type ("static" or "stream").
- `Source:getDuration`: Returns the total duration in seconds.
- `Source:tell`: Returns the current playback position in seconds.
- `Source:seek`: Seeks to a time position in seconds.
- `Source:setLowpass`: Applies a low-pass filter at the given cutoff frequency.
- `Source:setHighpass`: Applies a high-pass filter at the given cutoff frequency.
- `Source:getLowpass`: Returns the low-pass filter cutoff frequency.
- `Source:getHighpass`: Returns the high-pass filter cutoff frequency.
- `Source:clearFilter`: Removes any active filter from this source.
- `Source:fadeIn`: Fades in from silence over the given duration in seconds.
- `Source:getFadeIn`: Returns the current fade-in duration in seconds.

### `mlua` Methods
- `mlua:getSampleCount`: Lua-facing function documented in the binding source.
- `mlua:getSampleRate`: Lua-facing function documented in the binding source.
- `mlua:getChannelCount`: Lua-facing function documented in the binding source.
- `mlua:getDuration`: Lua-facing function documented in the binding source.
- `mlua:getBitDepth`: Lua-facing function documented in the binding source.
- `mlua:getSample`: Lua-facing function documented in the binding source.
- `mlua:setSample`: Lua-facing function documented in the binding source.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/audio/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
