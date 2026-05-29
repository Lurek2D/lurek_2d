//! Defines the minimal frame payload of source rectangle and optional per-frame timing override.
//! Supports clip timing fallback by allowing zero-duration frames to inherit clip-level FPS behavior.
//! Serves as the shared frame unit across import, playback, preview, and rendering pathways.

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
