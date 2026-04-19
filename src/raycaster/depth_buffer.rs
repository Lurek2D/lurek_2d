//! Column-based depth buffer for sprite occlusion.
//!
//! Provides a simple 1D depth buffer (one depth per screen column) used
//! for correct sprite-vs-wall ordering in raycaster rendering.

/// Column-based depth buffer for sprite occlusion.
///
/// Stores one depth value per screen column. After rendering walls, each
/// column's depth is recorded so that sprites can be correctly occluded.
///
/// # Fields
/// - `width` — `u32`. Number of screen columns.
/// - `buffer` — `Vec<f32>`. Per-column depth value; initialized to `f32::MAX`.
pub struct DepthBuffer {
    width: u32,
    buffer: Vec<f32>,
}

impl DepthBuffer {
    /// Creates a new depth buffer with the given width, initialized to `f32::MAX`.
    ///
    /// # Parameters
    /// - `width` — `u32`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(width: u32) -> Self {
        Self {
            width,
            buffer: vec![f32::MAX; width as usize],
        }
    }

    /// Clears all depth values to `f32::MAX`.
    pub fn clear(&mut self) {
        self.buffer.fill(f32::MAX);
    }

    /// Sets the depth for a specific column.
    ///
    /// # Parameters
    /// - `column` — `u32`.
    /// - `depth` — `f32`.
    pub fn set(&mut self, column: u32, depth: f32) {
        if (column as usize) < self.buffer.len() {
            self.buffer[column as usize] = depth;
        }
    }

    /// Gets the depth for a specific column. Returns `f32::MAX` for out-of-bounds.
    ///
    /// # Parameters
    /// - `column` — `u32`.
    ///
    /// # Returns
    /// `f32`.
    pub fn get(&self, column: u32) -> f32 {
        if (column as usize) < self.buffer.len() {
            self.buffer[column as usize]
        } else {
            f32::MAX
        }
    }

    /// Returns true if the given depth is closer than the stored depth at this column.
    ///
    /// # Parameters
    /// - `column` — `u32`.
    /// - `depth` — `f32`.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_visible(&self, column: u32, depth: f32) -> bool {
        depth < self.get(column)
    }

    /// Returns the buffer width.
    ///
    /// # Returns
    /// `u32`.
    pub fn width(&self) -> u32 {
        self.width
    }
}
