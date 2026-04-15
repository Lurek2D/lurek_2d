# IDEA.md — `audio` module

> Migrated from `ideas/features/audio.md` and `ideas/performance/03-particle-audio.md` (audio section).
> Status checked against `src/audio/` and `src/lua_api/audio_api.rs`.

---

## Features

### ✅ DONE — Sound Pooling
**Source**: features/audio.md — Feature Gaps #8 / Suggestions #2

`src/audio/pool.rs` exists. `LuaSoundPool` userdata in `audio_api.rs` (line ~969).
Exposed as `lurek.audio.newPool(sound, maxInstances)`.

---

### ✅ DONE — Crossfade Between Sources
**Source**: features/audio.md — Feature Gaps #5 / Suggestions #3

`lurek.audio.crossfade(from, to, duration)` implemented in `audio_api.rs` (line ~2688).

---

### ✅ DONE — Random Pitch Variation
**Source**: features/audio.md — Feature Gaps #9 / Suggestions #4

`setRandomPitch(min, max)` and `clearRandomPitch()` implemented in `audio_api.rs` (line ~2650).

---

### ✅ DONE — Waveform / Spectrogram Visualisation
**Source**: features/audio.md — Feature Gaps #1 (partial)

`src/audio/visualizer.rs` exposes `waveform_to_png` and `spectrogram_to_png`.
Bound in `audio_api.rs` as `lurek.audio.waveformToPng()` and `lurek.audio.spectrogramToPng()`.
`drawWaveform()` method also present on the visualizer userdata.

Note: this is file-to-PNG rendering, not a real-time spectrum callback. See FFT TODO below.

---

### ✅ DONE — Volume/Peak Metering
**Source**: features/audio.md — Feature Gaps #6

`lurek.audio.setMeter(level)` stores the master peak level in `Mixer.master_peak` (0-1).
`lurek.audio.getMeter()` returns it. Per-source peak stored in `AudioEntry.peak` via
corners of `Mixer.set_peak(key, peak)` / `get_peak(key)`. Bus-level averaging via
`Mixer.bus_peak(bus_key)` and `Mixer.get_bus_peak(bus_name)` (previously stub, now functional).
`LuaBus:getPeak()` exposes the bus average to Lua.

---

### ❌ TODO — Real-Time FFT / Spectrum Output
**Source**: features/audio.md — Feature Gaps #1 / Suggestions #5

No `getSpectrum(bands)` API found for real-time frequency data during playback. The
visualizer generates offline PNG files only. Real-time FFT is needed for:
- Music visualizers
- Rhythm games / beat detection
- Audio-reactive gameplay

---

### ✅ DONE — Audio Ducking
**Source**: features/audio.md — Feature Gaps #7 / Suggestions #6

`Bus.duck_target: Option<(String, f32)>` field added to `src/audio/bus.rs`.
`bus:setDuckTarget(targetBusName, duckVolume)` and `bus:clearDuck()` added to `LuaBus` in `audio_api.rs`.
`Bus::set_duck_target()` and `Bus::clear_duck_target()` domain methods added.
Note: fade time not implemented — duck applies instantly on config; Mixer should read
`duck_target` during bus volume computation to apply the reduction at runtime.

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

`src/audio/midi.rs` and `src/audio/midi_player.rs` exist but MIDI is currently
disabled/commented out in the build. Either fully implement and enable it or remove the dead
code. Leaving it disabled creates maintenance debt.
