# audio

## TL;DR

- The `audio` module provides a comprehensive, high-performance sound engine for Lurek2D, built on top of `rodio` and positioned within the Platform Services tier.

## General Info

- Module group: `Platform Services`
- Source path: `src/audio/`
- Lua API path(s): `src/lua_api/audio_api.rs`
- Primary Lua namespace: `lurek.audio`
- Rust test path(s): tests/rust/unit/audio_tests.rs, tests/rust/unit/audio_sound_tests.rs
- Lua test path(s): tests/lua/unit/test_audio.lua, tests/lua/unit/test_audio_bus.lua, tests/lua/unit/test_audio_dsp.lua, tests/lua/integration/test_audio_timer.lua, tests/lua/integration/test_audio_event.lua, tests/lua/evidence/test_evidence_audio.lua, tests/lua/evidence/test_evidence_audio_bus.lua

## Summary

 It manages the entire audio lifecycle, including loading, real-time playback, bus mixing, DSP effects, spatial 2D audio, MIDI synthesis, and offline processing. At the core of the module is the `Mixer`, which serves as the central registry for all audio operations. It utilizes a highly efficient `SlotMap` to provide O(1) handle lookups for `AudioEntry` records, ensuring that the engine can effortlessly manage hundreds of concurrent sound instances. Audio sources can be loaded as fully decoded `Static` in-memory buffers for zero-latency sound effects, or as `Stream` sources for memory-efficient incremental decoding of longer music and voice tracks.

A standout feature of the `audio` module is its advanced `Bus` routing system. It supports hierarchical audio buses—such as Master, SFX, Music, and Voice—each equipped with its own volume, pitch, pause state, and dynamic `EffectChain`. The DSP effect system provides a rich suite of audio filters, including low-pass, high-pass, biquad EQ, reverb, chorus, flanger, phaser, distortion, limiter, and compressor. These effects operate using lock-free atomic parameters, allowing Lua scripts to modulate audio parameters dynamically without blocking the audio thread. Additionally, buses support automatic ducking, meaning a 'Voice' bus can automatically suppress the volume of a 'Music' bus when active.

For environmental immersion, the module includes a robust spatial audio system. It tracks the 3D position, velocity, and orientation of both the listener and individual audio sources. This enables realistic distance attenuation (using configurable drop-off models), stereo panning, and accurate Doppler shift effects based on relative velocities. Furthermore, to prevent audio stuttering during intense scenes, the `SoundPool` implements a round-robin polyphonic voice pool with intelligent voice stealing for one-shot playback of heavily reused assets like footsteps or weapon fire.

Beyond standard PCM playback, the module natively supports MIDI file playback via a built-in software synthesizer. The `MidiPlayer` translates MIDI note events into PCM audio using loaded SoundFont data, offering complete transport controls, per-channel muting, and instrument assignment. Finally, an `offline` processing suite allows developers to apply DSP effect chains or perform peak normalization on audio files directly to disk without requiring real-time playback, which is invaluable for asset pipelining. The entire feature set is cleanly exposed to Lua through the `lurek.audio.*` namespace, giving script developers full control over sound design and dynamic mixing.

## Source Documentation

### `bus.rs`
- Named audio routing bus with per-bus volume, pitch, pause, and duck-target controls.
- Shared DSP effect chain stored as `Arc<RwLock<Vec<Arc<EffectParams>>>>` for lock-free audio-thread reads.
- Dynamic add/remove of typed effects (lowpass, reverb, chorus, compressor, etc.) with runtime IDs.
- Duck-target assignment enabling automatic cross-bus volume suppression.
- Boundary clamping on volume, pitch, and duck volume values.

### `decoder.rs`
- Full-file PCM decoder backed by rodio for WAV/OGG/MP3/FLAC formats.
- Random-access seek and rewind via cursor over the decoded i16 sample buffer.
- Chunked iteration with configurable `buffer_size` for streaming consumption.
- Duration and position queries derived from sample rate and channel count.
- Seekable flag always true since the entire file is held in memory.

### `dsp.rs`
- Lock-free `AtomicParam` for sharing f32 parameters between the audio thread and Lua API.
- `EffectType` enum covering biquad filters, reverbs, chorus, flanger, phaser, distortion, limiter, and compressor.
- `EffectParams` shared parameter block with named `set_param` dispatch per effect type.
- `ActiveEffect` per-source instantiation holding biquad delay elements, circular comb buffer, LFO phase, and envelope state.
- Sample-by-sample `process` implementing each algorithm variant with clamped parameter reads.
- `SharedEffectGraph` Arc-wrapped effect list shared between `Bus` (writer) and `DynamicEffectSource` (reader).
- `DynamicEffectSource<I>` rodio `Source` wrapper applying the full effect chain per sample with per-frame sync.
- Comb-buffer sizing derived from sample rate and effect type at construction time.
- Biquad coefficient computation for lowpass, highpass, bandpass, notch, low-shelf, high-shelf, and bell EQ.
- LFO-driven modulated delay for flanger and phaser with depth and rate controls.

### `facade.rs`
- Stub device enumeration and selection for the audio output backend.
- Always reports a single "Default" device until platform-specific enumeration is added.
- Validates device name against the available list on set.

### `midi.rs`
- `MidiState` storage for loaded SoundFont binary data and its source path.
- RIFF+sfbk header validation on `set_soundfont` to reject malformed SF2 files.
- Query and clear helpers for SoundFont availability and data access.

### `midi_player.rs`
- `MidiPlayer` stateful transport controller for MIDI file playback via rendered PCM.
- File loading with parsed metadata: duration, BPM, ticks-per-beat, track names, note count.
- Transport controls: play, stop, pause, resume, seek, tell, and duration queries.
- Per-channel volume, mute, instrument, and solo/unsolo operations across 16 MIDI channels.
- Per-track mute support keyed by track index.
- Configurable tempo scaling, looping, and output sample rate / channel count.
- Mixer bus assignment via `BusKey` for routed playback.
- `MidiData` metadata struct storing parsed song-level attributes.
- Helper functions for MIDI note-to-frequency conversion and sine-wave note rendering.

### `mixer.rs`
- `Mixer` central registry: slot-mapped sources, buses, queueable streams, and spatial listener state.
- rodio `OutputStream`/`OutputStreamHandle` ownership with graceful fallback when audio hardware is unavailable.
- Per-source playback lifecycle: load, play, stop, pause, resume, seek, clone, release.
- Per-source parameters: volume, pitch, pan, looping, lowpass/highpass cutoff, fade-in, spatial position/velocity.
- `Bus` integration: bus creation, name lookup, per-source bus assignment, bus-level volume/pitch/pause propagation.
- `QueueableSource` push-buffer streaming with fixed slot count and free-buffer tracking.
- Spatial audio: listener position/orientation/velocity, per-source position/velocity/orientation, doppler scale, distance model.
- Peak metering: per-source, per-bus average, and master peak tracking.
- Stereo width, random pitch range, crossfade, and sound pool creation utilities.
- `SourceType` and `PlayState` enums for backing strategy and runtime state classification.

