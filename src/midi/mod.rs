//! MIDI subsystem for device discovery, event routing, and sequenced playback. `midi/mod` is the midi module index, declaring `player`, `state` so agents can identify which files own each feature slice before opening implementation code.
//! Bridges live MIDI input, software rendering, and hardware output from one module. `src/midi/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `player::MidiPlayer`, `state::MidiState` centralized for the midi subsystem.

/// Full MIDI playback controller with transport and per-channel controls.
pub mod player;
/// SoundFont binary data storage and validation.
pub mod state;

pub use player::MidiPlayer;
pub use state::MidiState;
