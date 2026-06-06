# midi

## General Info

- Module group: `Platform Services`
- Source path: `src/midi/`
- Binding: `src/lua_api/midi_api.rs`
- Namespace: `lurek.midi`
- Lua API surface: `4` functions, `0` types, `0` methods
- Rust test path(s): tests/rust/unit/audio_tests.rs (shared with audio)
- Lua test path(s): tests/lua/unit/test_midi_core_unit.lua

## Summary

This module handles MIDI playback and software synthesis by managing SoundFont resources. It implements a stateful transport player to control files, seeking, and loops. Additionally, it exposes per-channel mix properties like instrument selection, volume, mute, and solo controls, routing audio to the mixer.

This module primarily collaborates with `audio`, `runtime`. Its responsibility should stay inside the `Platform Services` group rather than absorb behavior owned by those neighbors.

## Files

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/midi/mod.rs)

- MIDI subsystem for device discovery, event routing, and sequenced playback.
- Bridges live MIDI input, software rendering, and hardware output from one module.
- Keeps device refresh and callback delivery aligned with the engine tick.

### [player.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/midi/player.rs)

- Stateful MIDI transport for file playback through rendered PCM.
- Holds parsed song metadata and playback position in one controller object.
- Handles play, pause, resume, seek, stop, and duration queries.
- Tracks per-channel mix state such as volume, mute, solo, and instrument selection.
- Supports per-track muting plus tempo, looping, and output format control.
- Routes output through the mixer bus so playback fits the engine audio graph.
- Gives Lua a stable player surface for song-driven sequencing and testing.

### [state.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/midi/state.rs)

- Storage for loaded MIDI SoundFont data and its source path.
- Validates SoundFont files before they enter the playback pipeline.
- Exposes query and clear helpers for runtime availability checks.
- Keeps the shared sample resource separate from transport state.
