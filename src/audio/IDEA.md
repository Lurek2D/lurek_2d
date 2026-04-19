# IDEA — `src/audio/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.

---

## 1. Header

- **Module**: `audio`
- **Owner module path**: `src/audio/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy**: `TIER-1-PLUGIN`
- **LOC (rust only)**: ~3300 · **Public Lua surface**: `lurek.audio` — ~55 fns / 1 userdata (SoundData)
- **Inbound non-`lua_api` callers**: `app` (audio init/shutdown)
- **Heavy dependencies**: `rodio` (playback), `gilrs` (none), `hound` (WAV encode — via SoundData)

## 2. Mission Summary

Full audio subsystem: playback, mixing, spatial audio, DSP effects, buses, sound pooling,
offline processing, and waveform generation. Serves EngDev (mixer integration), GameDev
(sound playback and effects from Lua), and GameTest (offline audio verification).
Deliberately NOT a music authoring DAW — no multi-track recording, no MIDI sequencer
(MIDI stubs exist but are disabled).

## 3. Existing Strengths

- SlotMap-based voice tracking in `mixer.rs` — O(1) lookup, no dangling references.
- Bus system (`bus.rs`) with per-bus volume, pitch, pause, and chained DSP effects.
- 15 DSP effect types with atomic parameter control (`dsp.rs`) — thread-safe real-time tuning.
- SoundData (`sound_data.rs`) with 5 waveform generators (sine, square, sawtooth, triangle, white noise).
- Sound pooling (`pool.rs`) for efficient SFX (gunshots, footsteps) without per-play allocation.
- Spatial audio with distance attenuation and panning in `source.rs`.
- Offline DSP processing (lowpass, highpass, bandpass, gain, mix) on SoundData buffers.

## 4. Gap List

1. **[P1][GAP]** `Real-time FFT / spectrum output` — no `getSpectrum(bands)` for live playback analysis.
   - Why: music visualizers, rhythm games, and beat detection require real-time frequency data.
2. **[P2][GAP]** `Audio recording / microphone capture` — no mic input API.
   - Why: voice chat, music creation tools, and audio-reactive games need capture.
3. **[P2][GAP]** `Audio node graph / routing` — DSP effects are per-source only; no routing graph.
   - Why: complex audio setups (reverb sends, side-chain compression) need flexible routing.
4. **[P3][GAP]** `MIDI playback` — `midi_player.rs` stubs exist but `midly` crate removed.
   - Why: chiptune and retro games benefit from MIDI; decision needed: restore or remove.

## 5. Feature Ideas

1. **[P1][FEAT]** `lurek.audio.getSpectrum(source, bands)` — Real-time FFT spectrum data.
   - Rationale: unlocks music visualizers, rhythm games, and audio-reactive gameplay.
   - Effort: L · Risk: med (real-time FFT on audio thread requires careful buffering).
   - Competitor inspiration: [FMOD: DSP::getParameterData for spectrum — fmod.com/docs/2.02/api/core-api-dsp.html].
2. **[P2][FEAT]** `lurek.audio.newBusRoute(from, to)` — Simple bus-to-bus routing for send effects.
   - Rationale: reverb/delay sends are the most common routing need; simpler than full node graph.
   - Effort: M · Risk: med (circular routing detection needed).
   - Competitor inspiration: [Godot: AudioServer bus routing — docs.godotengine.org/en/stable/classes/class_audioserver.html].
3. **[P3][FEAT]** `MIDI restore decision` — re-add `midly` crate or remove `midi_player.rs` stubs.
   - Rationale: dead code harms maintenance; decide: implement or clean up.
   - Effort: M (restore) or S (remove) · Risk: low.

## 6. Performance / Reliability / Quality Ideas

- **[P2][PERF]** `Mixer per-frame allocation` — `QueueableSource::fill_buffer` allocates Vec per call; could pre-allocate.
  - Hot path: `mixer.rs:500-550`.
  - Verification: `RUST_LOG=trace` + frame-time histogram under 64 simultaneous sources.
- **[P2][REL]** `Bus effect chain overflow` — no limit on effects per bus; 100+ effects could blow the audio budget.
  - Files: `bus.rs:80-90`.
  - Suggested fix: cap at 16 effects per bus with logged warning.
- **[P3][QUAL]** `MIDI disabled stubs cleanup` — `midi_player.rs` has 300 lines of commented/disabled code.
  - File: `midi_player.rs`.
  - Reason: either restore MIDI or remove the dead stubs to reduce maintenance noise.
- **[P3][QUAL]** `Decoder streaming chunk size` — `decoder.rs` hardcodes chunk size; should be configurable or bus-aware.
  - File: `decoder.rs:40`.
  - Reason: different use cases (music vs SFX) benefit from different chunk sizes.
- **[P1][QUAL]** `dsp.rs duplicate test module` — fixed: duplicate `#[cfg(test)] mod tests` block removed (was compilation error).
  - File: `dsp.rs:343`.
  - Reason: duplicate `mod tests` would fail to compile; stray `s ---` text after closing brace.
