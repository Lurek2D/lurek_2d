# Audio

- The `audio` module provides a comprehensive, high-performance sound engine for Lurek2D, built on top of `rodio` and positioned within the Platform Services tier.

It manages the entire audio lifecycle, including loading, real-time playback, bus mixing, DSP effects, spatial 2D audio, MIDI synthesis, and offline processing. At the core of the module is the `Mixer`, which serves as the central registry for all audio operations. It utilizes a highly efficient `SlotMap` to provide O(1) handle lookups for `AudioEntry` records, ensuring that the engine can effortlessly manage hundreds of concurrent sound instances. Audio sources can be loaded as fully decoded `Static` in-memory buffers for zero-latency sound effects, or as `Stream` sources for memory-efficient incremental decoding of longer music and voice tracks.

A standout feature of the `audio` module is its advanced `Bus` routing system. It supports hierarchical audio buses—such as Master, SFX, Music, and Voice—each equipped with its own volume, pitch, pause state, and dynamic `EffectChain`. The DSP effect system provides a rich suite of audio filters, including low-pass, high-pass, biquad EQ, reverb, chorus, flanger, phaser, distortion, limiter, and compressor. These effects operate using lock-free atomic parameters, allowing Lua scripts to modulate audio parameters dynamically without blocking the audio thread. Additionally, buses support automatic ducking, meaning a 'Voice' bus can automatically suppress the volume of a 'Music' bus when active.

For environmental immersion, the module includes a robust spatial audio system. It tracks the 3D position, velocity, and orientation of both the listener and individual audio sources. This enables realistic distance attenuation (using configurable drop-off models), stereo panning, and accurate Doppler shift effects based on relative velocities. Furthermore, to prevent audio stuttering during intense scenes, the `SoundPool` implements a round-robin polyphonic voice pool with intelligent voice stealing for one-shot playback of heavily reused assets like footsteps or weapon fire.

Beyond standard PCM playback, the module natively supports MIDI file playback via a built-in software synthesizer. The `MidiPlayer` translates MIDI note events into PCM audio using loaded SoundFont data, offering complete transport controls, per-channel muting, and instrument assignment. Finally, an `offline` processing suite allows developers to apply DSP effect chains or perform peak normalization on audio files directly to disk without requiring real-time playback, which is invaluable for asset pipelining. The entire feature set is cleanly exposed to Lua through the `lurek.audio.*` namespace, giving script developers full control over sound design and dynamic mixing.

## Functions

### `lurek.audio.clearFilter`

Removes all frequency filters from a source.

