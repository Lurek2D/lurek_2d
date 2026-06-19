//! This file owns lightweight diagnostic summaries shared by procgen generators that expose safe reports.
//! It centralizes seed, cell-count, iteration, and attempt metadata so feature-specific reports stay consistent.
//! Open it when a generator needs to surface deterministic run context or bounded-work diagnostics.

/// Shared summary metadata attached to procgen reports.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct ProcgenReport {
    /// Seed or RNG state snapshot when the generator has one.
    pub seed: Option<u64>,
    /// Total cell count touched or produced by the generator.
    pub cell_count: usize,
    /// Number of iterations or passes executed.
    pub iterations: u32,
    /// Number of attempts or retries executed.
    pub attempts: u32,
}
