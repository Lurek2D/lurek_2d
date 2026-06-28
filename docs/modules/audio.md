# Audio

## Purpose

Plays static and streaming sound via voice pools and mixing buses. - Controls priority ducking, spatial panning, and Doppler shifts. - Provides beat clocks for rhythmic scheduling and timing checks. - Applies lowpass/highpass filters and manages source-level playback state.

## Summary

- The `audio` module is the engine's main runtime sound system for users who need playback, routing, source state, timing, and mix control to live under one API.
- It covers the full everyday audio workflow: loading or decoding sound assets, creating reusable sound data, instantiating live voices, tracking listener state, and managing mixer-facing behavior without splitting those jobs across unrelated helpers.
- Named buses are one of the core abstractions because projects usually want music, effects, voice, ambience, and UI to be grouped, muted, paused, ducked, or rebalanced as categories instead of as isolated sounds.
- Source lifecycle and inspectable runtime state make the module practical for reactive gameplay cues, debugging, and longer sequences where scripts need to know what is playing, stopped, fading, pooled, or otherwise active.
- Sound pools give repeated effects such as footsteps, shots, and impacts a structured reuse path, while beat-clock support lets rhythm-aware gameplay or presentation synchronize against shared musical timing.
- The same subsystem therefore serves both simple one-shot playback and more deliberate mix orchestration, which is important for projects that start small and later grow into layered, routing-heavy sound design.
- Mixer control keeps overall gain policy and category coordination in one place, and deterministic timing helpers make live audio behavior easier to reason about during testing or tuning.
- Those timing and routing semantics are especially valuable when several playback categories must coexist coherently.
- They are also what keep music changes, ambience, voice, and reactive effects readable as parts of one shared mix.
- Asset-facing loading is also a major part of the value. Imported files become runtime-ready sound objects through engine-owned decoding and preparation rules instead of requiring every caller to reinvent codec handling, caching, or source setup.
- That content workflow matters because audio systems often fail not at playback itself but at all the surrounding decisions: how assets are reused, how transient voices are pooled, how categories stay legible, and how stateful transitions are coordinated over longer sessions.
- The module therefore gives projects a stable answer to both "play this now" and "manage the whole current mix." Those are different needs, but they have to coexist if a game wants reactive effects, adaptive music, voiced UI, and ambient layers to remain understandable together.
- Buses and mixer policy are the main reason the subsystem scales. A small prototype may only play a few sounds, but a larger project needs volume hierarchy, pause semantics, ducking rules, mute groups, and category-level tuning that remain visible rather than being buried in ad hoc script conventions.
- Listener-facing state broadens the feature from raw playback into world-aware audio behavior. Even when neighboring modules provide the scene, `audio` owns how sources and listener context become heard spatial or positional results.
- This is why the module stays useful across both live gameplay and tool-driven verification: it keeps playback, routing, timing, and category policy visible enough to inspect instead of hiding sound behavior behind fire-and-forget calls.
- It keeps mix policy legible as projects scale.
- `dsp` specializes lower-level signal processing, but `audio` owns the user-facing contract for how sounds are loaded, instantiated, routed, timed, and heard at runtime.

