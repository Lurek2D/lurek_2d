//! `src/camera/mod.rs` is the module index that exposes camera state, effects, paths, viewport logic, and render helpers.
//! It reexports core camera types plus effect, rig, tween, viewport, and walker APIs through one stable camera surface.
//! No live camera state is stored here; this file only declares child modules and defines which camera symbols are public.
//! Read this index when wiring view behavior, because it shows where transform state ends and specialized helpers begin.
//! Changes here reshape the camera boundary, since reexports decide what runtime code may import without deep paths.
//! This module keeps transforms, effects, scaling, and scripted movement split by responsibility for clearer ownership.

/// Exposes camera effect primitives for sway, breathing, and pulse behavior.
pub mod effects;
/// Exposes multi-camera rig management for split and overlay layouts.
pub mod multi;
/// Exposes camera path and zoom tween helpers for timed interpolation.
pub mod path;
/// Exposes render-command generation from camera state.
pub mod render;
/// Exposes core camera state containers and follow logic.
pub mod types;
/// Exposes viewport scaling strategies and screen/game transforms.
pub mod viewport;
/// Exposes viewport scaling state object used by resize flows.
pub mod viewport_scale;
/// Exposes tile-grid walker with smooth camera following.
pub mod walker;

pub use effects::{CameraBreathing, CameraSway, ZoomPulse};
pub use multi::CameraRig2D;
pub use path::{CameraPath, CameraTweenEasing, CameraZoomTween, ZoomTween};
pub use types::{Camera, Camera2D, CameraEasing};
pub use walker::CameraWalker;

/// Re-export for backwards compatibility.
pub use types::CameraEasing as CameraFollowEasing;
pub use viewport::{
    camera_visible_chunk_range, fit_content_to_screen, screen_to_content, zoom_offset_at,
    ChunkViewportRange, ScaleMode, Viewport,
};
pub use viewport_scale::ViewportScale;
