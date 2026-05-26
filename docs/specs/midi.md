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

### `mod.rs`
- MIDI input and playback sub-system: device discovery, event routing, and sequencing.
- Enumerates MIDI devices via the `midir` crate; device list is refreshed on demand.
- Incoming MIDI events are translated to `lurek.midi.*` Lua callbacks each tick.
- The built-in sequencer plays SMF (`.mid`) files via the audio mixer.
- MIDI output (to hardware synths) is also supported if an output port is open.

### `player.rs`
- `MidiPlayer` stateful transport controller for MIDI file playback via rendered PCM.
- File loading with parsed metadata: duration, BPM, ticks-per-beat, track names, note count.
- Transport controls: play, stop, pause, resume, seek, tell, and duration queries.
- Per-channel volume, mute, instrument, and solo/unsolo operations across 16 MIDI channels.
- Per-track mute support keyed by track index.
- Configurable tempo scaling, looping, and output sample rate / channel count.
- Mixer bus assignment via `BusKey` for routed playback.
- `MidiData` metadata struct storing parsed song-level attributes.
- Helper functions for MIDI note-to-frequency conversion and sine-wave note rendering.

### `state.rs`
- `MidiState` storage for loaded SoundFont binary data and its source path.
- RIFF+sfbk header validation on `set_soundfont` to reject malformed SF2 files.
- Query and clear helpers for SoundFont availability and data access.

## Types

- `MidiData` (`struct`, `player.rs`): Parsed metadata extracted from a MIDI file and used for transport/introspection queries.
- `MidiPlayer` (`struct`, `player.rs`): Stateful MIDI transport and playback controller backed by a rodio sink.
- `MidiState` (`struct`, `state.rs`): Stores the loaded SoundFont binary data and its source path for MIDI synthesis.

## Functions

