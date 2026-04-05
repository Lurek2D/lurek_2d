//! 2D Perlin and Simplex noise generators for procedural content.
//!
//! All standalone functions return values in `[-1.0, 1.0]`. Seed offsets
//! the gradient hash, producing different noise patterns per seed.
//!
//! Sub-modules:
//! - [`functions`] — standalone `perlin2d`, `simplex2d`, `fbm`, etc.
//! - [`generator`] — `NoiseGenerator`, `DistType`, `NoiseKind`, `FractalType`, `MapGenOptions`.

/// Standalone noise functions: `perlin2d`, `perlin3d`, `perlin4d`, `simplex2d`, `simplex_noise_2d`, `simplex_noise_3d`, and fractal Brownian motion (`fbm`).
pub mod functions;
/// Configurable noise generator: `NoiseGenerator`, `NoiseKind`, `FractalType`, `DistType`, and `MapGenOptions` for seeded, multi-octave noise maps.
pub mod generator;

pub use functions::{
    fbm, perlin2d, perlin3d, perlin4d, simplex2d, simplex_noise_2d, simplex_noise_3d,
};
pub use generator::{DistType, FractalType, MapGenOptions, NoiseGenerator, NoiseKind};
