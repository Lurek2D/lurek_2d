//! This file owns the shared `EvolutionaryLayer` trait used by learning blocks that expose flat trainable parameters.
//! It defines the minimal contract for counting, importing, and exporting weights so optimizers can treat layers uniformly.
//! Open it when parameter-boundary semantics change; concrete layer math and training logic live in sibling files.

/// Contract for layers usable in neuroevolution workflows.
pub trait EvolutionaryLayer {
    /// Total number of trainable parameters (weights and biases).
    fn param_count(&self) -> usize;

    /// Load parameters from a flat buffer. Returns `false` when shape does not match.
    fn set_weights(&mut self, weights: &[f32]) -> bool;

    /// Export all trainable parameters as a flat buffer.
    fn get_weights(&self) -> Vec<f32>;
}
