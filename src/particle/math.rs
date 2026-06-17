//! Keyframe interpolation for particle size, colour, and alpha over normalized lifetime. `particle/math` delivers the math implementation for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Offers uniform and normal random helpers for emission variance. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Clamps interpolation inputs and falls back cleanly on empty keyframe sets. Public callable behavior is centered on `next_u64`, `rand_f32`, `interpolate_sizes`, `interpolate_colors`, `interpolate_alphas`, and 4 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! Supports the numeric shaping layer used by emitter animation. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

pub use crate::math::lerp;

/// Advances a small deterministic PRNG state and returns the next `u64` sample.
pub(crate) fn next_u64(state: &mut u64) -> u64 {
    *state = state.wrapping_add(0x9E37_79B9_7F4A_7C15);
    let mut z = *state;
    z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
    z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
    z ^ (z >> 31)
}

/// Returns a deterministic random `f32` in `[0.0, 1.0)`.
pub(crate) fn rand_f32(state: &mut u64) -> f32 {
    const SCALE: f32 = 1.0 / ((1u32 << 24) as f32);
    ((next_u64(state) >> 40) as u32 as f32) * SCALE
}
/// Evaluate the particle size at normalised lifetime `t` with optional per-particle `variation` in `[0.0, 1.0]`.
pub fn interpolate_sizes(sizes: &[f32], t: f32, variation: f32) -> f32 {
    if sizes.is_empty() {
        return 1.0;
    }
    if sizes.len() == 1 {
        return sizes[0] * (1.0 - variation);
    }
    let t = t.clamp(0.0, 1.0);
    let segments = (sizes.len() - 1) as f32;
    let pos = t * segments;
    let idx = (pos as usize).min(sizes.len() - 2);
    let local_t = pos - idx as f32;
    let base = lerp(sizes[idx], sizes[idx + 1], local_t);
    base * (1.0 - variation)
}
/// Evaluate the RGBA colour keyframe at normalised lifetime `t`; returns white when the slice is empty.
pub fn interpolate_colors(colors: &[[f32; 4]], t: f32) -> [f32; 4] {
    if colors.is_empty() {
        return [1.0, 1.0, 1.0, 1.0];
    }
    if colors.len() == 1 {
        return colors[0];
    }
    let t = t.clamp(0.0, 1.0);
    let segments = (colors.len() - 1) as f32;
    let pos = t * segments;
    let idx = (pos as usize).min(colors.len() - 2);
    let local_t = pos - idx as f32;
    [
        lerp(colors[idx][0], colors[idx + 1][0], local_t),
        lerp(colors[idx][1], colors[idx + 1][1], local_t),
        lerp(colors[idx][2], colors[idx + 1][2], local_t),
        lerp(colors[idx][3], colors[idx + 1][3], local_t),
    ]
}
/// Evaluate the alpha keyframe at normalised lifetime `t`; returns 1.0 when the slice is empty.
pub fn interpolate_alphas(alphas: &[f32], t: f32) -> f32 {
    if alphas.is_empty() {
        return 1.0;
    }
    if alphas.len() == 1 {
        return alphas[0];
    }
    let t = t.clamp(0.0, 1.0);
    let segments = (alphas.len() - 1) as f32;
    let pos = t * segments;
    let idx = (pos as usize).min(alphas.len() - 2);
    let local_t = pos - idx as f32;
    lerp(alphas[idx], alphas[idx + 1], local_t)
}
/// Return a uniform random `f32` in `[min, max]`; returns `min` when the range is degenerate.
pub(crate) fn rand_range(state: &mut u64, min: f32, max: f32) -> f32 {
    if (max - min).abs() < f32::EPSILON {
        return min;
    }
    min + rand_f32(state) * (max - min)
}
/// Return a Box-Muller normal sample with mean 0 and std 1.
pub(crate) fn rand_normal(state: &mut u64) -> f32 {
    let u1 = rand_f32(state).max(f32::EPSILON);
    let u2 = rand_f32(state);
    (-2.0 * u1.ln()).sqrt() * (2.0 * std::f32::consts::PI * u2).cos()
}

/// Returns a deterministic random `u32` in `[start, end)`.
pub(crate) fn rand_u32(state: &mut u64, start: u32, end: u32) -> u32 {
    if start >= end {
        return start;
    }
    let span = (end - start) as u64;
    start + (next_u64(state) % span) as u32
}

/// Returns a deterministic random `usize` in `[0, max_inclusive]`.
pub(crate) fn rand_usize_inclusive(state: &mut u64, max_inclusive: usize) -> usize {
    if max_inclusive == 0 {
        return 0;
    }
    (next_u64(state) % ((max_inclusive + 1) as u64)) as usize
}
