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

## Files

### mod.rs

- MIDI input and playback sub-system: device discovery, event routing, and sequencing.
- Enumerates MIDI devices via the `midir` crate; device list is refreshed on demand.
- Incoming MIDI events are translated to `lurek.midi.*` Lua callbacks each tick.
- The built-in sequencer plays SMF (`.mid`) files via the audio mixer.
- MIDI output (to hardware synths) is also supported if an output port is open.

### player.rs

- `MidiPlayer` stateful transport controller for MIDI file playback via rendered PCM.
- File loading with parsed metadata: duration, BPM, ticks-per-beat, track names, note count.
- Transport controls: play, stop, pause, resume, seek, tell, and duration queries.
- Per-channel volume, mute, instrument, and solo/unsolo operations across 16 MIDI channels.
- Per-track mute support keyed by track index.
- Configurable tempo scaling, looping, and output sample rate / channel count.
- Mixer bus assignment via `BusKey` for routed playback.
- `MidiData` metadata struct storing parsed song-level attributes.
- Helper functions for MIDI note-to-frequency conversion and sine-wave note rendering.

### state.rs

- `MidiState` storage for loaded SoundFont binary data and its source path.
- RIFF+sfbk header validation on `set_soundfont` to reject malformed SF2 files.
- Query and clear helpers for SoundFont availability and data access.

## Lua API Ref

- Binding: `src/lua_api/midi_api.rs`
- Namespace: `lurek.midi`

### Functions

- `lurek.midi.clearSoundFont`: Unloads the current SoundFont and frees its memory.
- `lurek.midi.hasSoundFont`: Returns whether a SoundFont is currently loaded and ready for synthesis.
- `lurek.midi.loadSoundFont`: Loads a SoundFont (SF2) file into the global MIDI state for synthesis.
- `lurek.midi.newPlayer`: Creates a new MIDI player instance, optionally loading a file immediately.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- `audio`: Imports or references `src/audio/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.
