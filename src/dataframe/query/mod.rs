//! This module is the query index, grouping filter, processing, analytics, and window extensions over `DataFrame`.
//! It exposes `analytics`, `filter`, `grouping`, `processing`, and `window` from one focused table-transform surface.
//! `filter.rs` owns row selection and joins, `grouping.rs` owns keyed reshaping, and `window.rs` owns ordered spans.
//! `processing.rs` covers diagnostics and date helpers, while `analytics.rs` adds scaling, mode, and entropy utilities.
//! Only `percentile` is reexported here; all other behavior stays attached to `DataFrame` impl blocks in sibling files.
//! Open this file to navigate query ownership quickly; storage, codecs, and SQL grammar live outside this submodule.

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
