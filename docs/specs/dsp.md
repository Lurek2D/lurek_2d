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
- Provides RMS level detection, peak tracking, and clipping detection over f32 sample streams.
- `LevelDetector` accumulates sum-of-squares and peak per sample; exposes RMS, peak, clipping flag, and dBFS conversion.
- `SpectrumAnalyzer` delegates to `SoundData::analyze_dft` with a bounded bin count clamped to 1–512.
- Used by audio subsystem and Lua DSP bindings to inspect signal levels and spectrum before mixing.

### `effects.rs`
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

### `graph.rs`
- DSP processing graph: nodes connected by typed audio-rate and control-rate edges.
- `DspGraph` owns a topologically sorted list of `DspNode` processing units.
- Edges carry either audio frames (f32 interleaved) or scalar control signals.
- Evaluated once per audio buffer in the rodio callback on the audio thread.
- Graph mutation (add/remove node, patch edge) is performed from the game thread
- via a lock-free command queue consumed at the start of each audio callback.

### `mod.rs`
- Digital signal processing (DSP) sub-system: graph, nodes, and effect chain.
- Provides a per-source processing graph evaluated on the audio thread.
- Node types include: gain, pan, low-pass/high-pass filters, reverb, and delay.
- Graph topology changes are sent via a lock-free command queue to avoid blocking.
- Re-exported to Lua via `lurek.audio.dsp.*` through `audio_api.rs`.

### `offline.rs`
- Offline audio processing: apply DSP effect chains to files without real-time playback.
- Peak normalisation with configurable target level.
- WAV file decode to f32 and encode back to 16-bit PCM via rodio.
- `OfflineEffect` serialisable struct matching `EffectType` + three parameter slots.
- Parent directory auto-creation for output paths.

### `synthesis.rs`
- DSP synthesis helpers for procedural waveforms and envelopes.

### `visualizer.rs`
- Waveform-to-PNG rendering: peak min/max per column plotted as vertical bars.
- Spectrogram-to-PNG rendering: Hann-windowed DFT with frequency bins mapped to heatmap colours.
- Mono downmix helper for multi-channel input files.
- Heat-colour mapping from normalised magnitude to RGBA.
- Parent directory auto-creation for output image paths.

## Types

- `LevelDetector` (`struct`, `analysis.rs`): Structure for tracking real-time RMS and Peak volume levels.
- `SpectrumAnalyzer` (`struct`, `analysis.rs`): Spectrum analyzer performing Fast Fourier Transform (FFT) for real-time input.
- `AtomicParam` (`struct`, `effects.rs`): Lock-free f32 parameter shared between the audio thread and the Lua API via atomic bit-cast.
- `EffectType` (`enum`, `effects.rs`): DSP effect algorithm applied by `ActiveEffect::process` per sample.
- `EffectParams` (`struct`, `effects.rs`): Shared, lock-free parameter block for one DSP effect; shared between Lua API and audio thread.
- `ActiveEffect` (`struct`, `effects.rs`): Per-source instantiation of a DSP effect with its own filter and delay-line state.
- `SharedEffectGraph` (`struct`, `effects.rs`): Arc-wrapped effect parameter list shared between `Bus` (writer) and `DynamicEffectSource` (reader).
- `DynamicEffectSource` (`struct`, `effects.rs`): Rodio `Source` wrapper that applies the `SharedEffectGraph` effect chain sample by sample.
- `NodeId` (`type`, `graph.rs`): Unique identifier for a node in the DSP graph.
- `DspNodeType` (`enum`, `graph.rs`): Node types in the processing graph.
- `DspNode` (`struct`, `graph.rs`): Represents a single processing node in the DSP graph.
- `DspGraph` (`struct`, `graph.rs`): Dynamic connection graph processed topologically in real-time.
- `OfflineEffect` (`struct`, `offline.rs`): Serializable DSP effect parameters for offline processing.
- `Waveform` (`enum`, `synthesis.rs`): Waveform types for synthesis oscillators.
- `AdsrEnvelope` (`struct`, `synthesis.rs`): ADSR (Attack, Decay, Sustain, Release) envelope generator for amplitude and filter control.
- `Synthesizer` (`struct`, `synthesis.rs`): Sound synthesis generator supporting various oscillator types.

