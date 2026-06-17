//! Defines the compute module boundary for array math, analytics, transforms, and spatial processing. `compute/mod` is the compute module index, declaring `analytics`, `array`, `fft`, `linalg`, `ops`, and 1 more so agents can identify which files own each feature slice before opening implementation code.
//! Groups core numeric submodules under one cohesive surface with shared data contracts. `src/compute/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `array::{DataType, NdArray}`, `fft::{fft, fft_magnitude, ifft}`, `ops::{get_par_threshold, set_par_threshold}` centralized for the compute subsystem.

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
