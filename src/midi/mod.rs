//! `src/midi/mod.rs` is the module index that exposes MIDI playback state and SoundFont storage through one boundary.
//! It reexports `MidiPlayer` and `MidiState` so runtime code and Lua-facing layers consume one stable MIDI surface.
//! No transport or synthesis state lives here; this file only declares child modules and chooses what becomes public.
//! Read this index when wiring audio features, because it shows where playback control ends and asset state begins.
//! Changes here reshape the MIDI boundary, since reexports decide what engine code may import without deep paths.
//! This module keeps transport behavior and SoundFont ownership separate, which makes future MIDI work easier to place.

/// Full MIDI playback controller with transport and per-channel controls.
pub mod player;
/// SoundFont binary data storage and validation.
pub mod state;

pub use player::MidiPlayer;
pub use state::MidiState;
