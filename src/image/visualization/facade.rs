//! Provides the shared HSV-to-RGB helper used by visualization modules that need stable debug color palettes.
//! Keeps hue conversion local to the image-visualization layer so callers do not duplicate color-wheel math.
//! Open this tiny owner when visualization colors drift or when a new debug view needs HSV-based swatches.

/// Convert HSV values to an RGB tuple for visualization images.
pub(crate) fn hsv_to_rgb_viz(h: u16, s: f32, v: f32) -> (u8, u8, u8) {
    let h = (h % 360) as f32;
    let c = v * s;
    let x = c * (1.0 - ((h / 60.0) % 2.0 - 1.0).abs());
    let m = v - c;
    let (r, g, b) = match (h / 60.0) as u8 {
        0 => (c, x, 0.0f32),
        1 => (x, c, 0.0),
        2 => (0.0, c, x),
        3 => (0.0, x, c),
        4 => (x, 0.0, c),
        _ => (c, 0.0, x),
    };
    (
        ((r + m) * 255.0) as u8,
        ((g + m) * 255.0) as u8,
        ((b + m) * 255.0) as u8,
    )
}
