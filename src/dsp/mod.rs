//! Digital signal processing (DSP) sub-system: graph, nodes, and effect chain.

/// Level and spectrum analysis helpers.
pub mod analysis;
/// DSP effect types, parameters, active effect state, and the dynamic effect source wrapper.
pub mod effects;
/// Re-exports of the shared effect graph types.
pub mod graph;
/// Offline audio processing: apply effects to files without real-time playback.
pub mod offline;
/// Waveform, ADSR envelope, and synthesizer helpers.
pub mod synthesis;
/// Waveform and spectrogram PNG rendering.
pub mod visualizer;

pub use analysis::{LevelDetector, SpectrumAnalyzer};
pub use effects::{
	add_effect_to_shared_chain, remove_effect_from_shared_chain, set_shared_chain_effect_param,
	ActiveEffect, AtomicParam, DynamicEffectSource, EffectParams, EffectType,
};
pub use effects::SharedEffectGraph;
pub use graph::{DspGraph, DspNode, DspNodeType, NodeId};
pub use offline::OfflineEffect;
pub use synthesis::{AdsrEnvelope, Synthesizer, Waveform};
