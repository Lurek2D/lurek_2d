//! MIDI input and playback sub-system: device discovery, event routing, and sequencing.

/// Full MIDI playback controller with transport and per-channel controls.
pub mod player;
/// SoundFont binary data storage and validation.
pub mod state;

pub use player::MidiPlayer;
pub use state::MidiState;
