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

The `dsp` module owns signal-processing logic independent from the playback scheduler. It provides real-time graph/effect components, offline processing helpers, waveform/synthesis tools, and analysis/visualization utilities, while audio transport and source lifecycle stay in the `audio` module.

Submodule boundaries are functional: `effects` defines effect types and parameter/state wrappers, `graph` coordinates shared processing graph abstractions, `analysis` provides level/spectrum helpers, `offline` applies effect chains to file workflows, `synthesis` provides waveform/envelope generation helpers, and `visualizer` renders waveform/spectrogram outputs.

A key design requirement is thread-safe processing behavior for audio-thread usage, including non-blocking control paths for graph/effect updates. This enables dynamic effect changes without coupling control traffic to render/audio critical paths.

In architecture terms, `dsp` should remain the transformation layer: it mutates and analyzes signal data. Playback orchestration and source routing should continue to be handled by neighboring audio runtime modules.

Implementation detail and boundary guarantees for dsp: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: analysis.rs: Provides RMS level detection, peak tracking, and clipping detection over f32 sample streams.; effects.rs: Lock-free AtomicParam for sharing f32 parameters between the audio thread and Lua API.; graph.rs: DSP processing graph: nodes connected by typed audio-rate and control-rate edges.; mod.rs: Digital signal processing (DSP) sub-system: graph, nodes, and effect chain.; offline.rs: Offline audio processing: apply DSP effect chains to files without real-time playback.; synthesis.rs: Procedural audio synthesis: waveform oscillators, noise generation, ADSR envelope, and multi-oscillator rendering.; visualizer.rs: Waveform-to-PNG rendering: peak min/max per column plotted as vertical bars.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### analysis.rs

- Provides RMS level detection, peak tracking, and clipping detection over f32 sample streams.
- `LevelDetector` accumulates sum-of-squares and peak per sample; exposes RMS, peak, clipping flag, and dBFS conversion.
- `SpectrumAnalyzer` delegates to `SoundData::analyze_dft` with a bounded bin count clamped to 1–512.
- Used by audio subsystem and Lua DSP bindings to inspect signal levels and spectrum before mixing.

### effects.rs

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

### graph.rs

- DSP processing graph: nodes connected by typed audio-rate and control-rate edges.
- `DspGraph` owns a topologically sorted list of `DspNode` processing units.
- Edges carry either audio frames (f32 interleaved) or scalar control signals.
- Evaluated once per audio buffer in the rodio callback on the audio thread.
- Graph mutation (add/remove node, patch edge) is performed from the game thread
- via a lock-free command queue consumed at the start of each audio callback.

### mod.rs

- Digital signal processing (DSP) sub-system: graph, nodes, and effect chain.
- Provides a per-source processing graph evaluated on the audio thread.
- Node types include: gain, pan, low-pass/high-pass filters, reverb, and delay.
- Graph topology changes are sent via a lock-free command queue to avoid blocking.
- Re-exported to Lua via `lurek.audio.dsp.*` through `audio_api.rs`.

### offline.rs

- Offline audio processing: apply DSP effect chains to files without real-time playback.
- Peak normalisation with configurable target level.
- WAV file decode to f32 and encode back to 16-bit PCM via rodio.
- `OfflineEffect` serialisable struct matching `EffectType` + three parameter slots.
- Parent directory auto-creation for output paths.

### synthesis.rs

- Procedural audio synthesis: waveform oscillators, noise generation, ADSR envelope, and multi-oscillator rendering.
- `Waveform` selects the oscillator shape — sine, square, sawtooth, triangle, or white noise — and exposes `parse()` for name-based construction from Lua configuration.
- `AdsrEnvelope` applies attack, decay, sustain, and release amplitude shaping; `amplitude_at(elapsed)` returns the gain multiplier at any point in the note's lifetime.
- `Synthesizer` combines a `Waveform` oscillator and an `AdsrEnvelope` to render a complete `SoundData` PCM buffer at a given frequency, duration, sample rate, and peak amplitude.
- All rendering is CPU-side in a tight sample loop; the resulting `SoundData` is passed to `rodio` for device mixing via the audio subsystem.

### visualizer.rs

- Waveform-to-PNG rendering: peak min/max per column plotted as vertical bars.
- Spectrogram-to-PNG rendering: Hann-windowed DFT with frequency bins mapped to heatmap colours.
- Mono downmix helper for multi-channel input files.
- Heat-colour mapping from normalised magnitude to RGBA.
- Parent directory auto-creation for output image paths.

## Lua API Ref

- Binding: `src/lua_api/dsp_api.rs`
- Namespace: `lurek.dsp`

### Functions

