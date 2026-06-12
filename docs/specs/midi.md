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
- Lua test path(s): tests/lua_reorg/unit/test_midi_core_unit.lua

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
