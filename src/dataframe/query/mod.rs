//! Defines the dataframe query module boundary for filtering, grouping, processing, analytics, and window logic.
//! Groups query submodules under one cohesive extension surface over core frame structures.
//! Serves as the composition entry for staged dataframe query operations.

/// Statistical and distribution-oriented query helpers.
pub mod analytics;
/// Row filtering, sorting, joins, and sampling helpers.
pub mod filter;
/// Grouped aggregation, pivoting, and correlation helpers.
pub mod grouping;
/// Reusable processing helpers for counts, missingness, duplicates, and dates.
pub mod processing;
/// Rolling and ranking window computations.
pub mod window;
pub use analytics::percentile;
