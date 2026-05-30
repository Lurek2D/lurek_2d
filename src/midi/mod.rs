//! MIDI subsystem for device discovery, event routing, and sequenced playback.
//! Bridges live MIDI input, software rendering, and hardware output from one module.
//! Keeps device refresh and callback delivery aligned with the engine tick.

/// Full MIDI playback controller with transport and per-channel controls.
pub mod player;
/// SoundFont binary data storage and validation.
pub mod state;

pub use player::MidiPlayer;
pub use state::MidiState;
