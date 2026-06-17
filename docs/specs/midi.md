# midi

## TL;DR

- Synthesizes MIDI files.

## General Info

- Module group: `Platform Services`
- Source path: `src/midi/`
- Binding: `src/lua_api/midi_api.rs`
- Namespace: `lurek.midi`
- Lua API surface: `4` functions, `0` types, `0` methods
- Rust test path(s): tests/rust/unit/audio_tests.rs (shared with audio)
- Lua test path(s): tests/lua/unit/test_midi_core_unit.lua

## Summary

- The midi module provides MIDI-focused playback and synthesis control backed by SoundFont rendering.
- It exposes transport operations such as load, play, pause, stop, seek, and loop.
- Channel and track controls support mute, solo, volume shaping, and instrument-level adjustment.
- The module gives users scriptable MIDI sequencing that plugs cleanly into the engine audio runtime.

This module primarily collaborates with `audio`, `runtime`. Its responsibility should stay inside the `Platform Services` group rather than absorb behavior owned by those neighbors.

## Imports

- `audio`: Imports or references `src/audio/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.

## Files

### mod.rs

- MIDI subsystem for device discovery, event routing, and sequenced playback. `midi/mod` is the midi module index, declaring `player`, `state` so agents can identify which files own each feature slice before opening implementation code.
- Bridges live MIDI input, software rendering, and hardware output from one module. `src/midi/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `player::MidiPlayer`, `state::MidiState` centralized for the midi subsystem.

### player.rs

- Stateful MIDI transport for file playback through rendered PCM. `midi/player` delivers the player implementation for the midi subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Holds parsed song metadata and playback position in one controller object. The file owns or coordinates data contracts including `MidiData`, `MidiPlayer`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Handles play, pause, resume, seek, stop, and duration queries. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `load`, `load_data`, `is_loaded`, `file_path`, `play`, and 38 more stays attached to the local data model and invariants.
- Tracks per-channel mix state such as volume, mute, solo, and instrument selection. Runtime integration reaches sibling engine areas through crate modules `audio`, `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Supports per-track muting plus tempo, looping, and output format control. External integration uses `rodio`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### state.rs

- Storage for loaded MIDI SoundFont data and its source path. `midi/state` delivers the state container and transition helpers for the midi subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Validates SoundFont files before they enter the playback pipeline. The file owns or coordinates data contracts including `MidiState`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Exposes query and clear helpers for runtime availability checks. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `set_soundfont`, `has_soundfont`, `clear_soundfont`, `soundfont_path`, `soundfont_data` stays attached to the local data model and invariants.



## Lua API Ref

### Functions

- `lurek.midi.clearSoundFont() -> nil`: Unloads the current SoundFont and frees its memory.
- `lurek.midi.hasSoundFont() -> boolean`: Returns whether a SoundFont is currently loaded and ready for synthesis.
- `lurek.midi.loadSoundFont(path) -> boolean`: Loads a SoundFont (SF2) file into the global MIDI state for synthesis.
- `lurek.midi.newPlayer(path?) -> LMidiPlayer`: Creates a new MIDI player instance, optionally loading a file immediately.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- `audio`: Imports or references `src/audio/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.

## Notes

- No additional module-specific notes.
