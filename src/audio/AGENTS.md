# Audio Module Contract

## Mission & Scope
- Own playback, decode, buses, spatial source data, MIDI, and DSP routing.
- Keep long-running audio work off frame-critical paths.

## Files
- `mixer.rs`, `source.rs`, `bus.rs`: Runtime routing and source state.
- `decoder.rs`, `sound_data.rs`, `midi.rs`: Decode, buffers, and import paths.

## Rules
- Keep sample units explicit: frames vs interleaved samples vs seconds.
- Clamp gain, pitch, pan, and filter parameters at entry points.
- Do not share mutable mixer state without clear lock lifetime boundaries.

## Workflow
- Validate with `cargo test --test audio_tests`.
