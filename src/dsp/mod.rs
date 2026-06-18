//! `src/dsp/mod.rs` is the module index for signal analysis, effects, graphs, offline processing, synthesis, and visuals.
//! It declares the files that own measurement, per-sample transforms, graph contracts, rendering, and file-based DSP work.
//! This file reexports the main DSP types so callers can assemble analysis and processing flows without deep imports.
//! No filter state, generated samples, or offline buffers live here; it only defines visibility and subsystem boundaries.
//! Read this index first when tracing DSP behavior, because it shows where runtime effects, synthesis, and tooling split.
//! Changes here affect reachability and API shape, not effect math, spectrum rules, or sample-generation semantics.

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
pub use effects::SharedEffectGraph;
pub use effects::{
    add_effect_to_shared_chain, remove_effect_from_shared_chain, set_shared_chain_effect_param,
    ActiveEffect, AtomicParam, DynamicEffectSource, EffectParams, EffectType,
};
pub use graph::{DspGraph, DspNode, DspNodeType, NodeId};
pub use offline::OfflineEffect;
pub use synthesis::{AdsrEnvelope, Synthesizer, Waveform};
