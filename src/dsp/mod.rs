//! Digital signal processing (DSP) sub-system: graph, nodes, and effect chain.
//!
//! - Provides a per-source processing graph evaluated on the audio thread.
//! - Node types include: gain, pan, low-pass/high-pass filters, reverb, and delay.
//! - Graph topology changes are sent via a lock-free command queue to avoid blocking.
//! - Re-exported to Lua via `lurek.audio.dsp.*` through `audio_api.rs`.

/// DSP effect types, parameters, active effect state, and the dynamic effect source wrapper.
pub mod effects;
/// Re-exports of the shared effect graph types.
pub mod graph;
/// Offline audio processing: apply effects to files without real-time playback.
pub mod offline;
/// Waveform and spectrogram PNG rendering.
pub mod visualizer;

pub use effects::{ActiveEffect, AtomicParam, DynamicEffectSource, EffectParams, EffectType};
pub use effects::SharedEffectGraph;
pub use offline::OfflineEffect;
