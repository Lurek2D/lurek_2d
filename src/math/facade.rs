//! Foundational math free functions: `lerp`, `remap`, `clamp`, `sign`, `smoothstep`, `inverse_lerp`.

/// Linear interpolation between `a` and `b` by factor `t` in [0, 1].
///
/// # Parameters
/// - `a` — `f32`.
/// - `b` — `f32`.
/// - `t` — `f32`.
///
/// # Returns
/// `f32`.
pub fn lerp(a: f32, b: f32, t: f32) -> f32 {
    a + t * (b - a)
}

/// Remap `v` from `[in_min, in_max]` to `[out_min, out_max]`.
///
/// # Parameters
/// - `v` — `f32`.
/// - `in_min` — `f32`.
/// - `in_max` — `f32`.
/// - `out_min` — `f32`.
/// - `out_max` — `f32`.
///
/// # Returns
/// `f32`.
pub fn remap(v: f32, in_min: f32, in_max: f32, out_min: f32, out_max: f32) -> f32 {
    // Guard against near-zero input range to avoid division by zero
    let t = if (in_max - in_min).abs() < 1e-7 { 0.0 } else { (v - in_min) / (in_max - in_min) };
    out_min + t * (out_max - out_min)
}

/// Clamp `v` to the range `[min, max]`.
///
/// # Parameters
/// - `v` — Value to clamp.
/// - `min` — Lower bound.
/// - `max` — Upper bound.
///
/// # Returns
/// `f32` — `v` clamped to `[min, max]`.
pub fn clamp(v: f32, min: f32, max: f32) -> f32 {
    if v < min {
        min
    } else if v > max {
        max
    } else {
        v
    }
}

/// Returns the sign of `v`: `1.0` if positive, `-1.0` if negative, `0.0` if zero.
///
/// # Parameters
/// - `v` — `f32`.
///
/// # Returns
/// `f32` — `-1.0`, `0.0`, or `1.0`.
pub fn sign(v: f32) -> f32 {
    if v > 0.0 {
        1.0
    } else if v < 0.0 {
        -1.0
    } else {
        0.0
    }
}

/// Hermite smooth interpolation between 0 and 1 when `x` is in `[edge0, edge1]`.
///
/// Returns 0 if `x <= edge0`, 1 if `x >= edge1`, and a smooth cubic curve in between.
///
/// # Parameters
/// - `edge0` — Lower edge of the transition.
/// - `edge1` — Upper edge of the transition.
/// - `x` — Input value.
///
/// # Returns
/// `f32` — Smoothly interpolated value in `[0, 1]`.
pub fn smoothstep(edge0: f32, edge1: f32, x: f32) -> f32 {
    let t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    t * t * (3.0 - 2.0 * t)
}

/// Inverse linear interpolation: returns the `t` factor such that `lerp(a, b, t) ≈ v`.
///
/// # Parameters
/// - `a` — Start value.
/// - `b` — End value.
/// - `v` — Value between `a` and `b`.
///
/// # Returns
/// `f32` — Interpolation factor; `0.0` if `a ≈ b`.
pub fn inverse_lerp(a: f32, b: f32, v: f32) -> f32 {
    if (b - a).abs() < 1e-7 {
        0.0
    } else {
        (v - a) / (b - a)
    }
}
