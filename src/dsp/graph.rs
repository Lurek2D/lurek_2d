//! DSP processing graph: nodes connected by typed audio-rate and control-rate edges.
//!
//! - `DspGraph` owns a topologically sorted list of `DspNode` processing units.
//! - Edges carry either audio frames (f32 interleaved) or scalar control signals.
//! - Evaluated once per audio buffer in the rodio callback on the audio thread.
//! - Graph mutation (add/remove node, patch edge) is performed from the game thread
//!   via a lock-free command queue consumed at the start of each audio callback.

pub use super::effects::{DynamicEffectSource, SharedEffectGraph};
