//! Skeletal animation — bone hierarchies, slots, world-transform propagation, keyframe timelines, IK constraints, and skins.
//!
//! The spine module provides a hierarchical bone system for 2D skeletal animation.
//! Bones form a parent-child tree; calling `Skeleton::update_world_transforms()`
//! propagates local transforms down the hierarchy to produce world-space positions
//! for rendering.
//!
//! Timelines (`timeline`) drive bone properties over time via keyframes. IK constraints
//! (`ik`) solve two-bone chains via the law of cosines. Skins attach named resources to
//! slots and can be swapped at runtime.

/// Bone hierarchy node: local transform (translation, rotation, scale), parent pointer, and child list.
pub mod bone;
/// Two-bone inverse-kinematics constraints solved via the law of cosines.
pub mod ik;
/// GPU render-command generation for skeletal animation skeletons.
pub mod render;
/// `Skeleton` root type: manages the bone tree and calls `update_world_transforms()` to compute world-space positions.
pub mod skeleton;
/// Attachment slot that links a bone to a displayable resource (sprite, mesh, or point attachment).
pub mod slot;
/// Keyframe timelines that drive individual bone properties over an animation clip's duration.
pub mod timeline;

pub use bone::Bone;
pub use ik::IKConstraint;
pub use skeleton::{BoneParams, Skeleton};
pub use slot::Slot;
pub use timeline::{BoneProperty, BoneTimeline, EasingType, Keyframe, SkeletonAnimation};
