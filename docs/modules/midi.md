# Midi

- The `midi` module provides MIDI file playback via software synthesis using SoundFont data, with full transport controls and per-channel mixing.

The `midi` module encapsulates MIDI file parsing, event sequencing, and PCM synthesis using loaded SoundFont (.sf2) instrument data. It was extracted from `src/audio/` to isolate the MIDI-specific logic from the core playback and mixing pipeline.

The `MidiPlayer` struct manages:
- File loading and parsing of Standard MIDI Files.
- Transport controls: play, pause, stop, seek, tell, loop toggle.
- Tempo scaling for adjustable playback speed.
- Per-channel volume, mute, and instrument (program) assignment across 16 MIDI channels.
- Bus assignment via `BusKey` for routing MIDI output through the audio bus hierarchy.

The `MidiState` struct manages global SoundFont state:
- Loading and validating SoundFont files (RIFF + sfbk header check).
- Querying whether a SoundFont is currently loaded.
- Clearing loaded SoundFont data.

Backward compatibility is maintained via re-exports in `src/audio/mod.rs`. The `SharedState` holds a `midi_state: MidiState` field accessible to both the audio and midi API modules.

## Functions

### `lurek.midi.clearSoundFont`

Unloads the current SoundFont and frees its memory.

```lua
-- signature
lurek.midi.clearSoundFont()
```

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    lurek.midi.loadSoundFont(path)
    print("before clear = " .. tostring(lurek.midi.hasSoundFont()))
    lurek.midi.clearSoundFont()
    print("after clear = " .. tostring(lurek.midi.hasSoundFont()))
end
```

---

### `lurek.midi.hasSoundFont`

Returns whether a SoundFont is currently loaded and ready for synthesis.

```lua
-- signature
lurek.midi.hasSoundFont()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a SoundFont is loaded. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    lurek.midi.clearSoundFont()
    print("before load = " .. tostring(lurek.midi.hasSoundFont()))
    lurek.midi.loadSoundFont(path)
    print("after load = " .. tostring(lurek.midi.hasSoundFont()))
    lurek.midi.clearSoundFont()
end
```

---

### `lurek.midi.loadSoundFont`

Loads a SoundFont (SF2) file into the global MIDI state for synthesis.

```lua
-- signature
lurek.midi.loadSoundFont(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Relative path to the .sf2 file. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the SoundFont was loaded successfully. |

**Example**

```lua
do
    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok, err = pcall(function()
        local loaded = lurek.midi.loadSoundFont(path)
        print("loaded = " .. tostring(loaded))
        print("has soundfont = " .. tostring(lurek.midi.hasSoundFont()))
    end)
    if not ok then print("loadSoundFont skipped: " .. tostring(err)) end
end
```

---

### `lurek.midi.newPlayer`

Creates a new MIDI player instance, optionally loading a file immediately.

```lua
-- signature
lurek.midi.newPlayer(path)
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
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.midi.newPlayer(path)
    print("type = " .. player:type())
    print("loaded = " .. tostring(player:isLoaded()))
    print("path = " .. tostring(player:getFilePath()))
end
```

---
