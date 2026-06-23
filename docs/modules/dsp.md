# Dsp

## Purpose

Manages audio effect graphs, procedural synthesis, level detection, and visualizations.

## When To Use

- Effect chains and graph-style processing keep filters, modulation, tone shaping, and other signal operations composable instead of hardcoded into one playback path.
- Real-time and offline workflows live under the same conceptual surface, which means a processing idea can be used during gameplay, in content preparation, or in evidence-oriented audio diagnostics.
- Synthesis, envelopes, metering, spectrum work, and visualization support make the module useful both for designing sound behavior and for understanding why that behavior sounds the way it does.

## Minimal Example

Example block: `lurek.dsp.newEffectParams`

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local params = lurek.dsp.newEffectParams("reverb", 0.7, 0.4, 0.2)
    dsp_log("effect params type=" .. type(params))
    dsp_log("effect=" .. tostring(params.type))
    dsp_log("wet mix p1=" .. tostring(params.p1))
    dsp_log("room size p2=" .. tostring(params.p2))
    dsp_log("damping p3=" .. tostring(params.p3))
end
```

## Common Patterns

- Start with `lurek.dsp.addEffectToBus` when exploring this module.
- Start with `lurek.dsp.analyzeFft` when exploring this module.
- Start with `lurek.dsp.analyzeFft` when exploring this module.
- Start with `lurek.dsp.analyzePeak` when exploring this module.
- Start with `lurek.dsp.analyzeRms` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `dsp` module is the programmable signal-processing layer for users who need audio to be transformed, analyzed, or synthesized at runtime.
- Effect chains and graph-style processing keep filters, modulation, tone shaping, and other signal operations composable instead of hardcoded into one playback path.
- Real-time and offline workflows live under the same conceptual surface, which means a processing idea can be used during gameplay, in content preparation, or in evidence-oriented audio diagnostics.
- Synthesis, envelopes, metering, spectrum work, and visualization support make the module useful both for designing sound behavior and for understanding why that behavior sounds the way it does.
- This makes the module relevant not only for final playback polish but also for procedural audio, reactive sound design, analysis tools, and educational or debugging views into the signal itself.
- The graph-oriented model is especially useful because complex audio behavior often emerges from several small processing stages that must remain inspectable and reorderable.
- In other words, `dsp` gives the engine a place to reason about signal shape itself, not just about the existence of a sound event or playback source.
- Read it as the audio-processing authority above raw playback: neighboring audio systems own device-facing streaming and transport, while `dsp` owns what happens to the signal itself.

This module primarily collaborates with `audio`, `runtime`. Its responsibility should stay inside the `Platform Services` group rather than absorb behavior owned by those neighbors.

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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    lurek.audio.newBus("dsp_bus_fx")
    local id = lurek.dsp.addEffectToBus("dsp_bus_fx", "lowpass", {value=2000.0})
    local second_id = lurek.dsp.addEffectToBus("dsp_bus_fx", "highpass", {value=180.0})
    dsp_log("added lowpass id=" .. tostring(id))
    dsp_log("added highpass id=" .. tostring(second_id))
    dsp_log("effect ids are distinct=" .. tostring(id ~= second_id))
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
| `sd` | [LSoundData](#lsounddata) | The sound data to analyze. |
| `size` | number | Number of frequency bins to compute (capped at 512). |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of tables, each with `frequency` (number, Hz) and `magnitude` (number) fields. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local result = lurek.dsp.analyzeFft(sd, 64)
    dsp_log("analyzeFft bins=" .. tostring(#result))
    dsp_log("first bin frequency=" .. tostring(result[1] and result[1].frequency))
    dsp_log("first bin magnitude=" .. tostring(result[1] and result[1].magnitude))
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
| `sd` | [LSoundData](#lsounddata) | The sound data to analyze. |

**Returns**

| Type | Description |
|------|-------------|
| number | Peak amplitude in the range [0.0, 1.0]. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local peak = lurek.dsp.analyzePeak(sd)
    local rms = lurek.dsp.analyzeRms(sd)
    dsp_log("analyzePeak peak=" .. tostring(peak))
    dsp_log("matching rms=" .. tostring(rms))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
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
| `sd` | [LSoundData](#lsounddata) | The sound data to analyze. |

**Returns**

| Type | Description |
|------|-------------|
| number | RMS amplitude in the range [0.0, 1.0]. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    local rms = lurek.dsp.analyzeRms(sd)
    local peak = lurek.dsp.analyzePeak(sd)
    dsp_log("analyzeRms rms=" .. tostring(rms))
    dsp_log("reference peak=" .. tostring(peak))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
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
| `sd_ud` | [LSoundData](#lsounddata) | The sound data to process. |
| `low_hz` | number | Lower cutoff frequency in Hz. |
| `high_hz` | number | Upper cutoff frequency in Hz. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyBandpass(sd, 500.0, 2000.0)
    local peak = lurek.dsp.analyzePeak(sd)
    dsp_log("applyBandpass sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("post-filter peak=" .. tostring(peak))
    dsp_log("post-filter rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
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
| `sd_ud` | [LSoundData](#lsounddata) | The sound data to process. |
| `gain` | number | Gain multiplier (1.0 = unity, >1.0 = louder, <1.0 = quieter). |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyGain(sd, 0.5)
    dsp_log("applyGain sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak after gain=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms after gain=" .. tostring(lurek.dsp.analyzeRms(sd)))
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
| `sd_ud` | [LSoundData](#lsounddata) | The sound data to process. |
| `cutoff_hz` | number | Highpass cutoff frequency in Hz. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyHighpass(sd, 2000.0)
    dsp_log("applyHighpass sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("post-filter peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("post-filter rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
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
| `sd_ud` | [LSoundData](#lsounddata) | The sound data to process. |
| `cutoff_hz` | number | Lowpass cutoff frequency in Hz. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.1, 44100, 0.8)
    lurek.dsp.applyLowpass(sd, 1000.0)
    dsp_log("applyLowpass sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("post-filter peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("post-filter rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
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
| [LAdsrEnvelope](#ladsrenvelope) | New ADSR envelope instance. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local s = env:next_sample()
    dsp_log("newAdsrEnvelope sample=" .. tostring(s))
    dsp_log("newAdsrEnvelope idle=" .. tostring(env:is_idle()))
    env:trigger_off()
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    env:apply(sd)
    dsp_log("apply ok")
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local params = lurek.dsp.newEffectParams("reverb", 0.7, 0.4, 0.2)
    dsp_log("effect params type=" .. type(params))
    dsp_log("effect=" .. tostring(params.type))
    dsp_log("wet mix p1=" .. tostring(params.p1))
    dsp_log("room size p2=" .. tostring(params.p2))
    dsp_log("damping p3=" .. tostring(params.p3))
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
| [LDspGraph](#ldspgraph) | New DSP graph instance. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local g = lurek.dsp.newGraph()
    local n1 = lurek.dsp.newNode("lowpass")
    local n2 = lurek.dsp.newNode("gain")
    local id1 = g:addNode(n1)
    local id2 = g:addNode(n2)
    local ok = g:connect(id1, id2)
    dsp_log("newGraph connect ok=" .. tostring(ok))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local out = g:process(sd)
    dsp_log("process type=" .. type(out))
    local ok2 = g:disconnect(id1, id2)
    dsp_log("disconnect ok=" .. tostring(ok2))
    g:clear()
    dsp_log("clear ok")
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
| [LLevelDetector](#lleveldetector) | New level detector instance. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({ clipThreshold = 0.99 })
    det:process_sample(0.5)
    det:process_sample(-0.5)
    dsp_log("newLevelDetector rms=" .. tostring(det:get_rms()))
    dsp_log("newLevelDetector peak=" .. tostring(det:get_peak()))
    dsp_log("reference 1.0 db=" .. tostring(det:to_db(1.0)))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local result = det:process(sd)
    dsp_log("process rms=" .. tostring(result.rms))
    det:reset()
    dsp_log("reset rms=" .. tostring(det:get_rms()))
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
| [LDspNode](#ldspnode) | New graph node instance. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local node = lurek.dsp.newNode("lowpass")
    dsp_log("newNode type=" .. node:type())
    node:setParam("cutoff", 1000.0)
    local val = node:getParam("cutoff")
    dsp_log("getParam cutoff=" .. tostring(val))
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
| [LSoundData](#lsounddata) | Generated audio buffer. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSawtoothWave(440, 0.01, 44100, 0.5)
    dsp_log("newSawtoothWave type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
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
| [LSoundData](#lsounddata) | Generated audio buffer. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSineWave(440, 0.01, 44100, 0.5)
    dsp_log("newSineWave type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
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
| [LSpectrumAnalyzer](#lspectrumanalyzer) | New spectrum analyzer instance. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 64 })
    sa:setSize(32)
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bins = sa:analyze(sd)
    dsp_log("newSpectrumAnalyzer bins=" .. tostring(#bins))
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
| [LSoundData](#lsounddata) | Generated audio buffer. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSquareWave(440, 0.01, 44100, 0.5)
    dsp_log("newSquareWave type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
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
| [LSoundData](#lsounddata) | Generated synthesized sound buffer. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newSynthWave("sine", 440, 0.01, 44100, 0.5, nil)
    dsp_log("newSynthWave type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
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
| [LSynthesizer](#lsynthesizer) | New synthesizer instance. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("triangle")
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.02)
    synth:setEnvelope(env)
    local sd = synth:render(440, 0.01, 44100, 0.5)
    dsp_log("newSynthesizer render type=" .. type(sd))
    local sd2 = synth:generate(440, 0.01, 44100, 0.5)
    dsp_log("generate type=" .. type(sd2))
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
| [LSoundData](#lsounddata) | Generated audio buffer. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newTriangleWave(440, 0.01, 44100, 0.5)
    dsp_log("newTriangleWave type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
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
| [LWaveform](#lwaveform) | New waveform descriptor instance. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local waveform_name = "sawtooth"
    local wf = lurek.dsp.newWaveform(waveform_name)
    local sd = wf:render(220, 0.01, 44100, 0.5)
    dsp_log("newWaveform requested=" .. waveform_name)
    dsp_log("waveform type=" .. tostring(wf:type()))
    dsp_log("rendered sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("rendered peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
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
| [LSoundData](#lsounddata) | Generated noise buffer. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sd = lurek.dsp.newWhiteNoise(0.01, 44100, 0.5, 42)
    dsp_log("newWhiteNoise type=" .. type(sd))
    dsp_log("sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
    dsp_log("rms=" .. tostring(lurek.dsp.analyzeRms(sd)))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local input = "content/examples/assets/audio/sample_tone.wav"
    local output = "save/_fs_tests/dsp_normalized.wav"
    local ok = lurek.dsp.normalize(input, output, 0.9)
    dsp_log("normalize ok=" .. tostring(ok))
    dsp_log("target peak=0.9")
    dsp_log("input=" .. input)
    dsp_log("normalized exists=" .. tostring(lurek.filesystem.exists(output)))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local input = "content/examples/assets/audio/sample_click.wav"
    local output = "save/_fs_tests/dsp_processed.wav"
    local effects = {
        lurek.dsp.newEffectParams("reverb", 0.7, 0.4, 0.2),
        lurek.dsp.newEffectParams("compressor", 0.8, 2.5, 0.1),
    }
    local ok = lurek.dsp.processOffline(input, output, effects)
    dsp_log("processOffline ok=" .. tostring(ok))
    dsp_log("input=" .. input)
    dsp_log("effects applied=" .. tostring(#effects))
    dsp_log("output exists=" .. tostring(lurek.filesystem.exists(output)))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    lurek.audio.newBus("dsp_bus_rm")
    local id = lurek.dsp.addEffectToBus("dsp_bus_rm", "lowpass", {value=2000.0})
    local ok = lurek.dsp.removeEffectFromBus("dsp_bus_rm", id)
    local replacement_id = lurek.dsp.addEffectToBus("dsp_bus_rm", "highpass", {value=220.0})
    dsp_log("removeEffectFromBus ok=" .. tostring(ok))
    dsp_log("removed id=" .. tostring(id))
    dsp_log("replacement id=" .. tostring(replacement_id))
    dsp_log("ids differ after remove=" .. tostring(id ~= replacement_id))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    lurek.audio.newBus("dsp_bus_param")
    local id = lurek.dsp.addEffectToBus("dsp_bus_param", "lowpass", {value=2000.0})
    local ok = lurek.dsp.setEffectParam("dsp_bus_param", id, "cutoff", 1000.0)
    local ok2 = lurek.dsp.setEffectParam("dsp_bus_param", id, "q", 0.7)
    dsp_log("setEffectParam cutoff ok=" .. tostring(ok))
    dsp_log("setEffectParam q ok=" .. tostring(ok2))
end
```

