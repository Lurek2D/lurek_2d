//! Custom image cursor built from RGBA pixel data with configurable hotspot offset.
//!
//! - `CustomCursor` stores width, height, hotspot `(x, y)`, and a flat RGBA `Vec<u8>`.
//! - Pixel data is validated at construction; mismatched dimensions return an error.
//! - Used directly or as frames inside `AnimatedCursor`.
//! - Exposed to Lua scripts via `lurek.cursor.set_custom()`.

/// A custom cursor from RGBA pixel data.
#[derive(Debug, Clone)]
pub struct CustomCursor {
    /// Width in pixels.
    pub width: u32,
    /// Height in pixels.
    pub height: u32,
    /// Horizontal hotspot offset from the cursor image origin.
    pub hotspot_x: u32,
    /// Vertical hotspot offset from the cursor image origin.
    pub hotspot_y: u32,
    pixels: Vec<u8>,
}

impl CustomCursor {
    /// Create a blank (all-zero) custom cursor with the given dimensions and hotspot.
    pub fn new(width: u32, height: u32, hotspot_x: u32, hotspot_y: u32) -> Self {
        Self {
            width,
            height,
            hotspot_x: hotspot_x.min(width.saturating_sub(1)),
            hotspot_y: hotspot_y.min(height.saturating_sub(1)),
            pixels: vec![0u8; (width * height * 4) as usize],
        }
    }

    /// Create a cursor from raw RGBA byte data; returns `None` if `data.len()` does not match dimensions.
    pub fn from_rgba(width: u32, height: u32, hotspot_x: u32, hotspot_y: u32, data: Vec<u8>) -> Option<Self> {
        let expected = (width * height * 4) as usize;
        if data.len() != expected {
            return None;
        }
        Some(Self {
            width,
            height,
            hotspot_x: hotspot_x.min(width.saturating_sub(1)),
            hotspot_y: hotspot_y.min(height.saturating_sub(1)),
            pixels: data,
        })
    }

    /// Set the RGBA value of the pixel at `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn set_pixel(&mut self, x: u32, y: u32, r: u8, g: u8, b: u8, a: u8) {
        if x < self.width && y < self.height {
            let idx = ((y * self.width + x) * 4) as usize;
            self.pixels[idx] = r;
            self.pixels[idx + 1] = g;
            self.pixels[idx + 2] = b;
            self.pixels[idx + 3] = a;
        }
    }

    /// Return the RGBA value at `(x, y)`, or `None` if the coordinates are out of bounds.
    pub fn get_pixel(&self, x: u32, y: u32) -> Option<(u8, u8, u8, u8)> {
        if x < self.width && y < self.height {
            let idx = ((y * self.width + x) * 4) as usize;
            Some((self.pixels[idx], self.pixels[idx + 1], self.pixels[idx + 2], self.pixels[idx + 3]))
        } else {
            None
        }
    }

    /// Return the full flat RGBA pixel buffer (width × height × 4 bytes).
    pub fn pixels(&self) -> &[u8] {
        &self.pixels
    }

    /// Return the cursor image dimensions as `(width, height)` in pixels.
    pub fn size(&self) -> (u32, u32) {
        (self.width, self.height)
    }
}
