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

1. **Real-time effects** (`effects.rs`, `graph.rs`) — A 17-variant `EffectType` enum (lowpass, highpass, reverb, delay, chorus, flanger, distortion, bitcrush, compressor, limiter, tremolo, vibrato, phaser, gain, bandpass, notch, stereowidener) with `AtomicParam`-based lock-free parameter updates. `SharedEffectGraph` and `DynamicEffectSource<I>` wrap any rodio `Source` to apply an ordered effects chain without blocking the audio thread.

2. **Offline processing** (`offline.rs`) — `process_offline()` applies an effect chain to a WAV file and writes the result to disk. `normalize_file()` performs peak normalization. Both operate file-to-file without real-time playback.

3. **Visualization** (`visualizer.rs`) — `waveform_to_png()` and `spectrogram_to_png()` render audio data as PNG images for debug, editor, or asset-pipeline use.

The `audio` module's bus system references `dsp::SharedEffectGraph` and `dsp::DynamicEffectSource` for its per-bus effect chains. Backward compatibility is maintained via re-exports in `src/audio/mod.rs`.

## Source Documentation

### `analysis.rs`
- Audio signal analysis capabilities including real-time volume tracking and frequency spectrum algorithms.
- Provides real-time volume tracking and Fast Fourier Transform algorithms for signal processing.
- Volume tracking implements exponential decay for peak detection and accumulates squared values for root-mean-square calculations over time.
- Frequency analysis utilizes a Fast Fourier Transform with a Cooley-Tukey algorithm, applying a Hann window to smooth the input and using a pre-calculated bit-reversal table for performance.
- Designed to process raw float samples directly from the audio thread or offline buffers, avoiding heap allocations in hot paths.
- Used primarily by the Lua bindings to expose visualizer data to scripts and by offline processing functions to measure audio characteristics.

### `effects.rs`
- Lock-free audio effect processing chains and digital signal processing algorithms.
- Provides lock-free parameter sharing between the audio thread and external bindings via atomic bit-casting.
- Groups DSP algorithms covering biquad filters, reverbs, delays, modulation, distortion, and dynamic range compression.
- Shared parameter blocks use named string-dispatch to set type-specific values without runtime allocations.
- Per-source processing maintains independent biquad delay elements, circular comb buffers, LFO phases, and envelope states.
- Implements sample-by-sample processing algorithms applying clamped parameter reads directly in the hot audio thread.
- Encapsulates effect graphs inside thread-safe lists shared between configuration writers and playback readers.
- Integrates with the audio playback pipeline by wrapping upstream sample sources and processing frames synchronously.
- Comb-buffer sizes and biquad coefficients are pre-calculated and cached based on sample rates to minimize CPU overhead.
- Handles degenerate paths by falling back to dry signal output or clamping extreme values without panicking.

### `graph.rs`
- Dynamic DSP signal graph capabilities for routing and mixing audio streams.
- Provides directed acyclic graph structures to manage dynamic audio routing paths.
- Implements topological sorting to process audio nodes in dependency order during playback.
- Separates node processing into generators, filters, and mixers to maintain predictable flow.
- Designed to run synchronously on the audio thread with minimal lock contention or allocation.
- Used to construct complex effect chains and routing topologies without modifying underlying sources.

### `mod.rs`
- Core digital signal processing subsystem for audio manipulation and analysis.
- Groups all real-time audio filters, analysis tools, procedural synthesis generators, and graph routing structures.
- Centralizes offline processing and visualization capabilities.
- Avoids direct coupling with platform I/O, focusing exclusively on pure mathematical signal transformation.

### `offline.rs`
- Offline audio processing capabilities for modifying files without real-time playback.
- Provides peak normalisation processing to scale audio amplitudes to a configurable target level.
- Decodes waveform data into floating-point format and encodes processed results back to 16-bit PCM streams.
- Applies complete effect chains sequentially over the entire audio buffer before writing to disk.
- Automatically ensures parent directory structures exist for output paths prior to writing.
- Interacts directly with file system APIs and decoder utilities to facilitate batch processing from scripts.

