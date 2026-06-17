//! Canvas metadata representation for off-screen rendering targets. `render/canvas` delivers the canvas implementation for the render subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

use crate::log_msg;
use crate::runtime::log_messages::CV01;
/// A fixed-size render canvas owned by `GpuRenderer`; carries only dimensions.
///
/// # Fields
/// - `width` - Pixel width of the off-screen target.
/// - `height` - Pixel height of the off-screen target.
#[derive(Debug, Clone)]
pub struct Canvas {
    /// Pixel width of this canvas.
    pub width: u32,
    /// Pixel height of this canvas.
    pub height: u32,
}
impl Canvas {
    /// Create a canvas of `width` x `height` pixels and log its dimensions at debug level.
    pub fn new(width: u32, height: u32) -> Self {
        log_msg!(debug, CV01, "{}x{}", width, height);
        Self { width, height }
    }
}