### `mod.rs`
- Audio subsystem module: mixer, buses, DSP effects, decoders, MIDI, pools, and visualisation.
- Re-exports primary types: `Mixer`, `Bus`, `Decoder`, `SoundData`, `MidiPlayer`, `SoundPool`.
- Submodule organisation separating playback, offline processing, and device enumeration.

### `offline.rs`
- Offline audio processing: apply DSP effect chains to files without real-time playback.
- Peak normalisation with configurable target level.
- WAV file decode to f32 and encode back to 16-bit PCM via rodio.
- `OfflineEffect` serialisable struct matching `EffectType` + three parameter slots.
- Parent directory auto-creation for output paths.

### `pool.rs`
- `SoundPool` round-robin polyphonic voice pool for one-shot playback of a single sound asset.
- Preloaded `SoundKey` voices cycled via `next_voice` for low-latency triggering.
- Per-pool volume multiplier and optional bus routing assignment.
- Validity check ensuring at least one voice is available.

### `sound_data.rs`
- `SoundData` in-memory interleaved f32 PCM buffer with per-sample get/set and metadata.
- File decode via rodio, silent-buffer allocation, and Lua argument factory.
- WAV encoding to byte vector for save/export.
- Waveform generators: sine, square, sawtooth, triangle, and deterministic white noise.
- In-place DSP transforms: low-pass, high-pass, band-pass, gain, and mix-into.
- Waveform drawing into `ImageData` for visual feedback.
- Duration, sample count, and channel count queries.

### `source.rs`
- `SpatialState` 3D position, velocity, and orientation for positional audio.
- `AudioSource` basic metadata struct: ID, file path, volume, and looping flag.
- Default spatial state: origin position, zero velocity, forward -Z / up +Y orientation.

### `visualizer.rs`
- Waveform-to-PNG rendering: peak min/max per column plotted as vertical bars.
- Spectrogram-to-PNG rendering: Hann-windowed DFT with frequency bins mapped to heatmap colours.
- Mono downmix helper for multi-channel input files.
- Heat-colour mapping from normalised magnitude to RGBA.
- Parent directory auto-creation for output image paths.

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
- `OfflineEffect` (`struct`, `offline.rs`): Descriptor for a single DSP effect used in offline processing.
- `SoundPool` (`struct`, `pool.rs`): A round-robin voice pool for polyphonic playback of a single audio file.
- `SoundData` (`struct`, `sound_data.rs`): Decoded audio samples in f32 PCM format.
- `SpatialState` (`struct`, `source.rs`): 3D spatial audio state for an audio source.
- `AudioSource` (`struct`, `source.rs`): Handle for a loaded audio asset (legacy compatibility shim).

## Functions

