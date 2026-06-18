//! `src/parallax/draw.rs` rasterizes a single `ParallaxLayer` into `ImageData` for export, previews, or tooling use.
//! It owns only the bitmap fill path, translating visibility, tint, and opacity into a flat image without tiling logic.
//! Read it when parallax image export, solid-fill preview behavior, or layer-to-bitmap bridging needs to change.

use super::layer::ParallaxLayer;
use crate::image::ImageData;

/// Drawing helpers for `ParallaxLayer`.
impl ParallaxLayer {
    /// Rasterise this layer into a solid-colour `ImageData` sized `width × height`; returns transparent image when `visible` is `false`.
    pub fn draw_to_image(&self, width: u32, height: u32) -> ImageData {
        let mut img = ImageData::new(width, height);
        if !self.visible {
            img.fill(0, 0, 0, 0);
            return img;
        }
        let [tr, tg, tb, _ta] = self.tint;
        let alpha = (self.opacity * 255.0).clamp(0.0, 255.0) as u8;
        let r = (tr * 255.0).clamp(0.0, 255.0) as u8;
        let g = (tg * 255.0).clamp(0.0, 255.0) as u8;
        let b = (tb * 255.0).clamp(0.0, 255.0) as u8;
        img.fill(r, g, b, alpha);
        img
    }
}