---

### `lurek.dsp.spectrogramToPng`

Renders a spectrogram visualization of an audio file and saves it as a PNG image.

```lua
lurek.dsp.spectrogramToPng(input, output, width, height, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | string | Relative path to the input audio file. |
| `output` | string | Relative path for the output PNG file. |
| `width` | number | Image width in pixels. |
| `height` | number | Image height in pixels. |
| `options?` | table | Optional FFT settings: `windowSize`/`inputWindowSize` samples, `fftSize`/`fftPoints`, `hopSize`, `dynamicRangeDb`, `logFrequency`, or `frequencyScale`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the output image was written successfully. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local input = "content/examples/assets/audio/sample_loop.wav"
    local output = "save/_fs_tests/dsp_spectrogram.png"
    local ok = lurek.dsp.spectrogramToPng(input, output, 256, 128)
    dsp_log("spectrogramToPng ok=" .. tostring(ok))
    dsp_log("width=256")
    dsp_log("height=128")
    dsp_log("png exists=" .. tostring(lurek.filesystem.exists(output)))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local input = "content/examples/assets/audio/sample_loop.wav"
    local output = "save/_fs_tests/dsp_waveform.png"
    local ok = lurek.dsp.waveformToPng(input, output, 256, 64)
    dsp_log("waveformToPng ok=" .. tostring(ok))
    dsp_log("width=256")
    dsp_log("height=64")
    dsp_log("png exists=" .. tostring(lurek.filesystem.exists(output)))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LAdsrEnvelope](#ladsrenvelope)
- [LDspGraph](#ldspgraph)
- [LDspNode](#ldspnode)
- [LLevelDetector](#lleveldetector)
- [LSoundData](#lsounddata)
- [LSpectrumAnalyzer](#lspectrumanalyzer)
- [LSynthesizer](#lsynthesizer)
- [LWaveform](#lwaveform)

## LAdsrEnvelope

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAdsrEnvelope:apply`