## Functions

- `LevelDetector::new` (`analysis.rs`): Create a detector with the provided clipping threshold.
- `LevelDetector::process_sample` (`analysis.rs`): Process one sample and update detector state.
- `LevelDetector::process_sound_data` (`analysis.rs`): Process an entire sound buffer and return `(rms, peak, clipping)`.
- `LevelDetector::get_rms` (`analysis.rs`): Return the current RMS level.
- `LevelDetector::get_peak` (`analysis.rs`): Return the current peak level.
- `LevelDetector::is_clipping` (`analysis.rs`): Return whether any processed sample reached the clipping threshold.
- `LevelDetector::to_db` (`analysis.rs`): Convert a linear amplitude to decibels full scale.
- `LevelDetector::reset` (`analysis.rs`): Reset accumulated state.
- `SpectrumAnalyzer::new` (`analysis.rs`): Create a spectrum analyzer with a bounded bin count.
- `SpectrumAnalyzer::set_size` (`analysis.rs`): Set the analyzer bin count.
- `SpectrumAnalyzer::analyze` (`analysis.rs`): Analyze a sound buffer and return `(frequency, magnitude)` bins.
- `AtomicParam::new` (`effects.rs`): Create a new `AtomicParam` initialised to `val`.
- `AtomicParam::get` (`effects.rs`): Return the current f32 value using `Relaxed` ordering.
- `AtomicParam::set` (`effects.rs`): Store a new f32 value using `Relaxed` ordering.
- `EffectParams::new` (`effects.rs`): Create new `EffectParams` with `id`, `typ`, and all parameters initialised to 0.0.
- `EffectParams::set_param` (`effects.rs`): Set a named parameter on this effect; error if `param` is not valid for `typ`.
- `add_effect_to_shared_chain` (`effects.rs`): Append an effect to a shared effect chain and return the assigned effect ID.
- `remove_effect_from_shared_chain` (`effects.rs`): Remove the effect with `effect_id` from a shared effect chain.
- `set_shared_chain_effect_param` (`effects.rs`): Set one named parameter on an existing effect inside a shared effect chain.
- `ActiveEffect::new` (`effects.rs`): Allocate `ActiveEffect` for `params`, sizing `comb_buf` based on effect type and `sample_rate`.
- `ActiveEffect::process` (`effects.rs`): Apply the effect to one `sample` on `channel`, returning the processed output sample.
- `SharedEffectGraph::new` (`effects.rs`): Create an empty `SharedEffectGraph`.
- `new` (`effects.rs`): Wrap `input` with the given `shared_graph`; captures sample rate and channel count.
- `DspNodeType::parse` (`graph.rs`): Parse a Lua-facing node kind.
- `DspNodeType::as_str` (`graph.rs`): Return the Lua-facing node kind.
- `DspNode::new` (`graph.rs`): Create a node from a Lua-facing kind.
- `DspNode::set_param` (`graph.rs`): Set a named node parameter.
- `DspNode::get_param` (`graph.rs`): Get a named node parameter.
- `DspNode::node_type` (`graph.rs`): Return this node's kind.
- `DspGraph::new` (`graph.rs`): Create an empty DSP graph.
- `DspGraph::add_node` (`graph.rs`): Add a node and return its stable ID.
- `DspGraph::connect` (`graph.rs`): Connect two existing nodes.
- `DspGraph::disconnect` (`graph.rs`): Disconnect two nodes.
- `DspGraph::process` (`graph.rs`): Process a sound buffer through all nodes in insertion order.
- `DspGraph::clear` (`graph.rs`): Clear all graph nodes and connections.
- `process_offline` (`offline.rs`): Read `input_path`, apply `effects` sample-by-sample, and write 16-bit WAV to `output_path`.
- `normalize_file` (`offline.rs`): Normalize peak amplitude of `input_path` to `target_level` and write result to `output_path`.
- `Waveform::parse` (`synthesis.rs`): Parse a waveform name.
- `Waveform::as_str` (`synthesis.rs`): Return the stable Lua-facing waveform name.
- `Waveform::render` (`synthesis.rs`): Render a mono sound buffer for this waveform.
- `AdsrEnvelope::new` (`synthesis.rs`): Create a new ADSR envelope.
- `AdsrEnvelope::trigger_on` (`synthesis.rs`): Start the envelope attack phase.
- `AdsrEnvelope::trigger_off` (`synthesis.rs`): Start the envelope release phase.
- `AdsrEnvelope::next_sample` (`synthesis.rs`): Return the next envelope gain sample.
- `AdsrEnvelope::is_idle` (`synthesis.rs`): Return true when the envelope is idle.
- `AdsrEnvelope::apply` (`synthesis.rs`): Apply this envelope to a whole sound buffer.
- `AdsrEnvelope::set_sample_rate` (`synthesis.rs`): Set the sample rate used by `next_sample`.
- `Synthesizer::new` (`synthesis.rs`): Create a synthesizer using a sine waveform and no envelope.
- `Synthesizer::with_envelope` (`synthesis.rs`): Return a copy of this synthesizer with an envelope attached.
- `Synthesizer::set_waveform` (`synthesis.rs`): Set the oscillator waveform.
- `Synthesizer::set_envelope` (`synthesis.rs`): Set the optional envelope.
- `Synthesizer::generate` (`synthesis.rs`): Generate a sound buffer.
- `waveform_to_png` (`visualizer.rs`): Render waveform overview of `input_wav` to `output_png` with given image size.
- `spectrogram_to_png` (`visualizer.rs`): Render a spectrogram heatmap of `input_wav` to `output_png` using a Hann-windowed DFT.