- `Bus::new` (`bus.rs`): Create a new bus with the given name, volume=1.0, pitch=1.0, unpaused, and no effects.
- `Bus::name` (`bus.rs`): Return the name of this bus.
- `Bus::volume` (`bus.rs`): Return the current volume multiplier for this bus.
- `Bus::set_volume` (`bus.rs`): Set the volume multiplier; values below 0.0 are clamped to 0.0.
- `Bus::pitch` (`bus.rs`): Return the current pitch multiplier for this bus.
- `Bus::set_pitch` (`bus.rs`): Set the pitch multiplier; values below 0.0 are clamped to 0.0.
- `Bus::pause` (`bus.rs`): Pause all sources on this bus; no-op if already paused.
- `Bus::resume` (`bus.rs`): Resume all sources on this bus; no-op if already playing.
- `Bus::is_paused` (`bus.rs`): Return `true` when this bus is paused.
- `Bus::add_effect` (`bus.rs`): Append a DSP effect of `effect_type_str` with initial parameter `p1_val` to the chain; returns the new effect ID.
- `Bus::remove_effect` (`bus.rs`): Remove the DSP effect with `effect_id` from the chain; error if not found.
- `Bus::set_duck_target` (`bus.rs`): Set the duck target bus name and duck volume; volume is clamped to 0.0..=1.0.
- `Bus::clear_duck_target` (`bus.rs`): Remove configured duck target from this bus.
- `Decoder::from_file` (`decoder.rs`): Open and fully decode `path` using rodio; `buffer_size` sets the chunk size for `decode()`.
- `Decoder::decode` (`decoder.rs`): Return the next `buffer_size` samples as a `Vec<i16>`, advancing the cursor; `None` at end.
- `Decoder::get_duration` (`decoder.rs`): Return total audio duration in seconds; 0.0 if sample rate or channel count is zero.
- `Decoder::seek` (`decoder.rs`): Seek to `offset` seconds from the start, clamping to the end of the buffer.
- `Decoder::tell` (`decoder.rs`): Return the current playback position in seconds.
- `Decoder::is_seekable` (`decoder.rs`): Return `true`; the PCM buffer always supports random-access seeking.
- `Decoder::rewind` (`decoder.rs`): Reset the read cursor to the start of the buffer.
- `AtomicParam::new` (`dsp.rs`): Create a new `AtomicParam` initialised to `val`.
- `AtomicParam::get` (`dsp.rs`): Return the current f32 value using `Relaxed` ordering.
- `AtomicParam::set` (`dsp.rs`): Store a new f32 value using `Relaxed` ordering.
- `EffectParams::new` (`dsp.rs`): Create new `EffectParams` with `id`, `typ`, and all parameters initialised to 0.0.
- `EffectParams::set_param` (`dsp.rs`): Set a named parameter on this effect; error if `param` is not valid for `typ`.
- `ActiveEffect::new` (`dsp.rs`): Allocate `ActiveEffect` for `params`, sizing `comb_buf` based on effect type and `sample_rate`.
- `ActiveEffect::process` (`dsp.rs`): Apply the effect to one `sample` on `channel`, returning the processed output sample.
- `SharedEffectGraph::new` (`dsp.rs`): Create an empty `SharedEffectGraph`.
- `new` (`dsp.rs`): Wraps an inner audio source with a dynamic DSP effect chain.
- `get_playback_devices` (`facade.rs`): Returns the names of all available audio output devices.
- `get_playback_device` (`facade.rs`): Returns the name of the currently active audio output device.
- `set_playback_device` (`facade.rs`): Selects the audio output device by name.
- `MidiState::new` (`midi.rs`): Create a new `MidiState` with no SoundFont loaded.
- `MidiState::set_soundfont` (`midi.rs`): Load `data` as an SF2 SoundFont, validating the RIFF+sfbk header; error if invalid.
- `MidiState::has_soundfont` (`midi.rs`): Return `true` when a SoundFont is loaded and ready for synthesis.
- `MidiState::clear_soundfont` (`midi.rs`): Unload the current SoundFont and clear its path.
- `MidiState::soundfont_path` (`midi.rs`): Return the source path of the loaded SoundFont, or `None` if none was loaded or path was not provided.
- `MidiState::soundfont_data` (`midi.rs`): Return a byte slice of the loaded SoundFont binary, or `None` if not loaded.
- `MidiPlayer::new` (`midi_player.rs`): Create a new MIDI player with default transport, channel, and output settings.
- `MidiPlayer::load` (`midi_player.rs`): Load MIDI bytes from `path` and pass them to `load_data`; return `false` on read or parse failure.
- `MidiPlayer::load_data` (`midi_player.rs`): Parse and prepare raw MIDI bytes for playback; currently disabled and always return `false`.
- `MidiPlayer::is_loaded` (`midi_player.rs`): Return `true` when parsed MIDI metadata is present.
- `MidiPlayer::file_path` (`midi_player.rs`): Return the loaded MIDI file path, or `None` when no file is loaded.
- `MidiPlayer::play` (`midi_player.rs`): Render the loaded MIDI to PCM and start playback on `stream_handle`; no-op if data is missing.
- `MidiPlayer::stop` (`midi_player.rs`): Stop playback, drop the sink, reset playhead to 0, and set state to `Stopped`.
- `MidiPlayer::pause` (`midi_player.rs`): Pause the active sink and set state to `Paused`.
- `MidiPlayer::resume` (`midi_player.rs`): Resume the active sink and transition from `Paused` to `Playing`.
- `MidiPlayer::is_playing` (`midi_player.rs`): Return `true` when playback state is `Playing`.
- `MidiPlayer::is_paused` (`midi_player.rs`): Return `true` when playback state is `Paused`.
- `MidiPlayer::seek` (`midi_player.rs`): Move the transport playhead to `secs`, clamped to >= 0.0.
- `MidiPlayer::tell` (`midi_player.rs`): Return the current transport playhead position in seconds.
- `MidiPlayer::duration` (`midi_player.rs`): Return song duration in seconds from metadata, or 0.0 if no MIDI is loaded.
- `MidiPlayer::set_volume` (`midi_player.rs`): Set output gain multiplier; values below 0.0 are clamped to 0.0.
- `MidiPlayer::volume` (`midi_player.rs`): Return the current output gain multiplier.
- `MidiPlayer::set_looping` (`midi_player.rs`): Enable or disable infinite playback looping.
- `MidiPlayer::is_looping` (`midi_player.rs`): Return `true` when looping playback is enabled.
- `MidiPlayer::set_tempo_scale` (`midi_player.rs`): Set tempo multiplier; clamped to at least 0.01.
- `MidiPlayer::tempo_scale` (`midi_player.rs`): Return the current tempo multiplier.
- `MidiPlayer::current_bpm` (`midi_player.rs`): Return the current effective BPM after tempo scaling.
- `MidiPlayer::original_tempo` (`midi_player.rs`): Return original BPM from MIDI metadata, or 120.0 when metadata is unavailable.
- `MidiPlayer::ticks_per_beat` (`midi_player.rs`): Return MIDI ticks-per-beat from metadata, or 0 when unavailable.
- `MidiPlayer::set_channel_volume` (`midi_player.rs`): Set channel volume for channel `ch` in 0..16; ignored for out-of-range channels.
- `MidiPlayer::channel_volume` (`midi_player.rs`): Return channel volume for `ch`, or 0.0 when `ch` is out of range.
- `MidiPlayer::set_channel_muted` (`midi_player.rs`): Set mute state for channel `ch` in 0..16; ignored for out-of-range channels.
- `MidiPlayer::is_channel_muted` (`midi_player.rs`): Return `true` when channel `ch` is muted and in range.
- `MidiPlayer::set_channel_instrument` (`midi_player.rs`): Set program/instrument number for channel `ch` in 0..16; ignored when out of range.
- `MidiPlayer::channel_instrument` (`midi_player.rs`): Return instrument number for channel `ch`, or 0 when out of range.
- `MidiPlayer::channel_count` (`midi_player.rs`): Return number of channels that contain note data in loaded metadata.
- `MidiPlayer::solo_channel` (`midi_player.rs`): Solo channel `ch` by muting all other channels.
- `MidiPlayer::unsolo_all` (`midi_player.rs`): Clear all channel mutes set by `solo_channel`.
- `MidiPlayer::track_count` (`midi_player.rs`): Return number of tracks in loaded metadata.
- `MidiPlayer::track_name` (`midi_player.rs`): Return optional track name for `idx`, or `None` if unavailable.
- `MidiPlayer::set_track_muted` (`midi_player.rs`): Set mute state for track `idx`; ignored if out of range.
- `MidiPlayer::is_track_muted` (`midi_player.rs`): Return `true` when track `idx` exists and is muted.
- `MidiPlayer::note_count` (`midi_player.rs`): Return total note event count in loaded metadata.
- `MidiPlayer::set_bus_key` (`midi_player.rs`): Assign or clear the mixer bus key used for this MIDI source.
- `MidiPlayer::bus_key` (`midi_player.rs`): Return the assigned mixer bus key, if any.
- `MidiPlayer::play_state` (`midi_player.rs`): Return current transport state.
- `MidiPlayer::get_output_sample_rate` (`midi_player.rs`): Return output sample rate used by MIDI PCM rendering.
- `MidiPlayer::set_output_sample_rate` (`midi_player.rs`): Set output sample rate, clamped to 8000..=192000 Hz.
- `MidiPlayer::get_output_channels` (`midi_player.rs`): Return output channel count used by MIDI PCM rendering.
- `MidiPlayer::set_output_channels` (`midi_player.rs`): Set output channel count, clamped to mono or stereo (1..=2).
- `QueueableSource::new` (`mixer.rs`): Create a queueable source with given sample rate, bit depth, channels, and buffer slot count.
- `QueueableSource::queue_buffer` (`mixer.rs`): Push `data` into the next free buffer slot; error if no slots are available.
- `QueueableSource::free_buffer_count` (`mixer.rs`): Return the number of unused buffer slots available for queuing.
- `Mixer::new` (`mixer.rs`): Create a new mixer, attempting to open the default audio output stream.
- `Mixer::stream_handle` (`mixer.rs`): Return a reference to the rodio output stream handle, or `None` if audio is unavailable.
- `Mixer::load_source` (`mixer.rs`): Register a new source entry for `file_path` with given `source_type` and return its key.
- `Mixer::play` (`mixer.rs`): Start or restart playback for the source; applies bus volume/pitch and builds a new sink.
- `Mixer::stop` (`mixer.rs`): Stop playback, drop the sink, and reset accumulated position to zero.
- `Mixer::set_volume` (`mixer.rs`): Set per-source volume multiplier; clamped to [0.0, 2.0] and applied to the active sink.
- `Mixer::get_volume` (`mixer.rs`): Return per-source volume multiplier, or 1.0 if the key is invalid.
- `Mixer::pause` (`mixer.rs`): Pause the source sink and accumulate elapsed play time.
- `Mixer::resume` (`mixer.rs`): Resume the paused source sink and restart the play-time clock.
- `Mixer::set_pitch` (`mixer.rs`): Set per-source pitch/speed multiplier; clamped to [0.1, 4.0] and applied to the active sink.
- `Mixer::get_pitch` (`mixer.rs`): Return per-source pitch multiplier, or 1.0 if the key is invalid.
- `Mixer::set_speed` (`mixer.rs`): Set playback speed (alias for `set_pitch`).
- `Mixer::is_playing` (`mixer.rs`): Return `true` when the source sink is active and not paused.
- `Mixer::get_play_state` (`mixer.rs`): Return the current transport state of the source by inspecting its sink.
- `Mixer::is_paused` (`mixer.rs`): Return `true` when the source is currently paused.
- `Mixer::is_stopped` (`mixer.rs`): Return `true` when the source is stopped or its sink is empty.
- `Mixer::set_looping` (`mixer.rs`): Set whether this source should loop.
- `Mixer::is_looping` (`mixer.rs`): Return `true` when the source is configured to loop.
- `Mixer::play_looping` (`mixer.rs`): Enable looping and start playback in one call.
- `Mixer::set_pan` (`mixer.rs`): Set stereo pan position; clamped to [-1.0, 1.0].
- `Mixer::get_pan` (`mixer.rs`): Return per-source pan position, or 0.0 if the key is invalid.
- `Mixer::set_master_volume` (`mixer.rs`): Set global master volume; clamped to [0.0, 1.0] and propagated to all active sinks.
- `Mixer::get_master_volume` (`mixer.rs`): Return the current master volume multiplier.
- `Mixer::get_source_type` (`mixer.rs`): Return the backing source type for the given key, or `None` if invalid.
- `Mixer::get_active_source_count` (`mixer.rs`): Return the number of sources currently playing (active sink, not paused).
- `Mixer::get_source_count` (`mixer.rs`): Return total number of registered sources (playing, paused, or stopped).
- `Mixer::contains_source` (`mixer.rs`): Return `true` when the source key is registered in the mixer.
- `Mixer::pause_all` (`mixer.rs`): Pause all playing sources and accumulate their elapsed time.
- `Mixer::stop_all` (`mixer.rs`): Stop all sources, drop their sinks, and reset positions to zero.
- `Mixer::resume_all` (`mixer.rs`): Resume all paused sources and restart their play-time clocks.
- `Mixer::clone_source` (`mixer.rs`): Clone a source entry (stopped, no sink) preserving its settings; return the new key.
- `Mixer::release` (`mixer.rs`): Remove and stop the source identified by `key`; return `true` if it existed.
- `Mixer::set_peak` (`mixer.rs`): Set the measured peak amplitude for a source; clamped to [0.0, 1.0].
- `Mixer::get_peak` (`mixer.rs`): Return the last measured peak amplitude for the source, or 0.0 if invalid.
- `Mixer::bus_peak` (`mixer.rs`): Return average peak of all sources assigned to the given bus.
- `Mixer::new_bus` (`mixer.rs`): Create a new named bus and return its key.
- `Mixer::get_bus_by_name` (`mixer.rs`): Find a bus key by its human-readable name.
- `Mixer::get_bus` (`mixer.rs`): Return a shared reference to the bus, or `None` if the key is invalid.
- `Mixer::get_bus_mut` (`mixer.rs`): Return a mutable reference to the bus, or `None` if the key is invalid.
- `Mixer::set_source_bus` (`mixer.rs`): Assign or clear the bus routing for a source.
- `Mixer::get_source_bus` (`mixer.rs`): Return the bus key assigned to this source, or `None` if unassigned.
- `Mixer::get_duration` (`mixer.rs`): Return cached total duration of the source in seconds, or `None` if unknown.
- `Mixer::get_tell` (`mixer.rs`): Return the current playback position in seconds based on accumulated and elapsed time.
- `Mixer::seek` (`mixer.rs`): Seek the source to `position_secs`, rebuilding the sink from that offset.
- `Mixer::set_lowpass` (`mixer.rs`): Set low-pass filter cutoff frequency in Hz for the source.
- `Mixer::clear_lowpass` (`mixer.rs`): Remove the low-pass filter from the source.
- `Mixer::set_highpass` (`mixer.rs`): Set high-pass filter cutoff frequency in Hz for the source.
- `Mixer::clear_highpass` (`mixer.rs`): Remove the high-pass filter from the source.
- `Mixer::clear_filter` (`mixer.rs`): Remove both low-pass and high-pass filters from the source.
- `Mixer::get_lowpass` (`mixer.rs`): Return the low-pass cutoff in Hz, or `None` if no low-pass is set.
- `Mixer::get_highpass` (`mixer.rs`): Return the high-pass cutoff in Hz, or `None` if no high-pass is set.
- `Mixer::set_fade_in` (`mixer.rs`): Set fade-in duration in seconds; clamped to >= 0.0.
- `Mixer::clear_fade_in` (`mixer.rs`): Remove configured fade-in from the source.
- `Mixer::get_fade_in` (`mixer.rs`): Return the configured fade-in duration in seconds, or `None` if unset.
- `Mixer::set_source_position` (`mixer.rs`): Set 3D source position and update pan from horizontal offset to listener.
- `Mixer::get_source_position` (`mixer.rs`): Return the 3D position of the source, or `[0,0,0]` if spatial state is unset.
- `Mixer::set_source_velocity` (`mixer.rs`): Set 3D source velocity for doppler calculations.
- `Mixer::get_source_velocity` (`mixer.rs`): Return the 3D velocity of the source, or `[0,0,0]` if spatial state is unset.
- `Mixer::set_source_orientation` (`mixer.rs`): Set 3D source orientation as forward and up vectors.
- `Mixer::get_source_orientation` (`mixer.rs`): Return the source orientation as `[fx,fy,fz,ux,uy,uz]`, or default forward-Z/up-Y.
- `Mixer::set_listener_position` (`mixer.rs`): Set the 3D listener position for spatial audio.
- `Mixer::get_listener_position` (`mixer.rs`): Return the current listener position.
- `Mixer::set_listener_orientation` (`mixer.rs`): Set the listener orientation as forward and up vectors.
- `Mixer::get_listener_orientation` (`mixer.rs`): Return the current listener orientation as `[fx,fy,fz,ux,uy,uz]`.
- `Mixer::set_listener_velocity` (`mixer.rs`): Set the listener velocity vector for doppler calculations.
- `Mixer::get_listener_velocity` (`mixer.rs`): Return the current listener velocity.
- `Mixer::set_doppler_scale` (`mixer.rs`): Set the doppler effect intensity multiplier; clamped to >= 0.0.
- `Mixer::get_doppler_scale` (`mixer.rs`): Return the current doppler scale.
- `Mixer::set_distance_model` (`mixer.rs`): Set the distance attenuation model name.
- `Mixer::get_distance_model` (`mixer.rs`): Return the name of the active distance model.
- `Mixer::new_queueable` (`mixer.rs`): Create a new queueable push-buffer source and return its key.
- `Mixer::queue_buffer` (`mixer.rs`): Push sample data into the queueable source's next free buffer slot.
- `Mixer::queueable_free_buffer_count` (`mixer.rs`): Return the number of free buffer slots for the given queueable source.
- `Mixer::play_queueable` (`mixer.rs`): Start playback of the queueable source (stub: not yet implemented).
- `Mixer::stop_queueable` (`mixer.rs`): Stop the queueable source and return all buffers to the free pool.
- `Mixer::release_queueable` (`mixer.rs`): Remove the queueable source from the mixer; return `true` if it existed.
- `Mixer::set_stereo_width` (`mixer.rs`): Set stereo width for the source; error if the key is invalid.
- `Mixer::get_stereo_width` (`mixer.rs`): Return the stereo width for the source; error if the key is invalid.
- `Mixer::set_random_pitch` (`mixer.rs`): Set a random pitch range `[min, max]` applied each time the source plays; error if min > max.
- `Mixer::clear_random_pitch` (`mixer.rs`): Remove the random pitch range from the source.
- `Mixer::crossfade` (`mixer.rs`): Crossfade from one source to another over `duration_secs`; stops the outgoing source.
- `Mixer::get_bus_peak` (`mixer.rs`): Return average peak amplitude of all sources on the named bus; error if bus not found.
- `Mixer::get_bus_rms` (`mixer.rs`): Return RMS level of the named bus (stub: always 0.0); error if bus not found.
- `Mixer::new_pool` (`mixer.rs`): Create a new sound pool with `voice_count` preloaded copies of `file_path`.
- `process_offline` (`offline.rs`): Decodes `input_path`, applies `effects` in series, and writes the result to `output_path`.
- `normalize_file` (`offline.rs`): Normalises the peak amplitude of `input_path` to `target_level` and writes to `output_path`.
- `SoundPool::new` (`pool.rs`): Create a pool with `keys` and source `file_path`, defaulting to volume=1.0 and no bus.
- `SoundPool::voice_count` (`pool.rs`): Return number of voices in this pool.
- `SoundPool::file_path` (`pool.rs`): Return source file path associated with this pool.
- `SoundPool::volume` (`pool.rs`): Return current pool gain multiplier.
- `SoundPool::set_volume` (`pool.rs`): Set pool gain multiplier; values below 0.0 are clamped to 0.0.
- `SoundPool::bus_name` (`pool.rs`): Return assigned bus name, or `None` if unassigned.
- `SoundPool::set_bus` (`pool.rs`): Assign this pool to bus `name`.
- `SoundPool::clear_bus` (`pool.rs`): Remove any bus assignment from this pool.
- `SoundPool::next_voice` (`pool.rs`): Return next voice key in round-robin order and advance the cursor.
- `SoundPool::all_keys` (`pool.rs`): Return all voice keys managed by this pool.
- `SoundPool::is_valid` (`pool.rs`): Return `true` when the pool contains at least one voice key.
- `SoundData::new` (`sound_data.rs`): Allocate silent audio buffer with `sample_count` frames and `channels` interleaved channels.
- `SoundData::from_samples` (`sound_data.rs`): Construct from an existing interleaved sample vector.
- `SoundData::from_lua_args` (`sound_data.rs`): Build `SoundData` from Lua arguments: load file when `path` is set, otherwise allocate silent buffer.
- `SoundData::from_file` (`sound_data.rs`): Decode audio file at `path` into f32 interleaved samples.
- `SoundData::get_sample` (`sound_data.rs`): Return sample value at `index`, or `None` when out of bounds.
- `SoundData::samples` (`sound_data.rs`): Return all interleaved samples as a shared slice.
- `SoundData::set_sample` (`sound_data.rs`): Set sample at `index` to `value` (clamped to [-1,1]); return `false` if index is invalid.
- `SoundData::sample_count` (`sound_data.rs`): Return number of frames (samples per channel), not raw interleaved element count.
- `SoundData::sample_rate` (`sound_data.rs`): Return sample rate in Hz.
- `SoundData::channel_count` (`sound_data.rs`): Return channel count.
- `SoundData::bit_depth` (`sound_data.rs`): Return logical bit depth metadata.
- `SoundData::duration` (`sound_data.rs`): Return duration in seconds.
- `SoundData::as_samples` (`sound_data.rs`): Return interleaved sample slice.
- `SoundData::encode_wav` (`sound_data.rs`): Encode current samples as an in-memory 16-bit PCM WAV byte vector.
- `SoundData::sine_wave` (`sound_data.rs`): Generate mono sine-wave `SoundData` at `freq` Hz for `duration` seconds.
- `SoundData::square_wave` (`sound_data.rs`): Generate mono square-wave `SoundData` at `freq` Hz for `duration` seconds.
- `SoundData::sawtooth_wave` (`sound_data.rs`): Generate mono sawtooth-wave `SoundData` at `freq` Hz for `duration` seconds.
- `SoundData::triangle_wave` (`sound_data.rs`): Generate mono triangle-wave `SoundData` at `freq` Hz for `duration` seconds.
- `SoundData::white_noise` (`sound_data.rs`): Generate mono white-noise `SoundData` using deterministic LCG seeded by `seed`.
- `SoundData::draw_waveform` (`sound_data.rs`): Draw waveform envelope into `img` as vertical min/max bars in RGBA colour `(r,g,b,a)`.
- `SoundData::apply_lowpass` (`sound_data.rs`): Apply one-pole low-pass filter in place with cutoff `cutoff_hz`.
- `SoundData::apply_highpass` (`sound_data.rs`): Apply one-pole high-pass filter in place with cutoff `cutoff_hz`.
- `SoundData::apply_bandpass` (`sound_data.rs`): Apply simple band-pass by chaining `apply_highpass(low_hz)` then `apply_lowpass(high_hz)`.
- `SoundData::apply_gain` (`sound_data.rs`): Multiply all samples by `gain` and clamp to [-1.0, 1.0].
- `SoundData::mix_into` (`sound_data.rs`): Mix `other` into `self` sample-by-sample, extending length if needed and clamping output to [-1,1].
- `AudioSource::new` (`source.rs`): Create a new source descriptor with volume=1.0 and looping disabled.
- `waveform_to_png` (`visualizer.rs`): Renders the amplitude waveform of `input_wav` to a PNG file at `output_png`.
- `spectrogram_to_png` (`visualizer.rs`): Renders a time–frequency spectrogram of `input_wav` to a PNG file at `output_png`.

