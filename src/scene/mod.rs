//! This module provides scene-stack flow control, scene rendering helpers, transition behavior, and depth ordering support for multi-state games.
//! It gives the engine a structured way to move between menus, gameplay, overlays, and other major runtime states. `src/scene/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `depth_sorter::DepthSorter`, `stack::{SceneId, SceneStack}`, `transition::{ActiveTransition, EasingType, TransitionType}` centralized for the scene subsystem.

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
