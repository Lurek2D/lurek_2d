//! Defines the minimal frame payload of source rectangle and optional per-frame timing override. `animation/frame` delivers the frame implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

use crate::math::Rect;
/// Frame rectangle and duration.
#[derive(Debug, Clone)]
pub struct AnimFrame {
    /// Source rectangle for the frame.
    pub quad: Rect,
    /// Duration in seconds; 0 uses clip FPS.
    pub duration: f32,
}
impl AnimFrame {
    /// Create a new animation frame.
    pub fn new(quad: Rect, duration: f32) -> Self {
        Self { quad, duration }
    }
}
/// Backward-compatible alias for `AnimFrame`.
pub type AnimationFrame = AnimFrame;
