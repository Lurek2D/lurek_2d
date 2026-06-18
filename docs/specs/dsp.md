# dsp

## TL;DR

- Manages audio effect graphs, procedural synthesis, level detection, and visualizations.

## General Info

- Module group: `Platform Services`
- Source path: `src/dsp/`
- Binding: `src/lua_api/dsp_api.rs`
- Namespace: `lurek.dsp`
- Lua API surface: `29` functions, `7` types, `27` methods
- Rust test path(s): tests/rust/unit/audio_tests.rs (shared with audio)
- Lua test path(s): tests/lua/unit/test_dsp_core_unit.lua

## Summary

- The `dsp` module is the programmable signal-processing layer for users who need audio to be transformed, analyzed, or synthesized at runtime.
- Effect chains and graph-style processing keep filters, modulation, tone shaping, and other signal operations composable instead of hardcoded into one playback path.
- Real-time and offline workflows live under the same conceptual surface, which means a processing idea can be used during gameplay, in content preparation, or in evidence-oriented audio diagnostics.
- Synthesis, envelopes, metering, spectrum work, and visualization support make the module useful both for designing sound behavior and for understanding why that behavior sounds the way it does.
- This makes the module relevant not only for final playback polish but also for procedural audio, reactive sound design, analysis tools, and educational or debugging views into the signal itself.
- The graph-oriented model is especially useful because complex audio behavior often emerges from several small processing stages that must remain inspectable and reorderable.
- In other words, `dsp` gives the engine a place to reason about signal shape itself, not just about the existence of a sound event or playback source.
- Read it as the audio-processing authority above raw playback: neighboring audio systems own device-facing streaming and transport, while `dsp` owns what happens to the signal itself.

## Imports

