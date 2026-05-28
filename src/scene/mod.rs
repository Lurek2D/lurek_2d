//! Scene stack with push/pop lifecycle and unique SceneId handles.

/// Depth-sorted entity ordering for scene draw calls.
pub mod depth_sorter;
/// Scene-level render assembly: collects draw commands for the active scene.
pub mod render;
/// SceneStack and SceneId: push/pop lifecycle for game scenes.
pub mod stack;
/// Transition types, active transition state, and easing type selection.
pub mod transition;
pub use depth_sorter::DepthSorter;
pub use stack::{SceneId, SceneStack};
pub use transition::{ActiveTransition, EasingType, TransitionType};
