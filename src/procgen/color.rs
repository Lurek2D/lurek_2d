//! Scalar-to-color conversion helpers for procedural outputs that need to become immediate pixel data. `procgen/color` delivers the color implementation for the procgen subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

/// Convert a normalised float slice to a flat grayscale RGBA buffer; clamps each value to 0.0–1.0.
pub fn scalar_map_to_rgba_bytes(values: &[f32]) -> Vec<u8> {
    let mut out = Vec::with_capacity(values.len() * 4);
    for &v in values {
        let g = (v.clamp(0.0, 1.0) * 255.0) as u8;
        out.extend_from_slice(&[g, g, g, 255]);
    }
    out
}
