//! Scalar-to-color conversion helpers for procedural outputs that need to become immediate pixel data.
//! The file focuses on clamped grayscale mapping so noise fields, heightmaps, and other sampled values can be previewed without bringing in a full rendering layer.
//! Functionally this file delivers the simplest visual projection path from numeric procgen data to RGBA buffers.

/// Convert a normalised float slice to a flat grayscale RGBA buffer; clamps each value to 0.0–1.0.
pub fn scalar_map_to_rgba_bytes(values: &[f32]) -> Vec<u8> {
    let mut out = Vec::with_capacity(values.len() * 4);
    for &v in values {
        let g = (v.clamp(0.0, 1.0) * 255.0) as u8;
        out.extend_from_slice(&[g, g, g, 255]);
    }
    out
}