### `synthesis.rs`
- Audio synthesis capabilities for generating procedural waveforms and shaping signal amplitudes.
- Provides primitive waveform oscillators including sine, square, sawtooth, triangle, and white noise generation.
- Integrates ADSR (Attack, Decay, Sustain, Release) envelope generators for dynamic amplitude shaping over time.
- Implements mathematical wave generation formulas optimized for synchronous processing within the audio loop.
- Evaluates phase and state progression locally to avoid external synchronization overhead during real-time playback.
- Typically utilized by dynamic signal sources to create procedural sound effects without relying on loaded assets.

### `visualizer.rs`
- Graphical visualization capabilities for rendering audio characteristics into image formats.
- Provides offline tools to convert decoded audio files directly into standard PNG image representations.
- Implements amplitude waveform plotting that maps peak minimum and maximum values into graphical vertical bars.
- Generates frequency spectrograms using Hann-windowed discrete Fourier transforms mapped into heatmap color palettes.
- Automatically handles multi-channel audio by applying a mono downmix prior to visual analysis.
- Designed to be invoked by offline scripts or tooling interfaces rather than real-time rendering pipelines.

## Types

- `LevelDetector` (`struct`, `analysis.rs`): Structure for tracking real-time RMS and Peak volume levels.
- `SpectrumAnalyzer` (`struct`, `analysis.rs`): Spectrum analyzer performing Fast Fourier Transform (FFT) for real-time input.
- `AtomicParam` (`struct`, `effects.rs`): Lock-free f32 parameter shared between the audio thread and the Lua API via atomic bit-cast.
- `EffectType` (`enum`, `effects.rs`): DSP effect algorithm applied by `ActiveEffect::process` per sample.
- `EffectParams` (`struct`, `effects.rs`): Shared, lock-free parameter block for one DSP effect; shared between Lua API and audio thread.
- `ActiveEffect` (`struct`, `effects.rs`): Per-source instantiation of a DSP effect with its own filter and delay-line state.
- `SharedEffectGraph` (`struct`, `effects.rs`): Arc-wrapped effect parameter list shared between `Bus` (writer) and `DynamicEffectSource` (reader).
- `DynamicEffectSource` (`struct`, `effects.rs`): Rodio `Source` wrapper that applies the `SharedEffectGraph` effect chain sample by sample.
- `NodeId` (`struct`, `graph.rs`): Unique identifier for a node in the DSP graph.
- `DspNodeType` (`enum`, `graph.rs`): Node types in the processing graph.
- `DspNode` (`struct`, `graph.rs`): Represents a single processing node in the DSP graph.
- `DspGraph` (`struct`, `graph.rs`): Dynamic connection graph processed topologically in real-time.
- `OfflineEffect` (`struct`, `offline.rs`): Serializable DSP effect parameters for offline processing.
- `Waveform` (`enum`, `synthesis.rs`): Waveform types for synthesis oscillators.
- `AdsrEnvelope` (`struct`, `synthesis.rs`): ADSR (Attack, Decay, Sustain, Release) envelope generator for amplitude and filter control.
- `Synthesizer` (`struct`, `synthesis.rs`): Sound synthesis generator supporting various oscillator types.

## Functions