## Lua API Reference

- Binding path(s): `src/lua_api/dsp_api.rs`
- Namespace: `lurek.dsp`

### Module Functions
- `lurek.dsp.newEffectParams`: Creates an effect parameter descriptor table for use with offline processing.
- `lurek.dsp.processOffline`: Processes an audio file offline through a chain of effects and writes the result to an output file.
- `lurek.dsp.normalize`: Normalizes an audio file to a target peak amplitude and saves the result.
- `lurek.dsp.waveformToPng`: Renders a waveform visualization of an audio file and saves it as a PNG image.
- `lurek.dsp.spectrogramToPng`: Renders a spectrogram visualization of an audio file and saves it as a PNG image.
- `lurek.dsp.applyLowpass`: Applies a lowpass filter in-place to the sound data.
- `lurek.dsp.applyHighpass`: Applies a highpass filter in-place to the sound data.
- `lurek.dsp.applyBandpass`: Applies a bandpass filter in-place to the sound data.
- `lurek.dsp.applyGain`: Applies a gain multiplier in-place to the sound data.
- `lurek.dsp.analyzeRms`: Analyzes the RMS volume of a `SoundData` buffer.
- `lurek.dsp.analyzePeak`: Analyzes the Peak volume of a `SoundData` buffer.
- `lurek.dsp.analyzeFft`: Performs FFT analysis on a `SoundData` buffer and returns frequency bin magnitudes.
- `lurek.dsp.analyzeFft`: Performs FFT analysis on a `SoundData` buffer and returns frequency bin magnitudes.
- `lurek.dsp.addEffectToBus`: Adds an effect to a named audio bus and returns its effect ID.
- `lurek.dsp.removeEffectFromBus`: Removes an effect from a named audio bus by effect ID.
- `lurek.dsp.setEffectParam`: Sets a parameter value on an effect attached to a named audio bus.
- `lurek.dsp.newSineWave`: Generates a sine wave as a `SoundData` buffer.
- `lurek.dsp.newSquareWave`: Generates a square wave as a `SoundData` buffer.
- `lurek.dsp.newSawtoothWave`: Generates a sawtooth wave as a `SoundData` buffer.
- `lurek.dsp.newTriangleWave`: Generates a triangle wave as a `SoundData` buffer.
- `lurek.dsp.newWhiteNoise`: Generates deterministic white noise as a `SoundData` buffer.
- `lurek.dsp.newSynthWave`: Generates a synthesized waveform with optional ADSR.
- `lurek.dsp.newLevelDetector`: Creates a level detector object that tracks RMS, peak, and clipping state over samples.
- `lurek.dsp.newSpectrumAnalyzer`: Creates a spectrum analyzer object for bounded frequency-bin analysis on SoundData.
- `lurek.dsp.newWaveform`: Creates a waveform descriptor object that can render repeated procedural tones.
- `lurek.dsp.newAdsrEnvelope`: Creates an ADSR envelope object for procedural synthesis and buffer shaping workflows.
- `lurek.dsp.newSynthesizer`: Creates a synthesizer object that combines waveform selection and optional ADSR shaping.
- `lurek.dsp.newNode`: Creates a DSP graph node object with a node kind and optional initial options.
- `lurek.dsp.newGraph`: Creates an empty DSP graph object for connecting nodes and processing SoundData buffers.

