# dsp

## TL;DR

- The `dsp` module is the signal-processing layer for audio: real-time effects, offline transforms, synthesis, analysis, and visualization helpers in one CPU-first toolkit.

## General Info

- Module group: `Platform Services`
- Source path: `src/dsp/`
- Binding: `src/lua_api/dsp_api.rs`
- Namespace: `lurek.dsp`
- Lua API surface: `29` functions, `7` types, `27` methods
- Rust test path(s): tests/rust/unit/audio_tests.rs (shared with audio)
- Lua test path(s): tests/lua/unit/test_dsp_core_unit.lua

## Summary

The `dsp` module is the engine's audio signal workbench. It focuses on transforming and analyzing sound data, while playback ownership and device scheduling stay in neighboring modules.

For live runtime use, it provides effect chains, graph-style processing, and safe parameter updates that can be changed during playback. This supports responsive sound design without forcing fragile ad-hoc processing code.

For offline workflows, the same module can process stored audio deterministically. Teams can run batch transforms, normalization, and export-oriented effect passes for content preparation and repeatable pipelines.

Synthesis and inspection are included in the same surface. You can generate tones and noise, shape them with envelopes, measure RMS and peak behavior, inspect spectrum bins, and produce visual outputs such as waveform or spectrogram images.

In practice, `lurek.dsp` provides one consistent signal core for runtime, tools, and QA: build effects, process buffers, inspect results, and visualize behavior with predictable outputs.

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

- `LAdsrEnvelope:apply`: Applies this ADSR envelope across an entire sound buffer in place.
- `LAdsrEnvelope:is_idle`: Returns whether the envelope has fully completed and is idle.
- `LAdsrEnvelope:next_sample`: Advances the envelope and returns the next gain sample.
- `LAdsrEnvelope:trigger_off`: Starts the envelope release phase.
- `LAdsrEnvelope:trigger_on`: Starts the envelope attack phase for this ADSR object.

#### LDspGraph Type

- Lua-visible DSP graph that stores nodes, edges, and offline processing order.

##### Fields

- No documented fields.

##### Methods

- `LDspGraph:addNode`: Adds a DSP node object to the graph and returns its stable node ID.
- `LDspGraph:clear`: Clears all graph nodes and edges from this graph.
- `LDspGraph:connect`: Connects two node IDs in this graph object.
- `LDspGraph:disconnect`: Removes a connection between two node IDs.
- `LDspGraph:process`: Processes a sound buffer through the graph and returns transformed data.

#### LDspNode Type

- Lua-visible DSP graph node carrying type and simple numeric parameters.

##### Fields

- No documented fields.

##### Methods

- `LDspNode:getParam`: Returns one named numeric parameter from the node.
- `LDspNode:setParam`: Sets one named numeric parameter on the node.
- `LDspNode:type`: Returns the node type string used by this node.

#### LLevelDetector Type

- Lua-visible running detector that tracks RMS, peak, and clipping state for processed audio.

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

- Lua-visible spectral analyzer that computes bounded frequency bins from sound buffers.

##### Fields

- No documented fields.

##### Methods

- `LSpectrumAnalyzer:analyze`: Analyzes one sound buffer and returns `(frequency, magnitude)` rows.
- `LSpectrumAnalyzer:setSize`: Sets the frequency-bin count used by subsequent spectrum analysis calls.

#### LSynthesizer Type

- Lua-visible synthesizer that combines waveform selection and optional ADSR shaping.

##### Fields

- No documented fields.

##### Methods

- `LSynthesizer:generate`: Generates a SoundData buffer; alias of `render` for compatibility.
- `LSynthesizer:render`: Renders a SoundData buffer using current synthesizer settings.
- `LSynthesizer:setEnvelope`: Attaches an ADSR envelope used by future render calls.
- `LSynthesizer:setWaveform`: Sets the oscillator waveform using a kind string or waveform object.

#### LWaveform Type

- Lua-visible procedural waveform descriptor used for repeated SoundData rendering.

##### Fields

- No documented fields.

##### Methods

- `LWaveform:render`: Renders this waveform to a new SoundData buffer.
- `LWaveform:type`: Returns the waveform identifier string.