Applies this ADSR envelope across an entire sound buffer in place.

```lua
LAdsrEnvelope:apply(sound_data_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sound_data_ud` | [LSoundData](#lsounddata) | Sound buffer to shape in-place. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    env:apply(sd)
    dsp_log("apply sampleCount=" .. tostring(sd:getSampleCount()))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    local before = env:is_idle()
    env:trigger_on()
    local during_note = env:is_idle()
    env:trigger_off()
    local after_release = env:is_idle()
    dsp_log("is_idle before=" .. tostring(before))
    dsp_log("is_idle during note=" .. tostring(during_note))
    dsp_log("is_idle after release=" .. tostring(after_release))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.005, 0.01, 0.7, 0.05)
    env:trigger_on()
    local s1 = env:next_sample()
    local s2 = env:next_sample()
    dsp_log("next_sample s1=" .. tostring(s1) .. " s2=" .. tostring(s2))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local attack_sample = env:next_sample()
    env:trigger_off()
    local release_sample = env:next_sample()
    dsp_log("trigger_off attack sample=" .. tostring(attack_sample))
    dsp_log("trigger_off release sample=" .. tostring(release_sample))
    dsp_log("trigger_off idle=" .. tostring(env:is_idle()))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.01, 0.8, 0.05)
    env:trigger_on()
    local first_sample = env:next_sample()
    local second_sample = env:next_sample()
    dsp_log("trigger_on first sample=" .. tostring(first_sample))
    dsp_log("trigger_on second sample=" .. tostring(second_sample))
    dsp_log("trigger_on idle=" .. tostring(env:is_idle()))
