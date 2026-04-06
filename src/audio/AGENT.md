# `audio` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 1 |
| **Status** | Implemented — Full |
| **Lua API** | `luna.audio` |
| **Source** | `src/audio/` |
| **Rust Tests** | `tests/unit/audio_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_audio.lua`, `tests/lua/unit/test_audio_dsp.lua` |
| **Architecture** | `docs/API/audio-dsp-design.md` |

## Summary

The audio module wraps the `rodio` cross-platform audio library into a
game-oriented mixing layer, handling every stage of game audio from file
loading to final output.  It decodes sound files (WAV, OGG Vorbis, FLAC, MP3)
into static in-memory sources or streaming sources, controls per-source
playback state (volume, pitch, looping, fade in/out), routes sources through
named audio buses for grouped volume control (for example a dedicated "sfx"
bus and a "music" bus), and applies simple DSP effects (low-pass and
high-pass filtering) as rodio source wrappers.

Each active sound is stored as an `AudioEntry` in a `SlotMap<SoundKey>`.  The
`Mixer` owns the underlying `rodio::OutputStream` and manages the lifecycle
of all `rodio::Sink` handles; a poll on every frame reaps finished sinks and
keeps the active-source count bounded.  Spatial audio is approximated for 2D
games: panning is derived from the horizontal offset between a sound's world
position and the listener position, mapped to a stereo split via a linear
panning law.

A `MidiPlayer` provides synthesised music playback: MIDI events are parsed
with `midly` and rendered to PCM at 44 100 Hz using additive sine synthesis,
supporting per-channel mute, independent volume control on each track, and
real-time tempo changes encoded in the MIDI file.

## Architecture

```
Mixer (central audio manager)
  │
  ├── Sources ─── SlotMap<SoundKey, AudioEntry>
  │     ├── Static ── entire file decoded into memory
  │     └── Stream ── streaming from disk
  │
  ├── Playback control (per-source)
  │     ├── play / pause / resume / stop
  │     ├── set_volume / set_pitch / set_looping
  │     ├── fade_in (linear over duration)
  │     ├── seek (rebuilds sink for seek support)
  │     └── clone_source (Arc sharing of decoded data)
  │
  ├── Bus routing ─── named buses with volume/pitch/paused
  │     └── Bus { name, volume, pitch, paused }
  │
  ├── Effects
  │     ├── lowpass(source, cutoff_hz)
  │     └── highpass(source, cutoff_hz)
  │
  └── MidiPlayer ─── midly parsing + sine-additive PCM synthesis
        ├── Per-track/channel mute and volume
        ├── Tempo changes (microseconds per beat)
        └── Real-time rendering at 44100 Hz
```

## Source Files

| File | Purpose |
|------|---------|
| `bus.rs` | Named audio bus for grouping sources under shared volume, pitch, and pause... |
| `midi.rs` | MIDI SoundFont state management |
| `midi_player.rs` | Software MIDI synthesizer: parses MIDI with `midly`, renders to PCM |
| `mixer.rs` | Core audio mixer that owns every loaded sound and drives playback through rodio |
| `sound_data.rs` | Decoded PCM audio sample buffer with per-sample read/write access |
| `source.rs` | Audio source type and playback state enums for the audio subsystem |
| `decoder.rs` | TODO: describe purpose of decoder.rs |
| `dsp.rs` | TODO: describe purpose of dsp.rs |

## Submodules

### `audio::bus`

Named audio bus for grouping sources under shared volume, pitch, and pause controls.

- **`Bus`** (struct): A named audio bus that applies volume, pitch, and pause overrides to all sources assigned to it.  Buses are pure data...

### `audio::midi`

MIDI SoundFont state management.

- **`MidiState`** (struct): MIDI SoundFont state. Consult the module-level documentation for the broader usage context and preconditions.  Tracks...

### `audio::midi_player`

Software MIDI synthesizer: parses MIDI with `midly`, renders to PCM via sine-additive synthesis, and plays through a rodio `Sink`.

- **`MidiData`** (struct): Pre-parsed MIDI metadata extracted during `load()`.
- **`MidiPlayer`** (struct): Software MIDI player with sine-additive synthesis.  Parses MIDI via `midly`, renders all tracks to a PCM buffer on...

