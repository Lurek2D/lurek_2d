//! Audio subsystem module: mixer, buses, decoders, pools, and device enumeration.
//!
//! - Re-exports primary types: `Mixer`, `Bus`, `Decoder`, `SoundData`, `SoundPool`.
//! - DSP effects are in `crate::dsp`; MIDI playback is in `crate::midi`.

/// `Bus` struct: named per-channel volume/pitch routing with effect chain and duck target.
pub mod bus;
/// `Decoder` struct: seeks and decodes audio files (WAV/OGG/MP3/FLAC) into PCM samples.
pub mod decoder;
/// `Mixer`: rodio-backed slot-map of sources and buses; owns playback, spatial, and peak state.
pub mod mixer;
/// `AudioSource` and `SpatialState`: per-source identity and spatial position/velocity/orientation.
pub mod source;
pub use bus::Bus;
pub use decoder::Decoder;
pub use mixer::Mixer;
pub use mixer::PlayState;
pub use mixer::QueueableSource;
pub use mixer::SourceType;
pub use source::AudioSource;
pub use source::SpatialState;
/// `SoundData`: in-memory PCM sample buffer with WAV encode, sine-wave generation, and Lua interop.
pub mod sound_data;
pub use sound_data::SoundData;
/// `SoundPool`: polyphonic round-robin voice pool for one-shot sound playback.
pub mod pool;
pub use pool::SoundPool;
/// Device enumeration and selection stubs: `get_playback_devices`, `get_playback_device`, `set_playback_device`.
pub mod facade;
pub use facade::{get_playback_device, get_playback_devices, set_playback_device};

// ── Backward-compatibility re-exports from extracted modules ────────────────
pub use crate::dsp::{AtomicParam, DynamicEffectSource, EffectParams, EffectType, SharedEffectGraph};
pub use crate::dsp::OfflineEffect;
pub use crate::midi::{MidiPlayer, MidiState};

/// Musical beat clock: BPM tracking, tap-tempo, beat scheduling, quantisation.
pub mod beat_clock;
pub use beat_clock::BeatClock;
pub use beat_clock::BeatClockEvents;
pub use beat_clock::BeatClockOpts;
pub use beat_clock::JudgementResult;
pub use beat_clock::JudgementWindows;
