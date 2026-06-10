//! - Paint-target surface descriptor for persistent world decals.
//! - Stores the durable dimensions (width and height) needed for later GPU texture allocation.
//! - Represents canvas-like surfaces where impact marks, splats, and footprints can be drawn.
//! - Minimizes overhead by keeping texture resource allocations managed by the central renderer.
//! - Ensures decal targets are cleanly referenced and reused across frame lifecycles.

/// Paint-target surface for persistent world decals; holds pixel dimensions only.
///
/// # Fields
/// - `width` - Pixel width of the decal target.
/// - `height` - Pixel height of the decal target.
pub struct DecalSurface {
    /// Pixel width of this surface.
    pub width: u32,
    /// Pixel height of this surface.
    pub height: u32,
}

/// Construction and dimension queries for a decal surface.
impl DecalSurface {
    /// Create a `DecalSurface` sized `width` x `height` pixels.
    pub fn new(width: u32, height: u32) -> Self {
        Self { width, height }
    }
    /// Return `(width, height)` as a tuple.
    pub fn get_dimensions(&self) -> (u32, u32) {
        (self.width, self.height)
    }
    /// Return the pixel width. This function is part of the public API.
    pub fn get_width(&self) -> u32 {
        self.width
    }
    /// Return the pixel height. This function is part of the public API.
    pub fn get_height(&self) -> u32 {
        self.height
    }
}
