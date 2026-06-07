//! This module provides scene-stack flow control, scene rendering helpers, transition behavior, and depth ordering support for multi-state games.
//! It gives the engine a structured way to move between menus, gameplay, overlays, and other major runtime states.
//! At the highest level this is the feature layer that organizes game flow over time rather than individual world entities.

/// Depth-sorted entity ordering for scene draw calls.
pub mod depth_sorter;
/// Scene object container for managing object lifecycle, updates, and layered rendering.
pub mod object_container;
/// Scene-level render assembly: collects draw commands for the active scene.
pub mod render;
/// SceneStack and SceneId: push/pop lifecycle for game scenes.
pub mod stack;
/// Transition types, active transition state, and easing type selection.
pub mod transition;
pub use depth_sorter::DepthSorter;
pub use stack::{SceneId, SceneStack};
pub use transition::{ActiveTransition, EasingType, TransitionType};
