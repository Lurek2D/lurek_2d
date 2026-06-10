# Audio

## Summary

- Lets gameplay scripts play one-shot effects, looped ambience, dialogue, and long-form music from one runtime surface.
- Gives designers two practical loading paths: instant static sounds for low-latency triggers and streaming queues for long tracks.
- Supports robust voice management so repeated events do not cut each other off during combat, UI spam, or particle-heavy scenes.
- Exposes fade-in, crossfade, seek, and stop controls that make scene transitions feel polished instead of abrupt.
- Provides source routing through named buses so teams can control music, SFX, VO, and ambience as separate loudness groups.
- Enables sidechain ducking workflows where critical channels stay audible while background layers automatically step down.
- Offers metering outputs for peak and RMS so HUD widgets and dev overlays can react to real loudness values.
- Adds spatial placement in 2D/3D so players hear direction, distance, and movement cues instead of flat stereo playback.
- Lets games tune attenuation models and Doppler intensity to match arcade, cinematic, or simulation-style movement feel.
- Gives scripts listener positioning APIs that tie audio perspective directly to camera, character, or spectator modes.
- Includes a beat-clock workflow for rhythm timing, beat callbacks, and judgment windows for music-driven gameplay loops.
- Supports tempo ramps and sync-safe scheduling so timeline events remain musically aligned during speed changes.
- Includes MIDI playback and SoundFont control for adaptive scoring without shipping large rendered audio stems.
- Allows per-track muting and tempo scaling so music can react to game states, difficulty, and encounter phases.
- Exposes lowpass/highpass controls for occlusion-like effects, underwater states, and menu muffling transitions.
- Supports stereo width and random pitch variation to reduce repetition fatigue in rapidly repeated sound effects.
- Provides a queueable PCM path for generated audio, voice streaming, and other runtime-produced sample content.
- Lets scripts inspect and edit sample buffers for procedural synthesis, waveform tools, or offline preprocessing.
- Includes buffer mixing helpers that simplify layering and signal baking without external audio middleware.
- Supports WAV export for captured takes, generated assets, and automated content pipelines.
- Keeps device selection scriptable so QA can reproduce issues against specific output hardware.
- Exposes global mute and master volume controls for user settings menus and accessibility presets.
- Reports active and total source counts, helping teams budget channel usage under stress.
- Enables pooled playback patterns that keep trigger latency stable during bursty gameplay.
- Works as the user-facing audio control plane while deeper DSP modules handle specialized processing.
- Gives one coherent API for sound effects, music systems, rhythm mechanics, and runtime audio diagnostics.
- Reduces ad-hoc audio glue code by centralizing lifecycle, routing, timing, and spatial behavior in one module.
- Helps teams ship mix-consistent experiences across scenes by standardizing bus-level and source-level controls.
- Improves iteration speed because gameplay scripts can tweak sonic behavior live without engine restarts.
- Scales from small 2D projects to content-heavy games that need layered, reactive, and inspectable audio behavior.
- Delivers a practical bridge between creative audio authoring intent and deterministic runtime playback control.
- Keeps advanced capabilities optional so simple projects can start with play/stop and grow into full mixing workflows.
- Supports robust testing by exposing deterministic timing and state query surfaces used by automation and QA.
- Helps user-facing features like subtitles timing and hit feedback stay synchronized with actual playback state.
- Serves as the core module for making game audio responsive, legible, and production-ready from script level.

