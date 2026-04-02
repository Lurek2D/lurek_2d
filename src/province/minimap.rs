//! Province-based minimap with downsampled colour representation.
//!
//! Generates a small RGBA pixel buffer by downsampling the province map,
//! suitable for rendering a minimap overlay or navigation widget.

use std::collections::HashMap;

use super::core::ProvinceMap;

/// Downsampled minimap derived from the province map.
#[derive(Debug, Clone)]
pub struct ProvinceMinimap {
    /// Minimap width in pixels.
    width: u32,
    /// Minimap height in pixels.
    height: u32,
    /// RGBA8 pixel buffer (`width * height * 4` bytes).
    pixels: Vec<u8>,
    /// Source province map width.
    map_width: u32,
    /// Source province map height.
    map_height: u32,
}

impl ProvinceMinimap {
    /// Create a minimap by downsampling the province map to the given size.
    ///
    /// Each minimap pixel samples the corresponding position in the full map
    /// and is coloured using the provided `colors` lookup (province ID → RGBA).
    /// Provinces not in the lookup default to transparent black.
    pub fn new(
        map: &ProvinceMap,
        colors: &HashMap<u32, [f32; 4]>,
        width: u32,
        height: u32,
    ) -> Self {
        let mw = map.width();
        let mh = map.height();
        let mut pixels = vec![0u8; (width as usize) * (height as usize) * 4];

        for my in 0..height {
            for mx in 0..width {
                let src_x = (mx as f32 / width as f32 * mw as f32) as u32;
                let src_y = (my as f32 / height as f32 * mh as f32) as u32;

                if let Some(pid) = map.get_province_at(src_x.min(mw - 1), src_y.min(mh - 1)) {
                    if pid != 0 {
                        if let Some(color) = colors.get(&pid) {
                            let base = ((my as usize) * (width as usize) + (mx as usize)) * 4;
                            pixels[base] = (color[0] * 255.0) as u8;
                            pixels[base + 1] = (color[1] * 255.0) as u8;
                            pixels[base + 2] = (color[2] * 255.0) as u8;
                            pixels[base + 3] = (color[3] * 255.0) as u8;
                        }
                    }
                }
            }
        }

        Self {
            width,
            height,
            pixels,
            map_width: mw,
            map_height: mh,
        }
    }

    /// Update just one province's pixels on the minimap.
    ///
    /// Re-scans the full minimap for pixels that belong to the given province
    /// and overwrites them with the new colour.
    pub fn update_province(
        &mut self,
        map: &ProvinceMap,
        province_id: u32,
        color: [f32; 4],
    ) {
        let rgba = [
            (color[0] * 255.0) as u8,
            (color[1] * 255.0) as u8,
            (color[2] * 255.0) as u8,
            (color[3] * 255.0) as u8,
        ];

        for my in 0..self.height {
            for mx in 0..self.width {
                let src_x =
                    (mx as f32 / self.width as f32 * self.map_width as f32) as u32;
                let src_y =
                    (my as f32 / self.height as f32 * self.map_height as f32) as u32;

                if map.get_province_at(src_x.min(self.map_width - 1), src_y.min(self.map_height - 1))
                    == Some(province_id)
                {
                    let base =
                        ((my as usize) * (self.width as usize) + (mx as usize)) * 4;
                    self.pixels[base] = rgba[0];
                    self.pixels[base + 1] = rgba[1];
                    self.pixels[base + 2] = rgba[2];
                    self.pixels[base + 3] = rgba[3];
                }
            }
        }
    }

    /// Get the raw RGBA pixel buffer for texture upload.
    pub fn pixels(&self) -> &[u8] {
        &self.pixels
    }

    /// Get the minimap width in pixels.
    pub fn width(&self) -> u32 {
        self.width
    }

    /// Get the minimap height in pixels.
    pub fn height(&self) -> u32 {
        self.height
    }

    /// Map minimap pixel coordinates back to a province ID.
    ///
    /// Takes minimap-relative coordinates `(mx, my)` and converts them to
    /// source map coordinates, then looks up the province ID.
    pub fn province_at(&self, mx: f32, my: f32, map: &ProvinceMap) -> Option<u32> {
        if mx < 0.0 || my < 0.0 || mx >= self.width as f32 || my >= self.height as f32 {
            return None;
        }

        let src_x = (mx / self.width as f32 * self.map_width as f32) as u32;
        let src_y = (my / self.height as f32 * self.map_height as f32) as u32;

        let pid = map.get_province_at(
            src_x.min(self.map_width.saturating_sub(1)),
            src_y.min(self.map_height.saturating_sub(1)),
        )?;

        if pid == 0 { None } else { Some(pid) }
    }
}