end
```

---

## LDspGraph

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDspGraph:addNode`

Adds a DSP node object to the graph and returns its stable node ID.

```lua
LDspGraph:addNode(node_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_ud` | [LDspNode](#ldspnode) | Node object to add to this graph. |

**Returns**

| Type | Description |
|------|-------------|
| number | Stable node identifier for connect and disconnect calls. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local g = lurek.dsp.newGraph()
    local lowpass_id = g:addNode(lurek.dsp.newNode("lowpass"))
    local gain_id = g:addNode(lurek.dsp.newNode("gain"))
    local connected = g:connect(lowpass_id, gain_id)
    local output = g:process(lurek.audio.newSoundData(44100, 44100, 1))
    dsp_log("addNode lowpass id=" .. tostring(lowpass_id))
    dsp_log("addNode gain id=" .. tostring(gain_id))
    dsp_log("addNode connect ok=" .. tostring(connected))
    dsp_log("addNode output type=" .. type(output))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

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
    dsp_log("clear graph reset, node count 0")
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local g = lurek.dsp.newGraph()
    local id1 = g:addNode(lurek.dsp.newNode("lowpass"))
    local id2 = g:addNode(lurek.dsp.newNode("gain"))
    local ok = g:connect(id1, id2)
    dsp_log("connect ok=" .. tostring(ok))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local g = lurek.dsp.newGraph()
    local id1 = g:addNode(lurek.dsp.newNode("lowpass"))
    local id2 = g:addNode(lurek.dsp.newNode("gain"))
    g:connect(id1, id2)
    local ok = g:disconnect(id1, id2)
    dsp_log("disconnect ok=" .. tostring(ok))
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
| `sound_data_ud` | [LSoundData](#lsounddata) | Input sound buffer. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata) | Processed sound buffer output. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local g = lurek.dsp.newGraph()
    g:addNode(lurek.dsp.newNode("lowpass"))
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local out = g:process(sd)
    dsp_log("process type=" .. type(out))
    dsp_log("process sampleCount=" .. tostring(out:getSampleCount()))
end
```

---

## LDspNode

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local node = lurek.dsp.newNode("gain")
    node:setParam("gain", 0.7)
    local gain_value = node:getParam("gain")
    dsp_log("getParam node=" .. tostring(node:type()))
    dsp_log("getParam gain=" .. tostring(gain_value))
    dsp_log("getParam matches target=" .. tostring(gain_value == 0.7))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local node = lurek.dsp.newNode("lowpass")
    node:setParam("cutoff", 800.0)
    node:setParam("q", 0.5)
    dsp_log("setParam type=" .. tostring(node:type()))
    dsp_log("setParam cutoff=" .. tostring(node:getParam("cutoff")))
    dsp_log("setParam q=" .. tostring(node:getParam("q")))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local node = lurek.dsp.newNode("gain")
    local node_type = node:type()
    node:setParam("gain", 0.75)
    dsp_log("type node=" .. tostring(node_type))
    dsp_log("type gain param=" .. tostring(node:getParam("gain")))
    dsp_log("type ready for graph routing")
end
```

---

## LLevelDetector

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.9)
    local peak = det:get_peak()
    dsp_log("get_peak peak=" .. tostring(peak))
    dsp_log("get_peak rms=" .. tostring(det:get_rms()))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.5)
    local rms = det:get_rms()
    dsp_log("get_rms rms=" .. tostring(rms))
    dsp_log("get_rms peak=" .. tostring(det:get_peak()))
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
| `sound_data_ud` | [LSoundData](#lsounddata) | Sound buffer to analyze. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table with `rms`, `peak`, and `clipping` fields. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local result = det:process(sd)
    dsp_log("process rms=" .. tostring(result.rms))
    dsp_log("process peak=" .. tostring(result.peak))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.8)
    det:process_sample(-0.3)
    dsp_log("process_sample peak=" .. tostring(det:get_peak()))
    dsp_log("process_sample rms=" .. tostring(det:get_rms()))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    det:process_sample(0.7)
    det:reset()
    dsp_log("reset rms=" .. tostring(det:get_rms()))
    dsp_log("reset peak=" .. tostring(det:get_peak()))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local det = lurek.dsp.newLevelDetector({})
    local db = det:to_db(0.5)
    det:process_sample(0.5)
    dsp_log("to_db db=" .. tostring(db))
    dsp_log("peak after sample=" .. tostring(det:get_peak()))
    dsp_log("rms after sample=" .. tostring(det:get_rms()))
