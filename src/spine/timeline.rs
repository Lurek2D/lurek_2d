//! Keyframe timelines and skeleton animation playback for the spine module.
//!
//! A [`SkeletonAnimation`] contains one or more [`BoneTimeline`]s. Each timeline
//! animates a single property of a single bone over time. Call
//! [`SkeletonAnimation::apply_to_skeleton`] each frame to evaluate all timelines
//! at the current playback time and write bone local transforms.

use super::bone::Bone;

// ── Easing ────────────────────────────────────────────────────────────────────

/// Interpolation curve type for keyframe blending.
///
/// # Variants
/// - `Linear` — uniform lerp.
/// - `EaseIn` — accelerates from zero.
/// - `EaseOut` — decelerates to zero.
/// - `EaseInOut` — S-curve.
/// - `Step` — jumps to end value at the next frame.
#[derive(Debug, Clone, PartialEq)]
pub enum EasingType {
    /// Uniform linear interpolation.
    Linear,
    /// Quadratic ease-in (t²).
    EaseIn,
    /// Quadratic ease-out (1-(1-t)²).
    EaseOut,
    /// Hermite S-curve ease-in-out.
    EaseInOut,
    /// Instant jump — holds previous value until the next keyframe.
    Step,
}

impl EasingType {
    /// Applies the easing curve to a normalised time value `t ∈ [0, 1]`.
    ///
    /// # Parameters
    /// - `t` — `f32`. Normalised time (0 = start, 1 = end).
    ///
    /// # Returns
    /// `f32` — eased value in `[0, 1]`.
    pub fn apply(&self, t: f32) -> f32 {
        let t = t.clamp(0.0, 1.0);
        match self {
            Self::Linear => t,
            Self::EaseIn => t * t,
            Self::EaseOut => 1.0 - (1.0 - t) * (1.0 - t),
            Self::EaseInOut => {
                if t < 0.5 {
                    2.0 * t * t
                } else {
                    1.0 - 2.0 * (1.0 - t) * (1.0 - t)
                }
            }
            Self::Step => 0.0, // holds — caller handles by returning previous value
        }
    }
}

// ── Bone property ─────────────────────────────────────────────────────────────

/// Bone local-transform property that a timeline can animate.
///
/// # Variants
/// - `X`, `Y`, `Rotation`, `ScaleX`, `ScaleY`.
#[derive(Debug, Clone, PartialEq)]
pub enum BoneProperty {
    /// Local X translation.
    X,
    /// Local Y translation.
    Y,
    /// Local rotation in radians.
    Rotation,
    /// Local X scale.
    ScaleX,
    /// Local Y scale.
    ScaleY,
}

// ── Keyframe ──────────────────────────────────────────────────────────────────

/// A single timed value sample on a bone timeline.
///
/// # Fields
/// - `time` — `f32`. Time in seconds from animation start.
/// - `value` — `f32`. Target value of the bone property.
/// - `easing` — [`EasingType`]. Interpolation curve to the next keyframe.
#[derive(Debug, Clone)]
pub struct Keyframe {
    /// Time offset from animation start in seconds.
    pub time: f32,
    /// Target value of the bone property at this keyframe.
    pub value: f32,
    /// Easing curve used when blending from this keyframe to the next.
    pub easing: EasingType,
}

// ── BoneTimeline ─────────────────────────────────────────────────────────────

/// Sequence of keyframes that animate a single property of a single bone.
///
/// # Fields
/// - `bone_idx` — `usize`. Index of the target bone in the skeleton's bone array.
/// - `property` — [`BoneProperty`]. Which local transform property to animate.
/// - `keys` — `Vec<Keyframe>`. Keyframes sorted by ascending time.
#[derive(Debug, Clone)]
pub struct BoneTimeline {
    /// Index of the target bone in the skeleton's bone array.
    pub bone_idx: usize,
    /// Local transform property this timeline animates.
    pub property: BoneProperty,
    /// Keyframes sorted by ascending time.
    pub keys: Vec<Keyframe>,
}

