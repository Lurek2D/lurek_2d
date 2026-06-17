//! This module provides the engine's skeletal animation runtime built around bones, slots, timelines, constraints, and posed rendering support.
//! It turns hierarchical transform animation into a reusable feature system for articulated 2D characters and props. `src/spine/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `bone::Bone`, `ik::IKConstraint`, `importer::{skeleton_from_json_str, skeleton_from_json_value, SpineImportError}`, `skeleton::{BoneParams, Skeleton}`, and 2 more centralized for the spine subsystem.

/// Bone transform hierarchy and parent-relative pose computation.
pub mod bone;
/// Inverse-kinematics constraint resolving 2-bone IK chains.
pub mod ik;
/// Spine and DragonBones JSON importer for skeleton data.
pub mod importer;
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
pub use importer::{skeleton_from_json_str, skeleton_from_json_value, SpineImportError};
pub use skeleton::{BoneParams, Skeleton};
pub use slot::Slot;
pub use timeline::{BoneProperty, BoneTimeline, EasingType, Keyframe, SkeletonAnimation};