### `LAdsrEnvelope` Methods
- `LAdsrEnvelope:trigger_on`: Starts the envelope attack phase for this ADSR object.
- `LAdsrEnvelope:trigger_off`: Starts the envelope release phase.
- `LAdsrEnvelope:next_sample`: Advances the envelope and returns the next gain sample.
- `LAdsrEnvelope:is_idle`: Returns whether the envelope has fully completed and is idle.
- `LAdsrEnvelope:apply`: Applies this ADSR envelope across an entire sound buffer in place.

### `LDspGraph` Methods
- `LDspGraph:addNode`: Adds a DSP node object to the graph and returns its stable node ID.
- `LDspGraph:connect`: Connects two node IDs in this graph object.
- `LDspGraph:disconnect`: Removes a connection between two node IDs.
- `LDspGraph:process`: Processes a sound buffer through the graph and returns transformed data.
- `LDspGraph:clear`: Clears all graph nodes and edges from this graph.

### `LDspNode` Methods
- `LDspNode:setParam`: Sets one named numeric parameter on the node.
- `LDspNode:getParam`: Returns one named numeric parameter from the node.
- `LDspNode:type`: Returns the node type string used by this node.

### `LLevelDetector` Methods
- `LLevelDetector:process_sample`: Processes one audio sample and updates detector statistics incrementally.
- `LLevelDetector:process`: Processes all samples in a sound buffer and returns aggregate level statistics.
- `LLevelDetector:get_rms`: Returns the current RMS level accumulated by the detector.
- `LLevelDetector:get_peak`: Returns the current peak level accumulated by the detector.
- `LLevelDetector:to_db`: Converts a linear amplitude value to decibels full scale.
- `LLevelDetector:reset`: Resets detector state so a new measurement window can begin.

### `LSpectrumAnalyzer` Methods
- `LSpectrumAnalyzer:setSize`: Sets the frequency-bin count used by subsequent spectrum analysis calls.
- `LSpectrumAnalyzer:analyze`: Analyzes one sound buffer and returns `(frequency, magnitude)` rows.

### `LSynthesizer` Methods
- `LSynthesizer:setWaveform`: Sets the oscillator waveform using a kind string or waveform object.
- `LSynthesizer:setEnvelope`: Attaches an ADSR envelope used by future render calls.
- `LSynthesizer:render`: Renders a SoundData buffer using current synthesizer settings.
- `LSynthesizer:generate`: Generates a SoundData buffer; alias of `render` for compatibility.

### `LWaveform` Methods
- `LWaveform:render`: Renders this waveform to a new SoundData buffer.
- `LWaveform:type`: Returns the waveform identifier string.

## References

- `audio`: Imports or references `src/audio/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.

## Notes

- None.
