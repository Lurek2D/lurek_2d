//! Keyframe-based animation curves with per-segment easing.
//!
//! An [`AnimCurve`] holds a list of `(time, value)` keyframes in ascending time
//! order and evaluates the interpolated value at any time `t` using the selected
//! [`EasingKind`].

use crate::math::easing;

// ── EasingKind ──────────────────────────────────────────────────────────────

/// Interpolation mode applied between each pair of consecutive keyframes.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum EasingKind {
    /// Constant hold — output equals the value of the preceding keyframe.
    Step,
    /// Linear interpolation.
    Linear,
    /// Smooth ease-in.
    EaseIn,
    /// Smooth ease-out.
    EaseOut,
    /// Smooth ease-in-out.
    EaseInOut,
}

// ── AnimCurve ────────────────────────────────────────────────────────────────

/// A keyframe-based animation curve.
///
/// Each `keyframe` entry is a `(time: f32, value: f32)` pair.  Keyframes must
/// be kept in ascending time order — [`AnimCurve::add_keyframe`] inserts them
/// in sorted position automatically.  [`AnimCurve::eval`] evaluates the curve
/// at any time by locating the surrounding pair and applying the chosen
/// [`EasingKind`].
#[derive(Debug, Clone)]
pub struct AnimCurve {
    /// Sorted (time, value) keyframe pairs.
    keyframes: Vec<(f32, f32)>,
    /// Default easing applied between keyframes when not otherwise overridden.
    pub easing: EasingKind,
}

impl AnimCurve {
    /// Creates an empty `AnimCurve` with [`EasingKind::Linear`] interpolation.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self {
            keyframes: Vec::new(),
            easing: EasingKind::Linear,
        }
    }

    /// Creates an empty `AnimCurve` with the given easing kind.
    ///
    /// # Parameters
    /// - `easing` — [`EasingKind`].
    ///
    /// # Returns
    /// `Self`.
    pub fn with_easing(easing: EasingKind) -> Self {
        Self {
            keyframes: Vec::new(),
            easing,
        }
    }

    /// Adds a keyframe, keeping the internal list sorted by time.
    ///
    /// If a keyframe at the exact same time already exists it is replaced.
    ///
    /// # Parameters
    /// - `time` — `f32`.
    /// - `value` — `f32`.
    pub fn add_keyframe(&mut self, time: f32, value: f32) {
        match self
            .keyframes
            .binary_search_by(|(t, _)| t.partial_cmp(&time).unwrap_or(std::cmp::Ordering::Equal))
        {
            Ok(pos) => self.keyframes[pos] = (time, value),
            Err(pos) => self.keyframes.insert(pos, (time, value)),
        }
    }

    /// Returns the number of keyframes.
    pub fn keyframe_count(&self) -> usize {
        self.keyframes.len()
    }

    /// Removes all keyframes.
    pub fn clear(&mut self) {
        self.keyframes.clear();
    }

    /// Evaluates the curve at the given time.
    ///
    /// - Returns `0.0` if there are no keyframes.
    /// - Returns the first keyframe value if `t` precedes all keyframes.
    /// - Returns the last keyframe value if `t` follows all keyframes.
    /// - Interpolates between the surrounding pair otherwise.
    ///
    /// # Parameters
    /// - `t` — evaluation time in the same units as the keyframes.
    ///
    /// # Returns
    /// `f32` — interpolated value.
    pub fn eval(&self, t: f32) -> f32 {
        match self.keyframes.len() {
            0 => 0.0,
            1 => self.keyframes[0].1,
            _ => {
                let last = self.keyframes.last().unwrap();
                if t <= self.keyframes[0].0 {
                    return self.keyframes[0].1;
                }
                if t >= last.0 {
                    return last.1;
                }
                // Find the segment: keyframes[i].0 <= t < keyframes[i+1].0
                let pos = self
                    .keyframes
                    .partition_point(|(kf_t, _)| *kf_t <= t)
                    .saturating_sub(1);
                let (t0, v0) = self.keyframes[pos];
                let (t1, v1) = self.keyframes[pos + 1];
                let span = t1 - t0;
                if span <= f32::EPSILON {
                    return v1;
                }
                let alpha = (t - t0) / span;
                let alpha_eased = match self.easing {
                    EasingKind::Step => 0.0,
                    EasingKind::Linear => easing::linear(alpha),
                    EasingKind::EaseIn => easing::ease_in_quad(alpha),
                    EasingKind::EaseOut => easing::ease_out_quad(alpha),
                    EasingKind::EaseInOut => easing::ease_in_out_quad(alpha),
                };
                v0 + (v1 - v0) * alpha_eased
            }
        }
    }
}

impl Default for AnimCurve {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn eval_empty_returns_zero() {
        let c = AnimCurve::new();
        assert!((c.eval(0.5) - 0.0).abs() < 1e-5);
    }

    #[test]
    fn eval_single_keyframe_returns_value() {
        let mut c = AnimCurve::new();
        c.add_keyframe(1.0, 42.0);
        assert!((c.eval(0.0) - 42.0).abs() < 1e-5);
        assert!((c.eval(2.0) - 42.0).abs() < 1e-5);
    }

    #[test]
    fn eval_linear_midpoint() {
        let mut c = AnimCurve::with_easing(EasingKind::Linear);
        c.add_keyframe(0.0, 0.0);
        c.add_keyframe(1.0, 10.0);
        assert!((c.eval(0.5) - 5.0).abs() < 1e-4);
    }

    #[test]
    fn add_keyframe_keeps_sorted_order() {
        let mut c = AnimCurve::new();
        c.add_keyframe(0.5, 1.0);
        c.add_keyframe(0.0, 0.0);
        c.add_keyframe(1.0, 2.0);
        assert_eq!(c.keyframes[0].0, 0.0);
        assert_eq!(c.keyframes[1].0, 0.5);
        assert_eq!(c.keyframes[2].0, 1.0);
    }

    #[test]
    fn eval_step_holds_previous_value() {
        let mut c = AnimCurve::with_easing(EasingKind::Step);
        c.add_keyframe(0.0, 5.0);
        c.add_keyframe(1.0, 10.0);
        // Step at 0.5 should still be v0=5 (alpha 0.5 → eased α=0.0 → v0)
        assert!((c.eval(0.5) - 5.0).abs() < 1e-4);
    }
}