end
```

---

## LSoundData

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSoundData:drawWaveform`

Draws this sound buffer as a waveform into an image buffer.

```lua
LSoundData:drawWaveform(target, x, y, w, h, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | [LImageData](render.md#limagedata) | Target image to draw into. |
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
| string | Always returns "[LSoundData](#lsounddata)". |

---

#### `LSoundData:typeOf`

Checks whether this object matches the given type name.

```lua
LSoundData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. "[LSoundData](#lsounddata)" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object matches the given type. |

---

## LSpectrumAnalyzer

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSpectrumAnalyzer:analyze`

Analyzes one sound buffer and returns `(frequency, magnitude)` rows.

```lua
LSpectrumAnalyzer:analyze(sound_data_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sound_data_ud` | [LSoundData](#lsounddata) | Sound buffer to analyze. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array with `frequency` and `magnitude` fields per bin. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 32 })
    local sd = lurek.dsp.newSineWave(440, 0.01, 44100, 0.8)
    local bins = sa:analyze(sd)
    dsp_log("analyze bins=" .. tostring(#bins))
    dsp_log("analyze bin[1]=" .. tostring(bins[1]))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local sa = lurek.dsp.newSpectrumAnalyzer({ size = 64 })
    sa:setSize(128)
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bins = sa:analyze(sd)
    dsp_log("setSize bins=" .. tostring(#bins))
end
```

---

## LSynthesizer

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
| [LSoundData](#lsounddata) | Generated sound buffer. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local synth = lurek.dsp.newSynthesizer()
    local envelope = lurek.dsp.newAdsrEnvelope(0.005, 0.02, 0.6, 0.03)
    synth:setEnvelope(envelope)
    local generated = synth:generate(440, 0.02, 44100, 0.7)
    dsp_log("generate type=" .. type(generated))
    dsp_log("generate sampleCount=" .. tostring(generated:getSampleCount()))
    dsp_log("generate peak=" .. tostring(lurek.dsp.analyzePeak(generated)))
    dsp_log("generate rms=" .. tostring(lurek.dsp.analyzeRms(generated)))
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
| [LSoundData](#lsounddata) | Generated sound buffer. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("sine")
    local sd = synth:render(330, 0.01, 44100, 0.5)
    dsp_log("render type=" .. type(sd))
    dsp_log("render sampleCount=" .. tostring(sd:getSampleCount()))
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
| `envelope_ud` | [LAdsrEnvelope](#ladsrenvelope) | Envelope object copied into the synthesizer. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local synth = lurek.dsp.newSynthesizer()
    local env = lurek.dsp.newAdsrEnvelope(0.01, 0.02, 0.7, 0.03)
    synth:setEnvelope(env)
    local sd = synth:render(523, 0.01, 44100, 0.5)
    dsp_log("setEnvelope sampleCount=" .. tostring(sd:getSampleCount()))
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
| `value` | any | Waveform kind string or [LWaveform](#lwaveform) instance. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local synth = lurek.dsp.newSynthesizer()
    synth:setWaveform("sawtooth")
    local rendered = synth:render(440, 0.01, 44100, 0.5)
    dsp_log("setWaveform waveform=sawtooth")
    dsp_log("setWaveform sampleCount=" .. tostring(rendered:getSampleCount()))
    dsp_log("setWaveform peak=" .. tostring(lurek.dsp.analyzePeak(rendered)))
    dsp_log("setWaveform rms=" .. tostring(lurek.dsp.analyzeRms(rendered)))
end
```

---

## LWaveform

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
| [LSoundData](#lsounddata) | Generated mono sound buffer. |

**Example**

```lua
do
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local wf = lurek.dsp.newWaveform("triangle")
    local sd = wf:render(330, 0.01, 44100, 0.6)
    dsp_log("render waveform=" .. tostring(wf:type()))
    dsp_log("render frequency=330")
    dsp_log("render sampleCount=" .. tostring(sd:getSampleCount()))
    dsp_log("render peak=" .. tostring(lurek.dsp.analyzePeak(sd)))
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
    local function dsp_log(message)
        lurek.log.info("[dsp.example] " .. tostring(message))
    end

    local wf = lurek.dsp.newWaveform("square")
    local waveform_type = wf:type()
    local preview = wf:render(330, 0.01, 44100, 0.4)
    dsp_log("type waveform=" .. tostring(waveform_type))
    dsp_log("preview sampleCount=" .. tostring(preview:getSampleCount()))
    dsp_log("preview rms=" .. tostring(lurek.dsp.analyzeRms(preview)))
end
```

---