## Lua API Reference

- Binding path(s): `src/lua_api/audio_api.rs`
- Namespace: `lurek.audio`

### Module Functions
- `lurek.audio.newSource`: Creates a new audio source from a file path, either fully loaded or streaming.
- `lurek.audio.play`: Starts playback of a source by handle, optionally routing through a named bus.
- `lurek.audio.stop`: Stops playback of a source and resets its position to the beginning.
- `lurek.audio.setVolume`: Sets the volume of a source by handle.
- `lurek.audio.getVolume`: Returns the current volume of a source.
- `lurek.audio.pause`: Pauses playback of a source at its current position.
- `lurek.audio.resume`: Resumes playback of a paused source.
- `lurek.audio.setPitch`: Sets the pitch multiplier of a source, affecting playback speed and tone.
- `lurek.audio.getPitch`: Returns the current pitch multiplier of a source.
- `lurek.audio.isPlaying`: Returns whether a source is currently playing.
- `lurek.audio.isPaused`: Returns whether a source is currently paused.
- `lurek.audio.isStopped`: Returns whether a source is currently stopped.
- `lurek.audio.setLooping`: Enables or disables looping for a source.
- `lurek.audio.isLooping`: Returns whether a source has looping enabled.
- `lurek.audio.playLooping`: Starts playback of a source with looping enabled in one call.
- `lurek.audio.setPan`: Sets the stereo panning of a source.
- `lurek.audio.getPan`: Returns the current stereo pan position of a source.
- `lurek.audio.setMasterVolume`: Sets the global master volume affecting all audio output.
- `lurek.audio.getMasterVolume`: Returns the current global master volume level.
- `lurek.audio.getActiveSourceCount`: Returns the number of sources currently playing audio.
- `lurek.audio.getSourceCount`: Returns the total number of loaded audio sources (playing or idle).
- `lurek.audio.getSourceType`: Returns whether a source is static or streaming.
- `lurek.audio.clone`: Creates an independent copy of a source sharing the same audio data.
- `lurek.audio.pauseAll`: Pauses all currently playing audio sources.
- `lurek.audio.stopAll`: Stops all audio sources and resets their positions.
- `lurek.audio.resumeAll`: Resumes all paused audio sources. This function is exposed to Lua scripts.
- `lurek.audio.release`: Releases an audio source, freeing its memory and stopping playback.
- `lurek.audio.newBus`: Creates a new audio mixing bus for grouping and controlling sources.
- `lurek.audio.setSourceBus`: Routes a source through a specific audio bus for grouped mixing.
- `lurek.audio.getSourceBus`: Returns the bus a source is routed through.
- `lurek.audio.getMaxSources`: Returns the maximum number of simultaneous audio sources supported.
- `lurek.audio.getDuration`: Returns the total duration of a source in seconds.
- `lurek.audio.tell`: Returns the current playback position of a source in seconds.
- `lurek.audio.seek`: Seeks a source to a specific position in seconds.
- `lurek.audio.setLowpass`: Applies a lowpass filter to a source, attenuating high frequencies.
- `lurek.audio.setHighpass`: Applies a highpass filter to a source, attenuating low frequencies.
- `lurek.audio.getLowpass`: Returns the current lowpass filter cutoff of a source.
- `lurek.audio.getHighpass`: Returns the current highpass filter cutoff of a source.
- `lurek.audio.clearFilter`: Removes all frequency filters from a source.
- `lurek.audio.fadeIn`: Sets the fade-in duration for a source so it ramps from silence on play.
- `lurek.audio.getFadeIn`: Returns the configured fade-in duration of a source.
- `lurek.audio.setListener2D`: Sets the 2D listener position for spatial audio calculations.
- `lurek.audio.getListener2D`: Returns the current 2D listener position.
- `lurek.audio.setListener`: Sets the 3D listener position for spatial audio (Z defaults to 0 for 2D games).
- `lurek.audio.getListener`: Returns the current 3D listener position.
- `lurek.audio.setPosition`: Sets the 3D position of a source for spatial audio panning and attenuation.
- `lurek.audio.getPosition`: Returns the 3D position of a source.
- `lurek.audio.setVelocity`: Sets the velocity of a source for Doppler effect calculations.
- `lurek.audio.getVelocity`: Returns the velocity vector of a source.
- `lurek.audio.setOrientation`: Sets the orientation of a source using forward and up vectors.
- `lurek.audio.getOrientation`: Returns the orientation vectors of a source.
- `lurek.audio.setDopplerScale`: Sets the global Doppler effect intensity multiplier.
- `lurek.audio.getDopplerScale`: Returns the current global Doppler effect scale.
- `lurek.audio.setDistanceModel`: Sets the distance attenuation model for spatial audio.
- `lurek.audio.getDistanceModel`: Returns the current distance attenuation model name.
- `lurek.audio.setMeter`: Sets the master peak level for metering purposes.
- `lurek.audio.getMeter`: Returns the current master peak level for VU-meter displays.
- `lurek.audio.newMidiPlayer`: Creates a new MIDI player instance, optionally loading a file immediately.
- `lurek.audio.newSoundData`: Creates a new SoundData object from a file path or blank buffer for procedural audio.
- `lurek.audio.setMidiSoundFont`: Sets the SoundFont file used for MIDI synthesis.
- `lurek.audio.hasMidiSoundFont`: Returns whether a SoundFont file has been loaded for MIDI synthesis.
- `lurek.audio.clearMidiSoundFont`: Clears the loaded SoundFont and reverts MIDI synthesis to default.
- `lurek.audio.newDecoder`: Creates a streaming audio decoder for the given file. The file is opened relative to the game directory.
- `lurek.audio.newQueueableSource`: Creates a new queueable audio source for streaming PCM data buffer by buffer.
- `lurek.audio.queueSource`: Queues a decoded audio chunk for playback on a queueable source.
- `lurek.audio.getFreeBufferCount`: Returns the number of free (available) buffer slots on a queueable source.
- `lurek.audio.playQueueable`: Starts playback of a queueable audio source.
- `lurek.audio.stopQueueable`: Stops playback of a queueable audio source.
- `lurek.audio.getPlaybackDevices`: Returns a list of available audio playback device names.
- `lurek.audio.getPlaybackDevice`: Returns the name of the currently active audio playback device.
- `lurek.audio.setPlaybackDevice`: Sets the active audio playback device by name.
- `lurek.audio.create_bus`: Creates a named audio bus, optionally parented to another bus.
- `lurek.audio.set_bus_volume`: Sets the volume of a named audio bus.
- `lurek.audio.add_effect`: Adds an effect to a named audio bus and returns its effect ID.
- `lurek.audio.remove_effect`: Removes an effect from a named audio bus by effect ID.
- `lurek.audio.set_effect_param`: Sets a parameter value on an effect attached to a named audio bus.
- `lurek.audio.newSineWave`: Generates a sine wave as a `SoundData` buffer.
- `lurek.audio.newSquareWave`: Generates a square wave as a `SoundData` buffer.
- `lurek.audio.newSawtoothWave`: Generates a sawtooth wave as a `SoundData` buffer.
- `lurek.audio.newTriangleWave`: Generates a triangle wave as a `SoundData` buffer.
- `lurek.audio.newWhiteNoise`: Generates white noise as a `SoundData` buffer using a deterministic seed.
- `lurek.audio.applyLowpass`: Applies a lowpass filter in-place to the sound data.
- `lurek.audio.applyHighpass`: Applies a highpass filter in-place to the sound data.
- `lurek.audio.applyBandpass`: Applies a bandpass filter in-place to the sound data.
- `lurek.audio.applyGain`: Applies a gain multiplier in-place to the sound data.
- `lurek.audio.mixInto`: Mixes the samples of `src` into `dest` in-place (both must have the same format).
- `lurek.audio.saveWAV`: Encodes the sound data as a WAV file and saves it to the given path (relative to game dir).
- `lurek.audio.setStereoWidth`: Sets the stereo width of an audio source (0.0 = mono, 1.0 = full stereo).
- `lurek.audio.getStereoWidth`: Returns the current stereo width factor of an audio source.
- `lurek.audio.setRandomPitch`: Sets a random pitch range for a source; each play picks a random pitch between min and max.
- `lurek.audio.clearRandomPitch`: Clears any random pitch range previously set on the source.
- `lurek.audio.crossfade`: Crossfades from one audio source to another over the given duration.
- `lurek.audio.getBusPeak`: Returns the peak amplitude of the named audio bus over the last processing frame.
- `lurek.audio.getBusRms`: Returns the RMS (root mean square) amplitude of the named audio bus over the last processing frame.
- `lurek.audio.newPool`: Creates a polyphonic sound pool that allows the same audio file to play on multiple simultaneous voices.
- `lurek.audio.processOffline`: Processes an audio file offline through a chain of effects and writes the result to an output file.
- `lurek.audio.normalizeFile`: Normalizes an audio file to a target peak amplitude and saves the result.
- `lurek.audio.waveformToPng`: Renders a waveform visualization of an audio file and saves it as a PNG image.
- `lurek.audio.spectrogramToPng`: Renders a spectrogram visualization of an audio file and saves it as a PNG image.

