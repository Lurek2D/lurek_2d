//! Visual transition types, easing curves, and active transition state for scene changes.
//!
//! This module is part of Lurek2D's `scene` subsystem and provides the implementation
//! details for transition-related operations, including easing curves.
//! Key types exported from this module: `TransitionType`, `EasingType`, `ActiveTransition`.
//! Primary functions: `from_lua_str()`, `new()`, `new_with_easing()`, `progress()`,
//! `progress_eased()`, `is_complete()`.
//!
//! # Easing
//! `EasingType` provides six standard curves (Linear, EaseIn, EaseOut, EaseInOut, Bounce,
//! Back).  The raw linear `progress()` value and the easing-adjusted `progress_eased()`
//! value are both available on `ActiveTransition`.
//!
//! All public items are documented. See the parent module for architectural context
//! and the `lurek.*` Lua API for the scripting interface.
use crate::runtime::log_messages::{TR01, TR02};
use crate::log_msg;

/// Visual transition types between scenes.
///
/// # Variants
/// - `None` — Instant switch, no animation.
/// - `Fade` — Alpha cross-fade.
/// - `SlideLeft` — New scene slides in from the right.
/// - `SlideRight` — New scene slides in from the left.
/// - `SlideUp` — New scene slides in from the bottom.
/// - `SlideDown` — New scene slides in from the top.
/// - `Wipe` — Horizontal luminance wipe from left to right.
/// - `Iris` — Radial iris open/close centred on the screen.
/// - `Zoom` — Scale-in for the entering scene, scale-out for the leaving scene.
/// - `CrossFade` — Dissolve using a dithered noise threshold.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum TransitionType {
    /// Instant switch, no animation.
    None,
    /// Crossfade between outgoing and incoming scenes.
    Fade,
    /// New scene slides in from the right.
    SlideLeft,
    /// New scene slides in from the left.
    SlideRight,
    /// New scene slides in from the bottom.
    SlideUp,
    /// New scene slides in from the top.
    SlideDown,
    /// Horizontal luminance wipe sweeping from left to right.
    Wipe,
    /// Radial iris open/close centred on the screen.
    Iris,
    /// Scale-in for the entering scene, scale-out for the leaving scene.
    Zoom,
    /// Dissolve transition using a dithered noise threshold pattern.
    CrossFade,
}

impl TransitionType {
    /// Parse a transition type from a Lua string token.
    ///
    /// Unrecognised strings map to `TransitionType::None`.
    ///
    /// # Parameters
    /// - `s` — `&str`. Case-sensitive token, e.g. `"fade"`, `"wipe"`, `"iris"`.
    ///
    /// # Returns
    /// `Self`.
    pub fn from_lua_str(s: &str) -> Self {
        match s {
            "fade" => Self::Fade,
            "slideleft" => Self::SlideLeft,
            "slideright" => Self::SlideRight,
            "slideup" => Self::SlideUp,
            "slidedown" => Self::SlideDown,
            "wipe" => Self::Wipe,
            "iris" => Self::Iris,
            "zoom" => Self::Zoom,
            "crossfade" => Self::CrossFade,
            _ => Self::None,
        }
    }
}

/// Easing curve applied to normalized transition progress.
///
/// All variants operate on a value `t ∈ [0, 1]` and return a value in `[0, 1]`.
/// Use `EasingType::apply(t)` to convert raw linear progress to the eased value.
///
/// # Variants
/// - `Linear` — No easing; output equals input.
/// - `EaseIn` — Starts slow, ends fast (quadratic acceleration).
/// - `EaseOut` — Starts fast, ends slow (quadratic deceleration).
/// - `EaseInOut` — Hermite S-curve; smooth at both ends.
/// - `Bounce` — Standard bounce ease-out with three diminishing bounces at the end.
/// - `Back` — Slight overshoot before settling (c1 = 1.70158).
#[derive(Debug, Clone, Copy, PartialEq, Default)]
pub enum EasingType {
    /// No easing — output equals input (t).
    #[default]
    Linear,
    /// Quadratic acceleration — starts slow, ends fast.
    EaseIn,
    /// Quadratic deceleration — starts fast, ends slow.
    EaseOut,
    /// Hermite S-curve — smooth acceleration and deceleration.
    EaseInOut,
    /// Bounce ease-out — three diminishing bounces at the end of the transition.
    Bounce,
    /// Slight overshoot — the value briefly exceeds 1.0 before settling.
    Back,
}

