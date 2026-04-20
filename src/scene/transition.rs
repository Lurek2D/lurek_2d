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
use crate::log_msg;
use crate::runtime::log_messages::{TR01, TR02};

/// Visual transition types between scenes.
///
/// # Variants
/// - `None` â€” Instant switch, no animation.
/// - `Fade` â€” Alpha cross-fade.
/// - `SlideLeft` â€” New scene slides in from the right.
/// - `SlideRight` â€” New scene slides in from the left.
/// - `SlideUp` â€” New scene slides in from the bottom.
/// - `SlideDown` â€” New scene slides in from the top.
/// - `Wipe` â€” Horizontal luminance wipe from left to right.
/// - `Iris` â€” Radial iris open/close centred on the screen.
/// - `Zoom` â€” Scale-in for the entering scene, scale-out for the leaving scene.
/// - `CrossFade` â€” Dissolve using a dithered noise threshold.
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
    /// - `s` â€” `&str`. Case-sensitive token, e.g. `"fade"`, `"wipe"`, `"iris"`.
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
/// All variants operate on a value `t â [0, 1]` and return a value in `[0, 1]`.
/// Use `EasingType::apply(t)` to convert raw linear progress to the eased value.
///
/// # Variants
/// - `Linear` â€” No easing; output equals input.
/// - `EaseIn` â€” Starts slow, ends fast (quadratic acceleration).
/// - `EaseOut` â€” Starts fast, ends slow (quadratic deceleration).
/// - `EaseInOut` â€” Hermite S-curve; smooth at both ends.
/// - `Bounce` â€” Standard bounce ease-out with three diminishing bounces at the end.
/// - `Back` â€” Slight overshoot before settling (c1 = 1.70158).
#[derive(Debug, Clone, Copy, PartialEq, Default)]
pub enum EasingType {
    /// No easing â€” output equals input (t).
    #[default]
    Linear,
    /// Quadratic acceleration â€” starts slow, ends fast.
    EaseIn,
    /// Quadratic deceleration â€” starts fast, ends slow.
    EaseOut,
    /// Hermite S-curve â€” smooth acceleration and deceleration.
    EaseInOut,
    /// Bounce ease-out â€” three diminishing bounces at the end of the transition.
    Bounce,
    /// Slight overshoot â€” the value briefly exceeds 1.0 before settling.
    Back,
}

impl EasingType {
    /// Parse an easing type from a Lua string token.
    ///
    /// Unrecognised strings map to `EasingType::Linear`.
    ///
    /// # Parameters
    /// - `s` â€” `&str`. Token, e.g. `"ease_in"`, `"bounce"`.
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
    /// - `t` â€” `f32`. Normalised time in `[0, 1]`.
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
/// - `t` â€” `f32`.
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
/// - `transition_type` â€” `TransitionType`. Visual effect to apply.
/// - `duration` â€” `f32`. Total animation duration in seconds.
/// - `elapsed` â€” `f32`. Time elapsed since the transition started.
/// - `easing` â€” `EasingType`. Curve applied to the raw progress value.
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
    /// - `transition_type` â€” `TransitionType`.
    /// - `duration` â€” `f32`.
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
    /// - `transition_type` â€” `TransitionType`.
    /// - `duration` â€” `f32`.
    /// - `easing` â€” `EasingType`.
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
    /// - `easing` â€” `EasingType`.
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
    /// - `dt` â€” `f32`.
    pub fn update(&mut self, dt: f32) {
        self.elapsed += dt;
    }
}
