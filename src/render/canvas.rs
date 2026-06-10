//! - Canvas metadata representation for off-screen rendering targets.
//! - Defines the dimensions (width and height) of paintable canvases.
//! - Allows the game engine and Lua layers to query and specify render targets by ID.
//! - Separates the logical target handle from actual backing GPU texture resources.

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
