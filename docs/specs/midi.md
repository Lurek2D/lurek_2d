# midi

## TL;DR

- The `midi` module provides MIDI file playback via software synthesis using SoundFont data, with full transport controls and per-channel mixing.

## General Info

- Module group: `Platform Services`
- Source path: `src/midi/`
- Binding: `src/lua_api/midi_api.rs`
- Namespace: `lurek.midi`
- Lua API surface: `4` functions, `0` types, `0` methods
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

## Imports

- `audio`: Imports or references `src/audio/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.

## Files

### mod.rs

- MIDI subsystem for device discovery, event routing, and sequenced playback.
- Bridges live MIDI input, software rendering, and hardware output from one module.
- Keeps device refresh and callback delivery aligned with the engine tick.

### player.rs

- Stateful MIDI transport for file playback through rendered PCM.
- Holds parsed song metadata and playback position in one controller object.
- Handles play, pause, resume, seek, stop, and duration queries.
- Tracks per-channel mix state such as volume, mute, solo, and instrument selection.
- Supports per-track muting plus tempo, looping, and output format control.
- Routes output through the mixer bus so playback fits the engine audio graph.
- Gives Lua a stable player surface for song-driven sequencing and testing.

### state.rs

- Storage for loaded MIDI SoundFont data and its source path.
- Validates SoundFont files before they enter the playback pipeline.
- Exposes query and clear helpers for runtime availability checks.
- Keeps the shared sample resource separate from transport state.

## Lua API Ref

### Functions

- `lurek.midi.clearSoundFont`: Unloads the current SoundFont and frees its memory.
- `lurek.midi.hasSoundFont`: Returns whether a SoundFont is currently loaded and ready for synthesis.
- `lurek.midi.loadSoundFont`: Loads a SoundFont (SF2) file into the global MIDI state for synthesis.
- `lurek.midi.newPlayer`: Creates a new MIDI player instance, optionally loading a file immediately.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.
