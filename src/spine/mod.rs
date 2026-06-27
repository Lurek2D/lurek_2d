//! This module re-exports the spine subsystem surface for bones, slots, timelines, IK, import, and rendering.
//! It keeps navigation explicit by mapping which sibling files own transform hierarchy, clip timing, import, or drawing.
//! Public exports here route callers toward `Skeleton` as the runtime owner and importer functions for asset loading.
//! `bone.rs`, `slot.rs`, and `ik.rs` hold the core rig pieces, while `timeline.rs` owns keyframe evaluation semantics.
//! `skeleton.rs` coordinates playback and pose updates, and `render.rs` turns posed rigs into engine draw commands.
//! Change this file when the public spine symbol map moves; change siblings when rig behavior or data rules change.

/// Neutral attachment source descriptors for slot visuals.
pub mod attachment;
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
pub use attachment::{AttachmentSource, AttachmentSourceKind};
pub use bone::Bone;
pub use ik::IKConstraint;
pub use importer::{skeleton_from_json_str, skeleton_from_json_value, SpineImportError};
pub use skeleton::{BoneParams, Skeleton};
pub use slot::Slot;
pub use timeline::{BoneProperty, BoneTimeline, EasingType, Keyframe, SkeletonAnimation};
