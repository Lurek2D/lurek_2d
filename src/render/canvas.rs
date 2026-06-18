//! This file owns `Canvas`, the minimal metadata record for fixed-size off-screen render targets.
//! It stores only pixel dimensions and logs creation, leaving GPU allocation and rendering behavior to larger owners.
//! Open this file when canvas identity changes; renderer pipelines and image effects remain in sibling modules.

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