### `LBus` Methods
- `LBus:getName`: Returns the name of this audio bus. This method is available to Lua scripts.
- `LBus:setVolume`: Sets the volume multiplier for all sources routed through this bus.
- `LBus:getVolume`: Returns the current volume multiplier of this bus.
- `LBus:setPitch`: Sets the pitch multiplier applied to all sources routed through this bus.
- `LBus:getPitch`: Returns the current pitch multiplier of this bus.
- `LBus:pause`: Pauses all sources routed through this bus.
- `LBus:resume`: Resumes all sources routed through this bus that were paused.
- `LBus:isPaused`: Returns whether this bus is currently paused.
- `LBus:type`: Returns the type name of this object for runtime type-checking.
- `LBus:typeOf`: Checks whether this object matches the given type name.
- `LBus:setDuckTarget`: Configures ducking so this bus lowers the volume of a target bus when active.
- `LBus:clearDuck`: Removes the ducking configuration from this bus.
- `LBus:getPeak`: Returns the current peak amplitude level of this bus for VU-meter displays.

### `LDecoder` Methods
- `LDecoder:decode`: Decodes the next chunk of audio data and returns it as a LSoundData object.
- `LDecoder:getChannelCount`: Returns the number of audio channels in the source file.
- `LDecoder:getBitDepth`: Returns the bit depth of the source audio file.
- `LDecoder:getSampleRate`: Returns the sample rate of the source audio file.
- `LDecoder:getDuration`: Returns the total duration of the source audio file in seconds.
- `LDecoder:seek`: Seeks to a specific position in the audio stream.
- `LDecoder:rewind`: Rewinds the decoder back to the beginning of the audio stream.
- `LDecoder:tell`: Returns the current read position in the audio stream in seconds.
- `LDecoder:isSeekable`: Returns whether this decoder supports seeking.
- `LDecoder:release`: Releases decoder resources (no-op, kept for API symmetry).
- `LDecoder:type`: Returns the type name of this object for runtime type-checking.
- `LDecoder:typeOf`: Checks whether this object matches the given type name.

