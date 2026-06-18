//! `src/scene/mod.rs` is the module index that exposes scene stack flow, rendering helpers, transitions, and depth sorting.
//! It reexports `SceneStack`, transition types, and depth ordering helpers while keeping object and render details modular.
//! No scene stack state lives here; this file only declares child modules and defines which scene symbols are public.
//! Read this index when wiring scene flow, because it shows where stack policy, rendering, and transition visuals separate.
//! Changes here reshape the scene boundary, since reexports decide what runtime code may import without deep paths.
//! This module keeps stack control, transition state, render bridges, and object utilities split by clear ownership.

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
