//! Small scalar helper layer for interpolation and numeric remapping. `math/facade` delivers the public facade over lower-level subsystem helpers for the math subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Groups lerp, inverse lerp, remap, smoothstep, clamp, and sign behavior. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Operates on f32 values only and stays side-effect free. Public callable behavior is centered on `lerp`, `remap`, `clamp`, `sign`, `smoothstep`, and 1 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.

/// Linearly interpolate from `a` to `b` by factor `t`; t=0 returns `a`, t=1 returns `b`.
pub fn lerp(a: f32, b: f32, t: f32) -> f32 {
    a + t * (b - a)
}
/// Map `v` from input range `[in_min, in_max]` to output range `[out_min, out_max]`; returns `out_min` when input range is zero-width.
pub fn remap(v: f32, in_min: f32, in_max: f32, out_min: f32, out_max: f32) -> f32 {
    let t = if (in_max - in_min).abs() < 1e-7 {
        0.0
    } else {
        (v - in_min) / (in_max - in_min)
    };
    out_min + t * (out_max - out_min)
}
/// Clamp `v` to `[min, max]`; returns `min` or `max` when `v` is outside the range.
pub fn clamp(v: f32, min: f32, max: f32) -> f32 {
    if v < min {
        min
    } else if v > max {
        max
    } else {
        v
    }
}
/// Return 1.0 for positive `v`, -1.0 for negative, and 0.0 for zero.
pub fn sign(v: f32) -> f32 {
    if v > 0.0 {
        1.0
    } else if v < 0.0 {
        -1.0
    } else {
        0.0
    }
}
/// Hermite smooth interpolation between `edge0` and `edge1`; clamps `x` before applying S-curve.
pub fn smoothstep(edge0: f32, edge1: f32, x: f32) -> f32 {
    let t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    t * t * (3.0 - 2.0 * t)
}
/// Return the `t` in `[a, b]` that produces `v` under lerp; returns 0.0 when `a == b`.
pub fn inverse_lerp(a: f32, b: f32, v: f32) -> f32 {
    if (b - a).abs() < 1e-7 {
        0.0
    } else {
        (v - a) / (b - a)
    }
}
