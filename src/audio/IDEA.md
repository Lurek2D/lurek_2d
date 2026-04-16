# IDEA.md — `audio` module

> Migrated from `ideas/features/audio.md` and `ideas/performance/03-particle-audio.md` (audio section).
> Status checked against `src/audio/` and `src/lua_api/audio_api.rs`.

---

## Features

### ❌ TODO — Real-Time FFT / Spectrum Output
**Source**: features/audio.md — Feature Gaps #1 / Suggestions #5

No `getSpectrum(bands)` API found for real-time frequency data during playback. The
visualizer generates offline PNG files only. Real-time FFT is needed for:
- Music visualizers
- Rhythm games / beat detection
- Audio-reactive gameplay

---

### ❌ TODO — Audio Recording / Microphone Capture
**Source**: features/audio.md — Feature Gaps #2

No mic input or audio capture API exists. Lower priority — relevant for voice chat or music
creation tools.

---

### ❌ TODO — Audio Node Graph / Routing
**Source**: features/audio.md — Feature Gaps #4

DSP effects are per-source only. No node-based routing graph (source → reverb → EQ → bus →
master). Substantial architecture change — evaluate against scope constraints.

---

### 🤔 CONSIDER — Enable / Complete MIDI
**Source**: features/audio.md — Structural Issues

`src/audio/midi.rs` and `src/audio/midi_player.rs` exist with stub implementations.
The `midly` crate was removed from `Cargo.toml` due to dependency conflicts; function
bodies return empty results and log `A002_MIDI_DISABLED`. To re-enable:
1. Add `midly = "0.5"` back to `Cargo.toml`.
2. Uncomment the imports in `midi_player.rs` and restore the parse/render bodies from git.
3. Add `lurek.audio.loadMidi(path)` and `lurek.audio.playMidi(data, opts)` Lua bindings.
Decision needed: full implementation vs. removal to reduce maintenance debt.
