//! - Skeletal animation runtime: bones, slots, IK, timelines, and pose blending.
//! - Hierarchical bone transforms with parent-relative computation.
//! - Keyframe-driven animation clips with easing and interpolation.
//! - Skeleton-level render assembly converting posed bones to draw commands.

/// Bone transform hierarchy and parent-relative pose computation.
pub mod bone;
/// Inverse-kinematics constraint resolving 2-bone IK chains.
pub mod ik;
/// Skeleton-level render assembly: converts posed bones/slots to RenderCommands.
pub mod render;
/// Skeleton: bone tree, slot list, pose accumulation, and animation playback.
pub mod skeleton;
/// Slot: attachment point linking a bone to a drawable region.
pub mod slot;
/// Timeline, keyframe, easing, and animation clip data for skeletal animation.
pub mod timeline;
pub use bone::Bone;
pub use ik::IKConstraint;
pub use skeleton::{BoneParams, Skeleton};
pub use slot::Slot;
pub use timeline::{BoneProperty, BoneTimeline, EasingType, Keyframe, SkeletonAnimation};
