//! Provides bounded, headless CPU rasterization for parsed SVG trees.
//! The standard image catalog uses this boundary to produce RGBA8 `ImageData`
//! without creating a window or touching the GPU.  SVG parsing and palette
//! mutation remain owned by the caller; this file only owns pixel conversion.

use crate::image::{ImageData, ImageLimits};
use tiny_skia::{Pixmap, Transform};

/// Rasterize a parsed SVG tree into a checked straight-alpha RGBA8 image.
pub fn rasterize(tree: &usvg::Tree, width: u32, height: u32) -> Result<ImageData, String> {
    let limits = ImageLimits::default();
    limits.rgba_bytes(width, height)?;
    let pixels = u64::from(width)
        .checked_mul(u64::from(height))
        .ok_or_else(|| "SVG raster pixel count overflows".to_string())?;
    limits.work(pixels, 1, "SVG rasterization")?;
    let mut pixmap = Pixmap::new(width, height)
        .ok_or_else(|| format!("failed to allocate SVG raster target {}x{}", width, height))?;
    let sx = width as f32 / tree.size.width().max(1.0);
    let sy = height as f32 / tree.size.height().max(1.0);
    let transform = Transform::from_scale(sx, sy);
    let render_tree = resvg::Tree::from_usvg(tree);
    render_tree.render(transform, &mut pixmap.as_mut());

    let mut pixels = Vec::with_capacity((width as usize) * (height as usize) * 4);
    for chunk in pixmap.data().chunks_exact(4) {
        let alpha = u32::from(chunk[3]);
        if alpha == 0 {
            pixels.extend_from_slice(&[0, 0, 0, 0]);
            continue;
        }
        // tiny-skia stores premultiplied channels; ImageData stores straight alpha.
        pixels.push(((u32::from(chunk[0]) * 255 + alpha / 2) / alpha).min(255) as u8);
        pixels.push(((u32::from(chunk[1]) * 255 + alpha / 2) / alpha).min(255) as u8);
        pixels.push(((u32::from(chunk[2]) * 255 + alpha / 2) / alpha).min(255) as u8);
        pixels.push(chunk[3]);
    }
    ImageData::from_bytes_with_limits(width, height, pixels, limits)
}
