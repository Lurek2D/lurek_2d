//! Defines the compute module boundary for array math, analytics, transforms, and spatial processing.
//! Groups core numeric submodules under one cohesive surface with shared data contracts.
//! Serves as the composition entry for engine-side compute and numeric utility workflows.

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
