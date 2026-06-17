//! Defines the audio module boundary that groups playback, routing, decode, and source-data primitives. `audio/mod` is the audio module index, declaring `bus`, `decoder`, `mixer`, `source`, `sound_data`, and 3 more so agents can identify which files own each feature slice before opening implementation code.
//! Exposes coherent core audio contracts while delegating specialized processing to adjacent modules. `src/audio/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `bus::Bus`, `decoder::Decoder`, `mixer::Mixer`, `mixer::PlayState`, and 15 more centralized for the audio subsystem.
//! Serves as the composition entry for engine-side runtime audio behavior and shared types. The file documents how audio submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! `audio/mod` is the audio module index, declaring `bus`, `decoder`, `mixer`, `source`, `sound_data`, and 3 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/audio/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `bus::Bus`, `decoder::Decoder`, `mixer::Mixer`, `mixer::PlayState`, and 15 more centralized for the audio subsystem.
//! The file documents how audio submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

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
pub use crate::dsp::OfflineEffect;
pub use crate::dsp::{
    AtomicParam, DynamicEffectSource, EffectParams, EffectType, SharedEffectGraph,
};
pub use crate::midi::{MidiPlayer, MidiState};

/// Musical beat clock: BPM tracking, tap-tempo, beat scheduling, quantisation.
pub mod beat_clock;
pub use beat_clock::BeatClock;
pub use beat_clock::BeatClockEvents;
pub use beat_clock::BeatClockOpts;
pub use beat_clock::JudgementResult;
pub use beat_clock::JudgementWindows;