impl BoneTimeline {
    /// Creates a new empty timeline for the given bone and property.
    ///
    /// # Parameters
    /// - `bone_idx` — `usize`. Bone index.
    /// - `property` — [`BoneProperty`]. Transform property.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(bone_idx: usize, property: BoneProperty) -> Self {
        Self { bone_idx, property, keys: Vec::new() }
    }

    /// Appends a keyframe at `time` with `value` and the given easing.
    ///
    /// Keyframes are kept in ascending time order.
    ///
    /// # Parameters
    /// - `time` — `f32`. Time in seconds.
    /// - `value` — `f32`. Target value.
    /// - `easing` — [`EasingType`].
    pub fn add_key(&mut self, time: f32, value: f32, easing: EasingType) {
        let kf = Keyframe { time, value, easing };
        // Insert in sorted position
        let pos = self.keys.partition_point(|k| k.time <= time);
        self.keys.insert(pos, kf);
    }

    /// Evaluates the timeline at `time`, interpolating between surrounding keyframes.
    ///
    /// Returns the value from the first or last keyframe when `time` is outside the
    /// timeline range. Uses the easing of the earlier keyframe for blending.
    ///
    /// # Parameters
    /// - `time` — `f32`. Playback time in seconds.
    ///
    /// # Returns
    /// `f32`.
    pub fn evaluate(&self, time: f32) -> f32 {
        if self.keys.is_empty() {
            return 0.0;
        }
        if self.keys.len() == 1 || time <= self.keys[0].time {
            return self.keys[0].value;
        }
        let last = self.keys.last().unwrap();
        if time >= last.time {
            return last.value;
        }

        // Find the two surrounding keyframes.
        let next_idx = self.keys.partition_point(|k| k.time <= time);
        let prev_idx = next_idx - 1;

        let prev = &self.keys[prev_idx];
        let next = &self.keys[next_idx];

        // Step easing: hold prev value until next keyframe.
        if prev.easing == EasingType::Step {
            return prev.value;
        }

        let span = next.time - prev.time;
        if span <= 0.0 {
            return next.value;
        }

        let t = (time - prev.time) / span;
        let eased_t = prev.easing.apply(t);
        prev.value + (next.value - prev.value) * eased_t
    }
}

// ── SkeletonAnimation ─────────────────────────────────────────────────────────

/// Named animation clip for a skeleton: contains timelines for multiple bones.
///
/// # Fields
/// - `name` — `String`. Clip name.
/// - `duration` — `f32`. Total duration in seconds.
/// - `timelines` — `Vec<BoneTimeline>`.
#[derive(Debug, Clone)]
pub struct SkeletonAnimation {
    /// Human-readable animation name.
    pub name: String,
    /// Total animation duration in seconds.
    pub duration: f32,
    /// Timelines for individual bone properties.
    pub timelines: Vec<BoneTimeline>,
}

impl SkeletonAnimation {
    /// Creates a new empty skeleton animation clip.
    ///
    /// # Parameters
    /// - `name` — `impl Into<String>`. Clip name.
    /// - `duration` — `f32`. Duration in seconds.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(name: impl Into<String>, duration: f32) -> Self {
        Self { name: name.into(), duration, timelines: Vec::new() }
    }

    /// Appends a bone timeline.
    ///
    /// # Parameters
    /// - `timeline` — [`BoneTimeline`].
    pub fn add_timeline(&mut self, timeline: BoneTimeline) {
        self.timelines.push(timeline);
    }

    /// Evaluates all timelines at `time` and writes results into the skeleton's bones.
    ///
    /// Only writes to bone indices that are in-range for the provided bone slice.
    ///
    /// # Parameters
    /// - `skeleton` — `&mut super::skeleton::Skeleton`. Skeleton to modify.
    /// - `time` — `f32`. Playback time in seconds.
    pub fn apply_to_skeleton(&self, skeleton: &mut super::skeleton::Skeleton, time: f32) {
        for tl in &self.timelines {
            let value = tl.evaluate(time);
            if let Some(bone) = skeleton.bones.get_mut(tl.bone_idx) {
                apply_bone_property(bone, &tl.property, value);
            }
        }
    }
}

/// Writes `value` to the named local property of a bone.
fn apply_bone_property(bone: &mut Bone, prop: &BoneProperty, value: f32) {
    match prop {
        BoneProperty::X => bone.local_x = value,
        BoneProperty::Y => bone.local_y = value,
        BoneProperty::Rotation => bone.local_rotation = value,
        BoneProperty::ScaleX => bone.local_scale_x = value,
        BoneProperty::ScaleY => bone.local_scale_y = value,
    }
}