- **[P2][QUAL]** `mixer.rs get_bus() doc comment` — fixed: quadruplicated `///` doc block replaced with single canonical version.
  - File: `mixer.rs`.
  - Reason: copy-paste duplication of doc comments on `get_bus()`.

## 7. Test Coverage Gaps

- **[P1][TEST-RUST]** Add Rust unit test for `sound_data::SoundData` waveform generators and WAV encoding (now added).
- **[P1][TEST-RUST]** Add Rust unit test for `dsp::EffectParams` `set_param` for all effect types (now added).
- **[P1][TEST-RUST]** Add Rust unit test for `bus::Bus` volume/pitch/pause/ducking/effects (now added).
- **[P1][TEST-RUST]** Add Rust unit test for `decoder::Decoder` chunked decode/seek/tell (now added).
- **[P1][TEST-RUST]** Add Rust unit test for `mixer::Mixer` slot-map lifecycle, bus routing, filters, pools (now added — `mixer_tests.rs`).
- **[P2][TEST-RUST]** Add Rust unit test for `midi_player::MidiPlayer` state machine and parameter validation (now added).
- **[P2][TEST-LUA]** Add Lua BDD test for `lurek.audio.newSource`, `lurek.audio.play` under `tests/lua/audio/`.
- **[P2][TEST-RUST]** Add Rust unit test for `offline::process_offline` and `normalize_file` error paths (now added).
- **[P3][TEST-RUST]** Add Rust unit test for `visualizer::heat_colour` and error paths (now added).
- **[P3][TEST-FUZZ]** Fuzz target candidate: `sound_data::SoundData::from_lua_args` with extreme parameters.

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): effect::AudioEffect — effect module has audio-visual effect coupling that duplicates bus DSP chain
TODO(dedup): visualizer::export_waveform — overlaps with image::ImageData drawing; could share pixel-writing
```

## 9. TODO(helper): Engine-Level Helper Candidates

```text
TODO(helper): audio_manager — common play/stop/fadeIn/fadeOut pattern repeated in every game — citation: content/library/audio/init.lua:1
TODO(helper): music_player — playlist/shuffle/crossfade pattern seen in multiple demos — citation: content/examples/audio.lua:1
```

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): TIER-1-PLUGIN — audio is important but not every game needs sound; headless/server games can skip it. rodio is the heaviest non-GPU dependency.
```

- **Extraction blockers**: `app` calls mixer init/shutdown; `runtime::shared_state` holds `Mixer` via Rc<RefCell>.
- **Heavy dep impact if extracted**: `rodio` + `cpal` (~2 MB compiled); significant binary savings for headless builds.
- **Lua surface stability**: evolving (DSP and bus APIs still growing).
- **Migration step**: M2 (feature-flag `audio` → conditional compilation, then crate extraction).

## 11. References

- Module spec: [docs/specs/audio.md](../../../docs/specs/audio.md)
- Lua API reference: [docs/API/lua-api.md#audio](../../../docs/API/lua-api.md)
- Philosophy constraints touched: `B-03` (60 FPS — audio must not stall frame), `B-04` (no cross-VM audio state)
- Plugin doc tier table: [plugins.md §5](../../../docs/architecture/plugins.md#5-candidate-modules)
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