### `LMidiPlayer` Methods
- `LMidiPlayer:load`: Loads a MIDI file from the given path relative to the game directory.
- `LMidiPlayer:loadData`: Loads MIDI data from a raw byte string in memory.
- `LMidiPlayer:isLoaded`: Returns whether a MIDI file is currently loaded and ready to play.
- `LMidiPlayer:getFilePath`: Returns the file path of the currently loaded MIDI file.
- `LMidiPlayer:setSoundFont`: Sets a custom SoundFont file for MIDI synthesis (stub, not yet implemented).
- `LMidiPlayer:getSoundFontPath`: Returns the path of the currently set SoundFont (stub, not yet implemented).
- `LMidiPlayer:useDefaultSoundFont`: Reverts to the built-in default SoundFont (stub, not yet implemented).
- `LMidiPlayer:play`: Starts MIDI playback from the current position using the audio output stream.
- `LMidiPlayer:pause`: Pauses MIDI playback at the current position.
- `LMidiPlayer:stop`: Stops MIDI playback and resets position to the beginning.
- `LMidiPlayer:isPlaying`: Returns whether the MIDI player is currently playing.
- `LMidiPlayer:isPaused`: Returns whether the MIDI player is currently paused.
- `LMidiPlayer:seek`: Seeks to a specific position in the MIDI file.
- `LMidiPlayer:tell`: Returns the current playback position of the MIDI player in seconds.
- `LMidiPlayer:getDuration`: Returns the total duration of the loaded MIDI file in seconds.
- `LMidiPlayer:setLooping`: Enables or disables looping for MIDI playback.
- `LMidiPlayer:isLooping`: Returns whether MIDI looping is enabled.
- `LMidiPlayer:setVolume`: Sets the master volume for MIDI playback.
- `LMidiPlayer:getVolume`: Returns the current master volume of the MIDI player.
- `LMidiPlayer:setBus`: Routes this MIDI player's output through the specified audio bus.
- `LMidiPlayer:getBus`: Returns the audio bus this MIDI player is routed through.
- `LMidiPlayer:setTempo`: Sets the playback tempo in beats per minute.
- `LMidiPlayer:getTempo`: Returns the current effective tempo in beats per minute.
- `LMidiPlayer:getOriginalTempo`: Returns the original tempo of the MIDI file as authored.
- `LMidiPlayer:setTempoScale`: Sets a tempo multiplier relative to the original speed.
- `LMidiPlayer:getTempoScale`: Returns the current tempo scale multiplier.
- `LMidiPlayer:getTicksPerBeat`: Returns the MIDI file's resolution in ticks per beat (PPQN).
- `LMidiPlayer:setChannelVolume`: Sets the volume for a specific MIDI channel (1-16).
- `LMidiPlayer:getChannelVolume`: Returns the volume of a specific MIDI channel.
- `LMidiPlayer:setChannelMuted`: Mutes or unmutes a specific MIDI channel.
- `LMidiPlayer:isChannelMuted`: Returns whether a specific MIDI channel is muted.
- `LMidiPlayer:setChannelInstrument`: Sets the General MIDI instrument program for a channel.
- `LMidiPlayer:getChannelInstrument`: Returns the current GM instrument program for a channel.
- `LMidiPlayer:getChannelCount`: Returns the number of active MIDI channels in the loaded file.
- `LMidiPlayer:soloChannel`: Solos a specific MIDI channel, muting all others.
- `LMidiPlayer:unsoloAll`: Removes solo from all channels, restoring normal playback.
- `LMidiPlayer:getTrackCount`: Returns the number of tracks in the loaded MIDI file.
- `LMidiPlayer:getTrackName`: Returns the name of a MIDI track by 1-based index.
- `LMidiPlayer:setTrackMuted`: Mutes or unmutes a specific MIDI track.
- `LMidiPlayer:isTrackMuted`: Returns whether a specific MIDI track is muted.
- `LMidiPlayer:getNoteCount`: Returns the total number of note events in the loaded MIDI file.
- `LMidiPlayer:setOnNoteOn`: Registers a callback for MIDI note-on events (stub, not yet implemented).
- `LMidiPlayer:setOnNoteOff`: Registers a callback for MIDI note-off events (stub, not yet implemented).
- `LMidiPlayer:setOnEnd`: Registers a callback invoked when MIDI playback finishes (stub, not yet implemented).
- `LMidiPlayer:getSampleRate`: Returns the output sample rate used for MIDI synthesis.
- `LMidiPlayer:setSampleRate`: Sets the output sample rate for MIDI synthesis.
- `LMidiPlayer:getChannels`: Returns the number of output audio channels for MIDI synthesis.
- `LMidiPlayer:setChannels`: Sets the number of output audio channels for MIDI synthesis.
- `LMidiPlayer:type`: Returns the type name of this object for runtime type-checking.
- `LMidiPlayer:typeOf`: Checks whether this object matches the given type name.

