//! Owns the custom LIMG binary format for saving and loading flat images and layered image documents.
//! Writes file headers, version tags, and type markers so loaders can reject incompatible or corrupt payloads.
//! Compresses and decompresses image bytes with zlib while keeping format checks local to one serialization owner.
//! Supports both path-based and in-memory decode flows for tests, tools, and runtime asset import pipelines.
//! Persists layered images with names, visibility flags, opacity values, and embedded RGBA layer payloads.
//! Open this file when LIMG compatibility, compression, or layered-image round trips fail or drift in shape.

use super::image_data::ImageData;
use super::layers::{ImageLayer, LayeredImage};
use super::limits::ImageLimits;
use flate2::read::ZlibDecoder;
use flate2::write::ZlibEncoder;
use flate2::Compression;
use std::io::{Read, Write};
/// Four-byte magic identifier for the LIMG binary format.
const MAGIC: &[u8; 4] = b"LIMG";
/// Current LIMG format version number.
const VERSION: u8 = 1;
/// Type flag indicating a single flat image payload.
const TYPE_FLAT: u8 = 0;
/// Type flag indicating a multi-layer image payload.
const TYPE_LAYERED: u8 = 1;
/// Save a flat image as LIMG bytes on disk.
pub fn save_image(img: &ImageData, path: &str) -> Result<(), String> {
    let data = encode_flat(img)?;
    std::fs::write(path, &data).map_err(|e| format!("LIMG write error '{}': {}", path, e))
}
/// Load a flat image from disk and decode it from LIMG bytes.
pub fn load_image(path: &str) -> Result<ImageData, String> {
    let data = std::fs::read(path).map_err(|e| format!("LIMG read error '{}': {}", path, e))?;
    load_image_from_bytes(&data, path)
}
/// Load a flat image from raw LIMG bytes and validate the type flag.
pub fn load_image_from_bytes(data: &[u8], label: &str) -> Result<ImageData, String> {
    let (type_flag, payload) = parse_header(data)?;
    if type_flag != TYPE_FLAT {
        return Err(format!(
            "LIMG '{}': expected flat image (type 0), got type {}",
            label, type_flag
        ));
    }
    decode_flat(payload)
}
/// Save a layered image as LIMG bytes on disk.
pub fn save_layered(stack: &LayeredImage, path: &str) -> Result<(), String> {
    let data = encode_layered(stack)?;
    std::fs::write(path, &data).map_err(|e| format!("LIMG write error '{}': {}", path, e))
}
/// Load a layered image from disk and decode it from LIMG bytes.
pub fn load_layered(path: &str) -> Result<LayeredImage, String> {
    let data = std::fs::read(path).map_err(|e| format!("LIMG read error '{}': {}", path, e))?;
    load_layered_from_bytes(&data, path)
}
/// Load a layered image from raw LIMG bytes and validate the type flag.
pub fn load_layered_from_bytes(data: &[u8], label: &str) -> Result<LayeredImage, String> {
    let (type_flag, payload) = parse_header(data)?;
    if type_flag != TYPE_LAYERED {
        return Err(format!(
            "LIMG '{}': expected layered image (type 1), got type {}",
            label, type_flag
        ));
    }
    decode_layered(payload)
}
/// Build a LIMG header for the requested payload type.
fn write_header(type_flag: u8) -> Vec<u8> {
    let mut buf = Vec::with_capacity(6);
    buf.extend_from_slice(MAGIC);
    buf.push(VERSION);
    buf.push(type_flag);
    buf
}
/// Compress raw bytes with zlib and return the encoded payload.
fn compress(raw: &[u8]) -> Result<Vec<u8>, String> {
    let mut enc = ZlibEncoder::new(Vec::new(), Compression::default());
    enc.write_all(raw)
        .map_err(|e| format!("zlib compress error: {}", e))?;
    enc.finish()
        .map_err(|e| format!("zlib finish error: {}", e))
}
/// Decompress zlib-compressed bytes and return the raw payload.
fn decompress_bounded(
    compressed: &[u8],
    expected: usize,
    context: &str,
) -> Result<Vec<u8>, String> {
    let dec = ZlibDecoder::new(compressed);
    let mut out = Vec::new();
    out.try_reserve_exact(expected)
        .map_err(|e| format!("{} allocation failed: {}", context, e))?;
    dec.take(
        u64::try_from(expected).map_err(|_| format!("{} size is not addressable", context))? + 1,
    )
    .read_to_end(&mut out)
    .map_err(|e| format!("zlib decompress error: {}", e))?;
    if out.len() > expected {
        return Err(format!(
            "{} expands beyond its declared {} byte limit",
            context, expected
        ));
    }
    Ok(out)
}
/// Append a little-endian `u16` to a byte buffer.
fn push_u16(buf: &mut Vec<u8>, v: u16) {
    buf.extend_from_slice(&v.to_le_bytes());
}
/// Append a little-endian `u32` to a byte buffer.
fn push_u32(buf: &mut Vec<u8>, v: u32) {
    buf.extend_from_slice(&v.to_le_bytes());
}
/// Append a little-endian `f32` to a byte buffer.
fn push_f32(buf: &mut Vec<u8>, v: f32) {
    buf.extend_from_slice(&v.to_le_bytes());
}
/// Read a little-endian `u16` from a byte slice at the requested offset.
fn read_u16(buf: &[u8], offset: usize) -> Result<u16, String> {
    buf.get(offset..offset + 2)
        .map(|b| u16::from_le_bytes([b[0], b[1]]))
        .ok_or_else(|| format!("LIMG truncated at offset {} (expected u16)", offset))
}
/// Read a little-endian `u32` from a byte slice at the requested offset.
fn read_u32(buf: &[u8], offset: usize) -> Result<u32, String> {
    buf.get(offset..offset + 4)
        .map(|b| u32::from_le_bytes([b[0], b[1], b[2], b[3]]))
        .ok_or_else(|| format!("LIMG truncated at offset {} (expected u32)", offset))
}
/// Read a little-endian `f32` from a byte slice at the requested offset.
fn read_f32(buf: &[u8], offset: usize) -> Result<f32, String> {
    buf.get(offset..offset + 4)
        .map(|b| f32::from_le_bytes([b[0], b[1], b[2], b[3]]))
        .ok_or_else(|| format!("LIMG truncated at offset {} (expected f32)", offset))
}
/// Encode a flat image into a LIMG byte vector.
pub fn encode_flat(img: &ImageData) -> Result<Vec<u8>, String> {
    let mut buf = write_header(TYPE_FLAT);
    push_u32(&mut buf, img.width);
    push_u32(&mut buf, img.height);
    let compressed = compress(&img.pixels)?;
    buf.extend_from_slice(&compressed);
    ImageLimits::default().encoded_bytes(buf.len(), "LIMG flat output")?;
    Ok(buf)
}
/// Decode a flat image from a LIMG payload.
pub fn decode_flat(payload: &[u8]) -> Result<ImageData, String> {
    if payload.len() < 8 {
        return Err("LIMG flat payload too short".into());
    }
    let width = read_u32(payload, 0)?;
    let height = read_u32(payload, 4)?;
    let limits = ImageLimits::default();
    limits.encoded_bytes(payload.len(), "LIMG flat input")?;
    let expected = limits.rgba_bytes(width, height)?;
    let pixels = decompress_bounded(&payload[8..], expected, "LIMG flat")?;
    if pixels.len() != expected {
        return Err(format!(
            "LIMG flat: decompressed {} bytes, expected {} for {}x{}",
            pixels.len(),
            expected,
            width,
            height
        ));
    }
    ImageData::from_bytes_with_limits(width, height, pixels, limits)
        .map_err(|e| format!("LIMG flat: {}", e))
}
/// Encode a layered image into a LIMG byte vector.
/// Encode a layered image into bounded LIMG bytes without performing filesystem I/O.
pub fn encode_layered(stack: &LayeredImage) -> Result<Vec<u8>, String> {
    let limits = ImageLimits::default();
    if stack.layers.len() > limits.max_frames_or_layers {
        return Err(format!(
            "LIMG has {} layers, limit is {}",
            stack.layers.len(),
            limits.max_frames_or_layers
        ));
    }
    let mut buf = write_header(TYPE_LAYERED);
    push_u32(&mut buf, stack.width);
    push_u32(&mut buf, stack.height);
    push_u32(&mut buf, stack.layers.len() as u32);
    for layer in &stack.layers {
        let name_bytes = layer.name.as_bytes();
        if name_bytes.len() > u16::MAX as usize {
            return Err(format!(
                "LIMG: layer name '{}' exceeds max 65535 bytes",
                layer.name
            ));
        }
        push_u16(&mut buf, name_bytes.len() as u16);
        buf.extend_from_slice(name_bytes);
        push_f32(&mut buf, layer.opacity);
        buf.push(if layer.visible { 1 } else { 0 });
        let compressed = compress(&layer.data.pixels)?;
        push_u32(&mut buf, compressed.len() as u32);
        buf.extend_from_slice(&compressed);
    }
    limits.encoded_bytes(buf.len(), "LIMG layered output")?;
    Ok(buf)
}
/// Decode a layered image from a LIMG payload.
fn decode_layered(payload: &[u8]) -> Result<LayeredImage, String> {
    if payload.len() < 12 {
        return Err("LIMG layered payload too short".into());
    }
    let limits = ImageLimits::default();
    limits.encoded_bytes(payload.len(), "LIMG layered input")?;
    let canvas_w = read_u32(payload, 0)?;
    let canvas_h = read_u32(payload, 4)?;
    let layer_count = read_u32(payload, 8)? as usize;
    if layer_count > limits.max_frames_or_layers {
        return Err(format!(
            "LIMG layered has {} layers, limit is {}",
            layer_count, limits.max_frames_or_layers
        ));
    }
    let expected = limits.rgba_bytes(canvas_w, canvas_h)?;
    let aggregate = expected
        .checked_mul(layer_count)
        .ok_or_else(|| "LIMG layered aggregate byte count overflow".to_string())?;
    if aggregate > limits.max_aggregate_bytes {
        return Err(format!(
            "LIMG layered decoded bytes {} exceed limit {}",
            aggregate, limits.max_aggregate_bytes
        ));
    }
    let mut stack = LayeredImage::new(canvas_w, canvas_h);
    let mut pos = 12usize;
    let mut total_name_bytes = 0usize;
    for i in 0..layer_count {
        let name_len = read_u16(payload, pos)? as usize;
        total_name_bytes = total_name_bytes
            .checked_add(name_len)
            .ok_or_else(|| "LIMG layered name bytes overflow".to_string())?;
        if total_name_bytes > limits.max_layer_name_bytes {
            return Err(format!(
                "LIMG layered names exceed {} bytes",
                limits.max_layer_name_bytes
            ));
        }
        pos += 2;
        let name_end = pos
            .checked_add(name_len)
            .ok_or_else(|| format!("LIMG layered: layer {} name length overflow", i))?;
        if name_end > payload.len() {
            return Err(format!("LIMG layered: layer {} name out of bounds", i));
        }
        let name = std::str::from_utf8(&payload[pos..name_end])
            .map_err(|e| format!("LIMG layered: layer {} name is invalid UTF-8: {}", i, e))?
            .to_string();
        pos = name_end;
        let opacity = read_f32(payload, pos)?;
        pos += 4;
        if pos >= payload.len() {
            return Err(format!(
                "LIMG layered: layer {} visible flag out of bounds",
                i
            ));
        }
        let visible = payload[pos] != 0;
        pos += 1;
        let comp_len = read_u32(payload, pos)? as usize;
        pos += 4;
        let comp_end = pos
            .checked_add(comp_len)
            .ok_or_else(|| format!("LIMG layered: layer {} pixel block length overflow", i))?;
        if comp_end > payload.len() {
            return Err(format!(
                "LIMG layered: layer {} pixel block out of bounds",
                i
            ));
        }
        let pixels = decompress_bounded(
            &payload[pos..comp_end],
            expected,
            &format!("LIMG layered layer {}", i),
        )?;
        pos = comp_end;
        if pixels.len() != expected {
            return Err(format!(
                "LIMG layered: layer {} decompressed {} bytes, expected {}",
                i,
                pixels.len(),
                expected
            ));
        }
        let img = ImageData::from_bytes_with_limits(canvas_w, canvas_h, pixels, limits)
            .map_err(|e| format!("LIMG layered layer {}: {}", i, e))?;
        if !opacity.is_finite() {
            return Err(format!("LIMG layered: layer {} opacity must be finite", i));
        }
        stack.layers.push(ImageLayer {
            name,
            opacity: opacity.clamp(0.0, 1.0),
            visible,
            data: img,
        });
    }
    if pos != payload.len() {
        return Err("LIMG layered has trailing bytes".into());
    }
    Ok(stack)
}
/// Parse a LIMG header and return the type flag plus the remaining payload.
pub fn parse_header(data: &[u8]) -> Result<(u8, &[u8]), String> {
    if data.len() < 6 {
        return Err("LIMG file too short to contain a valid header".into());
    }
    if &data[0..4] != MAGIC {
        return Err(format!("LIMG: invalid magic bytes (got {:?})", &data[0..4]));
    }
    let version = data[4];
    if version != VERSION {
        return Err(format!(
            "LIMG: unsupported version {} (only {} supported)",
            version, VERSION
        ));
    }
    let type_flag = data[5];
    Ok((type_flag, &data[6..]))
}