- `MidiPlayer::new` (`player.rs`): Create a new MIDI player with default transport, channel, and output settings.
- `MidiPlayer::load` (`player.rs`): Load MIDI bytes from `path` and pass them to `load_data`; return `false` on read or parse failure.
- `MidiPlayer::load_data` (`player.rs`): Parse and prepare raw MIDI bytes for playback; currently disabled and always return `false`.
- `MidiPlayer::is_loaded` (`player.rs`): Return `true` when parsed MIDI metadata is present.
- `MidiPlayer::file_path` (`player.rs`): Return the loaded MIDI file path, or `None` when no file is loaded.
- `MidiPlayer::play` (`player.rs`): Render the loaded MIDI to PCM and start playback on `stream_handle`; no-op if data is missing.
- `MidiPlayer::stop` (`player.rs`): Stop playback, drop the sink, reset playhead to 0, and set state to `Stopped`.
- `MidiPlayer::pause` (`player.rs`): Pause the active sink and set state to `Paused`.
- `MidiPlayer::resume` (`player.rs`): Resume the active sink and transition from `Paused` to `Playing`.
- `MidiPlayer::is_playing` (`player.rs`): Return `true` when playback state is `Playing`.
- `MidiPlayer::is_paused` (`player.rs`): Return `true` when playback state is `Paused`.
- `MidiPlayer::seek` (`player.rs`): Move the transport playhead to `secs`, clamped to >= 0.0.
- `MidiPlayer::tell` (`player.rs`): Return the current transport playhead position in seconds.
- `MidiPlayer::duration` (`player.rs`): Return song duration in seconds from metadata, or 0.0 if no MIDI is loaded.
- `MidiPlayer::set_volume` (`player.rs`): Set output gain multiplier; values below 0.0 are clamped to 0.0.
- `MidiPlayer::volume` (`player.rs`): Return the current output gain multiplier.
- `MidiPlayer::set_looping` (`player.rs`): Enable or disable infinite playback looping.
- `MidiPlayer::is_looping` (`player.rs`): Return `true` when looping playback is enabled.
- `MidiPlayer::set_tempo_scale` (`player.rs`): Set tempo multiplier; clamped to at least 0.01.
- `MidiPlayer::tempo_scale` (`player.rs`): Return the current tempo multiplier.
- `MidiPlayer::current_bpm` (`player.rs`): Return the current effective BPM after tempo scaling.
- `MidiPlayer::original_tempo` (`player.rs`): Return original BPM from MIDI metadata, or 120.0 when metadata is unavailable.
- `MidiPlayer::ticks_per_beat` (`player.rs`): Return MIDI ticks-per-beat from metadata, or 0 when unavailable.
- `MidiPlayer::set_channel_volume` (`player.rs`): Set channel volume for channel `ch` in 0..16; ignored for out-of-range channels.
- `MidiPlayer::channel_volume` (`player.rs`): Return channel volume for `ch`, or 0.0 when `ch` is out of range.
- `MidiPlayer::set_channel_muted` (`player.rs`): Set mute state for channel `ch` in 0..16; ignored for out-of-range channels.
- `MidiPlayer::is_channel_muted` (`player.rs`): Return `true` when channel `ch` is muted and in range.
- `MidiPlayer::set_channel_instrument` (`player.rs`): Set program/instrument number for channel `ch` in 0..16; ignored when out of range.
- `MidiPlayer::channel_instrument` (`player.rs`): Return instrument number for channel `ch`, or 0 when out of range.
- `MidiPlayer::channel_count` (`player.rs`): Return number of channels that contain note data in loaded metadata.
- `MidiPlayer::solo_channel` (`player.rs`): Solo channel `ch` by muting all other channels.
- `MidiPlayer::unsolo_all` (`player.rs`): Clear all channel mutes set by `solo_channel`.
- `MidiPlayer::track_count` (`player.rs`): Return number of tracks in loaded metadata.
- `MidiPlayer::track_name` (`player.rs`): Return optional track name for `idx`, or `None` if unavailable.
- `MidiPlayer::set_track_muted` (`player.rs`): Set mute state for track `idx`; ignored if out of range.
- `MidiPlayer::is_track_muted` (`player.rs`): Return `true` when track `idx` exists and is muted.
- `MidiPlayer::note_count` (`player.rs`): Return total note event count in loaded metadata.
- `MidiPlayer::set_bus_key` (`player.rs`): Assign or clear the mixer bus key used for this MIDI source.
- `MidiPlayer::bus_key` (`player.rs`): Return the assigned mixer bus key, if any.
- `MidiPlayer::play_state` (`player.rs`): Return current transport state.
- `MidiPlayer::get_output_sample_rate` (`player.rs`): Return output sample rate used by MIDI PCM rendering.
- `MidiPlayer::set_output_sample_rate` (`player.rs`): Set output sample rate, clamped to 8000..=192000 Hz.
- `MidiPlayer::get_output_channels` (`player.rs`): Return output channel count used by MIDI PCM rendering.
- `MidiPlayer::set_output_channels` (`player.rs`): Set output channel count, clamped to mono or stereo (1..=2).
- `MidiState::new` (`state.rs`): Create a new `MidiState` with no SoundFont loaded.
- `MidiState::set_soundfont` (`state.rs`): Load `data` as an SF2 SoundFont, validating the RIFF+sfbk header; error if invalid.
- `MidiState::has_soundfont` (`state.rs`): Return `true` when a SoundFont is loaded and ready for synthesis.
- `MidiState::clear_soundfont` (`state.rs`): Unload the current SoundFont and clear its path.
- `MidiState::soundfont_path` (`state.rs`): Return the source path of the loaded SoundFont, or `None` if none was loaded or path was not provided.
- `MidiState::soundfont_data` (`state.rs`): Return a byte slice of the loaded SoundFont binary, or `None` if not loaded.

## Lua API Reference

- Binding path(s): `src/lua_api/midi_api.rs`
- Namespace: `lurek.midi`

### Module Functions
- `lurek.midi.newPlayer`: Creates a new MIDI player instance, optionally loading a file immediately.
- `lurek.midi.loadSoundFont`: Loads a SoundFont (SF2) file into the global MIDI state for synthesis.
- `lurek.midi.hasSoundFont`: Returns whether a SoundFont is currently loaded and ready for synthesis.
- `lurek.midi.clearSoundFont`: Unloads the current SoundFont and frees its memory.

## References

- `audio`: Imports or references `src/audio/`. Cross-group dependency from ``Platform Services`` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from ``Platform Services`` into `Core Runtime`.

## Notes

- Keep this module reference synchronized with `src/midi/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
