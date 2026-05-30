# audio

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

## Files

### [beat_clock.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/audio/beat_clock.rs)

- Implements musical time tracking that maps wall-clock progression to beats, bars, and pulses.
- Supports tempo and meter changes while preserving coherent phase continuity over runtime updates.
- Provides tap-tempo and quantized scheduling utilities for rhythm-aware gameplay coordination.
- Applies latency and swing parameters to shape musical timing feel without audio-thread coupling.
- Exposes deterministic query surfaces for beat index, measure position, and subdivision boundaries.
- Keeps timing logic pure and playback-agnostic so multiple systems can consume one clock source.
- Serves rhythm, sequencing, and procedural trigger systems that require stable musical time.
- Functions as the temporal backbone for Lua callbacks aligned to musical structure.

### [bus.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/audio/bus.rs)

- Implements named audio routing channels that apply shared gain, pitch, pause, and ducking control.
- Maintains per-bus processing parameters and effect-chain references for downstream mixer application.
- Supports duck-target relationships so one bus can attenuate others during priority playback.
- Enforces bounded parameter updates to keep runtime routing behavior stable and predictable.

### [decoder.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/audio/decoder.rs)

- Implements full-file PCM decode for supported audio formats into a seekable in-memory sample buffer.
- Provides random-access cursor movement for rewind, seek, and chunked iteration workflows.
- Exposes duration and playback-position metrics derived from decoded sample metadata.
- Serves as the decode bridge between file assets and streaming or buffered playback paths.

### [facade.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/audio/facade.rs)

- Provides the audio device facade used for output listing and active-device selection hooks.
- Exposes a stable API surface while backend-specific device enumeration remains minimal.
- Validates requested device names against known outputs before accepting selection changes.

### [mixer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/audio/mixer.rs)

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

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/audio/mod.rs)

- Defines the audio module boundary that groups playback, routing, decode, and source-data primitives.
- Exposes coherent core audio contracts while delegating specialized processing to adjacent modules.
- Serves as the composition entry for engine-side runtime audio behavior and shared types.

### [pool.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/audio/pool.rs)

- Implements round-robin voice pooling for low-latency repeated playback of one sound asset.
- Cycles preloaded source keys to distribute trigger load across reusable playback voices.
- Stores per-pool gain and optional bus assignment for grouped routing behavior.
- Validates pool integrity so empty or invalid voice sets are rejected early.

### [sound_data.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/audio/sound_data.rs)

- Implements in-memory interleaved PCM storage with metadata-aware sample access and mutation.
- Supports decode from file and direct buffer creation for generated or procedural audio content.
- Provides waveform synthesis helpers for common tonal and noise signal generation workflows.
- Applies lightweight in-place transforms such as filtering, gain, and buffer mixing operations.
- Exposes encode paths for export-ready WAV byte output from runtime sample data.
- Supplies duration and shape queries for tools, previews, and script-side audio reasoning.
- Bridges sample data to visual workflows through waveform drawing integration points.
- Serves as the core raw sound-data container for playback and preprocessing pipelines.

### [source.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/audio/source.rs)

- Defines source-level audio metadata and spatial attributes used by mixer-side playback control.
- Encapsulates position, velocity, and orientation state for positional and motion-aware rendering.
- Stores identity and basic playback defaults that classify each loaded runtime source.
- Serves as the foundational source contract shared across routing, playback, and spatialization paths.
