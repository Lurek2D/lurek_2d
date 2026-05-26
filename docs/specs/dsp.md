# dsp

## TL;DR

- The `dsp` module provides digital signal processing: real-time audio effects chains, offline batch processing, and audio visualization (waveform/spectrogram rendering).

## General Info

- Module group: `Platform Services`
- Source path: `src/dsp/`
- Lua API path(s): `src/lua_api/dsp_api.rs`
- Primary Lua namespace: `lurek.dsp`
- Rust test path(s): tests/rust/unit/audio_tests.rs (shared with audio)
- Lua test path(s): tests/lua/unit/test_dsp_core_unit.lua

## Summary

The `dsp` module encapsulates all audio signal processing that is independent of the playback pipeline. It was extracted from `src/audio/` to clarify the boundary between "playing sounds" (audio) and "transforming signals" (dsp).

The module provides three capabilities:

1. **Real-time effects** (`effects.rs`, `graph.rs`) — A 16-variant `EffectType` enum (lowpass, highpass, reverb, delay, chorus, flanger, distortion, bitcrush, compressor, limiter, tremolo, vibrato, phaser, gain, bandpass, notch) with `AtomicParam`-based lock-free parameter updates. `SharedEffectGraph` and `DynamicEffectSource<I>` wrap any rodio `Source` to apply an ordered effects chain without blocking the audio thread.

2. **Offline processing** (`offline.rs`) — `process_offline()` applies an effect chain to a WAV file and writes the result to disk. `normalize_file()` performs peak normalization. Both operate file-to-file without real-time playback.

3. **Visualization** (`visualizer.rs`) — `waveform_to_png()` and `spectrogram_to_png()` render audio data as PNG images for debug, editor, or asset-pipeline use.

The `audio` module's bus system references `dsp::SharedEffectGraph` and `dsp::DynamicEffectSource` for its per-bus effect chains. Backward compatibility is maintained via re-exports in `src/audio/mod.rs`.

## Source Documentation

### `effects.rs`
- `AtomicParam`: lock-free f32 wrapper using `AtomicU32` + `Ordering::Relaxed`.
- `EffectType`: 16-variant enum covering standard audio DSP filters.
- `EffectParams`: `type` + `p1`/`p2`/`p3` atomic parameters, uniquely identified by `id`.
- `ActiveEffect`: stateful per-effect processor (biquad coefficients, comb buffer, LFO phase). Constructed from `EffectParams`.
- `SharedEffectGraph`: `Arc<RwLock<Vec<Arc<EffectParams>>>>` — the ordered chain read by the audio thread.
- `DynamicEffectSource<I>`: wraps a rodio `Source<Item=f32>`, applies all active effects per-sample.

### `graph.rs`
- Re-exports `DynamicEffectSource` and `SharedEffectGraph` from `effects.rs`.

### `offline.rs`
- `OfflineEffect`: applies `ActiveEffect` processing to a sample buffer in-place.
- `process_offline(input, output, effects)`: reads WAV, applies chain, writes WAV.
- `normalize_file(input, output, target_peak)`: peak-normalizes a WAV file.
- Internal WAV I/O helpers: `read_wav_f32`, `write_wav_f32`.

### `visualizer.rs`
- `waveform_to_png(input, output, width, height)`: renders mono waveform as grayscale PNG.
- `spectrogram_to_png(input, output, width, height)`: renders FFT-based spectrogram as heat-colored PNG.
- `read_mono_f32(path)`: decodes any supported audio file to mono f32 samples.
- `heat_colour(t)`: maps [0,1] intensity to RGB for spectrogram coloring.

## Lua API

### `lurek.dsp.newEffectParams(type, p1, p2, p3)` → table
Creates an effect parameter descriptor table.

### `lurek.dsp.processOffline(input, output, effects)` → boolean
Applies an effects chain to a WAV file. `effects` is an array of `{type, p1, p2, p3}` tables.

### `lurek.dsp.normalize(input, output, targetPeak)` → boolean
Peak-normalizes a WAV file to the given target amplitude (0.0–1.0).

### `lurek.dsp.waveformToPng(input, output, width, height)` → boolean
Renders a waveform visualization of the audio file as a PNG image.

### `lurek.dsp.spectrogramToPng(input, output, width, height)` → boolean
Renders a spectrogram visualization of the audio file as a PNG image.

## Dependencies

- `rodio` — sample decoding for visualization.
- `image` — PNG output for visualizer.
- `std::sync::{Arc, RwLock, atomic}` — lock-free parameter sharing with the audio thread.

## Design Decisions

- Extracted from `audio` to allow independent testing and reuse outside the playback pipeline.
- Lock-free `AtomicParam` avoids priority inversion between audio thread and Lua main thread.
- Offline processing is entirely synchronous and file-to-file for simplicity.
- Backward-compat re-exports in `src/audio/mod.rs` prevent breakage of existing internal references.