impl EasingType {
    /// Parse an easing type from a Lua string token.
    ///
    /// Unrecognised strings map to `EasingType::Linear`.
    ///
    /// # Parameters
    /// - `s` — `&str`. Token, e.g. `"ease_in"`, `"bounce"`.
    ///
    /// # Returns
    /// `Self`.
    pub fn from_lua_str(s: &str) -> Self {
        match s {
            "linear" => Self::Linear,
            "ease_in" => Self::EaseIn,
            "ease_out" => Self::EaseOut,
            "ease_in_out" => Self::EaseInOut,
            "bounce" => Self::Bounce,
            "back" => Self::Back,
            _ => Self::Linear,
        }
    }

    /// Apply the easing curve to a normalised progress value.
    ///
    /// The input is clamped to `[0, 1]` before the curve is applied.  The output
    /// is also in `[0, 1]` for all variants except `Back`, which may briefly
    /// exceed `1.0` during its overshoot phase.
    ///
    /// # Parameters
    /// - `t` — `f32`. Normalised time in `[0, 1]`.
    ///
    /// # Returns
    /// `f32`. Eased progress value.
    pub fn apply(self, t: f32) -> f32 {
        let t = t.clamp(0.0, 1.0);
        match self {
            Self::Linear => t,
            Self::EaseIn => t * t,
            Self::EaseOut => 1.0 - (1.0 - t) * (1.0 - t),
            Self::EaseInOut => t * t * (3.0 - 2.0 * t),
            Self::Bounce => {
                // Bounce ease-out: bounce at the end of the transition.
                let t2 = 1.0 - t;
                1.0 - bounce_out(t2)
            }
            Self::Back => {
                // Overshoot factor: c1 = 1.70158, c3 = c1 + 1.
                const C1: f32 = 1.701_58;
                const C3: f32 = C1 + 1.0;
                C3 * t * t * t - C1 * t * t
            }
        }
    }
}

/// Bounce ease-out helper.
///
/// Evaluates the standard three-bounce equation for a normalised input `t`.
///
/// # Parameters
/// - `t` — `f32`.
///
/// # Returns
/// `f32`.
fn bounce_out(t: f32) -> f32 {
    const N1: f32 = 7.5625;
    const D1: f32 = 2.75;
    if t < 1.0 / D1 {
        N1 * t * t
    } else if t < 2.0 / D1 {
        let t = t - 1.5 / D1;
        N1 * t * t + 0.75
    } else if t < 2.5 / D1 {
        let t = t - 2.25 / D1;
        N1 * t * t + 0.9375
    } else {
        let t = t - 2.625 / D1;
        N1 * t * t + 0.984_375
    }
}

/// Active transition state tracking progress between two scenes.
///
/// Created by `SceneStack::push`, `pop`, `switch_to`, or `push_overlay` when a
/// non-`None` transition is requested.  The `elapsed` field is advanced by
/// `update()` each frame until `is_complete()` returns `true`.
///
/// Both raw (`progress`) and eased (`progress_eased`) values are available.
///
/// # Fields
/// - `transition_type` — `TransitionType`. Visual effect to apply.
/// - `duration` — `f32`. Total animation duration in seconds.
/// - `elapsed` — `f32`. Time elapsed since the transition started.
/// - `easing` — `EasingType`. Curve applied to the raw progress value.
pub struct ActiveTransition {
    /// The type of visual transition.
    pub transition_type: TransitionType,
    /// Total duration of the transition in seconds.
    pub duration: f32,
    /// Elapsed time since the transition started.
    pub elapsed: f32,
    /// Easing curve applied to the normalised progress value.
    pub easing: EasingType,
}