### `audio::mixer`

Core audio mixer that owns every loaded sound and drives playback through rodio.

- **`SourceType`** (enum): Type of audio source. Consult the module-level documentation for the broader usage context and preconditions.
- **`PlayState`** (enum): Playback state of an audio source. Consult the module-level documentation for the broader usage context and...
- **`Mixer`** (struct): Manages audio output via rodio: loads sources, controls playback, volume, pitch, pan, looping, fade effects, bus...

### `audio::sound_data`

Decoded PCM audio sample buffer with per-sample read/write access.

- **`SoundData`** (struct): Decoded audio samples in f32 PCM format.  Stores interleaved samples (for stereo: L, R, L, R, ...). Samples are always...

### `audio::source`

Audio source type and playback state enums for the audio subsystem.

- **`AudioSource`** (struct): Handle for a loaded audio asset (legacy compatibility shim).

## Key Types

### Structs

#### `audio::dsp::DynamicEffectSource`

Real-time audio DSP effect source wrapped around rodio streams.

#### `audio::dsp::SharedEffectGraph`

Thread-safe effect chain enabling parameter mutation during playback.

#### `audio::source::AudioSource`

Handle for a loaded audio asset (legacy compatibility shim).

#### `audio::bus::Bus`

A named audio bus that applies volume, pitch, and pause overrides to all sources assigned to it.  Buses are pure data...

#### `audio::midi_player::MidiData`

Pre-parsed MIDI metadata extracted during `load()`.

#### `audio::midi_player::MidiPlayer`

Software MIDI player with sine-additive synthesis.  Parses MIDI via `midly`, renders all tracks to a PCM buffer on...

#### `audio::midi::MidiState`

MIDI SoundFont state. Consult the module-level documentation for the broader usage context and preconditions.  Tracks...

#### `audio::mixer::Mixer`

Manages audio output via rodio: loads sources, controls playback, volume, pitch, pan, looping, fade effects, bus...

#### `audio::sound_data::SoundData`

Decoded audio samples in f32 PCM format.  Stores interleaved samples (for stereo: L, R, L, R, ...). Samples are always...

### Enums

#### `audio::mixer::PlayState`

Playback state of an audio source. Consult the module-level documentation for the broader usage context and...

#### `audio::mixer::SourceType`

Type of audio source. Consult the module-level documentation for the broader usage context and preconditions.

## Lua API

Exposed under `luna.audio.*` by `src/lua_api/audio_api/`. Includes functions for playback (`play`, `stop`, `pause`, `set_volume`), bus management (`set_bus_volume`, `get_bus_volume`, `pause_bus`), and real-time DSP effects (`add_effect`, `remove_effect`, `set_effect_param`).

## Item Summary

| Kind | Count |
|------|-------|
| `enum` | 2 |
| `mod` | 6 |
| `struct` | 7 |
| **Total** | **15** |

## Lua Examples

```lua
function luna.load()
    music = luna.audio.newSource("music.ogg", "stream")
    music:setLooping(true)
    music:setVolume(0.7)
    music:play()

    sfx = luna.audio.newSource("jump.wav", "static")
end

function luna.keypressed(key)
    if key == "space" then
        sfx:play()
    end
end
```

## References

| Module    | Relationship  | Notes                                              |
|-----------|-----------    |----------------------------------------------------|
| `engine`  | Imports from  | Uses `SharedState`, `SoundKey` from `resource_keys` |
| `math`    | Imports from  | Pure math utilities (none direct, indirect via engine) |
| `sound`   | Related       | `sound` provides decoded PCM buffers; `audio` owns playback engine |
| `lua_api` | Imported by   | `src/lua_api/audio_api/` registers `luna.audio.*` |

## Notes

- rodio 0.17 is the underlying playback library; do not call rodio types directly from Lua API code.
- On CI/headless systems, `Mixer::new()` falls back to a `Headless` sink that accepts all calls and silently discards audio.
- `SourceType::Stream` opens the file on each `play()` call; `SourceType::Static` decodes once and reuses the `Arc<[u8]>`.
- Volume range: 0.0 (silent) to 1.0 (full). Values above 1.0 are accepted but may clip.
- Audio buses (master, sfx, music, voice, ambient) apply multiplicative volume on top of per-source volume.
