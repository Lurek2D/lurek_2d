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
- Lua test path(s): tests/lua_reorg/unit/test_dsp_core_unit.lua

## Summary

- This module gives users programmable audio processing for both live playback and offline content workflows.
- It supports effect chains with runtime-adjustable parameters for filters, modulation, and tone shaping.
- DSP graph composition lets teams define ordered signal flows instead of hardcoding one-off pipelines.
- Real-time and offline paths make the same processing ideas usable in gameplay and asset preparation.
- Procedural synthesis tools generate tones and noise directly, reducing dependence on pre-rendered clips.
- ADSR envelope support enables musically useful shaping for notes, hits, and generated effects.
- Analysis tools expose peak, RMS, and spectrum insights for mix decisions and diagnostics.
- Visualization outputs help users inspect waveform and frequency behavior quickly.
- Offline normalization and processing utilities support repeatable batch prep steps.
- The module improves iteration by keeping synthesis, effects, and analysis in one namespace.
- Users can prototype sound design ideas directly in script before committing to asset pipelines.
- It also supports advanced debug workflows where audible behavior must be measurable.
- In short, this is the signal-processing layer for adaptive and inspectable game audio.
- It bridges creative sound design and deterministic runtime control in one module.

This module primarily collaborates with `audio`, `runtime`. Its responsibility should stay inside the `Platform Services` group rather than absorb behavior owned by those neighbors.

## Imports

- `audio`: Imports or references `src/audio/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.

## Files

### analysis.rs

- Provides realtime signal analysis primitives for level tracking and spectral inspection of sample streams.
- Maintains rolling RMS and peak state to expose stable loudness and clipping indicators during processing.
- Computes bounded frequency summaries that keep analysis cost predictable for scripting and runtime tooling.
- Supports both engine internals and Lua-facing diagnostics with consistent measurement semantics.
- Delivers the inspection layer used to observe signal health before and during mix decisions.

### effects.rs

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

### graph.rs

- Provides a typed DSP graph model where nodes and edges describe ordered signal-processing flow.
- Organizes processing units into deterministic traversal order for stable per-buffer execution.
- Supports audio-rate and control-rate connectivity so routing and parameter signals share one structure.
- Enables safe runtime mutation patterns that coordinate producer updates with callback-side consumption.
- Delivers the structural layer used to compose complex effect pipelines from reusable nodes.

### mod.rs

- Provides the high-level DSP module boundary that groups analysis, synthesis, effects, graphs, offline, and visualization flows.
- Coordinates reusable signal-processing capabilities while keeping runtime execution and inspection concerns clearly separated.
- Delivers one stable composition surface for audio-adjacent digital processing across engine integrations.

### offline.rs

- Provides offline DSP processing that applies effect chains to stored audio without live playback.
- Runs decode, transform, and encode stages in one pipeline for reproducible file-based processing.
- Supports peak normalization and deterministic parameterized effects for batch rendering scenarios.
- Uses a serializable effect description so external tooling can request stable offline transforms.
- Delivers the non-realtime processing path for exports, precompute steps, and content baking.

### synthesis.rs

- Provides procedural audio synthesis primitives for waveform generation and envelope-shaped note rendering.
- Defines stable oscillator forms and parsing paths that map script choices to deterministic sample output.
- Applies ADSR gain shaping so rendered notes include natural attack, sustain behavior, and release tails.
- Combines oscillator and envelope models into renderable buffers ready for playback and further processing.
- Delivers the synthesis layer used for generated sound effects and lightweight musical content.
- Keeps synthesis behavior modular so higher-level systems can extend sound generation workflows safely.

### visualizer.rs

- Provides DSP visualization utilities that convert audio buffers into readable waveform and spectrogram images.
- Extracts amplitude and frequency structure into pixel-space summaries for quick offline inspection.
- Handles multi-channel input normalization so visual output stays coherent across source formats.
- Maps signal magnitude to consistent color intensity for comparable visual diagnostics over time.
- Delivers artifact generation used by tooling, debugging workflows, and content analysis pipelines.



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