### `LSoundData` Methods
- `LSoundData:getSampleCount`: Returns the total number of samples stored in this sound buffer.
- `LSoundData:getSampleRate`: Returns the playback sample rate of this sound buffer.
- `LSoundData:getChannelCount`: Returns the number of audio channels stored in this sound buffer.
- `LSoundData:getDuration`: Returns the approximate playback duration of this sound buffer.
- `LSoundData:getBitDepth`: Returns the sample bit depth of this sound buffer.
- `LSoundData:getSample`: Returns the sample value at the given zero-based sample index.
- `LSoundData:drawWaveform`: Draws this sound buffer as a waveform into an image buffer.
- `LSoundData:setSample`: Overwrites the sample value at the given zero-based sample index.
- `LSoundData:type`: Returns the type name of this object for runtime type-checking.
- `LSoundData:typeOf`: Checks whether this object matches the given type name.

### `LSoundPool` Methods
- `LSoundPool:play`: Plays the next available voice from the pool in round-robin order.
- `LSoundPool:stopAll`: Stops all voices in this sound pool immediately.
- `LSoundPool:setVolume`: Sets the volume for all voices in this pool.
- `LSoundPool:setBus`: Routes all voices in this pool through the named audio bus.
- `LSoundPool:release`: Releases all voices and frees audio resources held by this pool.
- `LSoundPool:getVoiceCount`: Returns the number of pre-allocated voices in this pool.
- `LSoundPool:type`: Returns the type name of this object for runtime type-checking.
- `LSoundPool:typeOf`: Checks whether this object matches the given type name.