This module primarily collaborates with `dsp`, `image`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

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
    lurek.log.info(tostring("synced clock beat = " .. tostring(clock:getBeat())))
    lurek.log.info(tostring("synced clock running = " .. tostring(clock:isRunning())))
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
    lurek.log.info(tostring("lowpass before clear = " .. tostring(lurek.audio.getLowpass(src))))
    lurek.audio.clearFilter(src)
    lurek.log.info(tostring("filters cleared"))
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
    lurek.log.info(tostring("random pitch cleared"))
    lurek.log.info(tostring("source pitch now follows explicit setPitch calls"))
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
    lurek.log.info(tostring("original volume = " .. tostring(lurek.audio.getVolume(src))))
    lurek.log.info(tostring("clone volume = " .. tostring(lurek.audio.getVolume(copy))))
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
    lurek.audio.set_bus_volume("master_sfx", 0.65)
    local peak = lurek.audio.getBusPeak("master_sfx")
    local rms = lurek.audio.getBusRms("master_sfx")
    lurek.log.info("named bus created master_sfx")
    lurek.log.info("named bus peak=" .. tostring(peak) .. " rms=" .. tostring(rms) .. " volume_set=0.65")
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
    lurek.log.info(tostring("from path = " .. p1))
    lurek.log.info(tostring("to path = " .. p2))
    lurek.log.info(tostring("crossfading over 3s"))
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
    lurek.log.info(tostring("fade in requested = 2.0s"))
    lurek.log.info(tostring("fade in = " .. tostring(lurek.audio.getFadeIn(src)) .. "s"))
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
    local total = lurek.audio.getSourceCount()
    local idle = total - count
    lurek.log.info("active sources=" .. tostring(count))
    lurek.log.info("registered sources=" .. tostring(total) .. " idle=" .. tostring(idle))
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
    local rms = lurek.audio.getBusRms("vu_bus")
    lurek.log.info("vu bus peak=" .. tostring(peak))
    lurek.log.info("vu bus rms=" .. tostring(rms) .. " has_peak=" .. tostring(peak ~= nil))
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
    local peak = lurek.audio.getBusPeak("rms_bus")
    lurek.log.info("rms bus value=" .. tostring(rms))
    lurek.log.info("rms bus peak=" .. tostring(peak) .. " has_rms=" .. tostring(rms ~= nil))
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
    lurek.audio.setDistanceModel("inverse_clamped")
    local fallback = lurek.audio.getDistanceModel()
    lurek.log.info("configured distance model linear actual=" .. tostring(model))
    lurek.log.info("configured distance model fallback=" .. tostring(fallback))
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
    lurek.audio.setDopplerScale(1.0)
    local reset = lurek.audio.getDopplerScale()
    lurek.log.info("configured doppler scale=2.0 actual=" .. tostring(ds))
    lurek.log.info("doppler scale reset=" .. tostring(reset))
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
    lurek.log.info(tostring("path = " .. path))
    lurek.log.info(tostring("duration = " .. tostring(dur) .. "s"))
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
    lurek.log.info(tostring("configured fade in = 1.5"))
    lurek.log.info(tostring("fade in duration = " .. tostring(fi)))
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
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    lurek.audio.queueSource(qid, sd)
    local afterQueue = lurek.audio.getFreeBufferCount(qid)
    lurek.log.info("queueable free buffers before=" .. tostring(free))
    lurek.log.info("queueable free buffers after queue=" .. tostring(afterQueue) .. " delta=" .. tostring(free - afterQueue))
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
    lurek.log.info(tostring("configured highpass = 3000"))
    lurek.log.info(tostring("highpass = " .. tostring(hp)))
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
    local perfect = windows.perfect or windows[1]
    local good = windows.good or windows[2]
    lurek.log.info("judgement windows present=" .. tostring(windows ~= nil))
    lurek.log.info("judgement windows perfect=" .. tostring(perfect) .. " good=" .. tostring(good))
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
    lurek.audio.setListener(0, 0, 0)
    local ox, oy, oz = lurek.audio.getListener()
    lurek.log.info("listener3D queried=" .. x .. "," .. y .. "," .. z)
    lurek.log.info("listener3D reset=" .. ox .. "," .. oy .. "," .. oz)
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
    lurek.audio.setListener2D(0, 0)
    local ox, oy = lurek.audio.getListener2D()
    lurek.log.info("listener2D queried=" .. x .. "," .. y)
    lurek.log.info("listener2D origin=" .. ox .. "," .. oy)
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
    lurek.log.info(tostring("configured lowpass = 500"))
    lurek.log.info(tostring("lowpass = " .. tostring(lp)))
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
    lurek.audio.setMasterVolume(0.6)
    local ducked = lurek.audio.getMasterVolume()
    lurek.audio.setMasterVolume(1.0)
    lurek.log.info("master volume default=" .. tostring(mv))
    lurek.log.info("master volume ducked=" .. tostring(ducked))
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
    local total = lurek.audio.getSourceCount()
    local active = lurek.audio.getActiveSourceCount()
    local free = max - active
    lurek.log.info("audio max sources=" .. tostring(max))
    lurek.log.info("audio total=" .. tostring(total) .. " active=" .. tostring(active) .. " free_estimate=" .. tostring(free))
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
    lurek.audio.setMeter(0.1)
    local idle = lurek.audio.getMeter()
    lurek.log.info("configured meter 0.6 actual=" .. tostring(lvl))
    lurek.log.info("configured meter idle=" .. tostring(idle))
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
    lurek.log.info(tostring("source type = " .. tostring(lurek.audio.getSourceType(src))))
    lurek.log.info(tostring("forward = " .. fx .. ", " .. fy .. ", " .. fz))
    lurek.log.info(tostring("up = " .. ux .. ", " .. uy .. ", " .. uz))
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
    lurek.log.info(tostring("configured pan = 0.7"))
    lurek.log.info(tostring("pan = " .. tostring(pan)))
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
    lurek.log.info(tostring("configured pitch = 0.8"))
    lurek.log.info(tostring("pitch = " .. tostring(p)))
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
    local devices = lurek.audio.getPlaybackDevices()
    local listed = #devices
    lurek.log.info("current playback device=" .. tostring(dev))
    lurek.log.info("available playback devices=" .. tostring(listed) .. " first=" .. tostring(devices[1] or "none"))
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
    local active = lurek.audio.getPlaybackDevice()
    local first = devices[1] or "none"
    lurek.log.info("playback device count=" .. tostring(#devices))
    lurek.log.info("playback first=" .. tostring(first) .. " active=" .. tostring(active) .. " listed_active=" .. tostring(active == first or #devices > 0))
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
    lurek.log.info(tostring("source position queried"))
    lurek.log.info(tostring("pos = " .. x .. ", " .. y .. ", " .. z))
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
    lurek.log.info(tostring("source bus exists = " .. tostring(assigned ~= nil)))
    lurek.log.info(tostring("source bus = " .. assigned:getName()))
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
    local active = lurek.audio.getActiveSourceCount()
    local idle = total - active
    lurek.log.info("source registry count=" .. tostring(total))
    lurek.log.info("active sources=" .. tostring(active) .. " idle=" .. tostring(idle))
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
    lurek.log.info(tostring("path = " .. path))
    lurek.log.info(tostring("source type = " .. tostring(stype)))
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
    lurek.log.info(tostring("configured stereo width = 0.8"))
    lurek.log.info(tostring("width = " .. tostring(w)))
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
    lurek.log.info(tostring("source velocity queried"))
    lurek.log.info(tostring("vel = " .. vx .. ", " .. vy .. ", " .. vz))
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
    lurek.log.info(tostring("configured volume = 0.8"))
    lurek.log.info(tostring("volume = " .. tostring(vol)))
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
    lurek.log.info(tostring("source type = " .. tostring(lurek.audio.getSourceType(src))))
    lurek.log.info(tostring("isLooping = " .. tostring(lurek.audio.isLooping(src))))
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
    lurek.log.info(tostring("audio is muted = " .. tostring(muted)))
    if not muted then
        lurek.audio.setMuted(true)
        lurek.log.info(tostring("now muted = " .. tostring(lurek.audio.isMuted())))
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
    lurek.log.info(tostring("playing now = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.log.info(tostring("isPaused = " .. tostring(lurek.audio.isPaused(src))))
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
    lurek.log.info(tostring("before play = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.audio.play(src)
    lurek.log.info(tostring("after play = " .. tostring(lurek.audio.isPlaying(src))))
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
    local stoppedBefore = lurek.audio.isStopped(src)
    lurek.audio.play(src)
    local playingDuring = lurek.audio.isPlaying(src)
    lurek.audio.stop(src)
    local stoppedAfter = lurek.audio.isStopped(src)
    lurek.log.info("ui click stopped before=" .. tostring(stoppedBefore) .. " playing during=" .. tostring(playingDuring))
    lurek.log.info("ui click stopped after=" .. tostring(stoppedAfter))
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
    local earlyVerdict, earlyErr = lurek.audio.judgeBeat(clock, 4, -0.04)
    lurek.log.info("judgeBeat center verdict=" .. tostring(verdict) .. " error=" .. tostring(err))
    lurek.log.info("judgeBeat early verdict=" .. tostring(earlyVerdict) .. " error=" .. tostring(earlyErr))
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
    lurek.log.info(tostring("mixInto available = " .. tostring(has_fn)))
    lurek.log.info(tostring("mixed 880 Hz into 440 Hz"))

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
    lurek.log.info(tostring("beat clock beat = " .. tostring(clock:getBeat())))
    lurek.log.info(tostring("beat clock bar = " .. tostring(clock:getBar())))
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
    bus:setVolume(0.8)
    bus:setPitch(1.05)
    local peak = bus:getPeak()
    lurek.log.info("bus created name=" .. bus:getName())
    lurek.log.info("bus volume=" .. tostring(bus:getVolume()) .. " pitch=" .. tostring(bus:getPitch()) .. " peak=" .. tostring(peak))
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
    lurek.log.info(tostring("decoder created = " .. tostring(dec ~= nil)))
    lurek.log.info(tostring("sample rate = " .. tostring(dec:getSampleRate())))
    lurek.log.info(tostring("channels = " .. tostring(dec:getChannelCount())))
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
    local voices = pool:getVoiceCount()
    local bus = lurek.audio.newBus("pool_bus")
    pool:setVolume(0.8)
    lurek.log.info("sound pool voices=" .. tostring(voices))
    lurek.log.info("sound pool bus ready=" .. tostring(bus:getName()) .. " volume=" .. tostring(0.8) .. " pool_type=" .. tostring(pool:type()))
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
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    lurek.audio.queueSource(qid, sd)
    local afterQueue = lurek.audio.getFreeBufferCount(qid)
    lurek.log.info("queueable id=" .. tostring(qid) .. " free buffers=" .. tostring(free))
    lurek.log.info("queueable free after one chunk=" .. tostring(afterQueue) .. " queued=" .. tostring(afterQueue < free))
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
    local channels = sd:getChannelCount()
    local duration = sd:getDuration()
    lurek.log.info("sound data created=" .. tostring(sd ~= nil))
    lurek.log.info("sample count=" .. tostring(sd:getSampleCount()) .. " sample rate=" .. tostring(sd:getSampleRate()))
    lurek.log.info("channels=" .. tostring(channels) .. " duration=" .. tostring(duration))
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
    lurek.log.info(tostring("source created = " .. tostring(src ~= nil)))
    lurek.log.info(tostring("path = " .. path))
    lurek.log.info(tostring("source type = " .. tostring(source_type)))
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
    lurek.log.info(tostring("playing before pause = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.audio.pause(src)
    lurek.log.info(tostring("paused = " .. tostring(lurek.audio.isPaused(src))))
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
    lurek.log.info(tostring("all paused"))
    lurek.log.info(tostring("sample source paused = " .. tostring(lurek.audio.isPaused(src))))
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
    lurek.log.info(tostring("play requested for = " .. path))
    lurek.log.info(tostring("playing = " .. tostring(lurek.audio.isPlaying(src))))
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
    lurek.log.info(tostring("playing = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.log.info(tostring("playing+looping = " .. tostring(lurek.audio.isPlaying(src) and lurek.audio.isLooping(src))))
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
    lurek.log.info(tostring("queueable source started"))
    lurek.log.info(tostring("free buffers after play = " .. tostring(lurek.audio.getFreeBufferCount(qid))))
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
    lurek.log.info(tostring("sfx played = " .. tostring(sfx ~= nil)))
    lurek.log.info(tostring("sfx type = " .. sfx:type()))
    lurek.log.info(tostring("volume = " .. tostring(sfx:getVolume())))
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
    lurek.log.info(tostring("free buffers before queue = " .. tostring(before)))
    lurek.log.info(tostring("free buffers after queue = " .. tostring(after)))
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
    lurek.log.info(tostring("source released"))
    lurek.log.info(tostring("source count before release = " .. tostring(before)))
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
    lurek.log.info(tostring("paused before resume = " .. tostring(lurek.audio.isPaused(src))))
    lurek.audio.resume(src)
    lurek.log.info(tostring("playing after resume = " .. tostring(lurek.audio.isPlaying(src))))
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
    lurek.log.info(tostring("all resumed"))
    lurek.log.info(tostring("sample source playing = " .. tostring(lurek.audio.isPlaying(src))))
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
    lurek.log.info(tostring("saveWAV available = " .. tostring(has_fn)))
    lurek.log.info(tostring("saved WAV file"))

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
    lurek.log.info(tostring("seek target = 5.0"))
    lurek.log.info(tostring("position after seek = " .. tostring(lurek.audio.tell(src))))
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
    local inverse = lurek.audio.getDistanceModel()
    lurek.audio.setDistanceModel("inverse_clamped")
    local clamped = lurek.audio.getDistanceModel()
    lurek.log.info("distance model before=" .. tostring(before) .. " inverse=" .. tostring(inverse))
    lurek.log.info("distance model clamped=" .. tostring(clamped))
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
    lurek.log.info(tostring("doppler scale before = " .. tostring(before)))
    lurek.log.info(tostring("doppler scale after = " .. tostring(after)))
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
    lurek.log.info(tostring("highpass set to 2000 Hz"))
    lurek.log.info(tostring("highpass = " .. tostring(lurek.audio.getHighpass(src)) .. " Hz"))
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
    local windows = lurek.audio.getJudgementWindows()
    local perfect = windows.perfect or windows[1]
    local ok = windows.ok or windows[3]
    lurek.log.info("setJudgementWindows perfect=" .. tostring(perfect))
    lurek.log.info("setJudgementWindows ok=" .. tostring(ok))
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
    lurek.audio.setListener(10, 5, 2)
    local x2, y2, z2 = lurek.audio.getListener()
    lurek.log.info("listener3D origin=" .. x .. "," .. y .. "," .. z)
    lurek.log.info("listener3D balcony=" .. x2 .. "," .. y2 .. "," .. z2)
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
    lurek.audio.setListener2D(512, 256)
    local x2, y2 = lurek.audio.getListener2D()
    lurek.log.info("listener2D town square=" .. x .. "," .. y)
    lurek.log.info("listener2D boss arena=" .. x2 .. "," .. y2)
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
    lurek.log.info(tostring("looping before = " .. tostring(lurek.audio.isLooping(src))))
    lurek.audio.setLooping(src, true)
    lurek.log.info(tostring("looping after = " .. tostring(lurek.audio.isLooping(src))))
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
    lurek.log.info(tostring("lowpass set to 800 Hz"))
    lurek.log.info(tostring("lowpass = " .. tostring(lurek.audio.getLowpass(src)) .. " Hz"))
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
    local quieter = lurek.audio.getMasterVolume()
    lurek.audio.setMasterVolume(1.0)
    local restored = lurek.audio.getMasterVolume()
    lurek.log.info("master volume before=" .. tostring(before) .. " quieter=" .. tostring(quieter))
    lurek.log.info("master volume restored=" .. tostring(restored))
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
    local after = lurek.audio.getMeter()
    lurek.audio.setMeter(0.25)
    local quieter = lurek.audio.getMeter()
    lurek.log.info("meter before=" .. tostring(before) .. " after=" .. tostring(after))
    lurek.log.info("meter quieter mix=" .. tostring(quieter))
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
    local wasMuted = lurek.audio.isMuted()
    lurek.audio.setMuted(true)
    local pauseMenuMuted = lurek.audio.isMuted()
    lurek.audio.setMuted(false)
    local restored = not lurek.audio.isMuted()
    lurek.log.info("audio muted before pause menu=" .. tostring(wasMuted))
    lurek.log.info("audio muted in pause menu=" .. tostring(pauseMenuMuted) .. " restored=" .. tostring(restored))
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
    lurek.log.info(tostring("orientation applied"))
    lurek.log.info(tostring("forward = " .. fx .. ", " .. fy .. ", " .. fz))
    lurek.log.info(tostring("up = " .. ux .. ", " .. uy .. ", " .. uz))
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
    lurek.log.info(tostring("pan before = " .. tostring(lurek.audio.getPan(src))))
    lurek.audio.setPan(src, -0.5)
    lurek.log.info(tostring("pan after = " .. tostring(lurek.audio.getPan(src))))
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
    lurek.log.info(tostring("pitch before = " .. tostring(lurek.audio.getPitch(src))))
    lurek.audio.setPitch(src, 1.5)
    lurek.log.info(tostring("pitch after = " .. tostring(lurek.audio.getPitch(src))))
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
    lurek.log.info(tostring("requested device = " .. tostring(name)))
    lurek.log.info(tostring("active device = " .. tostring(lurek.audio.getPlaybackDevice())))
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
    lurek.log.info(tostring("source positioned for spatial playback"))
    lurek.log.info(tostring("source pos = " .. x .. ", " .. y .. ", " .. z))
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
    lurek.log.info(tostring("random pitch range = 0.9 to 1.1"))
    lurek.log.info(tostring("source ready for varied playback"))
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
    lurek.log.info(tostring("bus assigned = " .. tostring(assigned ~= nil)))
    lurek.log.info(tostring("bus = " .. assigned:getName()))
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
    lurek.log.info(tostring("configured stereo width = 0.5"))
    lurek.log.info(tostring("stereo width = " .. tostring(lurek.audio.getStereoWidth(src))))
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
    lurek.log.info(tostring("source velocity set for doppler"))
    lurek.log.info(tostring("velocity = " .. vx .. ", " .. vy .. ", " .. vz))
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
    lurek.log.info(tostring("volume before = " .. tostring(lurek.audio.getVolume(src))))
    lurek.audio.setVolume(src, 0.5)
    lurek.log.info(tostring("volume after = " .. tostring(lurek.audio.getVolume(src))))
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
    local peak = lurek.audio.getBusPeak("music_bus")
    local rms = lurek.audio.getBusRms("music_bus")
    lurek.log.info("configured music_bus volume=0.7")
    lurek.log.info("music_bus peak=" .. tostring(peak) .. " rms=" .. tostring(rms) .. " has_bus=" .. tostring(true))
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
    lurek.log.info(tostring("before stop playing = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.audio.stop(src)
    lurek.log.info(tostring("stopped = " .. tostring(lurek.audio.isStopped(src))))
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
    lurek.log.info(tostring("all stopped"))
    lurek.log.info(tostring("sample source stopped = " .. tostring(lurek.audio.isStopped(src))))
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
    lurek.log.info(tostring("music playing = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.audio.stopMusic(0.5)
    lurek.log.info(tostring("music stopped with fade"))
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
    local sd = lurek.audio.newSoundData(1024, 44100, 1)
    lurek.audio.queueSource(qid, sd)
    lurek.audio.playQueueable(qid)
    lurek.audio.stopQueueable(qid)
    local free = lurek.audio.getFreeBufferCount(qid)
    lurek.log.info("queueable source stopped")
    lurek.log.info("queueable free buffers after stop=" .. tostring(free) .. " restored=" .. tostring(free == 4))
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
    lurek.log.info(tostring("playing = " .. tostring(lurek.audio.isPlaying(src))))
    lurek.log.info(tostring("position = " .. tostring(pos)))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LBeatClock](#lbeatclock)
- [LBus](#lbus)
- [LDecoder](#ldecoder)
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
    local chorusCue = 0
    local at_h = clock:at(1.0, function(beat) chorusCue = beat end)
    clock:start()
    clock:update(1.1)
    lurek.log.info("cue at handle=" .. tostring(at_h ~= nil))
    lurek.log.info("cue triggered beat=" .. tostring(chorusCue))
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
    clock:start()
    clock:tick(0.125)
    local eighth = clock:beatTimeRemaining(8)
    local quarter = clock:beatTimeRemaining(4)
    lurek.log.info("beat time remaining eighth=" .. tostring(eighth))
    lurek.log.info("beat time remaining quarter=" .. tostring(quarter))
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
    clock:setBeatsPerBar(3)
    local barLen = clock:beatsPerBar()
    clock:start()
    clock:tick(1.1)
    lurek.log.info("waltz beatsPerBar=" .. tostring(barLen))
    lurek.log.info("waltz bar position=" .. tostring(clock:getBar()))
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
    clock:setBpm(140.0)
    local bpm = clock:bpm()
    local spb = clock:secondsPerBeat()
    lurek.log.info("boss section bpm=" .. tostring(bpm))
    lurek.log.info("boss section secondsPerBeat=" .. tostring(spb))
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
    clock:start()
    local events = clock:update(1.1)
    lurek.log.info("cancel returned=" .. tostring(cancelled))
    lurek.log.info("cancel update events=" .. tostring(#events))
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
    clock:pattern("x.x.", function() end)
    clock:cancelAll()
    clock:start()
    local events = clock:update(1.1)
    lurek.log.info("cancelAll ok")
    lurek.log.info("cancelAll update events=" .. tostring(#events))
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
    clock:scheduleAt(1.0)
    clock:tick(0.6)
    clock:tick(0.6)
    local fired = clock:drainFired()
    lurek.log.info(tostring("drainFired count = " .. tostring(#fired)))
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
    clock:start()
    local snap = clock:dump()
    local beat = snap.beat or snap.current_beat or 0
    local running = snap.running or false
    lurek.log.info("clock dump type=" .. type(snap))
    lurek.log.info("clock dump beat=" .. tostring(beat) .. " running=" .. tostring(running))
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
    local hits = 0
    local every_h = clock:every(4, function() hits = hits + 1 end)
    clock:start()
    clock:update(1.1)
    lurek.log.info("metronome every handle=" .. tostring(every_h ~= nil))
    lurek.log.info("metronome quarter hits=" .. tostring(hits))
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
    clock:start()
    clock:tick(1.1)
    local bar = clock:getBar()
    local beat = clock:getBeat()
    lurek.log.info("bar position=" .. tostring(bar))
    lurek.log.info("bar companion beat=" .. tostring(beat))
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
    clock:start()
    clock:tick(0.75)
    local beat = clock:getBeat()
    local phase = clock:getPhase(4)
    lurek.log.info("beat position=" .. tostring(beat))
    lurek.log.info("beat phase quarter=" .. tostring(phase))
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
    clock:setBpm(128.0)
    local bpm = clock:getBpm()
    local spb = clock:secondsPerBeat()
    lurek.log.info("getBpm=" .. tostring(bpm))
    lurek.log.info("getBpm secondsPerBeat=" .. tostring(spb))
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
    clock:start()
    clock:tick(0.125)
    local eighth = clock:getPhase(8)
    local quarter = clock:getPhase(4)
    lurek.log.info("phase eighth=" .. tostring(eighth))
    lurek.log.info("phase quarter=" .. tostring(quarter))
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
    clock:start()
    clock:tick(0.5)
    local onBeat = clock:isOnBeat()
    local tight = clock:isOnBeat(4, 0.02)
    lurek.log.info("isOnBeat default=" .. tostring(onBeat))
    lurek.log.info("isOnBeat tight=" .. tostring(tight))
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
    clock:start()
    local running = clock:isRunning()
    clock:stop()
    local stopped = clock:isRunning()
    lurek.log.info("clock running after start=" .. tostring(running))
    lurek.log.info("clock running after stop=" .. tostring(stopped))
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
    clock:start()
    clock:tick(0.2)
    local beat, err = clock:nearestBeat(4)
    lurek.log.info(tostring("nearestBeat = " .. tostring(beat) .. " err = " .. tostring(err)))
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
    local steps = {}
    local pattern_h = clock:pattern("x.x.", function(step) steps[#steps + 1] = step end)
    clock:start()
    clock:update(2.1)
    lurek.log.info("snare pattern handle=" .. tostring(pattern_h ~= nil))
    lurek.log.info("snare pattern fired=" .. tostring(#steps))
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
    clock:start()
    clock:tick(0.5)
    local pos = clock:position()
    lurek.log.info(tostring("position beat = " .. tostring(pos.beat) .. " bar = " .. tostring(pos.bar)))
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
    local q = clock:quantise(1.3, 0.25)
    local q2 = clock:quantise(2.62, 0.5)
    lurek.log.info("quantise(1.3, 0.25)=" .. tostring(q))
    lurek.log.info("quantise(2.62, 0.5)=" .. tostring(q2))
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
    clock:rampBpm(150.0, 0.5)
    clock:update(0.5)
    local afterRamp = clock:getBpm()
    local spb = clock:secondsPerBeat()
    lurek.log.info("bpm after ramp=" .. tostring(afterRamp))
    lurek.log.info("secondsPerBeat after ramp=" .. tostring(spb))
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
    clock:start()
    clock:tick(1.0)
    clock:reset()
    lurek.log.info(tostring("beat after reset = " .. tostring(clock:getBeat())))
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
    local ok = clock:scheduleAt(2.0)
    clock:start()
    clock:tick(1.1)
    local fired = clock:drainFired()
    lurek.log.info("scheduleAt ok=" .. tostring(ok))
    lurek.log.info("scheduleAt fired count=" .. tostring(#fired))
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
    local spb = clock:secondsPerBeat()
    local twoBeats = spb * 2
    lurek.log.info("secondsPerBeat=" .. tostring(spb))
    lurek.log.info("seconds for two beats=" .. tostring(twoBeats))
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
    clock:start()
    clock:tick(0.125)
    local nextBeat = clock:secondsToNextBeat()
    local remain = clock:beatTimeRemaining(4)
    lurek.log.info("secondsToNextBeat=" .. tostring(nextBeat))
    lurek.log.info("quarter remaining=" .. tostring(remain))
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
    clock:setBeatsPerBar(3)
    local beats = clock:beatsPerBar()
    clock:start()
    clock:tick(1.6)
    lurek.log.info("setBeatsPerBar now=" .. tostring(beats))
    lurek.log.info("setBeatsPerBar bar=" .. tostring(clock:getBar()))
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
    clock:setBpm(90.0)
    local bpm = clock:getBpm()
    local spb = clock:secondsPerBeat()
    lurek.log.info("setBpm new bpm=" .. tostring(bpm))
    lurek.log.info("setBpm secondsPerBeat=" .. tostring(spb))
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
    clock:setSwing(0.2)
    clock:start()
    clock:update(0.25)
    lurek.log.info(tostring("phase after swing = " .. tostring(clock:getPhase(8))))
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
    clock:start()
    local running = clock:isRunning()
    clock:tick(0.5)
    lurek.log.info("start running=" .. tostring(running))
    lurek.log.info("start beat after tick=" .. tostring(clock:getBeat()))
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
    clock:start()
    clock:stop()
    local running = clock:isRunning()
    local beat = clock:getBeat()
    lurek.log.info("stop running=" .. tostring(running))
    lurek.log.info("stop preserved beat=" .. tostring(beat))
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
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    lurek.audio.play(src)
    local clock = lurek.audio.newBeatClock(120.0, 4)
    clock:syncToSource(src)
    lurek.log.info(tostring("synced beat = " .. tostring(clock:getBeat())))
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
    local first = clock:tap(0.0)
    local second = clock:tap(0.5)
    local third = clock:tap(1.0)
    lurek.log.info("tap bpm first=" .. tostring(first) .. " second=" .. tostring(second))
    lurek.log.info("tap bpm third=" .. tostring(third))
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
    clock:start()
    local crossings = clock:tick(0.5)
    local beat = clock:getBeat()
    lurek.log.info("tick crossings=" .. tostring(#crossings))
    lurek.log.info("tick beat=" .. tostring(beat))
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
    local bpm = clock:getBpm()
    local beat = clock:getBeat()
    lurek.log.info("clock type=" .. tostring(clock:type()))
    lurek.log.info("clock is object=" .. tostring(clock:typeOf("LBeatClock")) .. " bpm=" .. tostring(bpm) .. " beat=" .. tostring(beat))
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
    local running = clock:isRunning()
    local bpm = clock:getBpm()
    lurek.log.info("typeOf LBeatClock=" .. tostring(clock:typeOf("LBeatClock")))
    lurek.log.info("type=" .. tostring(clock:type()) .. " running=" .. tostring(running) .. " bpm=" .. tostring(bpm))
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
    clock:start()
    local events = clock:update(0.5)
    local beat = clock:getBeat()
    lurek.log.info("update events=" .. tostring(#events))
    lurek.log.info("update beat=" .. tostring(beat))
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
    local wasBus = bus:typeOf("LBus")
    bus:clearDuck()
    local narratorName = bus:getName()
    lurek.log.info("duck cleared for=" .. tostring(narratorName))
    lurek.log.info("narrator is bus=" .. tostring(wasBus))
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
    local name = bus:getName()
    local typeName = bus:type()
    lurek.log.info("bus name=" .. tostring(name))
    lurek.log.info("bus type=" .. tostring(typeName))
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
    bus:setVolume(0.75)
    local peak = bus:getPeak()
    local name = bus:getName()
    lurek.log.info("meter bus=" .. tostring(name))
    lurek.log.info("peak=" .. tostring(peak) .. " volume=" .. tostring(bus:getVolume()))
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
    local rainyPitch = bus:getPitch()
    bus:setPitch(1.05)
    local clearPitch = bus:getPitch()
    lurek.log.info("ambient bus rainy pitch=" .. tostring(rainyPitch))
    lurek.log.info("ambient bus clear pitch=" .. tostring(clearPitch))
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
    local chapterVolume = bus:getVolume()
    bus:setVolume(0.55)
    local duckedVolume = bus:getVolume()
    lurek.log.info("music bus chapter volume=" .. tostring(chapterVolume))
    lurek.log.info("music bus ducked volume=" .. tostring(duckedVolume))
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
    local paused = bus:isPaused()
    bus:resume()
    lurek.log.info("bus paused flag=" .. tostring(paused))
    lurek.log.info("bus paused after resume=" .. tostring(bus:isPaused()))
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
    local paused = bus:isPaused()
    bus:resume()
    lurek.log.info("bus paused=" .. tostring(paused))
    lurek.log.info("bus resumed=" .. tostring(not bus:isPaused()))
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
    local resumed = not bus:isPaused()
    local peak = bus:getPeak()
    lurek.log.info("bus resumed=" .. tostring(resumed))
    lurek.log.info("bus peak after resume=" .. tostring(peak))
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
    music:setVolume(0.8)
    voice:setDuckTarget("bg_music", 0.3)
    local voiceType = voice:type()
    local musicVolume = music:getVolume()
    lurek.log.info("voice bus type=" .. tostring(voiceType))
    lurek.log.info("bg_music keeps base volume=" .. tostring(musicVolume))
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
    local high = bus:getPitch()
    bus:setPitch(0.8)
    lurek.log.info("bus pitch high=" .. tostring(high))
    lurek.log.info("bus pitch low=" .. tostring(bus:getPitch()))
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
    local low = bus:getVolume()
    bus:setVolume(0.9)
    lurek.log.info("bus volume low=" .. tostring(low))
    lurek.log.info("bus volume high=" .. tostring(bus:getVolume()))
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
    local typeName = bus:type()
    local isBus = bus:typeOf("LBus")
    lurek.log.info("bus type=" .. tostring(typeName))
    lurek.log.info("bus typeOf LBus=" .. tostring(isBus))
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
    local isBus = bus:typeOf("LBus")
    local typeName = bus:type()
    lurek.log.info("bus typeOf LBus=" .. tostring(isBus))
    lurek.log.info("bus type=" .. tostring(typeName))
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
    local sampleCount = chunk and chunk:getSampleCount() or 0
    local sampleRate = dec:getSampleRate()
    local seekable = dec:isSeekable()
    lurek.log.info("decoded chunk present=" .. tostring(chunk ~= nil))
    lurek.log.info("chunk samples=" .. tostring(sampleCount) .. " rate=" .. tostring(sampleRate) .. " seekable=" .. tostring(seekable))
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
    local bitDepth = dec:getBitDepth()
    local channels = dec:getChannelCount()
    local duration = dec:getDuration()
    lurek.log.info("loop bit depth=" .. tostring(bitDepth))
    lurek.log.info("loop channels=" .. tostring(channels) .. " duration=" .. tostring(duration))
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
    local channels = dec:getChannelCount()
    local bitDepth = dec:getBitDepth()
    local sampleRate = dec:getSampleRate()
    lurek.log.info("decoder channels=" .. tostring(channels))
    lurek.log.info("decoder bitDepth=" .. tostring(bitDepth) .. " sampleRate=" .. tostring(sampleRate))
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
    local duration = dec:getDuration()
    local sampleRate = dec:getSampleRate()
    local bitDepth = dec:getBitDepth()
    lurek.log.info("loop duration=" .. tostring(duration))
    lurek.log.info("loop sample rate=" .. tostring(sampleRate) .. " bitDepth=" .. tostring(bitDepth))
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
    local sampleRate = dec:getSampleRate()
    local duration = dec:getDuration()
    local channels = dec:getChannelCount()
    lurek.log.info("decoded sample rate=" .. tostring(sampleRate))
    lurek.log.info("decoded duration=" .. tostring(duration) .. " channels=" .. tostring(channels))
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
    local seekable = dec:isSeekable()
    dec:seek(1.0)
    local position = dec:tell()
    lurek.log.info("decoder seekable=" .. tostring(seekable))
    lurek.log.info("position after editor seek=" .. tostring(position))
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
    local duration = dec:getDuration()
    local seekable = dec:isSeekable()
    dec:release()
    local typeName = dec:type()
    lurek.log.info("released decoder duration=" .. tostring(duration))
    lurek.log.info("decoder seekable=" .. tostring(seekable) .. " type=" .. tostring(typeName))
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
    lurek.log.info(tostring("rewound to " .. dec:tell()))
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
    local canSeek = dec:isSeekable()
    dec:seek(2.5)
    local position = dec:tell()
    local duration = dec:getDuration()
    lurek.log.info("decoder seekable=" .. tostring(canSeek))
    lurek.log.info("preview cursor=" .. tostring(position) .. " duration=" .. tostring(duration))
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
    lurek.log.info(tostring("position = " .. pos))
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
    local typeName = dec:type()
    local isDecoder = dec:typeOf("LDecoder")
    local sampleRate = dec:getSampleRate()
    lurek.log.info("decoder type=" .. tostring(typeName))
    lurek.log.info("is decoder=" .. tostring(isDecoder) .. " sampleRate=" .. tostring(sampleRate))
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
    local isDecoder = dec:typeOf("LDecoder")
    local isObject = dec:typeOf("LObject")
    local typeName = dec:type()
    lurek.log.info("is LDecoder=" .. tostring(isDecoder))
    lurek.log.info("is LObject=" .. tostring(isObject) .. " type=" .. tostring(typeName))
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
    lurek.log.info(tostring("waveform drawn to image"))

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
    local bitDepth = sd:getBitDepth()
    local channels = sd:getChannelCount()
    local sampleRate = sd:getSampleRate()
    lurek.log.info("buffer bit depth=" .. tostring(bitDepth))
    lurek.log.info("buffer channels=" .. tostring(channels) .. " rate=" .. tostring(sampleRate))
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
    local channels = sd:getChannelCount()
    local sampleRate = sd:getSampleRate()
    local duration = sd:getDuration()
    lurek.log.info("stereo buffer channels=" .. tostring(channels))
    lurek.log.info("stereo buffer rate=" .. tostring(sampleRate) .. " duration=" .. tostring(duration))
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
    local duration = sd:getDuration()
    local sampleCount = sd:getSampleCount()
    local sampleRate = sd:getSampleRate()
    lurek.log.info("tone buffer duration=" .. tostring(duration))
    lurek.log.info("tone buffer samples=" .. tostring(sampleCount) .. " rate=" .. tostring(sampleRate))
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
    sd:setSample(1, -0.5)
    local firstSample = sd:getSample(0)
    local secondSample = sd:getSample(1)
    lurek.log.info("attack sample=" .. tostring(firstSample))
    lurek.log.info("release sample=" .. tostring(secondSample))
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
    local sampleCount = sd:getSampleCount()
    local duration = sd:getDuration()
    local sampleRate = sd:getSampleRate()
    lurek.log.info("procedural buffer samples=" .. tostring(sampleCount))
    lurek.log.info("procedural buffer duration=" .. tostring(duration) .. " rate=" .. tostring(sampleRate))
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
    local sampleRate = sd:getSampleRate()
    local duration = sd:getDuration()
    local sampleCount = sd:getSampleCount()
    lurek.log.info("voice line sample rate=" .. tostring(sampleRate))
    lurek.log.info("voice line duration=" .. tostring(duration) .. " samples=" .. tostring(sampleCount))
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
    local startSample = sd:getSample(0)
    local midSample = sd:getSample(50)
    lurek.log.info("start sample=" .. tostring(startSample))
    lurek.log.info("mid sample=" .. tostring(midSample))
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
    local typeName = sd:type()
    local isSoundData = sd:typeOf("LSoundData")
    local isObject = sd:typeOf("LObject")
    lurek.log.info("sound data type=" .. tostring(typeName))
    lurek.log.info("is sound data=" .. tostring(isSoundData) .. " is object=" .. tostring(isObject))
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
    local isSoundData = sd:typeOf("LSoundData")
    local isDecoder = sd:typeOf("LDecoder")
    local typeName = sd:type()
    lurek.log.info("is LSoundData=" .. tostring(isSoundData))
    lurek.log.info("is LDecoder=" .. tostring(isDecoder) .. " type=" .. tostring(typeName))
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
    local reservedVoices = pool:getVoiceCount()
    local firstVoice = pool:play()
    local secondVoice = pool:play()
    lurek.log.info("pool reserved voices=" .. tostring(reservedVoices))
    lurek.log.info("first two voice ids=" .. tostring(firstVoice) .. "," .. tostring(secondVoice))
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
    pool:setVolume(0.7)
    local firstVoice = pool:play()
    local secondVoice = pool:play()
    lurek.log.info("ui click pool first voice=" .. tostring(firstVoice))
    lurek.log.info("ui click pool second voice=" .. tostring(secondVoice))
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
    local firstVoice = pool:play()
    local voiceCount = pool:getVoiceCount()
    pool:release()
    local typeName = pool:type()
    lurek.log.info("released pool after voice=" .. tostring(firstVoice))
    lurek.log.info("pool voices=" .. tostring(voiceCount) .. " type=" .. tostring(typeName))
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
    lurek.log.info(tostring("pool routed to pool_bus"))
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
    local quietVoice = pool:play()
    pool:setVolume(0.9)
    local loudVoice = pool:play()
    lurek.log.info("quiet click voice=" .. tostring(quietVoice))
    lurek.log.info("loud click voice=" .. tostring(loudVoice))
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
    lurek.log.info(tostring("all voices stopped"))
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
    local typeName = pool:type()
    local voiceCount = pool:getVoiceCount()
    local isPool = pool:typeOf("LSoundPool")
    lurek.log.info("sound pool type=" .. tostring(typeName))
    lurek.log.info("voice count=" .. tostring(voiceCount) .. " is pool=" .. tostring(isPool))
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
    local isPool = pool:typeOf("LSoundPool")
    local isObject = pool:typeOf("LObject")
    local typeName = pool:type()
    lurek.log.info("is LSoundPool=" .. tostring(isPool))
    lurek.log.info("is LObject=" .. tostring(isObject) .. " type=" .. tostring(typeName))
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
    lurek.log.info(tostring("filters cleared"))
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
    lurek.log.info(tostring("clone volume = " .. copy:getVolume()))
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
    local fade = src:getFadeIn()
    src:play()
    lurek.log.info("source fade in=" .. tostring(fade) .. "s")
    lurek.log.info("source playing after fade request=" .. tostring(src:isPlaying()))
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
    local sourceKind = src:getType()
    lurek.log.info("source duration=" .. tostring(dur) .. "s")
    lurek.log.info("source kind=" .. tostring(sourceKind))
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
    lurek.log.info(tostring("fade in = " .. fi))
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
    lurek.log.info(tostring("highpass = " .. hp))
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
    lurek.log.info(tostring("lowpass = " .. lp))
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
    lurek.log.info(tostring("pan = " .. pan))
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
    lurek.log.info(tostring("pitch = " .. p))
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
    local sourceKind = src:getType()
    local typeName = src:type()
    lurek.log.info("source getType=" .. tostring(sourceKind))
    lurek.log.info("source userdata type=" .. tostring(typeName))
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
    lurek.log.info(tostring("volume = " .. v))
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
    local looping = src:isLooping()
    local sourceType = src:getType()
    lurek.log.info("source isLooping=" .. tostring(looping))
    lurek.log.info("source type=" .. tostring(sourceType))
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
    lurek.log.info(tostring("paused = " .. tostring(src:isPaused())))
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
    local playing = src:isPlaying()
    local stopped = src:isStopped()
    lurek.log.info("source isPlaying=" .. tostring(playing))
    lurek.log.info("source isStopped while playing=" .. tostring(stopped))
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
    local stoppedBefore = src:isStopped()
    src:play()
    src:stop()
    local stoppedAfter = src:isStopped()
    lurek.log.info("source stopped before play=" .. tostring(stoppedBefore))
    lurek.log.info("source stopped after stop=" .. tostring(stoppedAfter))
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
    lurek.log.info(tostring("paused = " .. tostring(src:isPaused())))
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
    local playing = src:isPlaying()
    local stopped = src:isStopped()
    lurek.log.info("source play via method=" .. tostring(playing))
    lurek.log.info("source stopped after play=" .. tostring(stopped))
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
    lurek.log.info(tostring("resumed = " .. tostring(src:isPlaying())))
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
    lurek.log.info(tostring("seeked to " .. src:tell()))
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
    local high = src:getHighpass()
    src:setHighpass(3000)
    lurek.log.info("source highpass light=" .. tostring(high))
    lurek.log.info("source highpass heavy=" .. tostring(src:getHighpass()))
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
    local looping = src:isLooping()
    src:setLooping(false)
    lurek.log.info("source looping enabled=" .. tostring(looping))
    lurek.log.info("source looping disabled=" .. tostring(src:isLooping()))
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
    local low = src:getLowpass()
    src:setLowpass(1200)
    lurek.log.info("source lowpass narrow=" .. tostring(low))
    lurek.log.info("source lowpass wide=" .. tostring(src:getLowpass()))
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
    local left = src:getPan()
    src:setPan(0.8)
    lurek.log.info("source pan left=" .. tostring(left))
    lurek.log.info("source pan right=" .. tostring(src:getPan()))
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
    local pitch = src:getPitch()
    src:setPitch(0.75)
    lurek.log.info("source pitch fast=" .. tostring(pitch))
    lurek.log.info("source pitch slow=" .. tostring(src:getPitch()))
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
    local volume = src:getVolume()
    src:setVolume(0.8)
    lurek.log.info("source volume low=" .. tostring(volume))
    lurek.log.info("source volume high=" .. tostring(src:getVolume()))
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
    lurek.log.info(tostring("stopped = " .. tostring(src:isStopped())))
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
    lurek.log.info(tostring("position = " .. pos))
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
    local typeName = src:type()
    local sourceKind = src:getType()
    lurek.log.info("source type=" .. tostring(typeName))
    lurek.log.info("source kind=" .. tostring(sourceKind))
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
    local isSource = src:typeOf("LSource")
    local typeName = src:type()
    lurek.log.info("source typeOf LSource=" .. tostring(isSource))
    lurek.log.info("source type=" .. tostring(typeName))
end
```

---