- `lurek.dsp.addEffectToBus`: Adds an effect to a named audio bus and returns its effect ID.
- `lurek.dsp.analyzeFft`: Performs FFT analysis on a `SoundData` buffer and returns frequency bin magnitudes.
- `lurek.dsp.analyzeFft`: Performs FFT analysis on a `SoundData` buffer and returns frequency bin magnitudes.
- `lurek.dsp.analyzePeak`: Analyzes the Peak volume of a `SoundData` buffer.
- `lurek.dsp.analyzeRms`: Analyzes the RMS volume of a `SoundData` buffer.
- `lurek.dsp.applyBandpass`: Applies a bandpass filter in-place to the sound data.
- `lurek.dsp.applyGain`: Applies a gain multiplier in-place to the sound data.
- `lurek.dsp.applyHighpass`: Applies a highpass filter in-place to the sound data.
- `lurek.dsp.applyLowpass`: Applies a lowpass filter in-place to the sound data.
- `lurek.dsp.newAdsrEnvelope`: Creates an ADSR envelope object for procedural synthesis and buffer shaping workflows.
- `lurek.dsp.newEffectParams`: Creates an effect parameter descriptor table for use with offline processing.
- `lurek.dsp.newGraph`: Creates an empty DSP graph object for connecting nodes and processing SoundData buffers.
- `lurek.dsp.newLevelDetector`: Creates a level detector object that tracks RMS, peak, and clipping state over samples.
- `lurek.dsp.newNode`: Creates a DSP graph node object with a node kind and optional initial options.
- `lurek.dsp.newSawtoothWave`: Generates a sawtooth wave as a `SoundData` buffer.
- `lurek.dsp.newSineWave`: Generates a sine wave as a `SoundData` buffer.
- `lurek.dsp.newSpectrumAnalyzer`: Creates a spectrum analyzer object for bounded frequency-bin analysis on SoundData.
- `lurek.dsp.newSquareWave`: Generates a square wave as a `SoundData` buffer.
- `lurek.dsp.newSynthWave`: Generates a synthesized waveform with optional ADSR.
- `lurek.dsp.newSynthesizer`: Creates a synthesizer object that combines waveform selection and optional ADSR shaping.
- `lurek.dsp.newTriangleWave`: Generates a triangle wave as a `SoundData` buffer.
- `lurek.dsp.newWaveform`: Creates a waveform descriptor object that can render repeated procedural tones.
- `lurek.dsp.newWhiteNoise`: Generates deterministic white noise as a `SoundData` buffer.
- `lurek.dsp.normalize`: Normalizes an audio file to a target peak amplitude and saves the result.
- `lurek.dsp.processOffline`: Processes an audio file offline through a chain of effects and writes the result to an output file.
- `lurek.dsp.removeEffectFromBus`: Removes an effect from a named audio bus by effect ID.
- `lurek.dsp.setEffectParam`: Sets a parameter value on an effect attached to a named audio bus.
- `lurek.dsp.spectrogramToPng`: Renders a spectrogram visualization of an audio file and saves it as a PNG image.
- `lurek.dsp.waveformToPng`: Renders a waveform visualization of an audio file and saves it as a PNG image.

### Enums

- No documented module-level enums/constants.

### Types


#### LAdsrEnvelope Type


##### Fields

- No documented fields.

##### Methods

- `LAdsrEnvelope:apply`: Applies this ADSR envelope across an entire sound buffer in place.
- `LAdsrEnvelope:is_idle`: Returns whether the envelope has fully completed and is idle.
- `LAdsrEnvelope:next_sample`: Advances the envelope and returns the next gain sample.
- `LAdsrEnvelope:trigger_off`: Starts the envelope release phase.
- `LAdsrEnvelope:trigger_on`: Starts the envelope attack phase for this ADSR object.


#### LDspGraph Type


##### Fields

- No documented fields.

##### Methods

- `LDspGraph:addNode`: Adds a DSP node object to the graph and returns its stable node ID.
- `LDspGraph:clear`: Clears all graph nodes and edges from this graph.
- `LDspGraph:connect`: Connects two node IDs in this graph object.
- `LDspGraph:disconnect`: Removes a connection between two node IDs.
- `LDspGraph:process`: Processes a sound buffer through the graph and returns transformed data.


#### LDspNode Type


##### Fields

- No documented fields.

##### Methods

- `LDspNode:getParam`: Returns one named numeric parameter from the node.
- `LDspNode:setParam`: Sets one named numeric parameter on the node.
- `LDspNode:type`: Returns the node type string used by this node.


#### LLevelDetector Type


##### Fields

- No documented fields.

##### Methods

- `LLevelDetector:get_peak`: Returns the current peak level accumulated by the detector.
- `LLevelDetector:get_rms`: Returns the current RMS level accumulated by the detector.
- `LLevelDetector:process`: Processes all samples in a sound buffer and returns aggregate level statistics.
- `LLevelDetector:process_sample`: Processes one audio sample and updates detector statistics incrementally.
- `LLevelDetector:reset`: Resets detector state so a new measurement window can begin.
- `LLevelDetector:to_db`: Converts a linear amplitude value to decibels full scale.


#### LSpectrumAnalyzer Type


##### Fields

- No documented fields.

##### Methods

- `LSpectrumAnalyzer:analyze`: Analyzes one sound buffer and returns `(frequency, magnitude)` rows.
- `LSpectrumAnalyzer:setSize`: Sets the frequency-bin count used by subsequent spectrum analysis calls.


#### LSynthesizer Type


##### Fields

- No documented fields.

##### Methods

- `LSynthesizer:generate`: Generates a SoundData buffer; alias of `render` for compatibility.
- `LSynthesizer:render`: Renders a SoundData buffer using current synthesizer settings.
- `LSynthesizer:setEnvelope`: Attaches an ADSR envelope used by future render calls.
- `LSynthesizer:setWaveform`: Sets the oscillator waveform using a kind string or waveform object.


#### LWaveform Type


##### Fields

- No documented fields.

##### Methods

- `LWaveform:render`: Renders this waveform to a new SoundData buffer.
- `LWaveform:type`: Returns the waveform identifier string.

## References

- `audio`: Imports or references `src/audio/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.
