//! - Scene stack with push/pop lifecycle and unique SceneId handles.
//! - Depth-sorted entity ordering for layered draw calls.
//! - Transition effects (fade, slide, wipe) with configurable easing curves.

/// Depth-sorted entity ordering for scene draw calls.
pub mod depth_sorter;
/// Internal easing curve math used by transition.rs.
pub(crate) mod easing;
/// Scene-level render assembly: collects draw commands for the active scene.
pub mod render;
/// SceneStack and SceneId: push/pop lifecycle for game scenes.
pub mod stack;
/// Transition types, active transition state, and easing type selection.
pub mod transition;
pub use depth_sorter::DepthSorter;
pub use stack::{SceneId, SceneStack};
pub use transition::{ActiveTransition, EasingType, TransitionType};
