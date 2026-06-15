//! Defines the camera module boundary that groups transform state, effects, viewport, and rendering helpers.
//! Exposes a coherent camera surface while keeping pathing, rigs, and scaling concerns modularized.
//! Serves as the high-level composition root for runtime camera behavior across engine systems.

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
pub use viewport::{ScaleMode, Viewport};
pub use viewport_scale::ViewportScale;