```lua
-- signature
lurek.audio.clearFilter(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

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
-- signature
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
-- signature
lurek.audio.clearRandomPitch(src_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | `LSource` | The audio source to reset. |

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
-- signature
lurek.audio.clone(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID to clone. |

**Returns**

| Type | Description |
|------|-------------|
| `LSource` | A new source instance with identical settings. |

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
-- signature
lurek.audio.create_bus(name, parent_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name for the new bus. |
| `parent_name?` | `string` | Name of the parent bus, or nil for a root bus. |

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
-- signature
lurek.audio.crossfade(from_ud, to_ud, duration)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_ud` | `LSource` | The source to fade out. |
| `to_ud` | `LSource` | The source to fade in. |
| `duration` | `number` | Crossfade duration in seconds. |

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
-- signature
lurek.audio.fadeIn(source, dur)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `dur` | `number` | Fade-in duration in seconds. |

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
-- signature
lurek.audio.getActiveSourceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of active (playing) sources. |

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
-- signature
lurek.audio.getBusPeak(bus_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bus_name` | `string` | Name of the audio bus to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Peak amplitude in the range [0.0, 1.0+]. |

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
-- signature
lurek.audio.getBusRms(bus_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bus_name` | `string` | Name of the audio bus to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | RMS amplitude in the range [0.0, 1.0+]. |

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
-- signature
lurek.audio.getDistanceModel()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Distance model name. |

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
-- signature
lurek.audio.getDopplerScale()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Doppler scale factor. |

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
-- signature
lurek.audio.getDuration(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Duration in seconds. |

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
-- signature
lurek.audio.getFadeIn(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Fade-in duration in seconds. |

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
-- signature
lurek.audio.getFreeBufferCount(qsource_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qsource_id` | `number` | Queueable source handle returned by `newQueueableSource`. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of free buffer slots available for queuing. |

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
-- signature
lurek.audio.getHighpass(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cutoff frequency in Hz, or 0 if not set. |

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

### `lurek.audio.getListener`

Returns the current 3D listener position.

```lua
-- signature
lurek.audio.getListener()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X, Y, and Z position of the listener. |
| `number` | b X, Y, and Z position of the listener. |
| `number` | c X, Y, and Z position of the listener. |

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
-- signature
lurek.audio.getListener2D()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X and Y position of the listener. |
| `number` | b X and Y position of the listener. |

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
-- signature
lurek.audio.getLowpass(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cutoff frequency in Hz, or 0 if not set. |

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
-- signature
lurek.audio.getMasterVolume()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Master volume multiplier. |

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
-- signature
lurek.audio.getMaxSources()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Maximum source count (64). |

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
-- signature
lurek.audio.getMeter()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Peak level from 0.0 to 1.0. |

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
-- signature
lurek.audio.getOrientation(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Forward (fx,fy,fz) and up (ux,uy,uz) vectors. |
| `number` | b Forward (fx,fy,fz) and up (ux,uy,uz) vectors. |
| `number` | c Forward (fx,fy,fz) and up (ux,uy,uz) vectors. |
| `number` | d Forward (fx,fy,fz) and up (ux,uy,uz) vectors. |
| `number` | e Forward (fx,fy,fz) and up (ux,uy,uz) vectors. |
| `number` | f Forward (fx,fy,fz) and up (ux,uy,uz) vectors. |

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
-- signature
lurek.audio.getPan(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Pan value from -1.0 (left) to 1.0 (right). |

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
-- signature
lurek.audio.getPitch(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current pitch multiplier. |

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
-- signature
lurek.audio.getPlaybackDevice()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current playback device name. |

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
-- signature
lurek.audio.getPlaybackDevices()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Device name strings. |

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
-- signature
lurek.audio.getPosition(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X, Y, and Z position. |
| `number` | b X, Y, and Z position. |
| `number` | c X, Y, and Z position. |

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
-- signature
lurek.audio.getSourceBus(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `LBus` | The assigned bus, or nil if using direct output. |

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
-- signature
lurek.audio.getSourceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Total source count. |

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
-- signature
lurek.audio.getSourceType(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Either "static" or "stream". |

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
-- signature
lurek.audio.getStereoWidth(src_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | `LSource` | The audio source to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Stereo width factor (0.0 = mono, 1.0 = full stereo). |

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
-- signature
lurek.audio.getVelocity(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a X, Y, and Z velocity components. |
| `number` | b X, Y, and Z velocity components. |
| `number` | c X, Y, and Z velocity components. |

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
-- signature
lurek.audio.getVolume(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current volume multiplier. |

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
-- signature
lurek.audio.hasMidiSoundFont()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a SoundFont is loaded. |

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
-- signature
lurek.audio.isLooping(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if looping is enabled. |

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

### `lurek.audio.isPaused`

Returns whether a source is currently paused.

```lua
-- signature
lurek.audio.isPaused(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the source is paused. |

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
-- signature
lurek.audio.isPlaying(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the source is playing. |

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
-- signature
lurek.audio.isStopped(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the source is stopped. |

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

### `lurek.audio.mixInto`

Mixes the samples of `src` into `dest` in-place (both must have the same format).

```lua
-- signature
lurek.audio.mixInto(dest_ud, src_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dest_ud` | `LSoundData` | Destination sound data to mix into. |
| `src_ud` | `LSoundData` | Source sound data to mix from. |

**Example**

```lua
do
    local dest = lurek.audio.newSineWave(440, 1.0, 44100, 0.5)
    local src = lurek.audio.newSineWave(880, 1.0, 44100, 0.3)
    lurek.audio.mixInto(dest, src)
    print("mixed 880 Hz into 440 Hz")
end
```

---

### `lurek.audio.newBus`

Creates a new audio mixing bus for grouping and controlling sources.

```lua
-- signature
lurek.audio.newBus(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name for the bus (e.g. "music", "sfx"). |

**Returns**

| Type | Description |
|------|-------------|
| `LBus` | The new audio bus handle. |

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
-- signature
lurek.audio.newDecoder(source, buffersize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `string` | Relative path to the audio file (WAV, OGG, MP3, or FLAC). |
| `buffersize?` | `number` | Number of samples per decode chunk; defaults to 2048. |

**Returns**

| Type | Description |
|------|-------------|
| `LDecoder` | A streaming decoder with `decode`, `seek`, `rewind`, and `getSampleRate` methods. |

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
-- signature
lurek.audio.newMidiPlayer(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path?` | `string` | Optional relative path to a .mid file to load. |

**Returns**

| Type | Description |
|------|-------------|
| `LMidiPlayer` | A new MIDI player ready for playback. |

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
-- signature
lurek.audio.newPool(file_path, voice_count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `file_path` | `string` | Relative path to the audio file shared by all voices in the pool. |
| `voice_count` | `number` | Number of concurrent voices to pre-allocate. |

**Returns**

| Type | Description |
|------|-------------|
| `LSoundPool` | A sound pool with `play`, `stopAll`, `setVolume`, `release`, and `getVoiceCount` methods. |

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
-- signature
lurek.audio.newQueueableSource(sample_rate, bit_depth, channels, buffer_count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sample_rate` | `number` | Sample rate in Hz (e.g. 44100). |
| `bit_depth` | `number` | Bit depth per sample (8 or 16). |
| `channels` | `number` | Channel count (1 = mono, 2 = stereo). |
| `buffer_count?` | `number` | Number of internal buffers to pre-allocate; defaults to 4. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | An opaque integer handle for use with `queueSource`, `playQueueable`, and `stopQueueable`. |

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
-- signature
lurek.audio.newSoundData(pathOrCount, sampleRate, channels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pathOrCount` | `string|number` | File path to decode, or sample count for blank buffer. |
| `sampleRate` | `number` | Sample rate in Hz (e.g. 44100, 48000). |
| `channels?` | `number` | Channel count (1 = mono, 2 = stereo), defaults to 1. |

**Returns**

| Type | Description |
|------|-------------|
| `LSoundData` | Raw PCM sample data for manipulation or playback. |

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
-- signature
lurek.audio.newSource(path, sourceType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Relative path to the audio file (WAV, OGG, MP3, FLAC). |
| `sourceType?` | `string` | "static" to load fully into memory, or "stream" (default) for streaming. |

**Returns**

| Type | Description |
|------|-------------|
| `LSource` | A new audio source ready for playback. |

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
-- signature
lurek.audio.pause(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

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
-- signature
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
-- signature
lurek.audio.play(source, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `options?` | `table` | Optional table with "bus" field for bus routing. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Numeric source ID of the playing source. |

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
-- signature
lurek.audio.playLooping(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

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
-- signature
lurek.audio.playQueueable(qsource_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qsource_id` | `number` | Queueable source handle returned by newQueueableSource. |

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

### `lurek.audio.queueSource`

Queues a decoded audio chunk for playback on a queueable source.

```lua
-- signature
lurek.audio.queueSource(qsource_id, sd)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qsource_id` | `number` | Queueable source handle returned by `newQueueableSource`. |
| `sd` | `LSoundData` | Sound data chunk to enqueue for playback. |

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
-- signature
lurek.audio.release(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID to release. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the source was successfully released. |

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
-- signature
lurek.audio.resume(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

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
-- signature
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
-- signature
lurek.audio.saveWAV(sd_ud, filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sd_ud` | `LSoundData` | The sound data to encode and save. |
| `filename` | `string` | Relative output path for the WAV file. |

**Example**

```lua
do
    local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.8)
    lurek.audio.saveWAV(sd, "work/output/test_tone.wav")
    print("saved WAV file")
end
```

---

### `lurek.audio.seek`

Seeks a source to a specific position in seconds.

```lua
-- signature
lurek.audio.seek(source, pos)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `pos` | `number` | Target position in seconds. |

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
-- signature
lurek.audio.setDistanceModel(model)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `model` | `string` | Model name (e.g. "inverse", "linear", "exponent", "none"). |

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
-- signature
lurek.audio.setDopplerScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | `number` | Doppler scale (0 = disabled, 1.0 = realistic). |

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
-- signature
lurek.audio.setHighpass(source, cutoff_hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `cutoff_hz` | `number` | Cutoff frequency in Hertz. |

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

### `lurek.audio.setListener`

Sets the 3D listener position for spatial audio (Z defaults to 0 for 2D games).

```lua
-- signature
lurek.audio.setListener(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Listener X position. |
| `y` | `number` | Listener Y position. |
| `z?` | `number` | Listener Z position (defaults to 0). |

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
-- signature
lurek.audio.setListener2D(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Listener X position in world units. |
| `y` | `number` | Listener Y position in world units. |

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
-- signature
lurek.audio.setLooping(source, looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `looping` | `boolean` | True to loop, false to play once. |

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
-- signature
lurek.audio.setLowpass(source, cutoff_hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `cutoff_hz` | `number` | Cutoff frequency in Hertz. |

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
-- signature
lurek.audio.setMasterVolume(vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vol` | `number` | Master volume multiplier (0.0 = silent, 1.0 = normal). |

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
-- signature
lurek.audio.setMeter(level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | `number` | Peak level clamped to 0.0-1.0. |

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
-- signature
lurek.audio.setMidiSoundFont(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Relative path to the .sf2 SoundFont file. |

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

### `lurek.audio.setOrientation`

Sets the orientation of a source using forward and up vectors.

```lua
-- signature
lurek.audio.setOrientation(source, fx, fy, fz, ux, uy, uz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `fx` | `number` | Forward vector X. |
| `fy` | `number` | Forward vector Y. |
| `fz` | `number` | Forward vector Z. |
| `ux` | `number` | Up vector X. |
| `uy` | `number` | Up vector Y. |
| `uz` | `number` | Up vector Z. |

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
-- signature
lurek.audio.setPan(source, pan)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `pan` | `number` | Pan from -1.0 (left) to 1.0 (right), 0.0 is center. |

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
-- signature
lurek.audio.setPitch(source, pitch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `pitch` | `number` | Pitch multiplier (1.0 = normal, 2.0 = octave up). |

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
-- signature
lurek.audio.setPlaybackDevice(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name of the playback device to activate. |

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
-- signature
lurek.audio.setPosition(source, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `x` | `number` | X position in world units. |
| `y` | `number` | Y position in world units. |
| `z?` | `number` | Z position (defaults to 0). |

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
-- signature
lurek.audio.setRandomPitch(src_ud, min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | `LSource` | The audio source to configure. |
| `min` | `number` | Minimum pitch multiplier. |
| `max` | `number` | Maximum pitch multiplier. |

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
-- signature
lurek.audio.setSourceBus(source, bus)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `bus` | `LBus` | The bus to route through. |

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
-- signature
lurek.audio.setStereoWidth(src_ud, width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | `LSource` | The audio source to adjust. |
| `width` | `number` | Stereo width factor (0.0 = mono, 1.0 = full stereo). |

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
-- signature
lurek.audio.setVelocity(source, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `x` | `number` | X velocity component. |
| `y` | `number` | Y velocity component. |
| `z?` | `number` | Z velocity component (defaults to 0). |

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
-- signature
lurek.audio.setVolume(source, vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |
| `vol` | `number` | Volume multiplier (0.0 = silent, 1.0 = normal). |

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
-- signature
lurek.audio.set_bus_volume(name, volume)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name of the audio bus. |
| `volume` | `number` | Volume level (0.0 = silent, 1.0 = full, >1.0 = boost). |

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
-- signature
lurek.audio.stop(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

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
-- signature
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

### `lurek.audio.stopQueueable`

Stops playback of a queueable audio source.

```lua
-- signature
lurek.audio.stopQueueable(qsource_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qsource_id` | `number` | Queueable source handle returned by newQueueableSource. |

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
-- signature
lurek.audio.tell(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | `LSource|number` | Audio source or numeric source ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current position in seconds. |

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

## LBus

### `LBus:clearDuck`

Removes the ducking configuration from this bus.

```lua
-- signature
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

### `LBus:getName`

Returns the name of this audio bus. This method is available to Lua scripts.

```lua
-- signature
LBus:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Bus name as registered during creation. |

**Example**

```lua
do
    local bus = lurek.audio.newBus("gameplay")
    print("bus name = " .. bus:getName())
end
```

---

### `LBus:getPeak`

Returns the current peak amplitude level of this bus for VU-meter displays.

```lua
-- signature
LBus:getPeak()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Peak level from 0.0 to 1.0. |

**Example**

```lua
do
    local bus = lurek.audio.newBus("meter_bus")
    local peak = bus:getPeak()
    print("peak = " .. peak)
end
```

---

### `LBus:getPitch`

Returns the current pitch multiplier of this bus.

```lua
-- signature
LBus:getPitch()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current pitch multiplier (defaults to 1.0). |

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

### `LBus:getVolume`

Returns the current volume multiplier of this bus.

```lua
-- signature
LBus:getVolume()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Volume multiplier (defaults to 1.0). |

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

### `LBus:isPaused`

Returns whether this bus is currently paused.

```lua
-- signature
LBus:isPaused()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the bus is paused. |

**Example**

```lua
do
    local bus = lurek.audio.newBus("ui")
    bus:pause()
    print("paused = " .. tostring(bus:isPaused()))
end
```

---

### `LBus:pause`

Pauses all sources routed through this bus.

```lua
-- signature
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

### `LBus:resume`

Resumes all sources routed through this bus that were paused.

```lua
-- signature
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

### `LBus:setDuckTarget`

Configures ducking so this bus lowers the volume of a target bus when active.

```lua
-- signature
LBus:setDuckTarget(target_name, duck_vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target_name` | `string` | Name of the bus to duck. |
| `duck_vol` | `number` | Volume multiplier applied to the target when ducking (0.0-1.0). |

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

### `LBus:setPitch`

Sets the pitch multiplier applied to all sources routed through this bus.

```lua
-- signature
LBus:setPitch(pitch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pitch` | `number` | Pitch multiplier (1.0 = normal speed). |

**Example**

```lua
do
    local bus = lurek.audio.newBus("fx")
    bus:setPitch(1.2)
    print("bus pitch = " .. bus:getPitch())
end
```

---

### `LBus:setVolume`

Sets the volume multiplier for all sources routed through this bus.

```lua
-- signature
LBus:setVolume(vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vol` | `number` | Volume multiplier (0.0 = silent, 1.0 = normal). |

**Example**

```lua
do
    local bus = lurek.audio.newBus("sfx")
    bus:setVolume(0.6)
    print("bus volume = " .. bus:getVolume())
end
```

---

### `LBus:type`

Returns the type name of this object for runtime type-checking.

```lua
-- signature
LBus:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always returns "LBus". |

**Example**

```lua
do
    local bus = lurek.audio.newBus("test")
    print("type = " .. bus:type())
end
```

---

### `LBus:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LBus:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check (e.g. "LBus", "Bus", or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if this object matches the given type. |

**Example**

```lua
do
    local bus = lurek.audio.newBus("check")
    print("is LBus = " .. tostring(bus:typeOf("LBus")))
end
```

---

## LDecoder

### `LDecoder:decode`

Decodes the next chunk of audio data and returns it as a LSoundData object.

```lua
-- signature
LDecoder:decode()
```

**Returns**

| Type | Description |
|------|-------------|
| `LSoundData` | Decoded PCM data, or nil if end of stream reached. |

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

### `LDecoder:getBitDepth`

Returns the bit depth of the source audio file.

```lua
-- signature
LDecoder:getBitDepth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Bits per sample (e.g. 16, 24). |

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

### `LDecoder:getChannelCount`

Returns the number of audio channels in the source file.

```lua
-- signature
LDecoder:getChannelCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Channel count (1 = mono, 2 = stereo). |

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

### `LDecoder:getDuration`

Returns the total duration of the source audio file in seconds.

```lua
-- signature
LDecoder:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Duration in seconds. |

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

### `LDecoder:getSampleRate`

Returns the sample rate of the source audio file.

```lua
-- signature
LDecoder:getSampleRate()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Sample rate in Hz. |

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

### `LDecoder:isSeekable`

Returns whether this decoder supports seeking.

```lua
-- signature
LDecoder:isSeekable()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if seek operations are supported. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    print("seekable = " .. tostring(dec:isSeekable()))
end
```

---

### `LDecoder:release`

Releases decoder resources (no-op, kept for API symmetry).

```lua
-- signature
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

### `LDecoder:rewind`

Rewinds the decoder back to the beginning of the audio stream.

```lua
-- signature
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

### `LDecoder:seek`

Seeks to a specific position in the audio stream.

```lua
-- signature
LDecoder:seek(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | `number` | Target position in seconds. |

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

### `LDecoder:tell`

Returns the current read position in the audio stream in seconds.

```lua
-- signature
LDecoder:tell()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current position in seconds. |

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

### `LDecoder:type`

Returns the type name of this object for runtime type-checking.

```lua
-- signature
LDecoder:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always returns "LDecoder". |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local dec = lurek.audio.newDecoder(path)
    print("type = " .. dec:type())
end
```

---

### `LDecoder:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LDecoder:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check (e.g. "LDecoder" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if this object matches the given type. |

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

### `LMidiPlayer:getBus`

Returns the audio bus this MIDI player is routed through.

```lua
-- signature
LMidiPlayer:getBus()
```

**Returns**

| Type | Description |
|------|-------------|
| `LBus` | The assigned bus, or nil if using direct output. |

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

### `LMidiPlayer:getChannelCount`

Returns the number of active MIDI channels in the loaded file.

```lua
-- signature
LMidiPlayer:getChannelCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of active channels. |

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

### `LMidiPlayer:getChannelInstrument`

Returns the current GM instrument program for a channel.

```lua
-- signature
LMidiPlayer:getChannelInstrument(ch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | `number` | Channel number (1-16). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | GM instrument program number (0-127). |

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

### `LMidiPlayer:getChannelVolume`

Returns the volume of a specific MIDI channel.

```lua
-- signature
LMidiPlayer:getChannelVolume(ch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | `number` | Channel number (1-16). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Channel volume (0.0-1.0). |

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

### `LMidiPlayer:getChannels`

Returns the number of output audio channels for MIDI synthesis.

```lua
-- signature
LMidiPlayer:getChannels()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Channel count (1 = mono, 2 = stereo). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    local ch = player:getChannels()
    print("output channels = " .. ch)
end
```

---

### `LMidiPlayer:getDuration`

Returns the total duration of the loaded MIDI file in seconds.

```lua
-- signature
LMidiPlayer:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Duration in seconds. |

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

### `LMidiPlayer:getFilePath`

Returns the file path of the currently loaded MIDI file.

```lua
-- signature
LMidiPlayer:getFilePath()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | File path string or nil if no file is loaded. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.audio.newMidiPlayer(path)
    print("file = " .. tostring(player:getFilePath()))
end
```

---

### `LMidiPlayer:getNoteCount`

Returns the total number of note events in the loaded MIDI file.

```lua
-- signature
LMidiPlayer:getNoteCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Total note count. |

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

### `LMidiPlayer:getOriginalTempo`

Returns the original tempo of the MIDI file as authored.

```lua
-- signature
LMidiPlayer:getOriginalTempo()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Original tempo in BPM. |

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

### `LMidiPlayer:getSampleRate`

Returns the output sample rate used for MIDI synthesis.

```lua
-- signature
LMidiPlayer:getSampleRate()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Sample rate in Hz (e.g. 44100). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    local rate = player:getSampleRate()
    print("sample rate = " .. rate)
end
```

---

### `LMidiPlayer:getSoundFontPath`

Returns the path of the currently set SoundFont (stub, not yet implemented).

```lua
-- signature
LMidiPlayer:getSoundFontPath()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | SoundFont path or nil. |

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

### `LMidiPlayer:getTempo`

Returns the current effective tempo in beats per minute.

```lua
-- signature
LMidiPlayer:getTempo()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current tempo in BPM. |

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

### `LMidiPlayer:getTempoScale`

Returns the current tempo scale multiplier.

```lua
-- signature
LMidiPlayer:getTempoScale()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Tempo scale factor. |

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

### `LMidiPlayer:getTicksPerBeat`

Returns the MIDI file's resolution in ticks per beat (PPQN).

```lua
-- signature
LMidiPlayer:getTicksPerBeat()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Ticks per quarter note. |

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

### `LMidiPlayer:getTrackCount`

Returns the number of tracks in the loaded MIDI file.

```lua
-- signature
LMidiPlayer:getTrackCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of MIDI tracks. |

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

### `LMidiPlayer:getTrackName`

Returns the name of a MIDI track by 1-based index.

```lua
-- signature
LMidiPlayer:getTrackName(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Track index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Track name or nil if not available. |

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

### `LMidiPlayer:getVolume`

Returns the current master volume of the MIDI player.

```lua
-- signature
LMidiPlayer:getVolume()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Volume multiplier. |

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

### `LMidiPlayer:isChannelMuted`

Returns whether a specific MIDI channel is muted.

```lua
-- signature
LMidiPlayer:isChannelMuted(ch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | `number` | Channel number (1-16). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the channel is muted. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelMuted(3, true)
    print("ch3 muted = " .. tostring(player:isChannelMuted(3)))
end
```

---

### `LMidiPlayer:isLoaded`

Returns whether a MIDI file is currently loaded and ready to play.

```lua
-- signature
LMidiPlayer:isLoaded()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a MIDI file is loaded. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    print("loaded = " .. tostring(player:isLoaded()))
end
```

---

### `LMidiPlayer:isLooping`

Returns whether MIDI looping is enabled.

```lua
-- signature
LMidiPlayer:isLooping()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if looping. |

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

### `LMidiPlayer:isPaused`

Returns whether the MIDI player is currently paused.

```lua
-- signature
LMidiPlayer:isPaused()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if paused. |

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

### `LMidiPlayer:isPlaying`

Returns whether the MIDI player is currently playing.

```lua
-- signature
LMidiPlayer:isPlaying()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if playing. |

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

### `LMidiPlayer:isTrackMuted`

Returns whether a specific MIDI track is muted.

```lua
-- signature
LMidiPlayer:isTrackMuted(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Track index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the track is muted. |

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

### `LMidiPlayer:load`

Loads a MIDI file from the given path relative to the game directory.

```lua
-- signature
LMidiPlayer:load(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Relative path to the .mid file. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the file was loaded successfully. |

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

### `LMidiPlayer:loadData`

Loads MIDI data from a raw byte string in memory.

```lua
-- signature
LMidiPlayer:loadData(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `string` | Raw MIDI binary data. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the data was parsed successfully. |

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

### `LMidiPlayer:pause`

Pauses MIDI playback at the current position.

```lua
-- signature
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

### `LMidiPlayer:play`

Starts MIDI playback from the current position using the audio output stream.

```lua
-- signature
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

### `LMidiPlayer:seek`

Seeks to a specific position in the MIDI file.

```lua
-- signature
LMidiPlayer:seek(secs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `secs` | `number` | Target position in seconds. |

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

### `LMidiPlayer:setBus`

Routes this MIDI player's output through the specified audio bus.

```lua
-- signature
LMidiPlayer:setBus(bus)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bus?` | `LBus` | Bus to route through, or nil for direct output. |

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

### `LMidiPlayer:setChannelInstrument`

Sets the General MIDI instrument program for a channel.

```lua
-- signature
LMidiPlayer:setChannelInstrument(ch, inst)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | `number` | Channel number (1-16). |
| `inst` | `number` | GM instrument program number (0-127). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelInstrument(1, 25)
    print("ch1 instrument = " .. player:getChannelInstrument(1))
end
```

---

### `LMidiPlayer:setChannelMuted`

Mutes or unmutes a specific MIDI channel.

```lua
-- signature
LMidiPlayer:setChannelMuted(ch, muted)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | `number` | Channel number (1-16). |
| `muted` | `boolean` | True to mute, false to unmute. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelMuted(10, true)
    print("ch10 muted = " .. tostring(player:isChannelMuted(10)))
end
```

---

### `LMidiPlayer:setChannelVolume`

Sets the volume for a specific MIDI channel (1-16).

```lua
-- signature
LMidiPlayer:setChannelVolume(ch, vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | `number` | Channel number (1-16). |
| `vol` | `number` | Volume multiplier (0.0-1.0). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannelVolume(1, 0.8)
    print("ch1 volume = " .. player:getChannelVolume(1))
end
```

---

### `LMidiPlayer:setChannels`

Sets the number of output audio channels for MIDI synthesis.

```lua
-- signature
LMidiPlayer:setChannels(channels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channels` | `number` | Channel count (1 = mono, 2 = stereo). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setChannels(2)
    print("set stereo output")
end
```

---

### `LMidiPlayer:setLooping`

Enables or disables looping for MIDI playback.

```lua
-- signature
LMidiPlayer:setLooping(looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `looping` | `boolean` | True to loop, false to play once. |

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

### `LMidiPlayer:setOnEnd`

Registers a callback invoked when MIDI playback finishes (stub, not yet implemented).

```lua
-- signature
LMidiPlayer:setOnEnd(cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cb?` | `function` | Callback function or nil to clear. |

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

### `LMidiPlayer:setOnNoteOff`

Registers a callback for MIDI note-off events (stub, not yet implemented).

```lua
-- signature
LMidiPlayer:setOnNoteOff(cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cb?` | `function` | Callback function or nil to clear. |

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

### `LMidiPlayer:setOnNoteOn`

Registers a callback for MIDI note-on events (stub, not yet implemented).

```lua
-- signature
LMidiPlayer:setOnNoteOn(cb)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cb?` | `function` | Callback function or nil to clear. |

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

### `LMidiPlayer:setSampleRate`

Sets the output sample rate for MIDI synthesis.

```lua
-- signature
LMidiPlayer:setSampleRate(rate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rate` | `number` | Sample rate in Hz (e.g. 44100, 48000). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setSampleRate(48000)
    print("sample rate = " .. player:getSampleRate())
end
```

---

### `LMidiPlayer:setSoundFont`

Sets a custom SoundFont file for MIDI synthesis (stub, not yet implemented).

```lua
-- signature
LMidiPlayer:setSoundFont(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Relative path to the .sf2 file. |

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

### `LMidiPlayer:setTempo`

Sets the playback tempo in beats per minute.

```lua
-- signature
LMidiPlayer:setTempo(bpm)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bpm` | `number` | Desired tempo in BPM. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempo(140)
    print("tempo = " .. player:getTempo())
end
```

---

### `LMidiPlayer:setTempoScale`

Sets a tempo multiplier relative to the original speed.

```lua
-- signature
LMidiPlayer:setTempoScale(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale` | `number` | Tempo scale (1.0 = original, 2.0 = double speed). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setTempoScale(1.5)
    print("tempo scale = " .. player:getTempoScale())
end
```

---

### `LMidiPlayer:setTrackMuted`

Mutes or unmutes a specific MIDI track.

```lua
-- signature
LMidiPlayer:setTrackMuted(idx, muted)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Track index (1-based). |
| `muted` | `boolean` | True to mute, false to unmute. |

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

### `LMidiPlayer:setVolume`

Sets the master volume for MIDI playback.

```lua
-- signature
LMidiPlayer:setVolume(vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vol` | `number` | Volume multiplier (0.0 = silent, 1.0 = normal). |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:setVolume(0.7)
    print("volume = " .. player:getVolume())
end
```

---

### `LMidiPlayer:soloChannel`

Solos a specific MIDI channel, muting all others.

```lua
-- signature
LMidiPlayer:soloChannel(ch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ch` | `number` | Channel number (1-16) to solo. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    player:soloChannel(1)
    print("ch1 soloed")
end
```

---

### `LMidiPlayer:stop`

Stops MIDI playback and resets position to the beginning.

```lua
-- signature
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

### `LMidiPlayer:tell`

Returns the current playback position of the MIDI player in seconds.

```lua
-- signature
LMidiPlayer:tell()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current position in seconds. |

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

### `LMidiPlayer:type`

Returns the type name of this object for runtime type-checking.

```lua
-- signature
LMidiPlayer:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always returns "LMidiPlayer". |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    print("type = " .. player:type())
end
```

---

### `LMidiPlayer:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LMidiPlayer:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check (e.g. "LMidiPlayer", "MidiPlayer", or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if this object matches the given type. |

**Example**

```lua
do
    local player = lurek.audio.newMidiPlayer()
    print("is LMidiPlayer = " .. tostring(player:typeOf("LMidiPlayer")))
end
```

---

### `LMidiPlayer:unsoloAll`

Removes solo from all channels, restoring normal playback.

```lua
-- signature
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

### `LMidiPlayer:useDefaultSoundFont`

Reverts to the built-in default SoundFont (stub, not yet implemented).

```lua
-- signature
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

### `LSoundData:drawWaveform`

Draws this sound buffer as a waveform into an image buffer.

```lua
-- signature
LSoundData:drawWaveform(target, x, y, w, h, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | Target image to draw into. |
| `x` | `number` | Left pixel coordinate. |
| `y` | `number` | Top pixel coordinate. |
| `w` | `number` | Waveform width in pixels. |
| `h` | `number` | Waveform height in pixels. |
| `r` | `number` | Red channel from 0 to 255. |
| `g` | `number` | Green channel from 0 to 255. |
| `b` | `number` | Blue channel from 0 to 255. |
| `a` | `number` | Alpha channel from 0 to 255. |

**Example**

```lua
do
    local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.8)
    local img = lurek.image.newImageData(400, 100)
    sd:drawWaveform(img, 0, 0, 400, 100, 0, 255, 0, 255)
    print("waveform drawn to image")
end
```

---

### `LSoundData:getBitDepth`

Returns the sample bit depth of this sound buffer.

```lua
-- signature
LSoundData:getBitDepth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Bit depth per sample. |

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bits = sd:getBitDepth()
    print("bit depth = " .. bits)
end
```

---

### `LSoundData:getChannelCount`

Returns the number of audio channels stored in this sound buffer.

```lua
-- signature
LSoundData:getChannelCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Channel count. |

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(44100, 44100, 2)
    local ch = sd:getChannelCount()
    print("channels = " .. ch)
end
```

---

### `LSoundData:getDuration`

Returns the approximate playback duration of this sound buffer.

```lua
-- signature
LSoundData:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Duration in seconds. |

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local dur = sd:getDuration()
    print("duration = " .. dur .. "s")
end
```

---

### `LSoundData:getSample`

Returns the sample value at the given zero-based sample index.

```lua
-- signature
LSoundData:getSample(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | Zero-based sample index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Sample value at the requested index. |

**Example**

```lua
do
    local sd = lurek.audio.newSineWave(440, 0.1, 44100, 1.0)
    local val = sd:getSample(0)
    print("sample[0] = " .. val)
end
```

---

### `LSoundData:getSampleCount`

Returns the total number of samples stored in this sound buffer.

```lua
-- signature
LSoundData:getSampleCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Total sample count. |

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local count = sd:getSampleCount()
    print("samples = " .. count)
end
```

---

### `LSoundData:getSampleRate`

Returns the playback sample rate of this sound buffer.

```lua
-- signature
LSoundData:getSampleRate()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Sample rate in Hz. |

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(22050, 22050, 1)
    local rate = sd:getSampleRate()
    print("sample rate = " .. rate)
end
```

---

### `LSoundData:setSample`

Overwrites the sample value at the given zero-based sample index.

```lua
-- signature
LSoundData:setSample(index, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | Zero-based sample index. |
| `value` | `number` | New sample value. |

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

### `LSoundData:type`

Returns the type name of this object for runtime type-checking.

```lua
-- signature
LSoundData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always returns "LSoundData". |

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    print("type = " .. sd:type())
end
```

---

### `LSoundData:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LSoundData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check (e.g. "LSoundData" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if this object matches the given type. |

**Example**

```lua
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    print("is LSoundData = " .. tostring(sd:typeOf("LSoundData")))
end
```

---

## LSoundPool

### `LSoundPool:getVoiceCount`

Returns the number of pre-allocated voices in this pool.

```lua
-- signature
LSoundPool:getVoiceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Voice count. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 8)
    print("voices = " .. pool:getVoiceCount())
end
```

---

### `LSoundPool:play`

Plays the next available voice from the pool in round-robin order.

```lua
-- signature
LSoundPool:play()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Numeric source ID of the voice that started playing. |

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

### `LSoundPool:release`

Releases all voices and frees audio resources held by this pool.

```lua
-- signature
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

### `LSoundPool:setBus`

Routes all voices in this pool through the named audio bus.

```lua
-- signature
LSoundPool:setBus(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name of the target bus. |

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

### `LSoundPool:setVolume`

Sets the volume for all voices in this pool.

```lua
-- signature
LSoundPool:setVolume(vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vol` | `number` | Volume multiplier (0.0 = silent, 1.0 = normal). |

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

### `LSoundPool:stopAll`

Stops all voices in this sound pool immediately.

```lua
-- signature
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

### `LSoundPool:type`

Returns the type name of this object for runtime type-checking.

```lua
-- signature
LSoundPool:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always returns "LSoundPool". |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local pool = lurek.audio.newPool(path, 2)
    print("type = " .. pool:type())
end
```

---

### `LSoundPool:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LSoundPool:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check (e.g. "LSoundPool" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if this object matches the given type. |

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

### `LSource:clearFilter`

Removes all frequency filters (lowpass and highpass) from this source.

```lua
-- signature
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

### `LSource:clone`

Creates an independent copy of this source sharing the same audio data.

```lua
-- signature
LSource:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| `LSource` | A new source instance with identical settings. |

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

### `LSource:fadeIn`

Sets the fade-in duration so the source ramps from silence to full volume on play.

```lua
-- signature
LSource:fadeIn(dur)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dur` | `number` | Fade-in duration in seconds. |

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

### `LSource:getDuration`

Returns the total duration of this audio source in seconds.

```lua
-- signature
LSource:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Duration in seconds. |

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

### `LSource:getFadeIn`

Returns the configured fade-in duration for this source.

```lua
-- signature
LSource:getFadeIn()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Fade-in duration in seconds. |

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

### `LSource:getHighpass`

Returns the current highpass filter cutoff frequency in Hertz.

```lua
-- signature
LSource:getHighpass()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cutoff frequency in Hz, or 0 if no highpass is set. |

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

### `LSource:getLowpass`

Returns the current lowpass filter cutoff frequency in Hertz.

```lua
-- signature
LSource:getLowpass()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Cutoff frequency in Hz, or 0 if no lowpass is set. |

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

### `LSource:getPan`

Returns the current stereo panning position of this source.

```lua
-- signature
LSource:getPan()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Pan value from -1.0 (left) to 1.0 (right). |

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

### `LSource:getPitch`

Returns the current pitch multiplier of this audio source.

```lua
-- signature
LSource:getPitch()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current pitch multiplier. |

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

### `LSource:getType`

Returns whether this source was loaded as static (fully in memory) or streaming.

```lua
-- signature
LSource:getType()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Either "static" or "stream". |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_loop.wav"
    local src = lurek.audio.newSource(path, "stream")
    print("type = " .. src:getType())
end
```

---

### `LSource:getVolume`

Returns the current volume level of this audio source.

```lua
-- signature
LSource:getVolume()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current volume multiplier. |

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

### `LSource:isLooping`

Returns whether this source is set to loop continuously.

```lua
-- signature
LSource:isLooping()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if looping is enabled. |

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

### `LSource:isPaused`

Returns whether this source is currently paused.

```lua
-- signature
LSource:isPaused()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the source is paused. |

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

### `LSource:isPlaying`

Returns whether this source is currently playing audio.

```lua
-- signature
LSource:isPlaying()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the source is actively playing. |

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

### `LSource:isStopped`

Returns whether this source is currently stopped (not playing or paused).

```lua
-- signature
LSource:isStopped()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the source is stopped. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("stopped = " .. tostring(src:isStopped()))
end
```

---

### `LSource:pause`

Pauses playback at the current position, allowing later resumption.

```lua
-- signature
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

### `LSource:play`

Starts playback of this audio source from the current position.

```lua
-- signature
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

### `LSource:resume`

Resumes playback from the position where the source was paused.

```lua
-- signature
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

### `LSource:seek`

Seeks to a specific position in seconds within this audio source.

```lua
-- signature
LSource:seek(pos)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pos` | `number` | Target position in seconds. |

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

### `LSource:setHighpass`

Applies a highpass filter that attenuates frequencies below the cutoff.

```lua
-- signature
LSource:setHighpass(cutoff_hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cutoff_hz` | `number` | Cutoff frequency in Hertz. |

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

### `LSource:setLooping`

Enables or disables looping so the source restarts automatically after finishing.

```lua
-- signature
LSource:setLooping(looping)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `looping` | `boolean` | True to loop continuously, false to play once. |

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

### `LSource:setLowpass`

Applies a lowpass filter that attenuates frequencies above the cutoff.

```lua
-- signature
LSource:setLowpass(cutoff_hz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cutoff_hz` | `number` | Cutoff frequency in Hertz. |

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

### `LSource:setPan`

Sets the stereo panning position of this source.

```lua
-- signature
LSource:setPan(pan)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pan` | `number` | Pan value from -1.0 (full left) to 1.0 (full right), 0.0 is center. |

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

### `LSource:setPitch`

Sets the playback speed multiplier, affecting both pitch and duration.

```lua
-- signature
LSource:setPitch(pitch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pitch` | `number` | Pitch multiplier (1.0 = normal, 2.0 = double speed/octave up). |

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

### `LSource:setVolume`

Sets the volume level of this source where 0.0 is silent and 1.0 is full volume.

```lua
-- signature
LSource:setVolume(vol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vol` | `number` | Volume multiplier (0.0 = silent, 1.0 = normal, >1.0 = amplified). |

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

### `LSource:stop`

Stops playback and resets the source position to the beginning.

```lua
-- signature
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

### `LSource:tell`

Returns the current playback position of this source in seconds.

```lua
-- signature
LSource:tell()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current position in seconds from the start. |

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

### `LSource:type`

Returns the type name of this object for runtime type-checking.

```lua
-- signature
LSource:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always returns "LSource". |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("type = " .. src:type())
end
```

---

### `LSource:typeOf`

Checks whether this object is of the given type name or a parent type.

```lua
-- signature
LSource:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check (e.g. "LSource" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if this object matches the given type. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_click.wav"
    local src = lurek.audio.newSource(path, "static")
    print("is LSource = " .. tostring(src:typeOf("LSource")))
end
```

---
