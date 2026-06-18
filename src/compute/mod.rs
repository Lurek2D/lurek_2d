//! `src/compute/mod.rs` is the module index for dense arrays, transforms, analytics, linear algebra, ops, and spatial.
//! It declares the files that own core numeric containers, FFT helpers, reductions, geometry, and neighborhood processing.
//! This file reexports the main compute types so callers can use numeric services without importing deep internal paths.
//! No shape metadata, parallel thresholds, or transform buffers live here; it only defines visibility and boundaries.
//! Read this index first when tracing compute behavior, because it shows where storage, math, and derived metrics split.
//! Changes here affect reachability and API shape, not dtype validation, reduction rules, or transform implementations.

/// Exposes analytics helpers for cumulative and statistical operations.
pub mod analytics;
/// Exposes typed n-dimensional array container and constructors.
pub mod array;
/// Exposes fast Fourier transform and inverse transform helpers.
pub mod fft;
/// Exposes linear algebra and transformation helpers.
pub mod linalg;
/// Exposes element-wise and reduction operations over NdArray values.
pub mod ops;
/// Exposes spatial operators such as convolution and morphology.
pub mod spatial;
pub use array::{DataType, NdArray};
pub use fft::{fft, fft_magnitude, ifft};
pub use ops::{get_par_threshold, set_par_threshold};
