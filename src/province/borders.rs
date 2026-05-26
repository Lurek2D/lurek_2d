//! Province border geometry: border index map, dilation, and edge detection.
//!
//! - `build_border_index` converts a raw province-ID grid into a border pixel mask.
//! - `dilate_border_index_with_styles` expands border pixels by per-pair style thickness.
//! - `build_border_index_from_registry` reads the current registry pixel buffer directly.
//! - Output is an `R16Uint` texture uploaded via `province::gpu_upload`.