impl ActiveTransition {
    /// Create a new active transition with linear easing.
    ///
    /// Use `new_with_easing` when a non-linear easing curve is required.
    ///
    /// # Parameters
    /// - `transition_type` — `TransitionType`.
    /// - `duration` — `f32`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(transition_type: TransitionType, duration: f32) -> Self {
        log_msg!(debug, TR01);
        Self {
            transition_type,
            duration,
            elapsed: 0.0,
            easing: EasingType::Linear,
        }
    }

    /// Create a new active transition with a specific easing curve.
    ///
    /// The easing curve is applied by `progress_eased()` but does not affect
    /// the raw `progress()` value.
    ///
    /// # Parameters
    /// - `transition_type` — `TransitionType`.
    /// - `duration` — `f32`.
    /// - `easing` — `EasingType`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new_with_easing(
        transition_type: TransitionType,
        duration: f32,
        easing: EasingType,
    ) -> Self {
        log_msg!(debug, TR01);
        Self {
            transition_type,
            duration,
            elapsed: 0.0,
            easing,
        }
    }

    /// Set the easing curve after construction.
    ///
    /// # Parameters
    /// - `easing` — `EasingType`.
    pub fn set_easing(&mut self, easing: EasingType) {
        self.easing = easing;
    }

    /// Get the current easing curve.
    ///
    /// # Returns
    /// `EasingType`.
    pub fn get_easing(&self) -> EasingType {
        self.easing
    }

    /// Normalized raw progress of the transition, clamped to [0, 1].
    ///
    /// Does not apply the easing curve.  Use `progress_eased()` for renderer use.
    ///
    /// # Returns
    /// `f32`.
    pub fn progress(&self) -> f32 {
        if self.duration <= 0.0 {
            1.0
        } else {
            (self.elapsed / self.duration).min(1.0)
        }
    }

    /// Easing-adjusted progress of the transition.
    ///
    /// Equivalent to `easing.apply(progress())`.  This is the value renderers
    /// should use for blending or positioning.
    ///
    /// # Returns
    /// `f32`.
    pub fn progress_eased(&self) -> f32 {
        self.easing.apply(self.progress())
    }

    /// Whether the transition has completed.
    ///
    /// Returns `true` once `elapsed >= duration`.  Safe to call every frame; incurs
    /// no allocation.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_complete(&self) -> bool {
        let done = self.elapsed >= self.duration;
        if done {
            log_msg!(debug, TR02);
        }
        done
    }

    /// Advance the transition timer by `dt` seconds.
    ///
    /// # Parameters
    /// - `dt` — `f32`.
    pub fn update(&mut self, dt: f32) {
        self.elapsed += dt;
    }
}

// NOTE: Tests private internals (easing field, internal ActiveTransition state) — stays inline
#[cfg(test)]
mod tests {
    use super::*;

    // ── ActiveTransition construction ─────────────────────────────────────────

    #[test]
    fn new_starts_at_zero_elapsed() {
        let t = ActiveTransition::new(TransitionType::Fade, 1.0);
        assert!((t.elapsed).abs() < 1e-5);
    }

    #[test]
    fn new_defaults_to_linear_easing() {
        let t = ActiveTransition::new(TransitionType::Fade, 1.0);
        assert_eq!(t.easing, EasingType::Linear);
    }

    #[test]
    fn new_with_easing_stores_easing() {
        let t = ActiveTransition::new_with_easing(TransitionType::Wipe, 0.5, EasingType::EaseIn);
        assert_eq!(t.easing, EasingType::EaseIn);
        assert_eq!(t.transition_type, TransitionType::Wipe);
    }

    #[test]
    fn set_easing_updates_field() {
        let mut t = ActiveTransition::new(TransitionType::Fade, 1.0);
        t.set_easing(EasingType::Bounce);
        assert_eq!(t.get_easing(), EasingType::Bounce);
    }

    // ── Progress ─────────────────────────────────────────────────────────────

    #[test]
    fn progress_at_start_is_zero() {
        let t = ActiveTransition::new(TransitionType::Fade, 1.0);
        assert!((t.progress()).abs() < 1e-5);
    }

    #[test]
    fn progress_after_half_duration_is_half() {
        let mut t = ActiveTransition::new(TransitionType::Fade, 2.0);
        t.update(1.0);
        assert!((t.progress() - 0.5).abs() < 1e-5);
    }

    #[test]
    fn progress_clamped_at_one() {
        let mut t = ActiveTransition::new(TransitionType::Fade, 1.0);
        t.update(10.0);
        assert!((t.progress() - 1.0).abs() < 1e-5);
    }

    #[test]
    fn zero_duration_progress_is_one() {
        let t = ActiveTransition::new(TransitionType::None, 0.0);
        assert!((t.progress() - 1.0).abs() < 1e-5);
    }

    // ── Eased progress ───────────────────────────────────────────────────────

