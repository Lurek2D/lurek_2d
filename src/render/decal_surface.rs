//! Defines the metadata record for persistent decal draw surfaces that later become GPU-backed paint targets.
//! Stores durable width and height only, leaving allocation and rendering behavior to heavier renderer owners.
//! Open this file when decal surface identity or dimensions change rather than GPU upload or paint logic.

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
