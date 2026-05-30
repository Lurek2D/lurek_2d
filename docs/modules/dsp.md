# Dsp

## Summary

The `dsp` module owns signal-processing logic independent from the playback scheduler. It provides real-time graph/effect components, offline processing helpers, waveform/synthesis tools, and analysis/visualization utilities, while audio transport and source lifecycle stay in the `audio` module.

Submodule boundaries are functional: `effects` defines effect types and parameter/state wrappers, `graph` coordinates shared processing graph abstractions, `analysis` provides level/spectrum helpers, `offline` applies effect chains to file workflows, `synthesis` provides waveform/envelope generation helpers, and `visualizer` renders waveform/spectrogram outputs.

A key design requirement is thread-safe processing behavior for audio-thread usage, including non-blocking control paths for graph/effect updates. This enables dynamic effect changes without coupling control traffic to render/audio critical paths.

In architecture terms, `dsp` should remain the transformation layer: it mutates and analyzes signal data. Playback orchestration and source routing should continue to be handled by neighboring audio runtime modules.

Implementation detail and boundary guarantees for dsp: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: analysis.rs: Provides RMS level detection, peak tracking, and clipping detection over f32 sample streams.; effects.rs: Lock-free AtomicParam for sharing f32 parameters between the audio thread and Lua API.; graph.rs: DSP processing graph: nodes connected by typed audio-rate and control-rate edges.; mod.rs: Digital signal processing (DSP) sub-system: graph, nodes, and effect chain.; offline.rs: Offline audio processing: apply DSP effect chains to files without real-time playback.; synthesis.rs: Procedural audio synthesis: waveform oscillators, noise generation, ADSR envelope, and multi-oscillator rendering.; visualizer.rs: Waveform-to-PNG rendering: peak min/max per column plotted as vertical bars.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

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

## Functions

### `lurek.dsp.addEffectToBus`

Adds an effect to a named audio bus and returns its effect ID.

```lua
lurek.dsp.addEffectToBus(bus_name, effect_type_str, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bus_name` | string | Name of the audio bus. |
| `effect_type_str` | string | Effect type identifier (e.g. `"lowpass"`, `"highpass"`, `"reverb"`). |
| `params?` | table | Optional parameters table; may include a `value` field. |

**Returns**

| Type | Description |
|------|-------------|
| number | Numeric effect ID handle for use with `removeEffectFromBus` and `setEffectParam`. |

**Example**

```lua
do
    lurek.audio.newBus("dsp_bus_fx")
    local id = lurek.dsp.addEffectToBus("dsp_bus_fx", "lowpass", {value=2000.0})
    print("lurek.dsp.addEffectToBus id=" .. tostring(id))
end
```

---

### `lurek.dsp.analyzeFft`

Performs FFT analysis on a `SoundData` buffer and returns frequency bin magnitudes.

