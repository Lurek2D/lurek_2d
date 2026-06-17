//! Defines the dataframe query module boundary for filtering, grouping, processing, analytics, and window logic. `dataframe/query/mod` is the dataframe module index, declaring `analytics`, `filter`, `grouping`, `processing`, `window` so agents can identify which files own each feature slice before opening implementation code.
//! Groups query submodules under one cohesive extension surface over core frame structures. `src/dataframe/query/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `analytics::percentile` centralized for the dataframe subsystem.

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