This module primarily collaborates with `dsp`, `image`, `midi`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.audio.beatClockFromSource`

Creates a new beat clock and synchronizes it to an audio source position.

```lua
lurek.audio.beatClockFromSource(source, bpm, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Source handle or numeric source id. |
| `bpm` | number | Initial BPM. |
| `opts?` | table | Optional beat clock options. |

**Returns**

| Type | Description |
|------|-------------|
| [LBeatClock](#lbeatclock) | New beat clock handle synced to source time. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    local clock = lurek.audio.beatClockFromSource(src, 128.0, { subdivision = 4 })
    print("synced clock beat = " .. tostring(clock:getBeat()))
    print("synced clock running = " .. tostring(clock:isRunning()))
end
```

---

### `lurek.audio.clearFilter`

Removes all frequency filters from a source.

```lua
lurek.audio.clearFilter(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setLowpass(src, 1000)
    print("lowpass before clear = " .. tostring(lurek.audio.getLowpass(src)))
    lurek.audio.clearFilter(src)
    print("filters cleared")
end
```

---

### `lurek.audio.clearMidiSoundFont`

Clears the loaded SoundFont and reverts MIDI synthesis to default.

```lua
lurek.audio.clearMidiSoundFont()
```

**Example**

```lua
do
    lurek.audio.clearMidiSoundFont()
    print("soundfont cleared = " .. tostring(not lurek.audio.hasMidiSoundFont()))
end
```

---

### `lurek.audio.clearRandomPitch`

Clears any random pitch range previously set on the source.

```lua
lurek.audio.clearRandomPitch(src_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LSource](#lsource) | The audio source to reset. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setRandomPitch(src, 0.8, 1.2)
    lurek.audio.clearRandomPitch(src)
    print("random pitch cleared")
    print("source pitch now follows explicit setPitch calls")
end
```

---

### `lurek.audio.clone`

Creates an independent copy of a source sharing the same audio data.

```lua
lurek.audio.clone(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID to clone. |

**Returns**

| Type | Description |
|------|-------------|
| [LSource](#lsource) | A new source instance with identical settings. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVolume(src, 0.6)
    local copy = lurek.audio.clone(src)
    print("original volume = " .. tostring(lurek.audio.getVolume(src)))
    print("clone volume = " .. tostring(lurek.audio.getVolume(copy)))
end
```

---

### `lurek.audio.create_bus`

Creates a named audio bus, optionally parented to another bus.

```lua
lurek.audio.create_bus(name, parent_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name for the new bus. |
| `parent_name?` | string | Name of the parent bus, or nil for a root bus. |

**Example**

```lua
do
    lurek.audio.create_bus("master_sfx", nil)
    print("bus created: master_sfx")
    print("bus peak = " .. tostring(lurek.audio.getBusPeak("master_sfx")))
end
```

---

### `lurek.audio.crossfade`

Crossfades from one audio source to another over the given duration.

```lua
lurek.audio.crossfade(from_ud, to_ud, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | [LSource](#lsource) | The source to fade out. |
| `to_ud` | [LSource](#lsource) | The source to fade in. |
| `duration` | number | Crossfade duration in seconds. |

**Example**

```lua
do
    local p1 = "content/examples/assets/audio/sample_loop.wav"
    local p2 = "content/examples/assets/audio/sample_tone.wav"
    local from = lurek.audio.newSource(p1, "stream")
    local to = lurek.audio.newSource(p2, "stream")
    lurek.audio.play(from)
    lurek.audio.crossfade(from, to, 3.0)
    print("from path = " .. p1)
    print("to path = " .. p2)
    print("crossfading over 3s")
end
```

---

### `lurek.audio.fadeIn`

Sets the fade-in duration for a source so it ramps from silence on play.

```lua
lurek.audio.fadeIn(source, dur)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `dur` | number | Fade-in duration in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.fadeIn(src, 2.0)
    print("fade in requested = 2.0s")
    print("fade in = " .. tostring(lurek.audio.getFadeIn(src)) .. "s")
end
```

---

### `lurek.audio.getActiveSourceCount`

Returns the number of sources currently playing audio.

```lua
lurek.audio.getActiveSourceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of active (playing) sources. |

**Example**

```lua
do
    local count = lurek.audio.getActiveSourceCount()
    print("active sources = " .. tostring(count))
    print("active source count queried")
end
```

---

### `lurek.audio.getBusPeak`

Returns the peak amplitude of the named audio bus over the last processing frame.

```lua
lurek.audio.getBusPeak(bus_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bus_name` | string | Name of the audio bus to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Peak amplitude in the range [0.0, 1.0+]. |

**Example**

```lua
do
    lurek.audio.create_bus("vu_bus", nil)
    local peak = lurek.audio.getBusPeak("vu_bus")
    print("bus peak = " .. peak)
end
```

---

### `lurek.audio.getBusRms`

Returns the RMS (root mean square) amplitude of the named audio bus over the last processing frame.

```lua
lurek.audio.getBusRms(bus_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bus_name` | string | Name of the audio bus to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | RMS amplitude in the range [0.0, 1.0+]. |

**Example**

```lua
do
    lurek.audio.create_bus("rms_bus", nil)
    local rms = lurek.audio.getBusRms("rms_bus")
    print("bus rms = " .. rms)
end
```

---

### `lurek.audio.getDistanceModel`

Returns the current distance attenuation model name.

```lua
lurek.audio.getDistanceModel()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Distance model name. |

**Example**

```lua
do
    lurek.audio.setDistanceModel("linear")
    local model = lurek.audio.getDistanceModel()
    print("configured distance model = linear")
    print("distance model = " .. tostring(model))
end
```

---

### `lurek.audio.getDopplerScale`

Returns the current global Doppler effect scale.

```lua
lurek.audio.getDopplerScale()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Doppler scale factor. |

**Example**

```lua
do
    lurek.audio.setDopplerScale(2.0)
    local ds = lurek.audio.getDopplerScale()
    print("configured doppler scale = 2.0")
    print("doppler scale = " .. tostring(ds))
end
```

---

### `lurek.audio.getDuration`

Returns the total duration of a source in seconds.

```lua
lurek.audio.getDuration(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    local dur = lurek.audio.getDuration(src) or 0
    print("path = " .. path)
    print("duration = " .. tostring(dur) .. "s")
end
```

---

### `lurek.audio.getFadeIn`

Returns the configured fade-in duration of a source.

```lua
lurek.audio.getFadeIn(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Fade-in duration in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.fadeIn(src, 1.5)
    local fi = lurek.audio.getFadeIn(src)
    print("configured fade in = 1.5")
    print("fade in duration = " .. tostring(fi))
end
```

---

### `lurek.audio.getFreeBufferCount`

Returns the number of free (available) buffer slots on a queueable source.

```lua
lurek.audio.getFreeBufferCount(qsource_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qsource_id` | number | Queueable source handle returned by `newQueueableSource`. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of free buffer slots available for queuing. |

**Example**

```lua
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local free = lurek.audio.getFreeBufferCount(qid)
    print("queueable id = " .. tostring(qid))
    print("free buffers = " .. tostring(free))
end
```

---

### `lurek.audio.getHighpass`

Returns the current highpass filter cutoff of a source.

```lua
lurek.audio.getHighpass(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Cutoff frequency in Hz, or 0 if not set. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setHighpass(src, 3000)
    local hp = lurek.audio.getHighpass(src)
    print("configured highpass = 3000")
    print("highpass = " .. tostring(hp))
end
```

---

### `lurek.audio.getJudgementWindows`

Returns global default timing windows used by beat-clock judgement.

```lua
lurek.audio.getJudgementWindows()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Table with `perfect`, `great`, `good` in seconds. |

**Example**

```lua
do
    local windows = lurek.audio.getJudgementWindows()
    print("getJudgementWindows marker = " .. tostring(windows ~= nil))
end
```

---

### `lurek.audio.getListener`

Returns the current 3D listener position.

```lua
lurek.audio.getListener()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X; Y; and Z position of the listener. (value 1). |
| number | X; Y; and Z position of the listener. (value 2). |
| number | X; Y; and Z position of the listener. (value 3). |

**Example**

```lua
do
    lurek.audio.setListener(10, 5, 0)
    local x, y, z = lurek.audio.getListener()
    print("listener 3D queried")
    print("listener = " .. x .. ", " .. y .. ", " .. z)
end
```

---

### `lurek.audio.getListener2D`

Returns the current 2D listener position.

```lua
lurek.audio.getListener2D()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X and Y position of the listener. (value 1). |
| number | X and Y position of the listener. (value 2). |

**Example**

```lua
do
    lurek.audio.setListener2D(100, 200)
    local x, y = lurek.audio.getListener2D()
    print("listener 2D queried")
    print("listener at " .. x .. ", " .. y)
end
```

---

### `lurek.audio.getLowpass`

Returns the current lowpass filter cutoff of a source.

```lua
lurek.audio.getLowpass(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Cutoff frequency in Hz, or 0 if not set. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setLowpass(src, 500)
    local lp = lurek.audio.getLowpass(src)
    print("configured lowpass = 500")
    print("lowpass = " .. tostring(lp))
end
```

---

### `lurek.audio.getMasterVolume`

Returns the current global master volume level.

```lua
lurek.audio.getMasterVolume()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Master volume multiplier. |

**Example**

```lua
do
    lurek.audio.setMasterVolume(1.0)
    local mv = lurek.audio.getMasterVolume()
    print("configured master volume = 1.0")
    print("master volume = " .. tostring(mv))
end
```

---

### `lurek.audio.getMaxSources`

Returns the maximum number of simultaneous audio sources supported.

```lua
lurek.audio.getMaxSources()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum source count (64). |

**Example**

```lua
do
    local max = lurek.audio.getMaxSources()
    print("max sources = " .. tostring(max))
    print("audio capacity queried")
end
```

---

### `lurek.audio.getMeter`

Returns the current master peak level for VU-meter displays.

```lua
lurek.audio.getMeter()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Peak level from 0.0 to 1.0. |

**Example**

```lua
do
    lurek.audio.setMeter(0.6)
    local lvl = lurek.audio.getMeter()
    print("configured meter = 0.6")
    print("meter = " .. tostring(lvl))
end
```

---

### `lurek.audio.getOrientation`

Returns the orientation vectors of a source.

```lua
lurek.audio.getOrientation(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Forward (fx;fy;fz) and up (ux;uy;uz) vectors. (value 1). |
| number | Forward (fx;fy;fz) and up (ux;uy;uz) vectors. (value 2). |
| number | Forward (fx;fy;fz) and up (ux;uy;uz) vectors. (value 3). |
| number | Forward (fx;fy;fz) and up (ux;uy;uz) vectors. (value 4). |
| number | Forward (fx;fy;fz) and up (ux;uy;uz) vectors. (value 5). |
| number | Forward (fx;fy;fz) and up (ux;uy;uz) vectors. (value 6). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setOrientation(src, 0, 0, -1, 0, 1, 0)
    local fx, fy, fz, ux, uy, uz = lurek.audio.getOrientation(src)
    print("source type = " .. tostring(lurek.audio.getSourceType(src)))
    print("forward = " .. fx .. ", " .. fy .. ", " .. fz)
    print("up = " .. ux .. ", " .. uy .. ", " .. uz)
end
```

---

### `lurek.audio.getPan`

Returns the current stereo pan position of a source.

```lua
lurek.audio.getPan(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Pan value from -1.0 (left) to 1.0 (right). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPan(src, 0.7)
    local pan = lurek.audio.getPan(src)
    print("configured pan = 0.7")
    print("pan = " .. tostring(pan))
end
```

---

### `lurek.audio.getPitch`

Returns the current pitch multiplier of a source.

```lua
lurek.audio.getPitch(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Current pitch multiplier. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPitch(src, 0.8)
    local p = lurek.audio.getPitch(src)
    print("configured pitch = 0.8")
    print("pitch = " .. tostring(p))
end
```

---

### `lurek.audio.getPlaybackDevice`

Returns the name of the currently active audio playback device.

```lua
lurek.audio.getPlaybackDevice()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current playback device name. |

**Example**

```lua
do
    local dev = lurek.audio.getPlaybackDevice()
    print("current device = " .. tostring(dev))
    print("device query completed")
end
```

---

### `lurek.audio.getPlaybackDevices`

Returns a list of available audio playback device names.

```lua
lurek.audio.getPlaybackDevices()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Device name strings. |

**Example**

```lua
do
    local devices = lurek.audio.getPlaybackDevices()
    print("device count = " .. tostring(#devices))
    print("first device = " .. tostring(devices[1] or "none"))
end
```

---

### `lurek.audio.getPosition`

Returns the 3D position of a source.

```lua
lurek.audio.getPosition(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | X; Y; and Z position. (value 1). |
| number | X; Y; and Z position. (value 2). |
| number | X; Y; and Z position. (value 3). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPosition(src, 100, 0, 30)
    local x, y, z = lurek.audio.getPosition(src)
    print("source position queried")
    print("pos = " .. x .. ", " .. y .. ", " .. z)
end
```

---

### `lurek.audio.getSourceBus`

Returns the bus a source is routed through.

```lua
lurek.audio.getSourceBus(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| [LBus](#lbus) | The assigned bus, or nil if using direct output. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local bus = lurek.audio.newBus("ui")
    lurek.audio.setSourceBus(src, bus)
    local assigned = lurek.audio.getSourceBus(src)
    print("source bus exists = " .. tostring(assigned ~= nil))
    print("source bus = " .. assigned:getName())
end
```

---

### `lurek.audio.getSourceCount`

Returns the total number of loaded audio sources (playing or idle).

```lua
lurek.audio.getSourceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total source count. |

**Example**

```lua
do
    local total = lurek.audio.getSourceCount()
    print("total sources = " .. tostring(total))
    print("source registry count queried")
end
```

---

### `lurek.audio.getSourceType`

Returns whether a source is static or streaming.

```lua
lurek.audio.getSourceType(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| string | Either "static" or "stream". |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local stype = lurek.audio.getSourceType(src)
    print("path = " .. path)
    print("source type = " .. tostring(stype))
end
```

---

### `lurek.audio.getStereoWidth`

Returns the current stereo width factor of an audio source.

```lua
lurek.audio.getStereoWidth(src_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LSource](#lsource) | The audio source to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Stereo width factor (0.0 = mono, 1.0 = full stereo). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setStereoWidth(src, 0.8)
    local w = lurek.audio.getStereoWidth(src)
    print("configured stereo width = 0.8")
    print("width = " .. tostring(w))
end
```

---

### `lurek.audio.getVelocity`

Returns the velocity vector of a source.

```lua
lurek.audio.getVelocity(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | X; Y; and Z velocity components. (value 1). |
| number | X; Y; and Z velocity components. (value 2). |
| number | X; Y; and Z velocity components. (value 3). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVelocity(src, 5, 3, 0)
    local vx, vy, vz = lurek.audio.getVelocity(src)
    print("source velocity queried")
    print("vel = " .. vx .. ", " .. vy .. ", " .. vz)
end
```

---

### `lurek.audio.getVolume`

Returns the current volume of a source.

```lua
lurek.audio.getVolume(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Current volume multiplier. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVolume(src, 0.8)
    local vol = lurek.audio.getVolume(src)
    print("configured volume = 0.8")
    print("volume = " .. tostring(vol))
end
```

---

### `lurek.audio.hasMidiSoundFont`

Returns whether a SoundFont file has been loaded for MIDI synthesis.

```lua
lurek.audio.hasMidiSoundFont()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a SoundFont is loaded. |

**Example**

```lua
do
    local has = lurek.audio.hasMidiSoundFont()
    print("has soundfont = " .. tostring(has))
    print("soundfont ready check completed")
end
```

---

### `lurek.audio.isLooping`

Returns whether a source has looping enabled.

```lua
lurek.audio.isLooping(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if looping is enabled. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setLooping(src, true)
    print("source type = " .. tostring(lurek.audio.getSourceType(src)))
    print("isLooping = " .. tostring(lurek.audio.isLooping(src)))
end
```

---

### `lurek.audio.isMuted`

Returns whether global audio is currently muted.

```lua
lurek.audio.isMuted()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if muted (all sources paused). |

**Example**

```lua
do
    local muted = lurek.audio.isMuted()
    print("audio is muted = " .. tostring(muted))
    if not muted then
        lurek.audio.setMuted(true)
        print("now muted = " .. tostring(lurek.audio.isMuted()))
    end
end
```

---

### `lurek.audio.isPaused`

Returns whether a source is currently paused.

```lua
lurek.audio.isPaused(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the source is paused. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.audio.pause(src)
    print("playing now = " .. tostring(lurek.audio.isPlaying(src)))
    print("isPaused = " .. tostring(lurek.audio.isPaused(src)))
end
```

---

### `lurek.audio.isPlaying`

Returns whether a source is currently playing.

```lua
lurek.audio.isPlaying(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the source is playing. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("before play = " .. tostring(lurek.audio.isPlaying(src)))
    lurek.audio.play(src)
    print("after play = " .. tostring(lurek.audio.isPlaying(src)))
end
```

---

### `lurek.audio.isStopped`

Returns whether a source is currently stopped.

```lua
lurek.audio.isStopped(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the source is stopped. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("initially stopped = " .. tostring(lurek.audio.isStopped(src)))
    print("initially playing = " .. tostring(lurek.audio.isPlaying(src)))
end
```

---

### `lurek.audio.judgeBeat`

Judges timing against the nearest beat grid for a beat clock.

```lua
lurek.audio.judgeBeat(clock, division, hit_offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `clock` | [LBeatClock](#lbeatclock) | Beat clock handle. |
| `division?` | number | Beat division (defaults to clock subdivision). |
| `hit_offset?` | number | Signed hit offset in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| string | One of `perfect`; `great`; `good`; `miss`. |
| number | Signed timing error in seconds. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    local verdict, err = lurek.audio.judgeBeat(clock, 4, 0.0)
    print("judgeBeat verdict = " .. tostring(verdict))
    print("judgeBeat error = " .. tostring(err))
end
```

---

### `lurek.audio.mixInto`

Mixes the samples of `src` into `dest` in-place (both must have the same format).

```lua
lurek.audio.mixInto(dest_ud, src_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dest_ud` | [LSoundData](#lsounddata) | Destination sound data to mix into. |
| `src_ud` | [LSoundData](#lsounddata) | Source sound data to mix from. |

**Example**

```lua
do
    local has_wave = type(lurek.audio.newSineWave) == "function"
    local has_fn = type(lurek.audio.mixInto) == "function"
    local dest = has_wave and lurek.audio.newSineWave(440, 1.0, 44100, 0.5) or nil
    local src = has_wave and lurek.audio.newSineWave(880, 1.0, 44100, 0.3) or nil
    if has_fn and dest and src then
        lurek.audio.mixInto(dest, src)
    end
    print("mixInto available = " .. tostring(has_fn))
    print("mixed 880 Hz into 440 Hz")
end
```

---

### `lurek.audio.newBeatClock`

Creates a musical beat clock for rhythm-game timing, tap-tempo, and beat scheduling.

```lua
lurek.audio.newBeatClock(bpm, beats_per_bar_or_opts, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bpm` | number | Initial beats-per-minute (minimum 1). |
| `beats_per_bar_or_opts` | any | Beats per bar (legacy) or options table. |
| `opts?` | table | Optional options table when second argument is numeric. |

**Returns**

| Type | Description |
|------|-------------|
| [LBeatClock](#lbeatclock) | New beat clock handle. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, { subdivision = 8, swing = 0.2, latency_ms = 5 })
    clock:start()
    clock:update(0.25)
    print("beat clock beat = " .. tostring(clock:getBeat()))
    print("beat clock bar = " .. tostring(clock:getBar()))
end
```

---

### `lurek.audio.newBus`

Creates a new audio mixing bus for grouping and controlling sources.

```lua
lurek.audio.newBus(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name for the bus (e.g. "music", "sfx"). |

**Returns**

| Type | Description |
|------|-------------|
| [LBus](#lbus) | The new audio bus handle. |

**Example**

```lua
do
    local bus = lurek.audio.newBus("sfx")
    print("bus created: sfx")
    print("bus name = " .. bus:getName())
end
```

---

### `lurek.audio.newDecoder`

Creates a streaming audio decoder for the given file. The file is opened relative to the game directory.

```lua
lurek.audio.newDecoder(source, buffersize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | string | Relative path to the audio file (WAV, OGG, MP3, or FLAC). |
| `buffersize?` | number | Number of samples per decode chunk; defaults to 2048. |

**Returns**

| Type | Description |
|------|-------------|
| [LDecoder](#ldecoder) | A streaming decoder with `decode`, `seek`, `rewind`, and `getSampleRate` methods. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path, 4096)
    print("decoder created = " .. tostring(dec ~= nil))
    print("sample rate = " .. tostring(dec:getSampleRate()))
    print("channels = " .. tostring(dec:getChannelCount()))
end
```

---

### `lurek.audio.newMidiPlayer`

Creates a new MIDI player instance, optionally loading a file immediately.

```lua
lurek.audio.newMidiPlayer(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path?` | string | Optional relative path to a .mid file to load. |

**Returns**

| Type | Description |
|------|-------------|
| [LMidiPlayer](#lmidiplayer) | A new MIDI player ready for playback. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    print("midi player created = " .. tostring(player ~= nil))
    print("player type = " .. player:type())
end
```

---

### `lurek.audio.newPool`

Creates a polyphonic sound pool that allows the same audio file to play on multiple simultaneous voices.

```lua
lurek.audio.newPool(file_path, voice_count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `file_path` | string | Relative path to the audio file shared by all voices in the pool. |
| `voice_count` | number | Number of concurrent voices to pre-allocate. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundPool](#lsoundpool) | A sound pool with `play`, `stopAll`, `setVolume`, `release`, and `getVoiceCount` methods. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 8)
    print("pool voices = " .. pool:getVoiceCount())
end
```

---

### `lurek.audio.newQueueableSource`

Creates a new queueable audio source for streaming PCM data buffer by buffer.

```lua
lurek.audio.newQueueableSource(sample_rate, bit_depth, channels, buffer_count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sample_rate` | number | Sample rate in Hz (e.g. 44100). |
| `bit_depth` | number | Bit depth per sample (8 or 16). |
| `channels` | number | Channel count (1 = mono, 2 = stereo). |
| `buffer_count?` | number | Number of internal buffers to pre-allocate; defaults to 4. |

**Returns**

| Type | Description |
|------|-------------|
| number | An opaque integer handle for use with `queueSource`, `playQueueable`, and `stopQueueable`. |

**Example**

```lua
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local free = lurek.audio.getFreeBufferCount(qid)
    print("queueable id = " .. tostring(qid))
    print("free buffers = " .. tostring(free))
end
```

---

### `lurek.audio.newSoundData`

Creates a new SoundData object from a file path or blank buffer for procedural audio.

```lua
lurek.audio.newSoundData(pathOrCount, sampleRate, channels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pathOrCount` | string|number | File path to decode, or sample count for blank buffer. |
| `sampleRate` | number | Sample rate in Hz (e.g. 44100, 48000). |
| `channels?` | number | Channel count (1 = mono, 2 = stereo), defaults to 1. |

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata) | Raw PCM sample data for manipulation or playback. |

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    print("sound data created = " .. tostring(sd ~= nil))
    print("sample count = " .. tostring(sd:getSampleCount()))
    print("sample rate = " .. tostring(sd:getSampleRate()))
end
```

---

### `lurek.audio.newSource`

Creates a new audio source from a file path, either fully loaded or streaming.

```lua
lurek.audio.newSource(path, sourceType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Relative path to the audio file (WAV, OGG, MP3, FLAC). |
| `sourceType?` | string | "static" to load fully into memory, or "stream" (default) for streaming. |

**Returns**

| Type | Description |
|------|-------------|
| [LSource](#lsource) | A new audio source ready for playback. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local source_type = lurek.audio.getSourceType(src)
    print("source created = " .. tostring(src ~= nil))
    print("path = " .. path)
    print("source type = " .. tostring(source_type))
end
```

---

### `lurek.audio.pause`

Pauses playback of a source at its current position.

```lua
lurek.audio.pause(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    print("playing before pause = " .. tostring(lurek.audio.isPlaying(src)))
    lurek.audio.pause(src)
    print("paused = " .. tostring(lurek.audio.isPaused(src)))
end
```

---

### `lurek.audio.pauseAll`

Pauses all currently playing audio sources.

```lua
lurek.audio.pauseAll()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.audio.pauseAll()
    print("all paused")
    print("sample source paused = " .. tostring(lurek.audio.isPaused(src)))
end
```

---

### `lurek.audio.play`

Starts playback of a source by handle, optionally routing through a named bus.

```lua
lurek.audio.play(source, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `options?` | table | Optional table with "bus" field for bus routing. |

**Returns**

| Type | Description |
|------|-------------|
| number | Numeric source ID of the playing source. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    print("play requested for = " .. path)
    print("playing = " .. tostring(lurek.audio.isPlaying(src)))
end
```

---

### `lurek.audio.playLooping`

Starts playback of a source with looping enabled in one call.

```lua
lurek.audio.playLooping(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.playLooping(src)
    print("playing = " .. tostring(lurek.audio.isPlaying(src)))
    print("playing+looping = " .. tostring(lurek.audio.isPlaying(src) and lurek.audio.isLooping(src)))
end
```

---

### `lurek.audio.playQueueable`

Starts playback of a queueable audio source.

```lua
lurek.audio.playQueueable(qsource_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qsource_id` | number | Queueable source handle returned by newQueueableSource. |

**Example**

```lua
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    lurek.audio.queueSource(qid, sd)
    lurek.audio.playQueueable(qid)
    print("queueable source started")
    print("free buffers after play = " .. tostring(lurek.audio.getFreeBufferCount(qid)))
end
```

---

### `lurek.audio.playSfx`

Plays a one-shot sound effect from a file path with optional settings.

```lua
lurek.audio.playSfx(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Path to audio file. |
| `opts?` | table | Optional: `bus` (string), `volume` (0.0-1.0), `loop` (bool). |

**Returns**

| Type | Description |
|------|-------------|
| [LSource](#lsource) | The audio source handle for the playing effect. |

**Example**

```lua
do
    local opts = { volume = 0.8, loop = false }
    local sfx = lurek.audio.playSfx("content/examples/assets/audio/sample_click.wav", opts)
    print("sfx played = " .. tostring(sfx ~= nil))
    print("sfx type = " .. sfx:type())
    print("volume = " .. tostring(sfx:getVolume()))
end
```

---

### `lurek.audio.queueSource`

Queues a decoded audio chunk for playback on a queueable source.

```lua
lurek.audio.queueSource(qsource_id, sd)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qsource_id` | number | Queueable source handle returned by `newQueueableSource`. |
| `sd` | [LSoundData](#lsounddata) | Sound data chunk to enqueue for playback. |

**Example**

```lua
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    local before = lurek.audio.getFreeBufferCount(qid)
    lurek.audio.queueSource(qid, sd)
    local after = lurek.audio.getFreeBufferCount(qid)
    print("free buffers before queue = " .. tostring(before))
    print("free buffers after queue = " .. tostring(after))
end
```

---

### `lurek.audio.release`

Releases an audio source, freeing its memory and stopping playback.

```lua
lurek.audio.release(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID to release. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the source was successfully released. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local before = lurek.audio.getSourceCount()
    lurek.audio.release(src)
    print("source released")
    print("source count before release = " .. tostring(before))
end
```

---

### `lurek.audio.resume`

Resumes playback of a paused source.

```lua
lurek.audio.resume(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.pause(src)
    print("paused before resume = " .. tostring(lurek.audio.isPaused(src)))
    lurek.audio.resume(src)
    print("playing after resume = " .. tostring(lurek.audio.isPlaying(src)))
end
```

---

### `lurek.audio.resumeAll`

Resumes all paused audio sources. This function is exposed to Lua scripts.

```lua
lurek.audio.resumeAll()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.pauseAll()
    lurek.audio.resumeAll()
    print("all resumed")
    print("sample source playing = " .. tostring(lurek.audio.isPlaying(src)))
end
```

---

### `lurek.audio.saveWAV`

Encodes the sound data as a WAV file and saves it to the given path (relative to game dir).

```lua
lurek.audio.saveWAV(sd_ud, filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sd_ud` | [LSoundData](#lsounddata) | The sound data to encode and save. |
| `filename` | string | Relative output path for the WAV file. |

**Example**

```lua
do
    local has_wave = type(lurek.audio.newSineWave) == "function"
    local has_fn = type(lurek.audio.saveWAV) == "function"
    local sd = has_wave and lurek.audio.newSineWave(440, 1.0, 44100, 0.8) or nil
    if has_fn and sd then
        lurek.audio.saveWAV(sd, "save/test_tone.wav")
    end
    print("saveWAV available = " .. tostring(has_fn))
    print("saved WAV file")
end
```

---

### `lurek.audio.seek`

Seeks a source to a specific position in seconds.

```lua
lurek.audio.seek(source, pos)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `pos` | number | Target position in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    lurek.audio.seek(src, 5.0)
    print("seek target = 5.0")
    print("position after seek = " .. tostring(lurek.audio.tell(src)))
end
```

---

### `lurek.audio.setDistanceModel`

Sets the distance attenuation model for spatial audio.

```lua
lurek.audio.setDistanceModel(model)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `model` | string | Model name (e.g. "inverse", "linear", "exponent", "none"). |

**Example**

```lua
do
    local before = lurek.audio.getDistanceModel()
    lurek.audio.setDistanceModel("inverse")
    print("distance model before = " .. tostring(before))
    print("distance model after = " .. tostring(lurek.audio.getDistanceModel()))
end
```

---

### `lurek.audio.setDopplerScale`

Sets the global Doppler effect intensity multiplier.

```lua
lurek.audio.setDopplerScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | number | Doppler scale (0 = disabled, 1.0 = realistic). |

**Example**

```lua
do
    local before = lurek.audio.getDopplerScale()
    lurek.audio.setDopplerScale(1.5)
    local after = lurek.audio.getDopplerScale()
    print("doppler scale before = " .. tostring(before))
    print("doppler scale after = " .. tostring(after))
end
```

---

### `lurek.audio.setHighpass`

Applies a highpass filter to a source, attenuating low frequencies.

```lua
lurek.audio.setHighpass(source, cutoff_hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `cutoff_hz` | number | Cutoff frequency in Hertz. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setHighpass(src, 2000)
    print("highpass set to 2000 Hz")
    print("highpass = " .. tostring(lurek.audio.getHighpass(src)) .. " Hz")
end
```

---

### `lurek.audio.setJudgementWindows`

Sets global default timing windows used by beat-clock judgement.

```lua
lurek.audio.setJudgementWindows(windows)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `windows` | table | Table with optional `perfect`, `great`, `good` in seconds. |

**Example**

```lua
do
    lurek.audio.setJudgementWindows({ perfect = 0.03, good = 0.08, ok = 0.12 })
    print("setJudgementWindows marker")
end
```

---

### `lurek.audio.setListener`

Sets the 3D listener position for spatial audio (Z defaults to 0 for 2D games).

```lua
lurek.audio.setListener(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Listener X position. |
| `y` | number | Listener Y position. |
| `z?` | number | Listener Z position (defaults to 0). |

**Example**

```lua
do
    lurek.audio.setListener(0, 0, 0)
    local x, y, z = lurek.audio.getListener()
    print("listener 3D reset to origin")
    print("listener 3D = " .. x .. ", " .. y .. ", " .. z)
end
```

---

### `lurek.audio.setListener2D`

Sets the 2D listener position for spatial audio calculations.

```lua
lurek.audio.setListener2D(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Listener X position in world units. |
| `y` | number | Listener Y position in world units. |

**Example**

```lua
do
    lurek.audio.setListener2D(400, 300)
    local x, y = lurek.audio.getListener2D()
    print("listener 2D set to 400, 300")
    print("listener 2D = " .. x .. ", " .. y)
end
```

---

### `lurek.audio.setLooping`

Enables or disables looping for a source.

```lua
lurek.audio.setLooping(source, looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `looping` | boolean | True to loop, false to play once. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    print("looping before = " .. tostring(lurek.audio.isLooping(src)))
    lurek.audio.setLooping(src, true)
    print("looping after = " .. tostring(lurek.audio.isLooping(src)))
end
```

---

### `lurek.audio.setLowpass`

Applies a lowpass filter to a source, attenuating high frequencies.

```lua
lurek.audio.setLowpass(source, cutoff_hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `cutoff_hz` | number | Cutoff frequency in Hertz. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setLowpass(src, 800)
    print("lowpass set to 800 Hz")
    print("lowpass = " .. tostring(lurek.audio.getLowpass(src)) .. " Hz")
end
```

---

### `lurek.audio.setMasterVolume`

Sets the global master volume affecting all audio output.

```lua
lurek.audio.setMasterVolume(vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vol` | number | Master volume multiplier (0.0 = silent, 1.0 = normal). |

**Example**

```lua
do
    local before = lurek.audio.getMasterVolume()
    lurek.audio.setMasterVolume(0.75)
    print("master volume before = " .. tostring(before))
    print("master volume after = " .. tostring(lurek.audio.getMasterVolume()))
end
```

---

### `lurek.audio.setMeter`

Sets the master peak level for metering purposes.

```lua
lurek.audio.setMeter(level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | number | Peak level clamped to 0.0-1.0. |

**Example**

```lua
do
    local before = lurek.audio.getMeter()
    lurek.audio.setMeter(0.8)
    print("meter before = " .. tostring(before))
    print("meter after = " .. tostring(lurek.audio.getMeter()))
end
```

---

### `lurek.audio.setMidiSoundFont`

Sets the SoundFont file used for MIDI synthesis.

```lua
lurek.audio.setMidiSoundFont(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Relative path to the .sf2 SoundFont file. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok = pcall(function()
        lurek.audio.setMidiSoundFont(path)
    end)
    print("soundfont set = " .. tostring(ok and lurek.audio.hasMidiSoundFont()))
end
```

---

### `lurek.audio.setMuted`

Globally mutes all audio (pauses all sources without stopping them).

```lua
lurek.audio.setMuted(muted)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `muted` | boolean | True to mute, false to unmute all audio. |

**Example**

```lua
do
    lurek.audio.setMuted(true)
    print("audio muted = " .. tostring(lurek.audio.isMuted()))
    lurek.audio.setMuted(false)
    print("audio unmuted = " .. tostring(not lurek.audio.isMuted()))
end
```

---

### `lurek.audio.setOrientation`

Sets the orientation of a source using forward and up vectors.

```lua
lurek.audio.setOrientation(source, fx, fy, fz, ux, uy, uz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `fx` | number | Forward vector X. |
| `fy` | number | Forward vector Y. |
| `fz` | number | Forward vector Z. |
| `ux` | number | Up vector X. |
| `uy` | number | Up vector Y. |
| `uz` | number | Up vector Z. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setOrientation(src, 0, 0, -1, 0, 1, 0)
    local fx, fy, fz, ux, uy, uz = lurek.audio.getOrientation(src)
    print("orientation applied")
    print("forward = " .. fx .. ", " .. fy .. ", " .. fz)
    print("up = " .. ux .. ", " .. uy .. ", " .. uz)
end
```

---

### `lurek.audio.setPan`

Sets the stereo panning of a source.

```lua
lurek.audio.setPan(source, pan)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `pan` | number | Pan from -1.0 (left) to 1.0 (right), 0.0 is center. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("pan before = " .. tostring(lurek.audio.getPan(src)))
    lurek.audio.setPan(src, -0.5)
    print("pan after = " .. tostring(lurek.audio.getPan(src)))
end
```

---

### `lurek.audio.setPitch`

Sets the pitch multiplier of a source, affecting playback speed and tone.

```lua
lurek.audio.setPitch(source, pitch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `pitch` | number | Pitch multiplier (1.0 = normal, 2.0 = octave up). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("pitch before = " .. tostring(lurek.audio.getPitch(src)))
    lurek.audio.setPitch(src, 1.5)
    print("pitch after = " .. tostring(lurek.audio.getPitch(src)))
end
```

---

### `lurek.audio.setPlaybackDevice`

Sets the active audio playback device by name.

```lua
lurek.audio.setPlaybackDevice(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the playback device to activate. |

**Example**

```lua
do
    local devices = lurek.audio.getPlaybackDevices()
    local name = devices[1] or lurek.audio.getPlaybackDevice()
    lurek.audio.setPlaybackDevice(name)
    print("requested device = " .. tostring(name))
    print("active device = " .. tostring(lurek.audio.getPlaybackDevice()))
end
```

---

### `lurek.audio.setPosition`

Sets the 3D position of a source for spatial audio panning and attenuation.

```lua
lurek.audio.setPosition(source, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `x` | number | X position in world units. |
| `y` | number | Y position in world units. |
| `z?` | number | Z position (defaults to 0). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setPosition(src, 50, 20, 0)
    local x, y, z = lurek.audio.getPosition(src)
    print("source positioned for spatial playback")
    print("source pos = " .. x .. ", " .. y .. ", " .. z)
end
```

---

### `lurek.audio.setRandomPitch`

Sets a random pitch range for a source; each play picks a random pitch between min and max.

```lua
lurek.audio.setRandomPitch(src_ud, min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LSource](#lsource) | The audio source to configure. |
| `min` | number | Minimum pitch multiplier. |
| `max` | number | Maximum pitch multiplier. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setRandomPitch(src, 0.9, 1.1)
    print("random pitch range = 0.9 to 1.1")
    print("source ready for varied playback")
end
```

---

### `lurek.audio.setSourceBus`

Routes a source through a specific audio bus for grouped mixing.

```lua
lurek.audio.setSourceBus(source, bus)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `bus` | [LBus](#lbus) | The bus to route through. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    local bus = lurek.audio.newBus("effects")
    lurek.audio.setSourceBus(src, bus)
    local assigned = lurek.audio.getSourceBus(src)
    print("bus assigned = " .. tostring(assigned ~= nil))
    print("bus = " .. assigned:getName())
end
```

---

### `lurek.audio.setStereoWidth`

Sets the stereo width of an audio source (0.0 = mono, 1.0 = full stereo).

```lua
lurek.audio.setStereoWidth(src_ud, width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LSource](#lsource) | The audio source to adjust. |
| `width` | number | Stereo width factor (0.0 = mono, 1.0 = full stereo). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.setStereoWidth(src, 0.5)
    print("configured stereo width = 0.5")
    print("stereo width = " .. tostring(lurek.audio.getStereoWidth(src)))
end
```

---

### `lurek.audio.setVelocity`

Sets the velocity of a source for Doppler effect calculations.

```lua
lurek.audio.setVelocity(source, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `x` | number | X velocity component. |
| `y` | number | Y velocity component. |
| `z?` | number | Z velocity component (defaults to 0). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.setVelocity(src, 10, 0, 0)
    local vx, vy, vz = lurek.audio.getVelocity(src)
    print("source velocity set for doppler")
    print("velocity = " .. vx .. ", " .. vy .. ", " .. vz)
end
```

---

### `lurek.audio.setVolume`

Sets the volume of a source by handle.

```lua
lurek.audio.setVolume(source, vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |
| `vol` | number | Volume multiplier (0.0 = silent, 1.0 = normal). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("volume before = " .. tostring(lurek.audio.getVolume(src)))
    lurek.audio.setVolume(src, 0.5)
    print("volume after = " .. tostring(lurek.audio.getVolume(src)))
end
```

---

### `lurek.audio.set_bus_volume`

Sets the volume of a named audio bus.

```lua
lurek.audio.set_bus_volume(name, volume)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the audio bus. |
| `volume` | number | Volume level (0.0 = silent, 1.0 = full, >1.0 = boost). |

**Example**

```lua
do
    lurek.audio.create_bus("music_bus", nil)
    lurek.audio.set_bus_volume("music_bus", 0.7)
    print("configured music_bus volume = 0.7")
    print("music_bus peak = " .. tostring(lurek.audio.getBusPeak("music_bus")))
end
```

---

### `lurek.audio.stop`

Stops playback of a source and resets its position to the beginning.

```lua
lurek.audio.stop(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    print("before stop playing = " .. tostring(lurek.audio.isPlaying(src)))
    lurek.audio.stop(src)
    print("stopped = " .. tostring(lurek.audio.isStopped(src)))
end
```

---

### `lurek.audio.stopAll`

Stops all audio sources and resets their positions.

```lua
lurek.audio.stopAll()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    lurek.audio.play(src)
    lurek.audio.stopAll()
    print("all stopped")
    print("sample source stopped = " .. tostring(lurek.audio.isStopped(src)))
end
```

---

### `lurek.audio.stopMusic`

Stops all music sources with optional fade-out.

```lua
lurek.audio.stopMusic(fade_duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fade_duration?` | number | Fade-out duration in seconds (default: 0.0). |

**Example**

```lua
do
    local src = lurek.audio.newSource("content/examples/assets/audio/sample_loop.wav", "stream")
    lurek.audio.play(src)
    print("music playing = " .. tostring(lurek.audio.isPlaying(src)))
    lurek.audio.stopMusic(0.5)
    print("music stopped with fade")
end
```

---

### `lurek.audio.stopQueueable`

Stops playback of a queueable audio source.

```lua
lurek.audio.stopQueueable(qsource_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qsource_id` | number | Queueable source handle returned by newQueueableSource. |

**Example**

```lua
do
    local qid = lurek.audio.newQueueableSource(44100, 16, 1, 4)
    lurek.audio.stopQueueable(qid)
    print("queueable source stopped")
    print("free buffers = " .. tostring(lurek.audio.getFreeBufferCount(qid)))
end
```

---

### `lurek.audio.tell`

Returns the current playback position of a source in seconds.

```lua
lurek.audio.tell(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Current position in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    local pos = lurek.audio.tell(src)
    print("playing = " .. tostring(lurek.audio.isPlaying(src)))
    print("position = " .. tostring(pos))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LBeatClock](#lbeatclock)
- [LBus](#lbus)
- [LDecoder](#ldecoder)
- [LMidiPlayer](#lmidiplayer)
- [LSoundData](#lsounddata)
- [LSoundPool](#lsoundpool)
- [LSource](#lsource)

## LBeatClock

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBeatClock:at`

Registers a one-shot callback fired when `beat` is crossed.

```lua
LBeatClock:at(beat, fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `beat` | number | Beat value threshold. |
| `fn` | function | Callback receiving the scheduled beat. |

**Returns**

| Type | Description |
|------|-------------|
| table | Handle table usable with `cancel`. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(60.0, { subdivision = 4 })
    local at_h = clock:at(1.0, function() end)
    print("at handle = " .. tostring(at_h))
end
```

---

#### `LBeatClock:beatTimeRemaining`

Returns seconds until the next division boundary.

```lua
LBeatClock:beatTimeRemaining(division)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `division?` | number | Beat division. |

**Returns**

| Type | Description |
|------|-------------|
| number | Seconds remaining. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("beatTimeRemaining marker")
end
```

---

#### `LBeatClock:beatsPerBar`

Returns the number of beats per bar.

```lua
LBeatClock:beatsPerBar()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Beats per bar. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("beatsPerBar marker")
end
```

---

#### `LBeatClock:bpm`

Returns the current tempo as beats-per-minute for this clock.

```lua
LBeatClock:bpm()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Beats-per-minute. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("bpm marker")
end
```

---

#### `LBeatClock:cancel`

Cancels a scheduled callback handle.

```lua
LBeatClock:cancel(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | any | Handle table returned by `every`/`at`/`pattern` or numeric id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a schedule was cancelled. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(60.0, { subdivision = 4 })
    local handle = clock:every(4, function() end)
    local cancelled = clock:cancel(handle)
    print("cancel returned = " .. tostring(cancelled))
end
```

---

#### `LBeatClock:cancelAll`

Cancels all scheduled callback handles registered on this clock.

```lua
LBeatClock:cancelAll()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Always true. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(60.0, { subdivision = 4 })
    clock:every(4, function() end)
    clock:cancelAll()
    print("cancelAll ok")
end
```

---

#### `LBeatClock:drainFired`

Returns and removes all scheduled beats that have now passed.

```lua
LBeatClock:drainFired()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of fired beat numbers. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("drainFired marker")
end
```

---

#### `LBeatClock:dump`

Returns a snapshot of clock state for debug and HUDs.

```lua
LBeatClock:dump()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Table with bpm, beat, bar, phase, and running. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("dump marker")
end
```

---

#### `LBeatClock:every`

Registers a callback fired on each crossed step of `division`.

```lua
LBeatClock:every(division, fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `division` | number | Beat division grid (e.g. 4 for quarter-beat steps). |
| `fn` | function | Callback receiving `step_index`. |

**Returns**

| Type | Description |
|------|-------------|
| table | Handle table usable with `cancel`. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(60.0, { subdivision = 4 })
    local every_h = clock:every(4, function() end)
    print("every handle = " .. tostring(every_h))
end
```

---

#### `LBeatClock:getBar`

Returns the current fractional bar position across elapsed musical time.

```lua
LBeatClock:getBar()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Fractional bar. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("getBar marker")
end
```

---

#### `LBeatClock:getBeat`

Returns fractional beat position.

```lua
LBeatClock:getBeat()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Fractional beat. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("getBeat marker")
end
```

---

#### `LBeatClock:getBpm`

Returns the current tempo as beats-per-minute for this clock.

```lua
LBeatClock:getBpm()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Beats-per-minute. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("getBpm marker")
end
```

---

#### `LBeatClock:getPhase`

Returns phase within the current division in [0, 1).

```lua
LBeatClock:getPhase(division)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `division?` | number | Beat division. |

**Returns**

| Type | Description |
|------|-------------|
| number | Phase value. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("getPhase marker")
end
```

---

#### `LBeatClock:isOnBeat`

Returns true when the clock is near a beat boundary.

```lua
LBeatClock:isOnBeat(division, tolerance)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `division?` | number | Beat division. |
| `tolerance?` | number | Tolerance in seconds (default 0.05). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when within tolerance. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("isOnBeat marker")
end
```

---

#### `LBeatClock:isRunning`

Returns true when the clock is running.

```lua
LBeatClock:isRunning()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Running state. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("isRunning marker")
end
```

---

#### `LBeatClock:nearestBeat`

Returns nearest beat and signed timing error in seconds.

```lua
LBeatClock:nearestBeat(division)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `division?` | number | Beat division. |

**Returns**

| Type | Description |
|------|-------------|
| number | Nearest beat and signed error in seconds. (value 1). |
| number | Nearest beat and signed error in seconds. (value 2). |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("nearestBeat marker")
end
```

---

#### `LBeatClock:pattern`

Registers a repeating pattern callback where `x` triggers and `.` skips.

```lua
LBeatClock:pattern(pattern, fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pattern` | string | Pattern string like `x.x.`. |
| `fn` | function | Callback receiving 1-based pattern step index. |

**Returns**

| Type | Description |
|------|-------------|
| table | Handle table usable with `cancel`. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(60.0, { subdivision = 4 })
    local pattern_h = clock:pattern("x.x.", function() end)
    print("pattern handle = " .. tostring(pattern_h))
end
```

---

#### `LBeatClock:position`

Returns the current beat position.

```lua
LBeatClock:position()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Table with `beat`, `bar`, `beat_in_bar`, `phase` fields. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("position marker")
end
```

---

#### `LBeatClock:quantise`

Quantises `beat` to the nearest `grid` beat grid (static utility).

```lua
LBeatClock:quantise(beat, grid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `beat` | number | Beat value to quantise. |
| `grid` | number | Grid size (e.g. 0.25 for 16th notes). |

**Returns**

| Type | Description |
|------|-------------|
| number | Quantised beat value. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("quantise marker")
end
```

---

#### `LBeatClock:rampBpm`

Ramps BPM linearly to a target value over time.

```lua
LBeatClock:rampBpm(target, seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | number | Target BPM. |
| `seconds` | number | Ramp duration in seconds. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("rampBpm marker")
end
```

---

#### `LBeatClock:reset`

Resets elapsed time to zero without changing running state.

```lua
LBeatClock:reset()
```

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("reset marker")
end
```

---

#### `LBeatClock:scheduleAt`

Schedules a one-shot event at `beat`. Returns true when the beat is in the future.

```lua
LBeatClock:scheduleAt(beat)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `beat` | number | Beat number to schedule. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when scheduled. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("scheduleAt marker")
end
```

---

#### `LBeatClock:secondsPerBeat`

Returns seconds-per-beat at the current BPM.

```lua
LBeatClock:secondsPerBeat()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Seconds per beat. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("secondsPerBeat marker")
end
```

---

#### `LBeatClock:secondsToNextBeat`

Returns seconds until the next whole beat boundary.

```lua
LBeatClock:secondsToNextBeat()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Seconds until next beat. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("secondsToNextBeat marker")
end
```

---

#### `LBeatClock:setBeatsPerBar`

Changes the time-signature beats-per-bar.

```lua
LBeatClock:setBeatsPerBar(beats)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `beats` | number | New beats per bar (clamped to â‰Ą1). |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("setBeatsPerBar marker")
end
```

---

#### `LBeatClock:setBpm`

Sets a new BPM. Elapsed time is preserved.

```lua
LBeatClock:setBpm(bpm)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bpm` | number | New BPM (clamped to â‰Ą1). |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("setBpm marker")
end
```

---

#### `LBeatClock:setSwing`

Sets rhythmic swing amount in `[0.0, 0.5]` for off-beat timing feel.

```lua
LBeatClock:setSwing(amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amount` | number | Swing amount. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("setSwing marker")
end
```

---

#### `LBeatClock:start`

Starts beat-clock playback so scheduled beat callbacks can begin firing.

```lua
LBeatClock:start()
```

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("start marker")
end
```

---

#### `LBeatClock:stop`

Stops beat-clock playback while preserving the current musical position.

```lua
LBeatClock:stop()
```

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("stop marker")
end
```

---

#### `LBeatClock:syncToSource`

Synchronizes beat position to an audio source playback position.

```lua
LBeatClock:syncToSource(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | [LSource](#lsource)|number | Source handle or source id. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("syncToSource marker")
end
```

---

#### `LBeatClock:tap`

Records a tap-tempo tap at `wall_time_secs`. Returns the estimated BPM (0.0 when fewer than 2 taps).

```lua
LBeatClock:tap(wall_time_secs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wall_time_secs` | number | Current real-world time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| number | Estimated BPM, or 0.0 when not enough taps. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("tap marker")
end
```

---

#### `LBeatClock:tick`

Advances the clock by `dt` seconds. Returns an array of whole-beat crossings.

```lua
LBeatClock:tick(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of beat numbers crossed during this tick. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("tick marker")
end
```

---

#### `LBeatClock:type`

Returns the Lua-visible type name.

```lua
LBeatClock:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LBeatClock](#lbeatclock)`. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("type marker")
end
```

---

#### `LBeatClock:typeOf`

Returns whether this handle matches the given type name.

```lua
LBeatClock:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when matched. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("typeOf marker")
end
```

---

#### `LBeatClock:update`

Advances the clock by `dt` seconds and returns beat/bar transitions.

```lua
LBeatClock:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table with optional `beat` and `bar` integer fields. |

**Example**

```lua
do
    local clock = lurek.audio.newBeatClock(120.0, 4)
    print("update marker")
end
```

---

## LBus

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBus:clearDuck`

Removes the ducking configuration from this bus.

```lua
LBus:clearDuck()
```

**Example**

```lua
do
    local bus = lurek.audio.newBus("narrator")
    bus:setDuckTarget("bg_music", 0.2)
    bus:clearDuck()
    print("duck cleared")
end
```

---

#### `LBus:getName`

Returns the name of this audio bus. This method is available to Lua scripts.

```lua
LBus:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Bus name as registered during creation. |

**Example**

```lua
do
    local bus = lurek.audio.newBus("gameplay")
    print("bus name = " .. bus:getName())
end
```

---

#### `LBus:getPeak`

Returns the current peak amplitude level of this bus for VU-meter displays.

```lua
LBus:getPeak()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Peak level from 0.0 to 1.0. |

**Example**

```lua
do
    local bus = lurek.audio.newBus("meter_bus")
    local peak = bus:getPeak()
    print("peak = " .. peak)
end
```

---

#### `LBus:getPitch`

Returns the current pitch multiplier of this bus.

```lua
LBus:getPitch()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current pitch multiplier (defaults to 1.0). |

**Example**

```lua
do
    local bus = lurek.audio.newBus("ambient")
    bus:setPitch(0.9)
    local p = bus:getPitch()
    print("pitch = " .. p)
end
```

---

#### `LBus:getVolume`

Returns the current volume multiplier of this bus.

```lua
LBus:getVolume()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Volume multiplier (defaults to 1.0). |

**Example**

```lua
do
    local bus = lurek.audio.newBus("music")
    bus:setVolume(0.8)
    local v = bus:getVolume()
    print("volume = " .. v)
end
```

---

#### `LBus:isPaused`

Returns whether this bus is currently paused.

```lua
LBus:isPaused()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the bus is paused. |

**Example**

```lua
do
    local bus = lurek.audio.newBus("ui")
    bus:pause()
    print("paused = " .. tostring(bus:isPaused()))
end
```

---

#### `LBus:pause`

Pauses all sources routed through this bus.

```lua
LBus:pause()
```

**Example**

```lua
do
    local bus = lurek.audio.newBus("dialog")
    bus:pause()
    print("bus paused = " .. tostring(bus:isPaused()))
end
```

---

#### `LBus:resume`

Resumes all sources routed through this bus that were paused.

```lua
LBus:resume()
```

**Example**

```lua
do
    local bus = lurek.audio.newBus("world")
    bus:pause()
    bus:resume()
    print("bus resumed = " .. tostring(not bus:isPaused()))
end
```

---

#### `LBus:setDuckTarget`

Configures ducking so this bus lowers the volume of a target bus when active.

```lua
LBus:setDuckTarget(target_name, duck_vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target_name` | string | Name of the bus to duck. |
| `duck_vol` | number | Volume multiplier applied to the target when ducking (0.0-1.0). |

**Example**

```lua
do
    local music = lurek.audio.newBus("bg_music")
    local voice = lurek.audio.newBus("voice_over")
    voice:setDuckTarget("bg_music", 0.3)
    print("ducking bg_music to 0.3 when voice active")
end
```

---

#### `LBus:setPitch`

Sets the pitch multiplier applied to all sources routed through this bus.

```lua
LBus:setPitch(pitch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pitch` | number | Pitch multiplier (1.0 = normal speed). |

**Example**

```lua
do
    local bus = lurek.audio.newBus("fx")
    bus:setPitch(1.2)
    print("bus pitch = " .. bus:getPitch())
end
```

---

#### `LBus:setVolume`

Sets the volume multiplier for all sources routed through this bus.

```lua
LBus:setVolume(vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vol` | number | Volume multiplier (0.0 = silent, 1.0 = normal). |

**Example**

```lua
do
    local bus = lurek.audio.newBus("sfx")
    bus:setVolume(0.6)
    print("bus volume = " .. bus:getVolume())
end
```

---

#### `LBus:type`

Returns the type name of this object for runtime type-checking.

```lua
LBus:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always returns "[LBus](#lbus)". |

**Example**

```lua
do
    local bus = lurek.audio.newBus("test")
    print("type = " .. bus:type())
end
```

---

#### `LBus:typeOf`

Checks whether this object matches the given type name.

```lua
LBus:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. "[LBus](#lbus)", "Bus", or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object matches the given type. |

**Example**

```lua
do
    local bus = lurek.audio.newBus("check")
    print("is LBus = " .. tostring(bus:typeOf("LBus")))
end
```

---

## LDecoder

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDecoder:decode`

Decodes the next chunk of audio data and returns it as a [LSoundData](#lsounddata) object.

```lua
LDecoder:decode()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSoundData](#lsounddata) | Decoded PCM data, or nil if end of stream reached. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path, 4096)
    local chunk = dec:decode()
    print("decoded chunk = " .. tostring(chunk ~= nil))
end
```

---

#### `LDecoder:getBitDepth`

Returns the bit depth of the source audio file.

```lua
LDecoder:getBitDepth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Bits per sample (e.g. 16, 24). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local bits = dec:getBitDepth()
    print("bit depth = " .. bits)
end
```

---

#### `LDecoder:getChannelCount`

Returns the number of audio channels in the source file.

```lua
LDecoder:getChannelCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Channel count (1 = mono, 2 = stereo). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local ch = dec:getChannelCount()
    print("channels = " .. ch)
end
```

---

#### `LDecoder:getDuration`

Returns the total duration of the source audio file in seconds.

```lua
LDecoder:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local dur = dec:getDuration()
    print("duration = " .. dur .. "s")
end
```

---

#### `LDecoder:getSampleRate`

Returns the sample rate of the source audio file.

```lua
LDecoder:getSampleRate()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Sample rate in Hz. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    local rate = dec:getSampleRate()
    print("sample rate = " .. rate)
end
```

---

#### `LDecoder:isSeekable`

Returns whether this decoder supports seeking.

```lua
LDecoder:isSeekable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if seek operations are supported. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    print("seekable = " .. tostring(dec:isSeekable()))
end
```

---

#### `LDecoder:release`

Releases decoder resources (no-op, kept for API symmetry).

```lua
LDecoder:release()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:release()
    print("decoder released")
end
```

---

#### `LDecoder:rewind`

Rewinds the decoder back to the beginning of the audio stream.

```lua
LDecoder:rewind()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(5.0)
    dec:rewind()
    print("rewound to " .. dec:tell())
end
```

---

#### `LDecoder:seek`

Seeks to a specific position in the audio stream.

```lua
LDecoder:seek(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Target position in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(2.5)
    print("seeked to " .. dec:tell())
end
```

---

#### `LDecoder:tell`

Returns the current read position in the audio stream in seconds.

```lua
LDecoder:tell()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current position in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(3.0)
    local pos = dec:tell()
    print("position = " .. pos)
end
```

---

#### `LDecoder:type`

Returns the type name of this object for runtime type-checking.

```lua
LDecoder:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always returns "[LDecoder](#ldecoder)". |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    print("type = " .. dec:type())
end
```

---

#### `LDecoder:typeOf`

Checks whether this object matches the given type name.

```lua
LDecoder:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. "[LDecoder](#ldecoder)" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object matches the given type. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    print("is LDecoder = " .. tostring(dec:typeOf("LDecoder")))
end
```

---

## LMidiPlayer

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMidiPlayer:getBus`

Returns the audio bus this MIDI player is routed through.

```lua
LMidiPlayer:getBus()
```

**Returns**

| Type | Description |
|------|-------------|
| [LBus](#lbus) | The assigned bus, or nil if using direct output. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    local bus = lurek.audio.newBus("midi_out")
    player:setBus(bus)
    local b = player:getBus()
    print("bus = " .. b:getName())
end
```

---

#### `LMidiPlayer:getChannelCount`

Returns the number of active MIDI channels in the loaded file.

```lua
LMidiPlayer:getChannelCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of active channels. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local count = player:getChannelCount()
    print("channels = " .. count)
end
```

---

#### `LMidiPlayer:getChannelInstrument`

Returns the current GM instrument program for a channel.

```lua
LMidiPlayer:getChannelInstrument(ch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | number | Channel number (1-16). |

**Returns**

| Type | Description |
|------|-------------|
| number | GM instrument program number (0-127). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelInstrument(2, 48)
    local inst = player:getChannelInstrument(2)
    print("ch2 instrument = " .. inst)
end
```

---

#### `LMidiPlayer:getChannelVolume`

Returns the volume of a specific MIDI channel.

```lua
LMidiPlayer:getChannelVolume(ch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | number | Channel number (1-16). |

**Returns**

| Type | Description |
|------|-------------|
| number | Channel volume (0.0-1.0). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelVolume(2, 0.6)
    local v = player:getChannelVolume(2)
    print("ch2 volume = " .. v)
end
```

---

#### `LMidiPlayer:getChannels`

Returns the number of output audio channels for MIDI synthesis.

```lua
LMidiPlayer:getChannels()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Channel count (1 = mono, 2 = stereo). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    local ch = player:getChannels()
    print("output channels = " .. ch)
end
```

---

#### `LMidiPlayer:getDuration`

Returns the total duration of the loaded MIDI file in seconds.

```lua
LMidiPlayer:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local dur = player:getDuration()
    print("duration = " .. dur .. "s")
end
```

---

#### `LMidiPlayer:getFilePath`

Returns the file path of the currently loaded MIDI file.

```lua
LMidiPlayer:getFilePath()
```

**Returns**

| Type | Description |
|------|-------------|
| string | File path string or nil if no file is loaded. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    print("file = " .. tostring(player:getFilePath()))
end
```

---

#### `LMidiPlayer:getNoteCount`

Returns the total number of note events in the loaded MIDI file.

```lua
LMidiPlayer:getNoteCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total note count. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local notes = player:getNoteCount()
    print("notes = " .. notes)
end
```

---

#### `LMidiPlayer:getOriginalTempo`

Returns the original tempo of the MIDI file as authored.

```lua
LMidiPlayer:getOriginalTempo()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Original tempo in BPM. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local orig = player:getOriginalTempo()
    print("original tempo = " .. orig)
end
```

---

#### `LMidiPlayer:getSampleRate`

Returns the output sample rate used for MIDI synthesis.

```lua
LMidiPlayer:getSampleRate()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Sample rate in Hz (e.g. 44100). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    local rate = player:getSampleRate()
    print("sample rate = " .. rate)
end
```

---

#### `LMidiPlayer:getSoundFontPath`

Returns the path of the currently set SoundFont (stub, not yet implemented).

```lua
LMidiPlayer:getSoundFontPath()
```

**Returns**

| Type | Description |
|------|-------------|
| string | SoundFont path or nil. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    local sf_path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok = pcall(function() player:setSoundFont(sf_path) end)
    local p = ok and player:getSoundFontPath() or nil
    print("soundfont = " .. tostring(p))
end
```

---

#### `LMidiPlayer:getTempo`

Returns the current effective tempo in beats per minute.

```lua
LMidiPlayer:getTempo()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current tempo in BPM. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempo(120)
    local t = player:getTempo()
    print("tempo = " .. t)
end
```

---

#### `LMidiPlayer:getTempoScale`

Returns the current tempo scale multiplier.

```lua
LMidiPlayer:getTempoScale()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tempo scale factor. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempoScale(0.8)
    local s = player:getTempoScale()
    print("scale = " .. s)
end
```

---

#### `LMidiPlayer:getTicksPerBeat`

Returns the MIDI file's resolution in ticks per beat (PPQN).

```lua
LMidiPlayer:getTicksPerBeat()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Ticks per quarter note. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local tpb = player:getTicksPerBeat()
    print("ticks/beat = " .. tpb)
end
```

---

#### `LMidiPlayer:getTrackCount`

Returns the number of tracks in the loaded MIDI file.

```lua
LMidiPlayer:getTrackCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of MIDI tracks. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local count = player:getTrackCount()
    print("tracks = " .. count)
end
```

---

#### `LMidiPlayer:getTrackName`

Returns the name of a MIDI track by 1-based index.

```lua
LMidiPlayer:getTrackName(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Track index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| string | Track name or nil if not available. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    local name = player:getTrackName(1)
    print("track 1 = " .. tostring(name))
end
```

---

#### `LMidiPlayer:getVolume`

Returns the current master volume of the MIDI player.

```lua
LMidiPlayer:getVolume()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Volume multiplier. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setVolume(0.5)
    local v = player:getVolume()
    print("volume = " .. v)
end
```

---

#### `LMidiPlayer:isChannelMuted`

Returns whether a specific MIDI channel is muted.

```lua
LMidiPlayer:isChannelMuted(ch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | number | Channel number (1-16). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the channel is muted. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelMuted(3, true)
    print("ch3 muted = " .. tostring(player:isChannelMuted(3)))
end
```

---

#### `LMidiPlayer:isLoaded`

Returns whether a MIDI file is currently loaded and ready to play.

```lua
LMidiPlayer:isLoaded()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a MIDI file is loaded. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    print("loaded = " .. tostring(player:isLoaded()))
end
```

---

#### `LMidiPlayer:isLooping`

Returns whether MIDI looping is enabled.

```lua
LMidiPlayer:isLooping()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if looping. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setLooping(true)
    print("isLooping = " .. tostring(player:isLooping()))
end
```

---

#### `LMidiPlayer:isPaused`

Returns whether the MIDI player is currently paused.

```lua
LMidiPlayer:isPaused()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if paused. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:pause()
    print("paused = " .. tostring(player:isPaused()))
end
```

---

#### `LMidiPlayer:isPlaying`

Returns whether the MIDI player is currently playing.

```lua
LMidiPlayer:isPlaying()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if playing. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    print("playing = " .. tostring(player:isPlaying()))
end
```

---

#### `LMidiPlayer:isTrackMuted`

Returns whether a specific MIDI track is muted.

```lua
LMidiPlayer:isTrackMuted(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Track index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the track is muted. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setTrackMuted(2, true)
    print("track 2 muted = " .. tostring(player:isTrackMuted(2)))
end
```

---

#### `LMidiPlayer:load`

Loads a MIDI file from the given path relative to the game directory.

```lua
LMidiPlayer:load(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Relative path to the .mid file. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the file was loaded successfully. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    local path = "content/examples/assets/audio/sample_midi.mid"
    local ok = player:load(path)
    print("loaded = " .. tostring(ok))
end
```

---

#### `LMidiPlayer:loadData`

Loads MIDI data from a raw byte string in memory.

```lua
LMidiPlayer:loadData(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | string | Raw MIDI binary data. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the data was parsed successfully. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    local data = string.char(77,84,104,100,0,0,0,6,0,0,0,1,0,96,77,84,114,107,0,0,0,4,0,255,47,0)
    local ok = player:loadData(data)
    print("loaded data = " .. tostring(ok))
end
```

---

#### `LMidiPlayer:pause`

Pauses MIDI playback at the current position.

```lua
LMidiPlayer:pause()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:pause()
    print("midi paused = " .. tostring(player:isPaused()))
end
```

---

#### `LMidiPlayer:play`

Starts MIDI playback from the current position using the audio output stream.

```lua
LMidiPlayer:play()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    print("midi playing = " .. tostring(player:isPlaying()))
end
```

---

#### `LMidiPlayer:seek`

Seeks to a specific position in the MIDI file.

```lua
LMidiPlayer:seek(secs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `secs` | number | Target position in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:seek(5.0)
    print("seeked to " .. player:tell())
end
```

---

#### `LMidiPlayer:setBus`

Routes this MIDI player's output through the specified audio bus.

```lua
LMidiPlayer:setBus(bus)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bus?` | [LBus](#lbus) | Bus to route through, or nil for direct output. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    local bus = lurek.audio.newBus("midi_bus")
    player:setBus(bus)
    print("bus set")
end
```

---

#### `LMidiPlayer:setChannelInstrument`

Sets the General MIDI instrument program for a channel.

```lua
LMidiPlayer:setChannelInstrument(ch, inst)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | number | Channel number (1-16). |
| `inst` | number | GM instrument program number (0-127). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelInstrument(1, 25)
    print("ch1 instrument = " .. player:getChannelInstrument(1))
end
```

---

#### `LMidiPlayer:setChannelMuted`

Mutes or unmutes a specific MIDI channel.

```lua
LMidiPlayer:setChannelMuted(ch, muted)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | number | Channel number (1-16). |
| `muted` | boolean | True to mute, false to unmute. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelMuted(10, true)
    print("ch10 muted = " .. tostring(player:isChannelMuted(10)))
end
```

---

#### `LMidiPlayer:setChannelVolume`

Sets the volume for a specific MIDI channel (1-16).

```lua
LMidiPlayer:setChannelVolume(ch, vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | number | Channel number (1-16). |
| `vol` | number | Volume multiplier (0.0-1.0). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelVolume(1, 0.8)
    print("ch1 volume = " .. player:getChannelVolume(1))
end
```

---

#### `LMidiPlayer:setChannels`

Sets the number of output audio channels for MIDI synthesis.

```lua
LMidiPlayer:setChannels(channels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channels` | number | Channel count (1 = mono, 2 = stereo). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannels(2)
    print("set stereo output")
end
```

---

#### `LMidiPlayer:setLooping`

Enables or disables looping for MIDI playback.

```lua
LMidiPlayer:setLooping(looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `looping` | boolean | True to loop, false to play once. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setLooping(true)
    print("looping = " .. tostring(player:isLooping()))
end
```

---

#### `LMidiPlayer:setOnEnd`

Registers a callback invoked when MIDI playback finishes (stub, not yet implemented).

```lua
LMidiPlayer:setOnEnd(cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cb?` | function | Callback function or nil to clear. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setOnEnd(function()
        print("midi playback ended")
    end)
    print("onEnd callback set")
end
```

---

#### `LMidiPlayer:setOnNoteOff`

Registers a callback for MIDI note-off events (stub, not yet implemented).

```lua
LMidiPlayer:setOnNoteOff(cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cb?` | function | Callback function or nil to clear. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setOnNoteOff(function(ch, note)
        print("note off: ch=" .. ch .. " note=" .. note)
    end)
    print("onNoteOff callback set")
end
```

---

#### `LMidiPlayer:setOnNoteOn`

Registers a callback for MIDI note-on events (stub, not yet implemented).

```lua
LMidiPlayer:setOnNoteOn(cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cb?` | function | Callback function or nil to clear. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setOnNoteOn(function(ch, note, vel)
        print("note on: ch=" .. ch .. " note=" .. note .. " vel=" .. vel)
    end)
    print("onNoteOn callback set")
end
```

---

#### `LMidiPlayer:setSampleRate`

Sets the output sample rate for MIDI synthesis.

```lua
LMidiPlayer:setSampleRate(rate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rate` | number | Sample rate in Hz (e.g. 44100, 48000). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setSampleRate(48000)
    print("sample rate = " .. player:getSampleRate())
end
```

---

#### `LMidiPlayer:setSoundFont`

Sets a custom SoundFont file for MIDI synthesis (stub, not yet implemented).

```lua
LMidiPlayer:setSoundFont(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Relative path to the .sf2 file. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    local sf_path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok = pcall(function() player:setSoundFont(sf_path) end)
    print("sf = " .. tostring(ok and player:getSoundFontPath()))
end
```

---

#### `LMidiPlayer:setTempo`

Sets the playback tempo in beats per minute.

```lua
LMidiPlayer:setTempo(bpm)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bpm` | number | Desired tempo in BPM. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempo(140)
    print("tempo = " .. player:getTempo())
end
```

---

#### `LMidiPlayer:setTempoScale`

Sets a tempo multiplier relative to the original speed.

```lua
LMidiPlayer:setTempoScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | number | Tempo scale (1.0 = original, 2.0 = double speed). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempoScale(1.5)
    print("tempo scale = " .. player:getTempoScale())
end
```

---

#### `LMidiPlayer:setTrackMuted`

Mutes or unmutes a specific MIDI track.

```lua
LMidiPlayer:setTrackMuted(idx, muted)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Track index (1-based). |
| `muted` | boolean | True to mute, false to unmute. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:setTrackMuted(1, true)
    print("track 1 muted = " .. tostring(player:isTrackMuted(1)))
end
```

---

#### `LMidiPlayer:setVolume`

Sets the master volume for MIDI playback.

```lua
LMidiPlayer:setVolume(vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vol` | number | Volume multiplier (0.0 = silent, 1.0 = normal). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setVolume(0.7)
    print("volume = " .. player:getVolume())
end
```

---

#### `LMidiPlayer:soloChannel`

Solos a specific MIDI channel, muting all others.

```lua
LMidiPlayer:soloChannel(ch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | number | Channel number (1-16) to solo. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:soloChannel(1)
    print("ch1 soloed")
end
```

---

#### `LMidiPlayer:stop`

Stops MIDI playback and resets position to the beginning.

```lua
LMidiPlayer:stop()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    player:stop()
    print("midi stopped")
end
```

---

#### `LMidiPlayer:tell`

Returns the current playback position of the MIDI player in seconds.

```lua
LMidiPlayer:tell()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current position in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    player:play()
    local pos = player:tell()
    print("position = " .. pos)
end
```

---

#### `LMidiPlayer:type`

Returns the type name of this object for runtime type-checking.

```lua
LMidiPlayer:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always returns "[LMidiPlayer](#lmidiplayer)". |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    print("type = " .. player:type())
end
```

---

#### `LMidiPlayer:typeOf`

Checks whether this object matches the given type name.

```lua
LMidiPlayer:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. "[LMidiPlayer](#lmidiplayer)", "MidiPlayer", or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object matches the given type. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    print("is LMidiPlayer = " .. tostring(player:typeOf("LMidiPlayer")))
end
```

---

#### `LMidiPlayer:unsoloAll`

Removes solo from all channels, restoring normal playback.

```lua
LMidiPlayer:unsoloAll()
```

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:soloChannel(1)
    player:unsoloAll()
    print("unsolo all done")
end
```

---

#### `LMidiPlayer:useDefaultSoundFont`

Reverts to the built-in default SoundFont (stub, not yet implemented).

```lua
LMidiPlayer:useDefaultSoundFont()
```

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:useDefaultSoundFont()
    print("using default soundfont")
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

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(128, 44100, 1)
    for i = 0, 127 do
        local sample = (i % 16) / 15.0
        sd:setSample(i, sample * 2.0 - 1.0)
    end
    local img = lurek.image.newImageData(400, 100)
    sd:drawWaveform(img, 0, 0, 400, 100, 0, 255, 0, 255)
    print("waveform drawn to image")
end
```

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

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bits = sd:getBitDepth()
    print("bit depth = " .. bits)
end
```

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

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(44100, 44100, 2)
    local ch = sd:getChannelCount()
    print("channels = " .. ch)
end
```

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

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local dur = sd:getDuration()
    print("duration = " .. dur .. "s")
end
```

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

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(32, 44100, 1)
    sd:setSample(0, 1.0)
    local val = sd:getSample(0)
    print("sample[0] = " .. val)
end
```

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

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local count = sd:getSampleCount()
    print("samples = " .. count)
end
```

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

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(22050, 22050, 1)
    local rate = sd:getSampleRate()
    print("sample rate = " .. rate)
end
```

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

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    sd:setSample(0, 0.5)
    sd:setSample(50, -0.3)
    print("sample[0] = " .. sd:getSample(0) .. " sample[50] = " .. sd:getSample(50))
end
```

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

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    print("type = " .. sd:type())
end
```

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

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    print("is LSoundData = " .. tostring(sd:typeOf("LSoundData")))
end
```

---

## LSoundPool

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSoundPool:getVoiceCount`

Returns the number of pre-allocated voices in this pool.

```lua
LSoundPool:getVoiceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Voice count. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 8)
    print("voices = " .. pool:getVoiceCount())
end
```

---

#### `LSoundPool:play`

Plays the next available voice from the pool in round-robin order.

```lua
LSoundPool:play()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Numeric source ID of the voice that started playing. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    local id = pool:play()
    print("playing voice id = " .. id)
end
```

---

#### `LSoundPool:release`

Releases all voices and frees audio resources held by this pool.

```lua
LSoundPool:release()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:release()
    print("pool released")
end
```

---

#### `LSoundPool:setBus`

Routes all voices in this pool through the named audio bus.

```lua
LSoundPool:setBus(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the target bus. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    lurek.audio.newBus("pool_bus")
    pool:setBus("pool_bus")
    print("pool routed to pool_bus")
end
```

---

#### `LSoundPool:setVolume`

Sets the volume for all voices in this pool.

```lua
LSoundPool:setVolume(vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vol` | number | Volume multiplier (0.0 = silent, 1.0 = normal). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:setVolume(0.5)
    print("pool volume = 0.5")
end
```

---

#### `LSoundPool:stopAll`

Stops all voices in this sound pool immediately.

```lua
LSoundPool:stopAll()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 4)
    pool:play()
    pool:stopAll()
    print("all voices stopped")
end
```

---

#### `LSoundPool:type`

Returns the type name of this object for runtime type-checking.

```lua
LSoundPool:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always returns "[LSoundPool](#lsoundpool)". |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 2)
    print("type = " .. pool:type())
end
```

---

#### `LSoundPool:typeOf`

Checks whether this object matches the given type name.

```lua
LSoundPool:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. "[LSoundPool](#lsoundpool)" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object matches the given type. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 2)
    print("is LSoundPool = " .. tostring(pool:typeOf("LSoundPool")))
end
```

---

## LSource

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSource:clearFilter`

Removes all frequency filters (lowpass and highpass) from this source.

```lua
LSource:clearFilter()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setLowpass(800)
    src:clearFilter()
    print("filters cleared")
end
```

---

#### `LSource:clone`

Creates an independent copy of this source sharing the same audio data.

```lua
LSource:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSource](#lsource) | A new source instance with identical settings. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.3)
    local copy = src:clone()
    print("clone volume = " .. copy:getVolume())
end
```

---

#### `LSource:fadeIn`

Sets the fade-in duration so the source ramps from silence to full volume on play.

```lua
LSource:fadeIn(dur)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dur` | number | Fade-in duration in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:fadeIn(2.5)
    print("fade in = " .. src:getFadeIn() .. "s")
end
```

---

#### `LSource:getDuration`

Returns the total duration of this audio source in seconds.

```lua
LSource:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    local dur = src:getDuration()
    print("duration = " .. tostring(dur) .. "s")
end
```

---

#### `LSource:getFadeIn`

Returns the configured fade-in duration for this source.

```lua
LSource:getFadeIn()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Fade-in duration in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:fadeIn(1.0)
    local fi = src:getFadeIn()
    print("fade in = " .. fi)
end
```

---

#### `LSource:getHighpass`

Returns the current highpass filter cutoff frequency in Hertz.

```lua
LSource:getHighpass()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cutoff frequency in Hz, or 0 if no highpass is set. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setHighpass(4000)
    local hp = src:getHighpass()
    print("highpass = " .. hp)
end
```

---

#### `LSource:getLowpass`

Returns the current lowpass filter cutoff frequency in Hertz.

```lua
LSource:getLowpass()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cutoff frequency in Hz, or 0 if no lowpass is set. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setLowpass(400)
    local lp = src:getLowpass()
    print("lowpass = " .. lp)
end
```

---

#### `LSource:getPan`

Returns the current stereo panning position of this source.

```lua
LSource:getPan()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Pan value from -1.0 (left) to 1.0 (right). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPan(0.5)
    local pan = src:getPan()
    print("pan = " .. pan)
end
```

---

#### `LSource:getPitch`

Returns the current pitch multiplier of this audio source.

```lua
LSource:getPitch()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current pitch multiplier. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPitch(0.7)
    local p = src:getPitch()
    print("pitch = " .. p)
end
```

---

#### `LSource:getType`

Returns whether this source was loaded as static (fully in memory) or streaming.

```lua
LSource:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Either "static" or "stream". |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    print("type = " .. src:getType())
end
```

---

#### `LSource:getVolume`

Returns the current volume level of this audio source.

```lua
LSource:getVolume()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current volume multiplier. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.9)
    local v = src:getVolume()
    print("volume = " .. v)
end
```

---

#### `LSource:isLooping`

Returns whether this source is set to loop continuously.

```lua
LSource:isLooping()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if looping is enabled. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:setLooping(true)
    print("isLooping = " .. tostring(src:isLooping()))
end
```

---

#### `LSource:isPaused`

Returns whether this source is currently paused.

```lua
LSource:isPaused()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the source is paused. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    src:pause()
    print("paused = " .. tostring(src:isPaused()))
end
```

---

#### `LSource:isPlaying`

Returns whether this source is currently playing audio.

```lua
LSource:isPlaying()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the source is actively playing. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    print("playing = " .. tostring(src:isPlaying()))
end
```

---

#### `LSource:isStopped`

Returns whether this source is currently stopped (not playing or paused).

```lua
LSource:isStopped()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the source is stopped. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("stopped = " .. tostring(src:isStopped()))
end
```

---

#### `LSource:pause`

Pauses playback at the current position, allowing later resumption.

```lua
LSource:pause()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:pause()
    print("paused = " .. tostring(src:isPaused()))
end
```

---

#### `LSource:play`

Starts playback of this audio source from the current position.

```lua
LSource:play()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    print("playing via method = " .. tostring(src:isPlaying()))
end
```

---

#### `LSource:resume`

Resumes playback from the position where the source was paused.

```lua
LSource:resume()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:pause()
    src:resume()
    print("resumed = " .. tostring(src:isPlaying()))
end
```

---

#### `LSource:seek`

Seeks to a specific position in seconds within this audio source.

```lua
LSource:seek(pos)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pos` | number | Target position in seconds. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    src:seek(10.0)
    print("seeked to " .. src:tell())
end
```

---

#### `LSource:setHighpass`

Applies a highpass filter that attenuates frequencies below the cutoff.

```lua
LSource:setHighpass(cutoff_hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cutoff_hz` | number | Cutoff frequency in Hertz. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setHighpass(1500)
    print("highpass = " .. src:getHighpass())
end
```

---

#### `LSource:setLooping`

Enables or disables looping so the source restarts automatically after finishing.

```lua
LSource:setLooping(looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `looping` | boolean | True to loop continuously, false to play once. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:setLooping(true)
    print("looping = " .. tostring(src:isLooping()))
end
```

---

#### `LSource:setLowpass`

Applies a lowpass filter that attenuates frequencies above the cutoff.

```lua
LSource:setLowpass(cutoff_hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cutoff_hz` | number | Cutoff frequency in Hertz. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:setLowpass(600)
    print("lowpass = " .. src:getLowpass())
end
```

---

#### `LSource:setPan`

Sets the stereo panning position of this source.

```lua
LSource:setPan(pan)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pan` | number | Pan value from -1.0 (full left) to 1.0 (full right), 0.0 is center. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPan(-0.8)
    print("pan = " .. src:getPan())
end
```

---

#### `LSource:setPitch`

Sets the playback speed multiplier, affecting both pitch and duration.

```lua
LSource:setPitch(pitch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pitch` | number | Pitch multiplier (1.0 = normal, 2.0 = double speed/octave up). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setPitch(1.5)
    print("pitch = " .. src:getPitch())
end
```

---

#### `LSource:setVolume`

Sets the volume level of this source where 0.0 is silent and 1.0 is full volume.

```lua
LSource:setVolume(vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vol` | number | Volume multiplier (0.0 = silent, 1.0 = normal, >1.0 = amplified). |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:setVolume(0.4)
    print("volume = " .. src:getVolume())
end
```

---

#### `LSource:stop`

Stops playback and resets the source position to the beginning.

```lua
LSource:stop()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    src:play()
    src:stop()
    print("stopped = " .. tostring(src:isStopped()))
end
```

---

#### `LSource:tell`

Returns the current playback position of this source in seconds.

```lua
LSource:tell()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current position in seconds from the start. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    src:play()
    local pos = src:tell()
    print("position = " .. pos)
end
```

---

#### `LSource:type`

Returns the type name of this object for runtime type-checking.

```lua
LSource:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always returns "[LSource](#lsource)". |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("type = " .. src:type())
end
```

---

#### `LSource:typeOf`

Checks whether this object is of the given type name or a parent type.

```lua
LSource:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. "[LSource](#lsource)" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if this object matches the given type. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("is LSource = " .. tostring(src:typeOf("LSource")))
end
```

---