```lua
lurek.dsp.analyzeFft(sd, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sd` | [LSoundData](#lsounddata-handle) | The sound data to analyze. |
| `size` | number | Number of frequency bins to compute (capped at 512). |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of tables, each with `frequency` (number, Hz) and `magnitude` (number) fields. |

**Example**

```lua
do
    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local result = lurek.dsp.analyzeFft(sd, 64)
    print("lurek.dsp.analyzeFft bins=" .. tostring(#result))
end
```

---

### `lurek.dsp.analyzePeak`

Analyzes the Peak volume of a `SoundData` buffer.

```lua
lurek.dsp.analyzePeak(sd)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sd` | [LSoundData](#lsounddata-handle) | The sound data to analyze. |

**Returns**

| Type | Description |
|------|-------------|
| number | Peak amplitude in the range [0.0, 1.0]. |

**Example**

```lua
do
    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local peak = lurek.dsp.analyzePeak(sd)
    print("lurek.dsp.analyzePeak peak=" .. tostring(peak))
end
```

---

### `lurek.dsp.analyzeRms`

Analyzes the RMS volume of a `SoundData` buffer.

```lua
lurek.dsp.analyzeRms(sd)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sd` | [LSoundData](#lsounddata-handle) | The sound data to analyze. |

**Returns**

| Type | Description |
|------|-------------|
| number | RMS amplitude in the range [0.0, 1.0]. |

**Example**

```lua
do
    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local rms = lurek.dsp.analyzeRms(sd)
    print("lurek.dsp.analyzeRms rms=" .. tostring(rms))
end
```

---

### `lurek.dsp.applyBandpass`

Applies a bandpass filter in-place to the sound data.

```lua
lurek.dsp.applyBandpass(sd_ud, low_hz, high_hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sd_ud` | [LSoundData](#lsounddata-handle) | The sound data to process. |
| `low_hz` | number | Lower cutoff frequency in Hz. |
| `high_hz` | number | Upper cutoff frequency in Hz. |

**Example**

```lua
do
    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyBandpass(sd, 500.0, 2000.0)
    print("lurek.dsp.applyBandpass sampleCount=" .. tostring(sd:getSampleCount()))
end
```

---

### `lurek.dsp.applyGain`

Applies a gain multiplier in-place to the sound data.

```lua
lurek.dsp.applyGain(sd_ud, gain)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sd_ud` | [LSoundData](#lsounddata-handle) | The sound data to process. |
| `gain` | number | Gain multiplier (1.0 = unity, >1.0 = louder, <1.0 = quieter). |

**Example**

```lua
do
    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyGain(sd, 0.5)
    print("lurek.dsp.applyGain sampleCount=" .. tostring(sd:getSampleCount()))
end
```

---

### `lurek.dsp.applyHighpass`

Applies a highpass filter in-place to the sound data.

```lua
lurek.dsp.applyHighpass(sd_ud, cutoff_hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sd_ud` | [LSoundData](#lsounddata-handle) | The sound data to process. |
| `cutoff_hz` | number | Highpass cutoff frequency in Hz. |

**Example**

```lua
do
    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyHighpass(sd, 2000.0)
    print("lurek.dsp.applyHighpass sampleCount=" .. tostring(sd:getSampleCount()))
end
```

---

### `lurek.dsp.applyLowpass`

Applies a lowpass filter in-place to the sound data.

```lua
lurek.dsp.applyLowpass(sd_ud, cutoff_hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sd_ud` | [LSoundData](#lsounddata-handle) | The sound data to process. |
| `cutoff_hz` | number | Lowpass cutoff frequency in Hz. |

**Example**

```lua
do
    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyLowpass(sd, 1000.0)
    print("lurek.dsp.applyLowpass sampleCount=" .. tostring(sd:getSampleCount()))
end
```

---

### `lurek.dsp.newAdsrEnvelope`

Creates an ADSR envelope object for procedural synthesis and buffer shaping workflows.

```lua
lurek.dsp.newAdsrEnvelope(attack, decay, sustain, release)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `attack` | number | Attack time in seconds. |
| `decay` | number | Decay time in seconds. |
| `sustain` | number | Sustain gain in [0, 1]. |
| `release` | number | Release time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| [LAdsrEnvelope](#ladsrenvelope-handle) | New ADSR envelope instance. |

**Example**

```lua
do
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local s = env:next_sample()
    print("lurek.dsp.newAdsrEnvelope sample=" .. tostring(s))
    print("LAdsrEnvelope:is_idle idle=" .. tostring(env:is_idle()))
    env:trigger_off()
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    env:apply(sd)
    print("LAdsrEnvelope:apply ok")
end
```

---

### `lurek.dsp.newEffectParams`

Creates an effect parameter descriptor table for use with offline processing.

```lua
lurek.dsp.newEffectParams(effectType, p1, p2, p3)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effectType` | string | Effect type name (e.g. "lowpass", "reverb", "compressor"). |
| `p1` | number | Primary parameter value. |
| `p2` | number | Secondary parameter value. |
| `p3` | number | Tertiary parameter value. |

**Returns**

| Type | Description |
|------|-------------|
| table | Effect parameter descriptor table. |

**Example**

```lua
do
    local params = lurek.dsp.newEffectParams("reverb", 0.7, 0.4, 0.2)
    print("lurek.dsp.newEffectParams type=" .. type(params))
    print("effect=" .. tostring(params.type))
end
```

---

### `lurek.dsp.newGraph`

Creates an empty DSP graph object for connecting nodes and processing SoundData buffers.

```lua
lurek.dsp.newGraph()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDspGraph](#ldspgraph-handle) | New DSP graph instance. |

**Example**

```lua
do
    local g = lurek.dsp.newGraph()
    local n1 = lurek.dsp.newNode("lowpass")
    local n2 = lurek.dsp.newNode("gain")
    local id1 = g:addNode(n1)
    local id2 = g:addNode(n2)
    local ok = g:connect(id1, id2)
    print("lurek.dsp.newGraph connect ok=" .. tostring(ok))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local out = g:process(sd)
    print("LDspGraph:process type=" .. type(out))
    local ok2 = g:disconnect(id1, id2)
    print("LDspGraph:disconnect ok=" .. tostring(ok2))
    g:clear()
    print("LDspGraph:clear ok")
end
```

---

### `lurek.dsp.newLevelDetector`

Creates a level detector object that tracks RMS, peak, and clipping state over samples.

```lua
lurek.dsp.newLevelDetector(options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `options?` | table | Optional table with `clipThreshold` numeric field. |

**Returns**

| Type | Description |
|------|-------------|
| [LLevelDetector](#lleveldetector-handle) | New level detector instance. |

**Example**

```lua
do
    local det = lurek.dsp.newLevelDetector({ clipThreshold = 0.99 })
    det:process_sample(0.5)
    det:process_sample(-0.5)
    print("lurek.dsp.newLevelDetector rms=" .. tostring(det:get_rms()))
    print("LLevelDetector:get_peak peak=" .. tostring(det:get_peak()))
    print("LLevelDetector:to_db db=" .. tostring(det:to_db(1.0)))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local result = det:process(sd)
    print("LLevelDetector:process rms=" .. tostring(result.rms))
    det:reset()
    print("LLevelDetector:reset rms=" .. tostring(det:get_rms()))
end
```

---

### `lurek.dsp.newNode`

Creates a DSP graph node object with a node kind and optional initial options.

```lua
lurek.dsp.newNode(kind, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kind` | string | Node kind such as `lowpass`, `highpass`, `bandpass`, or `gain`. |
| `options?` | table | Reserved options table for future node configuration. |

**Returns**

| Type | Description |
|------|-------------|
| [LDspNode](#ldspnode-handle) | New graph node instance. |

**Example**

```lua
do
    local node = lurek.dsp.newNode("lowpass")
    print("lurek.dsp.newNode type=" .. node:type())
    node:setParam("cutoff", 1000.0)
    local val = node:getParam("cutoff")
    print("LDspNode:getParam cutoff=" .. tostring(val))
end
```

---

### `lurek.dsp.newSawtoothWave`

Generates a sawtooth wave as a `SoundData` buffer.

```lua
lurek.dsp.newSawtoothWave(freq, duration, sample_rate, amplitude)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `freq` | number | Frequency in Hz. |
| `duration` | number | Duration in seconds. |
| `sample_rate` | number | Sample rate in Hz. |
| `amplitude` | number | Peak amplitude in [0, 1]. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata-handle) | Generated audio buffer. |

**Example**

```lua
do
    local sd = lurek.dsp.newSawtoothWave(440, 0.01, 44100, 0.5)
    print("lurek.dsp.newSawtoothWave type=" .. type(sd))
end
```

---

### `lurek.dsp.newSineWave`

Generates a sine wave as a `SoundData` buffer.

```lua
lurek.dsp.newSineWave(freq, duration, sample_rate, amplitude)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `freq` | number | Frequency in Hz. |
| `duration` | number | Duration in seconds. |
| `sample_rate` | number | Sample rate in Hz. |
| `amplitude` | number | Peak amplitude in [0, 1]. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata-handle) | Generated audio buffer. |

**Example**

```lua
do
    local sd = lurek.dsp.newSineWave(440, 0.01, 44100, 0.5)
    print("lurek.dsp.newSineWave type=" .. type(sd))
end
```

---

### `lurek.dsp.newSpectrumAnalyzer`

Creates a spectrum analyzer object for bounded frequency-bin analysis on SoundData.

```lua
lurek.dsp.newSpectrumAnalyzer(options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `options?` | table | Optional table with integer `size` field for bin count. |

**Returns**

| Type | Description |
|------|-------------|
| [LSpectrumAnalyzer](#lspectrumanalyzer-handle) | New spectrum analyzer instance. |

**Example**

```lua
do
    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 64 })
    sa:setSize(32)
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bins = sa:analyze(sd)
    print("lurek.dsp.newSpectrumAnalyzer bins=" .. tostring(#bins))
end
```

---

### `lurek.dsp.newSquareWave`

Generates a square wave as a `SoundData` buffer.

```lua
lurek.dsp.newSquareWave(freq, duration, sample_rate, amplitude)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `freq` | number | Frequency in Hz. |
| `duration` | number | Duration in seconds. |
| `sample_rate` | number | Sample rate in Hz. |
| `amplitude` | number | Peak amplitude in [0, 1]. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata-handle) | Generated audio buffer. |

**Example**

```lua
do
    local sd = lurek.dsp.newSquareWave(440, 0.01, 44100, 0.5)
    print("lurek.dsp.newSquareWave type=" .. type(sd))
end
```

---

### `lurek.dsp.newSynthWave`

Generates a synthesized waveform with optional ADSR.

```lua
lurek.dsp.newSynthWave(waveform, freq, duration, sample_rate, amplitude, adsr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `waveform` | string | Waveform kind: `sine`, `square`, `sawtooth`, or `triangle`. |
| `freq` | number | Frequency in Hz. |
| `duration` | number | Duration in seconds. |
| `sample_rate` | number | Sample rate in Hz. |
| `amplitude` | number | Peak amplitude in [0, 1]. |
| `adsr?` | table | Optional ADSR table with `attack`, `decay`, `sustain`, and `release`. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata-handle) | Generated synthesized sound buffer. |

**Example**

```lua
do
    local sd = lurek.dsp.newSynthWave("sine", 440, 0.01, 44100, 0.5, nil)
    print("lurek.dsp.newSynthWave type=" .. type(sd))
end
```

---

### `lurek.dsp.newSynthesizer`

Creates a synthesizer object that combines waveform selection and optional ADSR shaping.

```lua
lurek.dsp.newSynthesizer(options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `options?` | table | Reserved options table for future synthesizer defaults. |

**Returns**

| Type | Description |
|------|-------------|
| [LSynthesizer](#lsynthesizer-handle) | New synthesizer instance. |

**Example**

```lua
do
    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("triangle")
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.02)
    synth:setEnvelope(env)
    local sd = synth:render(440, 0.01, 44100, 0.5)
    print("lurek.dsp.newSynthesizer render type=" .. type(sd))
    local sd2 = synth:generate(440, 0.01, 44100, 0.5)
    print("LSynthesizer:generate type=" .. type(sd2))
end
```

---

### `lurek.dsp.newTriangleWave`

Generates a triangle wave as a `SoundData` buffer.

```lua
lurek.dsp.newTriangleWave(freq, duration, sample_rate, amplitude)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `freq` | number | Frequency in Hz. |
| `duration` | number | Duration in seconds. |
| `sample_rate` | number | Sample rate in Hz. |
| `amplitude` | number | Peak amplitude in [0, 1]. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata-handle) | Generated audio buffer. |

**Example**

```lua
do
    local sd = lurek.dsp.newTriangleWave(440, 0.01, 44100, 0.5)
    print("lurek.dsp.newTriangleWave type=" .. type(sd))
end
```

---

### `lurek.dsp.newWaveform`

Creates a waveform descriptor object that can render repeated procedural tones.

```lua
lurek.dsp.newWaveform(kind, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kind` | string | Waveform kind name. |
| `options?` | table | Reserved options table for future waveform behavior. |

**Returns**

| Type | Description |
|------|-------------|
| [LWaveform](#lwaveform-handle) | New waveform descriptor instance. |

**Example**

```lua
do
    local wf = lurek.dsp.newWaveform("sawtooth")
    print("lurek.dsp.newWaveform type=" .. wf:type())
    local sd = wf:render(220, 0.01, 44100, 0.5)
    print("LWaveform:render type=" .. type(sd))
end
```

---

### `lurek.dsp.newWhiteNoise`

Generates deterministic white noise as a `SoundData` buffer.

```lua
lurek.dsp.newWhiteNoise(duration, sample_rate, amplitude, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | number | Duration in seconds. |
| `sample_rate` | number | Sample rate in Hz. |
| `amplitude` | number | Peak amplitude in [0, 1]. |
| `seed` | number | Deterministic seed for the noise source. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata-handle) | Generated noise buffer. |

**Example**

```lua
do
    local sd = lurek.dsp.newWhiteNoise(0.01, 44100, 0.5, 42)
    print("lurek.dsp.newWhiteNoise type=" .. type(sd))
end
```

---

### `lurek.dsp.normalize`

Normalizes an audio file to a target peak amplitude and saves the result.

```lua
lurek.dsp.normalize(input, output, target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | string | Relative path to the input audio file. |
| `output` | string | Relative path for the output WAV file. |
| `target` | number | Target peak amplitude (e.g. 0.9 for headroom). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the output file was written successfully. |

**Example**

```lua
do
    local input = "content/examples/assets/audio/sample_tone.wav"
    local output = "save/_fs_tests/dsp_normalized.wav"
    local ok = lurek.dsp.normalize(input, output, 0.9)
    print("lurek.dsp.normalize ok=" .. tostring(ok))
    print("normalized exists=" .. tostring(lurek.filesystem.exists(output)))
end
```

---

### `lurek.dsp.processOffline`

Processes an audio file offline through a chain of effects and writes the result to an output file.

```lua
lurek.dsp.processOffline(input, output, effects)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | string | Relative path to the input audio file. |
| `output` | string | Relative path for the output WAV file. |
| `effects` | table | Array of effect tables; each has `type` (string) and optional `p1`, `p2`, `p3` (number) fields. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the output file was written successfully. |

**Example**

```lua
do
    local input = "content/examples/assets/audio/sample_click.wav"
    local output = "save/_fs_tests/dsp_processed.wav"
    local effects = {
        lurek.dsp.newEffectParams("reverb", 0.7, 0.4, 0.2),
        lurek.dsp.newEffectParams("compressor", 0.8, 2.5, 0.1),
    }
    local ok = lurek.dsp.processOffline(input, output, effects)
    print("lurek.dsp.processOffline ok=" .. tostring(ok))
    print("output exists=" .. tostring(lurek.filesystem.exists(output)))
end
```

---

### `lurek.dsp.removeEffectFromBus`

Removes an effect from a named audio bus by effect ID.

```lua
lurek.dsp.removeEffectFromBus(bus_name, effect_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bus_name` | string | Name of the audio bus. |
| `effect_id` | number | Effect ID returned by `addEffectToBus`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the effect was successfully removed. |

**Example**

```lua
do
    lurek.audio.newBus("dsp_bus_rm")
    local id = lurek.dsp.addEffectToBus("dsp_bus_rm", "lowpass", {value=2000.0})
    local ok = lurek.dsp.removeEffectFromBus("dsp_bus_rm", id)
    print("lurek.dsp.removeEffectFromBus ok=" .. tostring(ok))
end
```

---

### `lurek.dsp.setEffectParam`

Sets a parameter value on an effect attached to a named audio bus.

```lua
lurek.dsp.setEffectParam(bus_name, effect_id, param_name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bus_name` | string | Name of the audio bus. |
| `effect_id` | number | Effect ID returned by `addEffectToBus`. |
| `param_name` | string | Name of the effect parameter to set. |
| `value` | number | New value for the parameter. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the parameter was set successfully. |

**Example**

```lua
do
    lurek.audio.newBus("dsp_bus_param")
    local id = lurek.dsp.addEffectToBus("dsp_bus_param", "lowpass", {value=2000.0})
    lurek.dsp.setEffectParam("dsp_bus_param", id, "cutoff", 1000.0)
    print("lurek.dsp.setEffectParam ok")
end
```

---

### `lurek.dsp.spectrogramToPng`

Renders a spectrogram visualization of an audio file and saves it as a PNG image.

```lua
lurek.dsp.spectrogramToPng(input, output, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | string | Relative path to the input audio file. |
| `output` | string | Relative path for the output PNG file. |
| `width` | number | Image width in pixels. |
| `height` | number | Image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the output image was written successfully. |

**Example**

```lua
do
    local input = "content/examples/assets/audio/sample_loop.wav"
    local output = "save/_fs_tests/dsp_spectrogram.png"
    local ok = lurek.dsp.spectrogramToPng(input, output, 256, 128)
    print("lurek.dsp.spectrogramToPng ok=" .. tostring(ok))
    print("png exists=" .. tostring(lurek.filesystem.exists(output)))
end
```

---

### `lurek.dsp.waveformToPng`

Renders a waveform visualization of an audio file and saves it as a PNG image.

```lua
lurek.dsp.waveformToPng(input, output, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | string | Relative path to the input audio file. |
| `output` | string | Relative path for the output PNG file. |
| `width` | number | Image width in pixels. |
| `height` | number | Image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the output image was written successfully. |

**Example**

```lua
do
    local input = "content/examples/assets/audio/sample_loop.wav"
    local output = "save/_fs_tests/dsp_waveform.png"
    local ok = lurek.dsp.waveformToPng(input, output, 256, 64)
    print("lurek.dsp.waveformToPng ok=" .. tostring(ok))
    print("png exists=" .. tostring(lurek.filesystem.exists(output)))
end
```

---

## Module Fields

*No module-level fields documented.*

## Types

- [LAdsrEnvelope Handle](#ladsrenvelope-handle)
- [LDspGraph Handle](#ldspgraph-handle)
- [LDspNode Handle](#ldspnode-handle)
- [LLevelDetector Handle](#lleveldetector-handle)
- [LSoundData Handle](#lsounddata-handle)
- [LSpectrumAnalyzer Handle](#lspectrumanalyzer-handle)
- [LSynthesizer Handle](#lsynthesizer-handle)
- [LWaveform Handle](#lwaveform-handle)

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## LAdsrEnvelope Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LAdsrEnvelope:apply`

Applies this ADSR envelope across an entire sound buffer in place.

```lua
LAdsrEnvelope:apply(sound_data_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sound_data_ud` | [LSoundData](#lsounddata-handle) | Sound buffer to shape in-place. |

**Example**

```lua
do
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    env:apply(sd)
    print("LAdsrEnvelope:apply sampleCount=" .. tostring(sd:getSampleCount()))
end
```

---

#### `LAdsrEnvelope:is_idle`

Returns whether the envelope has fully completed and is idle.

```lua
LAdsrEnvelope:is_idle()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the envelope is idle. |

**Example**

```lua
do
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    print("LAdsrEnvelope:is_idle before=" .. tostring(env:is_idle()))
    env:trigger_on()
    print("LAdsrEnvelope:is_idle after=" .. tostring(env:is_idle()))
end
```

---

#### `LAdsrEnvelope:next_sample`

Advances the envelope and returns the next gain sample.

```lua
LAdsrEnvelope:next_sample()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current envelope gain after stepping. |

**Example**

```lua
do
    local env = lurek.dsp.newAdsrEnvelope(0.005, 0.01, 0.7, 0.05)
    env:trigger_on()
    local s1 = env:next_sample()
    local s2 = env:next_sample()
    print("LAdsrEnvelope:next_sample s1=" .. tostring(s1) .. " s2=" .. tostring(s2))
end
```

---

#### `LAdsrEnvelope:trigger_off`

Starts the envelope release phase.

```lua
LAdsrEnvelope:trigger_off()
```

**Example**

```lua
do
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    env:trigger_off()
    print("LAdsrEnvelope:trigger_off is_idle=" .. tostring(env:is_idle()))
end
```

---

#### `LAdsrEnvelope:trigger_on`

Starts the envelope attack phase for this ADSR object.

```lua
LAdsrEnvelope:trigger_on()
```

**Example**

```lua
do
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local s = env:next_sample()
    print("LAdsrEnvelope:trigger_on sample=" .. tostring(s))
end
```

---

## LDspGraph Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LDspGraph:addNode`

Adds a DSP node object to the graph and returns its stable node ID.

```lua
LDspGraph:addNode(node_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_ud` | [LDspNode](#ldspnode-handle) | Node object to add to this graph. |

**Returns**

| Type | Description |
|------|-------------|
| number | Stable node identifier for connect and disconnect calls. |

**Example**

```lua
do
    local g = lurek.dsp.newGraph()
    local n = lurek.dsp.newNode("lowpass")
    local id = g:addNode(n)
    print("LDspGraph:addNode id=" .. tostring(id))
end
```

---

#### `LDspGraph:clear`

Clears all graph nodes and edges from this graph.

```lua
LDspGraph:clear()
```

**Example**

```lua
do
    -- Build a small graph, process audio through it, then clear it.
    -- After clear() the graph can be reused with fresh nodes.
    local g = lurek.dsp.newGraph()
    local n1 = lurek.dsp.newNode("lowpass")
    local n2 = lurek.dsp.newNode("gain")
    local id1 = g:addNode(n1)
    local id2 = g:addNode(n2)
    g:connect(id1, id2)
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    g:process(sd)
    g:clear()
    print("LDspGraph:clear — graph reset, node count 0")
end
```

---

#### `LDspGraph:connect`

Connects two node IDs in this graph object.

```lua
LDspGraph:connect(from, to, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | number | Source node ID. |
| `to` | number | Destination node ID. |
| `options?` | table | Reserved connection options for future graph routing. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the connection is valid and stored. |

**Example**

```lua
do
    local g = lurek.dsp.newGraph()
    local id1 = g:addNode(lurek.dsp.newNode("lowpass"))
    local id2 = g:addNode(lurek.dsp.newNode("gain"))
    local ok = g:connect(id1, id2)
    print("LDspGraph:connect ok=" .. tostring(ok))
end
```

---

#### `LDspGraph:disconnect`

Removes a connection between two node IDs.

```lua
LDspGraph:disconnect(from, to)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | number | Source node ID. |
| `to` | number | Destination node ID. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an existing connection was removed. |

**Example**

```lua
do
    local g = lurek.dsp.newGraph()
    local id1 = g:addNode(lurek.dsp.newNode("lowpass"))
    local id2 = g:addNode(lurek.dsp.newNode("gain"))
    g:connect(id1, id2)
    local ok = g:disconnect(id1, id2)
    print("LDspGraph:disconnect ok=" .. tostring(ok))
end
```

---

#### `LDspGraph:process`

Processes a sound buffer through the graph and returns transformed data.

```lua
LDspGraph:process(sound_data_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sound_data_ud` | [LSoundData](#lsounddata-handle) | Input sound buffer. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata-handle) | Processed sound buffer output. |

**Example**

```lua
do
    local g = lurek.dsp.newGraph()
    g:addNode(lurek.dsp.newNode("lowpass"))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local out = g:process(sd)
    print("LDspGraph:process type=" .. type(out))
    print("LDspGraph:process sampleCount=" .. tostring(out:getSampleCount()))
end
```

---

## LDspNode Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LDspNode:getParam`

Returns one named numeric parameter from the node.

```lua
LDspNode:getParam(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter name to fetch. |

**Returns**

| Type | Description |
|------|-------------|
| number | Current parameter value. |

**Example**

```lua
do
    local node = lurek.dsp.newNode("gain")
    node:setParam("gain", 0.7)
    local val = node:getParam("gain")
    print("LDspNode:getParam gain=" .. tostring(val))
end
```

---

#### `LDspNode:setParam`

Sets one named numeric parameter on the node.

```lua
LDspNode:setParam(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter name such as `cutoff`, `low`, `high`, or `gain`. |
| `value` | number | New parameter value. |

**Example**

```lua
do
    local node = lurek.dsp.newNode("lowpass")
    node:setParam("cutoff", 800.0)
    local val = node:getParam("cutoff")
    print("LDspNode:setParam cutoff=" .. tostring(val))
end
```

---

#### `LDspNode:type`

Returns the node type string used by this node.

```lua
LDspNode:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Node kind used by this DSP node. |

**Example**

```lua
do
    local node = lurek.dsp.newNode("gain")
    local t = node:type()
    print("LDspNode:type t=" .. tostring(t))
end
```

---

## LLevelDetector Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LLevelDetector:get_peak`

Returns the current peak level accumulated by the detector.

```lua
LLevelDetector:get_peak()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Peak absolute amplitude in linear scale. |

**Example**

```lua
do
    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.9)
    local peak = det:get_peak()
    print("LLevelDetector:get_peak peak=" .. tostring(peak))
end
```

---

#### `LLevelDetector:get_rms`

Returns the current RMS level accumulated by the detector.

```lua
LLevelDetector:get_rms()
```

**Returns**

| Type | Description |
|------|-------------|
| number | RMS amplitude in linear scale. |

**Example**

```lua
do
    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.5)
    local rms = det:get_rms()
    print("LLevelDetector:get_rms rms=" .. tostring(rms))
end
```

---

#### `LLevelDetector:process`

Processes all samples in a sound buffer and returns aggregate level statistics.

```lua
LLevelDetector:process(sound_data_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sound_data_ud` | [LSoundData](#lsounddata-handle) | Sound buffer to analyze. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table with `rms`, `peak`, and `clipping` fields. |

**Example**

```lua
do
    local det = lurek.dsp.newLevelDetector({})
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local result = det:process(sd)
    print("LLevelDetector:process rms=" .. tostring(result.rms))
    print("LLevelDetector:process peak=" .. tostring(result.peak))
end
```

---

#### `LLevelDetector:process_sample`

Processes one audio sample and updates detector statistics incrementally.

```lua
LLevelDetector:process_sample(sample)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sample` | number | Input sample value in the range [-1.0, 1.0]. |

**Example**

```lua
do
    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.8)
    det:process_sample(-0.3)
    print("LLevelDetector:process_sample peak=" .. tostring(det:get_peak()))
end
```

---

#### `LLevelDetector:reset`

Resets detector state so a new measurement window can begin.

```lua
LLevelDetector:reset()
```

**Example**

```lua
do
    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.7)
    det:reset()
    print("LLevelDetector:reset rms=" .. tostring(det:get_rms()))
end
```

---

#### `LLevelDetector:to_db`

Converts a linear amplitude value to decibels full scale.

```lua
LLevelDetector:to_db(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Linear amplitude value to convert. |

**Returns**

| Type | Description |
|------|-------------|
| number | Converted dBFS value. |

**Example**

```lua
do
    local det = lurek.dsp.newLevelDetector({})
    local db = det:to_db(0.5)
    print("LLevelDetector:to_db db=" .. tostring(db))
end
```

---

## LSoundData Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LSoundData:drawWaveform`

Draws this sound buffer as a waveform into an image buffer.

```lua
LSoundData:drawWaveform(target, x, y, w, h, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | LImageData | Target image to draw into. |
| `x` | number | Left pixel coordinate. |
| `y` | number | Top pixel coordinate. |
| `w` | number | Waveform width in pixels. |
| `h` | number | Waveform height in pixels. |
| `r` | number | Red channel from 0 to 255. |
| `g` | number | Green channel from 0 to 255. |
| `b` | number | Blue channel from 0 to 255. |
| `a` | number | Alpha channel from 0 to 255. |

---

#### `LSoundData:getBitDepth`

Returns the sample bit depth of this sound buffer.

```lua
LSoundData:getBitDepth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Bit depth per sample. |

---

#### `LSoundData:getChannelCount`

Returns the number of audio channels stored in this sound buffer.

```lua
LSoundData:getChannelCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Channel count. |

---

#### `LSoundData:getDuration`

Returns the approximate playback duration of this sound buffer.

```lua
LSoundData:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in seconds. |

---

#### `LSoundData:getSample`

Returns the sample value at the given zero-based sample index.

```lua
LSoundData:getSample(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | Zero-based sample index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Sample value at the requested index. |

---

#### `LSoundData:getSampleCount`

Returns the total number of samples stored in this sound buffer.

```lua
LSoundData:getSampleCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total sample count. |

---

#### `LSoundData:getSampleRate`

Returns the playback sample rate of this sound buffer.

```lua
LSoundData:getSampleRate()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Sample rate in Hz. |

---

#### `LSoundData:setSample`

Overwrites the sample value at the given zero-based sample index.

```lua
LSoundData:setSample(index, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | Zero-based sample index. |
| `value` | number | New sample value. |

---

#### `LSoundData:type`

Returns the type name of this object for runtime type-checking.

```lua
LSoundData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always returns "[LSoundData](#lsounddata-handle)". |

---

#### `LSoundData:typeOf`

Checks whether this object matches the given type name.

```lua
LSoundData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. "[LSoundData](#lsounddata-handle)" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object matches the given type. |

---

## LSpectrumAnalyzer Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LSpectrumAnalyzer:analyze`

Analyzes one sound buffer and returns `(frequency, magnitude)` rows.

```lua
LSpectrumAnalyzer:analyze(sound_data_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sound_data_ud` | [LSoundData](#lsounddata-handle) | Sound buffer to analyze. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array with `frequency` and `magnitude` fields per bin. |

**Example**

```lua
do
    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 32 })
    local sd = lurek.dsp.newSineWave(440, 0.01, 44100, 0.8)
    local bins = sa:analyze(sd)
    print("LSpectrumAnalyzer:analyze bins=" .. tostring(#bins))
    print("LSpectrumAnalyzer:analyze bin[1]=" .. tostring(bins[1]))
end
```

---

#### `LSpectrumAnalyzer:setSize`

Sets the frequency-bin count used by subsequent spectrum analysis calls.

```lua
LSpectrumAnalyzer:setSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Requested number of bins (bounded internally). |

**Example**

```lua
do
    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 64 })
    sa:setSize(128)
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bins = sa:analyze(sd)
    print("LSpectrumAnalyzer:setSize bins=" .. tostring(#bins))
end
```

---

## LSynthesizer Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LSynthesizer:generate`

Generates a SoundData buffer; alias of `render` for compatibility.

```lua
LSynthesizer:generate(freq, duration, sample_rate, amplitude)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `freq` | number | Frequency in Hertz. |
| `duration` | number | Duration in seconds. |
| `sample_rate` | number | Sample rate in Hertz. |
| `amplitude` | number | Peak amplitude in the range [0.0, 1.0]. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata-handle) | Generated sound buffer. |

**Example**

```lua
do
    local synth = lurek.dsp.newSynthesizer()
    local sd = synth:generate(440, 0.02, 44100, 0.7)
    print("LSynthesizer:generate type=" .. type(sd))
    print("LSynthesizer:generate sampleCount=" .. tostring(sd:getSampleCount()))
end
```

---

#### `LSynthesizer:render`

Renders a SoundData buffer using current synthesizer settings.

```lua
LSynthesizer:render(freq, duration, sample_rate, amplitude)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `freq` | number | Frequency in Hertz. |
| `duration` | number | Duration in seconds. |
| `sample_rate` | number | Sample rate in Hertz. |
| `amplitude` | number | Peak amplitude in the range [0.0, 1.0]. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata-handle) | Generated sound buffer. |

**Example**

```lua
do
    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("sine")
    local sd = synth:render(330, 0.01, 44100, 0.5)
    print("LSynthesizer:render type=" .. type(sd))
    print("LSynthesizer:render sampleCount=" .. tostring(sd:getSampleCount()))
end
```

---

#### `LSynthesizer:setEnvelope`

Attaches an ADSR envelope used by future render calls.

```lua
LSynthesizer:setEnvelope(envelope_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `envelope_ud` | [LAdsrEnvelope](#ladsrenvelope-handle) | Envelope object copied into the synthesizer. |

**Example**

```lua
do
    local synth = lurek.dsp.newSynthesizer()
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.02, 0.7, 0.03)
    synth:setEnvelope(env)
    local sd = synth:render(523, 0.01, 44100, 0.5)
    print("LSynthesizer:setEnvelope sampleCount=" .. tostring(sd:getSampleCount()))
end
```

---

#### `LSynthesizer:setWaveform`

Sets the oscillator waveform using a kind string or waveform object.

```lua
LSynthesizer:setWaveform(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Waveform kind string or [LWaveform](#lwaveform-handle) instance. |

**Example**

```lua
do
    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("sawtooth")
    local sd = synth:render(440, 0.01, 44100, 0.5)
    print("LSynthesizer:setWaveform sampleCount=" .. tostring(sd:getSampleCount()))
end
```

---

## LWaveform Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LWaveform:render`

Renders this waveform to a new SoundData buffer.

```lua
LWaveform:render(freq, duration, sample_rate, amplitude)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `freq` | number | Frequency in Hertz. |
| `duration` | number | Duration in seconds. |
| `sample_rate` | number | Sample rate in Hertz. |
| `amplitude` | number | Peak amplitude in the range [0.0, 1.0]. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata-handle) | Generated mono sound buffer. |

**Example**

```lua
do
    local wf = lurek.dsp.newWaveform("triangle")
    local sd = wf:render(330, 0.01, 44100, 0.6)
    print("LWaveform:render sampleCount=" .. tostring(sd:getSampleCount()))
end
```

---

#### `LWaveform:type`

Returns the waveform identifier string.

```lua
LWaveform:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of `sine`, `square`, `sawtooth`, `triangle`, or `white_noise`. |

**Example**

```lua
do
    local wf = lurek.dsp.newWaveform("square")
    local t = wf:type()
    print("LWaveform:type t=" .. tostring(t))
end
```

---
