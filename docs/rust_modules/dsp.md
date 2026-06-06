# dsp

## General Info

- Module group: `Platform Services`
- Source path: `src/dsp/`
- Binding: `src/lua_api/dsp_api.rs`
- Namespace: `lurek.dsp`
- Lua API surface: `29` functions, `7` types, `27` methods
- Rust test path(s): tests/rust/unit/audio_tests.rs (shared with audio)
- Lua test path(s): tests/lua/unit/test_dsp_core_unit.lua

## Summary

This module handles audio signal processing and synthesis, offering control over sound generation and manipulation. It provides the runtime for real-time effects like filters, delays, and modulations. These effects use lock-free parameters to ensure low-latency safety, wrapping audio sources to apply clean transformations sample-by-sample during live playback.

To organize audio paths, the module features a digital signal processing graph where developers connect nodes to describe ordered signal flows. This supports both real-time streaming and offline processing, enabling users to batch render effect chains to files. This is ideal for asset baking, peak normalization, and preparing audio exports.

Procedural synthesis is supported by primitives generating waveforms and noise. These oscillators combine with envelopes that apply gain changes over attack, decay, sustain, and release phases. This makes it easy to generate dynamic sound effects and musical notes dynamically, without relying on pre-recorded files.

Additionally, the system provides level detectors tracking peak, average amplitude, and clipping thresholds, alongside spectral analyzers. These feed visualization utilities that convert audio data into waveform plots and spectrogram images, helping developers inspect audio assets and verify sound behaviors.

## Files

### [analysis.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dsp/analysis.rs)

- Provides realtime signal analysis primitives for level tracking and spectral inspection of sample streams.
- Maintains rolling RMS and peak state to expose stable loudness and clipping indicators during processing.
- Computes bounded frequency summaries that keep analysis cost predictable for scripting and runtime tooling.
- Supports both engine internals and Lua-facing diagnostics with consistent measurement semantics.
- Delivers the inspection layer used to observe signal health before and during mix decisions.

### [effects.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dsp/effects.rs)

- Provides the core DSP effect runtime that defines algorithms, parameters, and per-sample processing behavior.
- Encodes the supported effect family as stable typed variants consumed by both engine and Lua surfaces.
- Maintains shared parameter state with lock-free primitives to keep audio-thread reads predictable.
- Builds active processing instances that hold delay lines, filters, modulation state, and dynamic buffers.
- Executes effect transforms sample by sample with bounded parameter normalization and clamped control ranges.
- Supplies graph-backed shared chains for coordinating writer-side updates with reader-side playback.
- Wraps rodio sources in a dynamic processor that applies full chain processing during streaming.
- Handles effect-internal sizing from sample-rate context so algorithms remain portable across devices.
- Keeps filter and modulation math localized to one layer for consistent sonic behavior across call sites.
- Delivers the central effect-processing backbone for real-time and script-driven DSP workflows.

### [graph.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dsp/graph.rs)

- Provides a typed DSP graph model where nodes and edges describe ordered signal-processing flow.
- Organizes processing units into deterministic traversal order for stable per-buffer execution.
- Supports audio-rate and control-rate connectivity so routing and parameter signals share one structure.
- Enables safe runtime mutation patterns that coordinate producer updates with callback-side consumption.
- Delivers the structural layer used to compose complex effect pipelines from reusable nodes.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dsp/mod.rs)

- Provides the high-level DSP module boundary that groups analysis, synthesis, effects, graphs, offline, and visualization flows.
- Coordinates reusable signal-processing capabilities while keeping runtime execution and inspection concerns clearly separated.
- Delivers one stable composition surface for audio-adjacent digital processing across engine integrations.

### [offline.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dsp/offline.rs)

- Provides offline DSP processing that applies effect chains to stored audio without live playback.
- Runs decode, transform, and encode stages in one pipeline for reproducible file-based processing.
- Supports peak normalization and deterministic parameterized effects for batch rendering scenarios.
- Uses a serializable effect description so external tooling can request stable offline transforms.
- Delivers the non-realtime processing path for exports, precompute steps, and content baking.

### [synthesis.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dsp/synthesis.rs)

- Provides procedural audio synthesis primitives for waveform generation and envelope-shaped note rendering.
- Defines stable oscillator forms and parsing paths that map script choices to deterministic sample output.
- Applies ADSR gain shaping so rendered notes include natural attack, sustain behavior, and release tails.
- Combines oscillator and envelope models into renderable buffers ready for playback and further processing.
- Delivers the synthesis layer used for generated sound effects and lightweight musical content.
- Keeps synthesis behavior modular so higher-level systems can extend sound generation workflows safely.

### [visualizer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dsp/visualizer.rs)

- Provides DSP visualization utilities that convert audio buffers into readable waveform and spectrogram images.
- Extracts amplitude and frequency structure into pixel-space summaries for quick offline inspection.
- Handles multi-channel input normalization so visual output stays coherent across source formats.
- Maps signal magnitude to consistent color intensity for comparable visual diagnostics over time.
- Delivers artifact generation used by tooling, debugging workflows, and content analysis pipelines.
