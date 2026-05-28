//! MIDI input and playback sub-system: device discovery, event routing, and sequencing.
//!
//! - Enumerates MIDI devices via the `midir` crate; device list is refreshed on demand.
//! - Incoming MIDI events are translated to `lurek.midi.*` Lua callbacks each tick.
//! - The built-in sequencer plays SMF (`.mid`) files via the audio mixer.
//! - MIDI output (to hardware synths) is also supported if an output port is open.

/// Full MIDI playback controller with transport and per-channel controls.
pub mod player;
/// SoundFont binary data storage and validation.
pub mod state;

pub use player::MidiPlayer;
pub use state::MidiState;