- `LevelDetector::new` (`analysis.rs`): Creates and returns a new level detector with the specified decay time in milliseconds.
- `LevelDetector::process_sample` (`analysis.rs`): Processes a single sample to update the detector's peak and RMS state.
- `LevelDetector::get_rms` (`analysis.rs`): Returns the current RMS value and resets the accumulator for the next window.
- `LevelDetector::get_peak` (`analysis.rs`): Returns the current Peak value.
- `LevelDetector::to_db` (`analysis.rs`): Converts a linear amplitude value to decibels (dB).
- `SpectrumAnalyzer::new` (`analysis.rs`): Creates and returns an analyzer with a specific FFT window size (must be a power of two).
- `SpectrumAnalyzer::analyze` (`analysis.rs`): Analyzes a block of samples and returns a vector of size `size / 2` containing the bin amplitudes.
- `AtomicParam::new` (`effects.rs`): Create a new `AtomicParam` initialised to `val`.
- `AtomicParam::get` (`effects.rs`): Return the current f32 value using `Relaxed` ordering.
- `AtomicParam::set` (`effects.rs`): Store a new f32 value using `Relaxed` ordering.
- `EffectParams::new` (`effects.rs`): Create new `EffectParams` with `id`, `typ`, and all parameters initialised to 0.0.
- `EffectParams::set_param` (`effects.rs`): Set a named parameter on this effect; error if `param` is not valid for `typ`.
- `ActiveEffect::new` (`effects.rs`): Allocate `ActiveEffect` for `params`, sizing `comb_buf` based on effect type and `sample_rate`.
- `ActiveEffect::process` (`effects.rs`): Apply the effect to one `sample` on `channel`, returning the processed output sample.
- `ActiveEffect::process_stereo` (`effects.rs`): Processes a stereo frame (two input/output channels).
- `SharedEffectGraph::new` (`effects.rs`): Create an empty `SharedEffectGraph`.
- `new` (`effects.rs`): Wrap `input` with the given `shared_graph`; captures sample rate and channel count.
- `DspNode::new` (`graph.rs`): Creates a new DSP graph node.
- `DspGraph::new` (`graph.rs`): Creates an empty DSP signal graph.
- `DspGraph::add_node` (`graph.rs`): Adds a node to the graph and forces a topological resort.
- `DspGraph::connect` (`graph.rs`): Connects two nodes in the graph.
- `DspGraph::process` (`graph.rs`): Processes the entire graph, invoking nodes sequentially according to their topological dependency.
- `process_offline` (`offline.rs`): Read `input_path`, apply `effects` sample-by-sample, and write 16-bit WAV to `output_path`.
- `normalize_file` (`offline.rs`): Normalize peak amplitude of `input_path` to `target_level` and write result to `output_path`.
- `AdsrEnvelope::new` (`synthesis.rs`): Creates a new ADSR envelope with the specified parameters.
- `AdsrEnvelope::trigger_on` (`synthesis.rs`): Triggers the Attack phase (e.g., key press).
- `AdsrEnvelope::trigger_off` (`synthesis.rs`): Triggers the Release phase (e.g., key release).
- `AdsrEnvelope::next_sample` (`synthesis.rs`): Generates the next envelope sample and updates the state.
- `AdsrEnvelope::is_idle` (`synthesis.rs`): Returns true if the envelope has finished playing (Idle state).
- `Synthesizer::new` (`synthesis.rs`): Initializes the synthesizer with the specified parameters.
- `Synthesizer::with_envelope` (`synthesis.rs`): Configures an ADSR envelope for the synthesizer.
- `Synthesizer::generate` (`synthesis.rs`): Generates an array of f32 samples based on the requested duration in seconds.
- `waveform_to_png` (`visualizer.rs`): Render waveform overview of `input_wav` to `output_png` with given image size.
- `spectrogram_to_png` (`visualizer.rs`): Render a spectrogram heatmap of `input_wav` to `output_png` using a Hann-windowed DFT.

## Lua API Reference

- Binding path(s): `src/lua_api/dsp_api.rs`
- Namespace: `lurek.dsp`

### Module Functions
- `lurek.dsp.newEffectParams`: Creates an effect parameter descriptor table for use with offline processing.
- `lurek.dsp.applyLowpass`: Applies a lowpass filter in-place to `SoundData`.
- `lurek.dsp.applyHighpass`: Applies a highpass filter in-place to `SoundData`.
- `lurek.dsp.applyBandpass`: Applies a bandpass filter in-place to `SoundData`.
- `lurek.dsp.applyGain`: Applies a gain multiplier in-place to `SoundData`.
- `lurek.dsp.processOffline`: Processes an audio file offline through a chain of effects and writes the result to an output file.
- `lurek.dsp.normalize`: Normalizes an audio file to a target peak amplitude and saves the result.
- `lurek.dsp.waveformToPng`: Renders a waveform visualization of an audio file and saves it as a PNG image.
- `lurek.dsp.spectrogramToPng`: Renders a spectrogram visualization of an audio file and saves it as a PNG image.
- `lurek.dsp.analyzeRms`: Analyzes the RMS volume of a `SoundData` buffer.
- `lurek.dsp.analyzePeak`: Analyzes the Peak volume of a `SoundData` buffer.
- `lurek.dsp.analyzeFft`: Performs FFT analysis on a `SoundData` buffer and returns frequency bin magnitudes.
- `lurek.dsp.addEffectToBus`: Adds an effect to a named audio bus and returns its effect ID.
- `lurek.dsp.removeEffectFromBus`: Removes an effect from a named audio bus by effect ID.
- `lurek.dsp.setEffectParam`: Sets a parameter value on an effect attached to a named audio bus.

## References

- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.

## Notes

- None.
