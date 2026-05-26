# midi

## TL;DR

- The `midi` module provides MIDI file playback via software synthesis using SoundFont data, with full transport controls and per-channel mixing.

## General Info

- Module group: `Platform Services`
- Source path: `src/midi/`
- Lua API path(s): `src/lua_api/midi_api.rs`
- Primary Lua namespace: `lurek.midi`
- Rust test path(s): tests/rust/unit/audio_tests.rs (shared with audio)
- Lua test path(s): tests/lua/unit/test_midi_core_unit.lua

## Summary

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

## Source Documentation

### `player.rs`
- `MidiPlayer`: full-featured MIDI sequencer with 16-channel state.
- Transport: `play()`, `pause()`, `stop()`, `seek(pos)`, `tell()`, `duration()`, `is_playing()`.
- Tempo: `set_tempo_scale(scale)`, `tempo_scale()`.
- Volume: `set_volume(v)`, `volume()`. Clamped to [0.0, 2.0].
- Looping: `set_looping(b)`, `is_looping()`.
- Per-channel: `set_channel_volume(ch, v)`, `set_channel_muted(ch, b)`, `set_channel_instrument(ch, program)`.
- Bus routing: `set_bus(key)`, `bus()`.
- File: `load(path)` — reads MIDI file, resets transport.
- Play state: tracks `PlayState` (Playing, Paused, Stopped).
- Log messages: `A001_MIDI_READ_FAIL`, `A002_MIDI_DISABLED`.

### `state.rs`
- `MidiState`: global SoundFont registry.
- `load_soundfont(path)` — validates RIFF+sfbk header, stores raw bytes.
- `has_soundfont()` → bool.
- `clear_soundfont()` — drops loaded data.
- `new()` — constructs empty state.

## Lua API

### `lurek.midi.newPlayer()` → MidiPlayer
Creates a new MIDI player instance.

### `lurek.midi.loadSoundFont(path)` → boolean
Loads a SoundFont (.sf2) file for MIDI synthesis. Returns true on success.

### `lurek.midi.hasSoundFont()` → boolean
Returns whether a SoundFont is currently loaded.

### `lurek.midi.clearSoundFont()`
Unloads the current SoundFont data.

### MidiPlayer methods (via `lurek.audio.newMidiPlayer()` or `lurek.midi.newPlayer()`)
- `:load(path)`, `:play()`, `:pause()`, `:stop()`
- `:seek(seconds)`, `:tell()` → number, `:getDuration()` → number
- `:isPlaying()` → boolean, `:setLooping(bool)`, `:isLooping()` → boolean
- `:setVolume(v)`, `:getVolume()` → number
- `:setTempoScale(s)`, `:getTempoScale()` → number
- `:setChannelVolume(ch, v)`, `:setChannelMuted(ch, b)`, `:setChannelInstrument(ch, program)`

## Dependencies

- `crate::audio::PlayState` — shared enum for transport state.
- `crate::runtime::resource_keys::BusKey` — typed key for bus routing.
- `crate::runtime::log_messages` — structured log codes.

## Design Decisions

- Extracted from `audio` because MIDI synthesis is a distinct domain (file format parsing, event sequencing, SoundFont interpretation) that doesn't share implementation with PCM playback.
- `MidiState` lives on `SharedState` because SoundFont data is global (shared across all MIDI players).
- `MidiPlayer` is a Lua userdata object with method-style access, consistent with other resource handles in lurek.
- Backward-compat re-exports in `src/audio/mod.rs` prevent breakage.
