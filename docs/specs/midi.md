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

- The `midi` module is the playback surface for projects that want symbolic music control instead of treating every cue as rendered audio.
- It combines transport, playback state, and SoundFont-backed synthesis under one runtime surface.
- That makes it useful for adaptive scoring, live control, and note-driven playback.
- Read it as the bridge from MIDI data to audible output.

This module primarily collaborates with `audio`, `runtime`. Its responsibility should stay inside the `Platform Services` group rather than absorb behavior owned by those neighbors.

## Imports

- `audio`: Imports or references `src/audio/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.

## Files

### mod.rs

- `src/midi/mod.rs` is the module index that exposes MIDI playback state and SoundFont storage through one boundary.
- It reexports `MidiPlayer` and `MidiState` so runtime code and Lua-facing layers consume one stable MIDI surface.
- No transport or synthesis state lives here; this file only declares child modules and chooses what becomes public.
- Read this index when wiring audio features, because it shows where playback control ends and asset state begins.
- Changes here reshape the MIDI boundary, since reexports decide what engine code may import without deep paths.
- This module keeps transport behavior and SoundFont ownership separate, which makes future MIDI work easier to place.

### player.rs

- `src/midi/player.rs` owns MIDI transport state, loaded song metadata, and rodio-backed playback control.
- It defines `MidiData` and `MidiPlayer`, keeping file metadata, mix settings, output format, and playhead state together.
- Transport methods for load, play, stop, pause, resume, seek, looping, and volume changes are implemented here.
- Per-channel mute, solo, volume, instrument selection, and per-track mute controls also live in this controller.
- This file leaves `load_data` disabled and `render_to_pcm` empty, so transport structure exists before synthesis.
- Read it when MIDI runtime behavior, bus routing, output sample rules, or metadata queries need to change.
- Higher layers should treat this file as the transport boundary, while SoundFont asset ownership stays in `state.rs`.

### state.rs

- `src/midi/state.rs` owns the loaded SoundFont bytes and optional source path used by the MIDI subsystem.
- `MidiState` validates the RIFF and `sfbk` headers before accepting data, so bad SoundFont files fail early here.
- Availability checks, path lookup, raw byte access, and unload behavior all live here under one small state owner.
- Open this file when SoundFont lifetime, validation rules, or metadata exposure for synthesis setup must change.



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
