# Midi

## Purpose

Synthesizes MIDI files.

## When To Use

- It combines transport, playback state, and SoundFont-backed synthesis under one runtime surface.
- That makes it useful for adaptive scoring, live control, and note-driven playback.
- Read it as the bridge from MIDI data to audible output.

## Minimal Example

Example block: `lurek.midi.newPlayer`

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.midi.newPlayer(path)
    example_print_log("type = " .. player:type())
    example_print_log("loaded = " .. tostring(player:isLoaded()))
    example_print_log("path = " .. tostring(player:getFilePath()))
end
```

## Common Patterns

- Start with `lurek.midi.clearSoundFont` when exploring this module.
- Start with `lurek.midi.hasSoundFont` when exploring this module.
- Start with `lurek.midi.loadSoundFont` when exploring this module.
- Start with `lurek.midi.newPlayer` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `midi` module is the playback surface for projects that want symbolic music control instead of treating every cue as rendered audio.
- It combines transport, playback state, and SoundFont-backed synthesis under one runtime surface.
- That makes it useful for adaptive scoring, live control, and note-driven playback.
- Read it as the bridge from MIDI data to audible output.

This module primarily collaborates with `audio`, `runtime`. Its responsibility should stay inside the `Platform Services` group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.midi.clearSoundFont`

Unloads the current SoundFont and frees its memory.

```lua
lurek.midi.clearSoundFont()
```

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok, err = pcall(function()
        lurek.midi.loadSoundFont(path)
    end)
    if not ok then example_print_log("loadSoundFont skipped: " .. tostring(err)) end
    example_print_log("before clear = " .. tostring(lurek.midi.hasSoundFont()))
    lurek.midi.clearSoundFont()
    example_print_log("after clear = " .. tostring(lurek.midi.hasSoundFont()))
end
```

---

### `lurek.midi.hasSoundFont`

Returns whether a SoundFont is currently loaded and ready for synthesis.

```lua
lurek.midi.hasSoundFont()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a SoundFont is loaded. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    lurek.midi.clearSoundFont()
    example_print_log("before load = " .. tostring(lurek.midi.hasSoundFont()))
    local ok, err = pcall(function()
        lurek.midi.loadSoundFont(path)
    end)
    example_print_log("load ok = " .. tostring(ok))
    if not ok then example_print_log("loadSoundFont skipped: " .. tostring(err)) end
    example_print_log("after load = " .. tostring(lurek.midi.hasSoundFont()))
    lurek.midi.clearSoundFont()
end
```

---

### `lurek.midi.loadSoundFont`

Loads a SoundFont (SF2) file into the global MIDI state for synthesis.

```lua
lurek.midi.loadSoundFont(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Relative path to the .sf2 file. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the SoundFont was loaded successfully. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok, err = pcall(function()
        local loaded = lurek.midi.loadSoundFont(path)
        example_print_log("loaded = " .. tostring(loaded))
        example_print_log("has soundfont = " .. tostring(lurek.midi.hasSoundFont()))
    end)
    if not ok then example_print_log("loadSoundFont skipped: " .. tostring(err)) end
end
```

---

### `lurek.midi.newPlayer`

Creates a new MIDI player instance, optionally loading a file immediately.

```lua
lurek.midi.newPlayer(path)
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
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.midi.newPlayer(path)
    example_print_log("type = " .. player:type())
    example_print_log("loaded = " .. tostring(player:isLoaded()))
    example_print_log("path = " .. tostring(player:getFilePath()))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LMidiPlayer](#lmidiplayer)

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
| [LBus](audio.md#lbus) | The assigned bus, or nil if using direct output. |

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

---

#### `LMidiPlayer:pause`

Pauses MIDI playback at the current position.

```lua
LMidiPlayer:pause()
```

---

#### `LMidiPlayer:play`

Starts MIDI playback from the current position using the audio output stream.

```lua
LMidiPlayer:play()
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

---

#### `LMidiPlayer:setBus`

Routes this MIDI player's output through the specified audio bus.

```lua
LMidiPlayer:setBus(bus)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bus?` | [LBus](audio.md#lbus) | Bus to route through, or nil for direct output. |

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

---

#### `LMidiPlayer:stop`

Stops MIDI playback and resets position to the beginning.

```lua
LMidiPlayer:stop()
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

---

#### `LMidiPlayer:unsoloAll`

Removes solo from all channels, restoring normal playback.

```lua
LMidiPlayer:unsoloAll()
```

---

#### `LMidiPlayer:useDefaultSoundFont`

Reverts to the built-in default SoundFont (stub, not yet implemented).

```lua
LMidiPlayer:useDefaultSoundFont()
```

---