### `LSource` Methods
- `LSource:play`: Starts playback of this audio source from the current position.
- `LSource:stop`: Stops playback and resets the source position to the beginning.
- `LSource:pause`: Pauses playback at the current position, allowing later resumption.
- `LSource:resume`: Resumes playback from the position where the source was paused.
- `LSource:setVolume`: Sets the volume level of this source where 0.0 is silent and 1.0 is full volume.
- `LSource:getVolume`: Returns the current volume level of this audio source.
- `LSource:setPitch`: Sets the playback speed multiplier, affecting both pitch and duration.
- `LSource:getPitch`: Returns the current pitch multiplier of this audio source.
- `LSource:setLooping`: Enables or disables looping so the source restarts automatically after finishing.
- `LSource:isLooping`: Returns whether this source is set to loop continuously.
- `LSource:isPlaying`: Returns whether this source is currently playing audio.
- `LSource:isPaused`: Returns whether this source is currently paused.
- `LSource:isStopped`: Returns whether this source is currently stopped (not playing or paused).
- `LSource:setPan`: Sets the stereo panning position of this source.
- `LSource:getPan`: Returns the current stereo panning position of this source.
- `LSource:clone`: Creates an independent copy of this source sharing the same audio data.
- `LSource:getType`: Returns whether this source was loaded as static (fully in memory) or streaming.
- `LSource:getDuration`: Returns the total duration of this audio source in seconds.
- `LSource:tell`: Returns the current playback position of this source in seconds.
- `LSource:seek`: Seeks to a specific position in seconds within this audio source.
- `LSource:setLowpass`: Applies a lowpass filter that attenuates frequencies above the cutoff.
- `LSource:setHighpass`: Applies a highpass filter that attenuates frequencies below the cutoff.
- `LSource:getLowpass`: Returns the current lowpass filter cutoff frequency in Hertz.
- `LSource:getHighpass`: Returns the current highpass filter cutoff frequency in Hertz.
- `LSource:clearFilter`: Removes all frequency filters (lowpass and highpass) from this source.
- `LSource:fadeIn`: Sets the fade-in duration so the source ramps from silence to full volume on play.
- `LSource:getFadeIn`: Returns the configured fade-in duration for this source.
- `LSource:type`: Returns the type name of this object for runtime type-checking.
- `LSource:typeOf`: Checks whether this object is of the given type name or a parent type.

## References

- `image`: Imports or references `src/image/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/audio/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- **MIDI status**: The `midly` crate has been removed from `Cargo.toml`. Code stubs in `src/audio/midi/` remain and emit `A002_MIDI_DISABLED` log warnings at startup. To re-enable MIDI: add `midly = "0.5"` back to `Cargo.toml` and implement the disabled code paths in `midi_player.rs`. Alternatively, remove the dead code if MIDI support is not planned.