- `audio`: Imports or references `src/audio/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.

## Files

### analysis.rs

- `src/dsp/analysis.rs` owns realtime signal measurement for loudness, peaks, clipping, and bounded spectrum summaries.
- It stores rolling RMS and peak state in `LevelDetector` and delegates spectral bins through `SpectrumAnalyzer`.
- This file is the measurement boundary for runtime diagnostics and Lua-facing analysis; it does not alter audio samples.
- SoundData-wide scans and per-sample accumulation both live here so analysis semantics stay consistent across call sites.
- Read it when meter behavior, clipping thresholds, DFT bin sizing, or diagnostic signal analysis rules need changes.

### effects.rs

- `src/dsp/effects.rs` owns the runtime DSP effect system, including algorithms, shared params, and per-source state.
- It defines `EffectType`, `EffectParams`, `ActiveEffect`, `SharedEffectGraph`, and `DynamicEffectSource` together.
- Lock-free `AtomicParam` storage lives here so Lua parameter writes can be observed safely by audio-thread readers.
- Per-sample effect math also lives here, covering filters, shelves, reverb, chorus, flanger, phaser, and dynamics tools.
- The file stores biquad history, delay buffers, compressor envelopes, and LFO phase inside active effect instances.
- Shared-chain mutation helpers live here so writer-side effect edits and reader-side playback stay on one contract.
- This file is the realtime processing boundary for DSP effects; it does not own offline WAV pipelines or synthesis.
- Graph-backed shared chains are coordinated here, but higher-level bus ownership and Lua bindings stay in sibling files.
- Read it when effect algorithms, parameter semantics, chain syncing, or audio-thread processing behavior needs changes.

### graph.rs

- `src/dsp/graph.rs` owns the lightweight DSP graph model that names nodes, edges, routing order, and node parameters.
- It defines `DspNodeType`, `DspNode`, and `DspGraph`, plus the stable `NodeId` handles used for graph mutation.
- Graph processing here is deterministic and insertion-ordered so scripted offline SoundData transforms stay predictable.
- This file is the routing-contract boundary for DSP nodes; it does not own effect-chain runtime state or audio threading.
- Read it when node kinds, graph mutation rules, or ordered DSP processing semantics for SoundData need changes.

### mod.rs

- `src/dsp/mod.rs` is the module index for signal analysis, effects, graphs, offline processing, synthesis, and visuals.
- It declares the files that own measurement, per-sample transforms, graph contracts, rendering, and file-based DSP work.
- This file reexports the main DSP types so callers can assemble analysis and processing flows without deep imports.
- No filter state, generated samples, or offline buffers live here; it only defines visibility and subsystem boundaries.
- Read this index first when tracing DSP behavior, because it shows where runtime effects, synthesis, and tooling split.
- Changes here affect reachability and API shape, not effect math, spectrum rules, or sample-generation semantics.

### offline.rs

- `src/dsp/offline.rs` owns the file-based DSP pipeline that decodes audio, applies effects, and writes WAV output.
- It defines `OfflineEffect` and builds `ActiveEffect` chains from serializable params for deterministic batch processing.
- Peak normalization also lives here so offline loudness correction and effect rendering share one reproducible workflow.
- This file is the non-realtime processing boundary; it does not own live playback state, shared graphs, or visual output.
- Read it when offline render semantics, WAV I/O behavior, or batch effect application for stored audio needs changes.

### synthesis.rs

- `src/dsp/synthesis.rs` owns procedural waveform generation and ADSR-shaped note rendering for synthesized audio.
- It defines `Waveform`, `AdsrEnvelope`, and `Synthesizer`, keeping oscillator choice and envelope behavior in one owner.
- Waveform parsing, note rendering, trigger state, and envelope sampling live here so generated sound stays deterministic.
- It combines oscillator output and optional envelope shaping into `SoundData` buffers ready for later DSP stages.
- This file is the synthesis boundary for lightweight generated audio; it does not own effects, meters, or image output.
- Read it when oscillator shapes, ADSR semantics, or synthesized buffer generation behavior needs to change.

### visualizer.rs

- `src/dsp/visualizer.rs` converts decoded audio buffers into waveform and spectrogram PNG diagnostics.
- It owns mono reduction, windowing, DFT-style magnitude sampling, and pixel-color mapping for offline visual inspection.
- Waveform and spectrogram export live here so audio-image tooling stays separate from playback, synthesis, and effects.
- This file is the visual diagnostics boundary for DSP assets; it does not own meters or generated sample output.
- Read it when DSP image export, heatmap encoding, or waveform rendering rules for inspection tools need changes.



## Lua API Ref

### Functions

- `lurek.dsp.addEffectToBus(bus_name, effect_type_str, params?) -> integer`: Adds an effect to a named audio bus and returns its effect ID.
- `lurek.dsp.analyzeFft(sd, size) -> table`: Performs FFT analysis on a `SoundData` buffer and returns frequency bin magnitudes.
- `lurek.dsp.analyzeFft(sd, size) -> table`: Performs FFT analysis on a `SoundData` buffer and returns frequency bin magnitudes.
- `lurek.dsp.analyzePeak(sd) -> number`: Analyzes the Peak volume of a `SoundData` buffer.
- `lurek.dsp.analyzeRms(sd) -> number`: Analyzes the RMS volume of a `SoundData` buffer.
- `lurek.dsp.applyBandpass(sd_ud, low_hz, high_hz) -> nil`: Applies a bandpass filter in-place to the sound data.
- `lurek.dsp.applyGain(sd_ud, gain) -> nil`: Applies a gain multiplier in-place to the sound data.
- `lurek.dsp.applyHighpass(sd_ud, cutoff_hz) -> nil`: Applies a highpass filter in-place to the sound data.
- `lurek.dsp.applyLowpass(sd_ud, cutoff_hz) -> nil`: Applies a lowpass filter in-place to the sound data.
- `lurek.dsp.newAdsrEnvelope(attack, decay, sustain, release) -> LAdsrEnvelope`: Creates an ADSR envelope object for procedural synthesis and buffer shaping workflows.
- `lurek.dsp.newEffectParams(effectType, p1, p2, p3) -> table`: Creates an effect parameter descriptor table for use with offline processing.
- `lurek.dsp.newGraph() -> LDspGraph`: Creates an empty DSP graph object for connecting nodes and processing SoundData buffers.
- `lurek.dsp.newLevelDetector(options?) -> LLevelDetector`: Creates a level detector object that tracks RMS, peak, and clipping state over samples.
- `lurek.dsp.newNode(kind, options?) -> LDspNode`: Creates a DSP graph node object with a node kind and optional initial options.
- `lurek.dsp.newSawtoothWave(freq, duration, sample_rate, amplitude) -> LSoundData`: Generates a sawtooth wave as a `SoundData` buffer.
- `lurek.dsp.newSineWave(freq, duration, sample_rate, amplitude) -> LSoundData`: Generates a sine wave as a `SoundData` buffer.
- `lurek.dsp.newSpectrumAnalyzer(options?) -> LSpectrumAnalyzer`: Creates a spectrum analyzer object for bounded frequency-bin analysis on SoundData.
- `lurek.dsp.newSquareWave(freq, duration, sample_rate, amplitude) -> LSoundData`: Generates a square wave as a `SoundData` buffer.
- `lurek.dsp.newSynthWave(waveform, freq, duration, sample_rate, amplitude, adsr?) -> LSoundData`: Generates a synthesized waveform with optional ADSR.
- `lurek.dsp.newSynthesizer(options?) -> LSynthesizer`: Creates a synthesizer object that combines waveform selection and optional ADSR shaping.
- `lurek.dsp.newTriangleWave(freq, duration, sample_rate, amplitude) -> LSoundData`: Generates a triangle wave as a `SoundData` buffer.
- `lurek.dsp.newWaveform(kind, options?) -> LWaveform`: Creates a waveform descriptor object that can render repeated procedural tones.
- `lurek.dsp.newWhiteNoise(duration, sample_rate, amplitude, seed) -> LSoundData`: Generates deterministic white noise as a `SoundData` buffer.
- `lurek.dsp.normalize(input, output, target) -> boolean`: Normalizes an audio file to a target peak amplitude and saves the result.
- `lurek.dsp.processOffline(input, output, effects) -> boolean`: Processes an audio file offline through a chain of effects and writes the result to an output file.
- `lurek.dsp.removeEffectFromBus(bus_name, effect_id) -> boolean`: Removes an effect from a named audio bus by effect ID.
- `lurek.dsp.setEffectParam(bus_name, effect_id, param_name, value) -> boolean`: Sets a parameter value on an effect attached to a named audio bus.
- `lurek.dsp.spectrogramToPng(input, output, width, height) -> boolean`: Renders a spectrogram visualization of an audio file and saves it as a PNG image.
- `lurek.dsp.waveformToPng(input, output, width, height) -> boolean`: Renders a waveform visualization of an audio file and saves it as a PNG image.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAdsrEnvelope Type

- Lua-visible ADSR envelope object for sample stepping and buffer shaping.

##### Fields

- No documented fields.

##### Methods

- `LAdsrEnvelope:apply(sound_data_ud) -> nil`: Applies this ADSR envelope across an entire sound buffer in place.
- `LAdsrEnvelope:is_idle() -> boolean`: Returns whether the envelope has fully completed and is idle.
- `LAdsrEnvelope:next_sample() -> number`: Advances the envelope and returns the next gain sample.
- `LAdsrEnvelope:trigger_off() -> nil`: Starts the envelope release phase.
- `LAdsrEnvelope:trigger_on() -> nil`: Starts the envelope attack phase for this ADSR object.

#### LDspGraph Type

- Lua-visible DSP graph that stores nodes, edges, and offline processing order.

##### Fields

- No documented fields.

##### Methods

- `LDspGraph:addNode(node_ud) -> integer`: Adds a DSP node object to the graph and returns its stable node ID.
- `LDspGraph:clear() -> nil`: Clears all graph nodes and edges from this graph.
- `LDspGraph:connect(from, to, options?) -> boolean`: Connects two node IDs in this graph object.
- `LDspGraph:disconnect(from, to) -> boolean`: Removes a connection between two node IDs.
- `LDspGraph:process(sound_data_ud) -> LSoundData`: Processes a sound buffer through the graph and returns transformed data.

#### LDspNode Type

- Lua-visible DSP graph node carrying type and simple numeric parameters.

##### Fields

- No documented fields.

##### Methods

- `LDspNode:getParam(name) -> number`: Returns one named numeric parameter from the node.
- `LDspNode:setParam(name, value) -> nil`: Sets one named numeric parameter on the node.
- `LDspNode:type() -> string`: Returns the node type string used by this node.

#### LLevelDetector Type

- Lua-visible running detector that tracks RMS, peak, and clipping state for processed audio.

##### Fields

- No documented fields.

##### Methods

- `LLevelDetector:get_peak() -> number`: Returns the current peak level accumulated by the detector.
- `LLevelDetector:get_rms() -> number`: Returns the current RMS level accumulated by the detector.
- `LLevelDetector:process(sound_data_ud) -> table`: Processes all samples in a sound buffer and returns aggregate level statistics.
- `LLevelDetector:process_sample(sample) -> nil`: Processes one audio sample and updates detector statistics incrementally.
- `LLevelDetector:reset() -> nil`: Resets detector state so a new measurement window can begin.
- `LLevelDetector:to_db(value) -> number`: Converts a linear amplitude value to decibels full scale.

#### LSpectrumAnalyzer Type

- Lua-visible spectral analyzer that computes bounded frequency bins from sound buffers.

##### Fields

- No documented fields.

##### Methods

- `LSpectrumAnalyzer:analyze(sound_data_ud) -> table`: Analyzes one sound buffer and returns `(frequency, magnitude)` rows.
- `LSpectrumAnalyzer:setSize(size) -> nil`: Sets the frequency-bin count used by subsequent spectrum analysis calls.

#### LSynthesizer Type

- Lua-visible synthesizer that combines waveform selection and optional ADSR shaping.

##### Fields

- No documented fields.

##### Methods

- `LSynthesizer:generate(freq, duration, sample_rate, amplitude) -> LSoundData`: Generates a SoundData buffer; alias of `render` for compatibility.
- `LSynthesizer:render(freq, duration, sample_rate, amplitude) -> LSoundData`: Renders a SoundData buffer using current synthesizer settings.
- `LSynthesizer:setEnvelope(envelope_ud) -> nil`: Attaches an ADSR envelope used by future render calls.
- `LSynthesizer:setWaveform(value) -> nil`: Sets the oscillator waveform using a kind string or waveform object.

#### LWaveform Type

- Lua-visible procedural waveform descriptor used for repeated SoundData rendering.

##### Fields

- No documented fields.

##### Methods

- `LWaveform:render(freq, duration, sample_rate, amplitude) -> LSoundData`: Renders this waveform to a new SoundData buffer.
- `LWaveform:type() -> string`: Returns the waveform identifier string.

## References

- `audio`: Imports or references `src/audio/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.

## Notes

- No additional module-specific notes.
