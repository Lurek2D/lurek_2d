//! Fixed-size render canvas carrying pixel dimensions for the GPU surface.

use crate::log_msg;
use crate::runtime::log_messages::CV01;
/// A fixed-size render canvas owned by `GpuRenderer`; carries only dimensions.
#[derive(Debug, Clone)]
pub struct Canvas {
    /// Pixel width of this canvas.
    pub width: u32,
    /// Pixel height of this canvas.
    pub height: u32,
}
impl Canvas {
    /// Create a canvas of `width` × `height` pixels and log its dimensions at debug level.
    pub fn new(width: u32, height: u32) -> Self {
        log_msg!(debug, CV01, "{}x{}", width, height);
        Self { width, height }
    }
}