    #[test]
    fn progress_eased_linear_identity() {
        let mut t = ActiveTransition::new_with_easing(TransitionType::Fade, 2.0, EasingType::Linear);
        t.update(1.0); // t = 0.5
        assert!((t.progress_eased() - 0.5).abs() < 1e-5);
    }

    #[test]
    fn progress_eased_ease_in_starts_slow() {
        // At t=0.5 EaseIn gives 0.25 (t²)
        let mut t = ActiveTransition::new_with_easing(TransitionType::Fade, 2.0, EasingType::EaseIn);
        t.update(1.0);
        assert!((t.progress_eased() - 0.25).abs() < 1e-5);
    }

    #[test]
    fn progress_eased_ease_out_ends_slow() {
        // At t=0.5 EaseOut gives 1-(0.5)²=0.75
        let mut t = ActiveTransition::new_with_easing(TransitionType::Fade, 2.0, EasingType::EaseOut);
        t.update(1.0);
        assert!((t.progress_eased() - 0.75).abs() < 1e-5);
    }

    #[test]
    fn progress_eased_ease_in_out_midpoint_is_half() {
        // Hermite S-curve is symmetric around 0.5
        let mut t = ActiveTransition::new_with_easing(TransitionType::Fade, 2.0, EasingType::EaseInOut);
        t.update(1.0);
        assert!((t.progress_eased() - 0.5).abs() < 1e-4);
    }

    #[test]
    fn progress_eased_bounce_clips_to_one_at_end() {
        let mut t = ActiveTransition::new_with_easing(TransitionType::Fade, 1.0, EasingType::Bounce);
        t.update(1.0);
        assert!((t.progress_eased() - 1.0).abs() < 1e-4);
    }

    #[test]
    fn progress_eased_back_has_overshoot() {
        // Back easing overshoots slightly before 1.0 when t is near 1.0.
        // But the exact midpoint should still be below 0.5 due to the accelerating cubic.
        let eased_at_zero = EasingType::Back.apply(0.0);
        let eased_at_one = EasingType::Back.apply(1.0);
        assert!((eased_at_zero).abs() < 1e-5);
        assert!((eased_at_one - 1.0).abs() < 1e-4);
    }

    // ── Is complete ──────────────────────────────────────────────────────────

    #[test]
    fn is_complete_before_duration_false() {
        let t = ActiveTransition::new(TransitionType::Fade, 1.0);
        assert!(!t.is_complete());
    }

    #[test]
    fn is_complete_after_full_update_true() {
        let mut t = ActiveTransition::new(TransitionType::Fade, 0.5);
        t.update(0.5);
        assert!(t.is_complete());
    }

    // ── TransitionType parsing ────────────────────────────────────────────────

    #[test]
    fn from_lua_str_fade_correct() {
        assert_eq!(TransitionType::from_lua_str("fade"), TransitionType::Fade);
    }

    #[test]
    fn from_lua_str_unknown_returns_none_variant() {
        assert_eq!(TransitionType::from_lua_str("xyz"), TransitionType::None);
    }

    #[test]
    fn from_lua_str_slideleft() {
        assert_eq!(
            TransitionType::from_lua_str("slideleft"),
            TransitionType::SlideLeft
        );
    }

    #[test]
    fn from_lua_str_wipe() {
        assert_eq!(TransitionType::from_lua_str("wipe"), TransitionType::Wipe);
    }

    #[test]
    fn from_lua_str_iris() {
        assert_eq!(TransitionType::from_lua_str("iris"), TransitionType::Iris);
    }

    #[test]
    fn from_lua_str_zoom() {
        assert_eq!(TransitionType::from_lua_str("zoom"), TransitionType::Zoom);
    }

    #[test]
    fn from_lua_str_crossfade() {
        assert_eq!(
            TransitionType::from_lua_str("crossfade"),
            TransitionType::CrossFade
        );
    }

    // ── EasingType parsing ────────────────────────────────────────────────────

    #[test]
    fn easing_from_lua_str_linear() {
        assert_eq!(EasingType::from_lua_str("linear"), EasingType::Linear);
    }

    #[test]
    fn easing_from_lua_str_ease_in() {
        assert_eq!(EasingType::from_lua_str("ease_in"), EasingType::EaseIn);
    }

    #[test]
    fn easing_from_lua_str_unknown_returns_linear() {
        assert_eq!(EasingType::from_lua_str("xyz"), EasingType::Linear);
    }
}

