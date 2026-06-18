//! This file owns Aseprite JSON parsing that turns sheet exports into frame rectangles, timing, and clip tags.
//! `AsepriteParsed` stores normalized frame and tag metadata, while helpers validate numeric fields and layout.
//! Import logic accepts array and object frame layouts, derives sheet size, and preserves deterministic ordering.
//! Tag parsing normalizes forward, reverse, and ping-pong directions for later clip creation in the controller.
//! Open it when authored import semantics change; runtime playback and rendering live in sibling animation files.

use serde_json::Value;

fn value_u32(value: Option<&Value>, field: &str) -> Result<u32, String> {
    let raw = value
        .and_then(Value::as_u64)
        .ok_or_else(|| format!("aseprite: missing '{}'", field))?;
    u32::try_from(raw).map_err(|_| format!("aseprite: '{}' exceeds u32 range", field))
}

fn value_usize(value: Option<&Value>, field: &str) -> Result<usize, String> {
    let raw = value
        .and_then(Value::as_u64)
        .ok_or_else(|| format!("aseprite: missing '{}'", field))?;
    usize::try_from(raw).map_err(|_| format!("aseprite: '{}' exceeds usize range", field))
}
/// One frame rectangle parsed from an Aseprite sheet.
#[derive(Debug, Clone)]
pub struct AsepriteFrameData {
    /// Source frame name, usually the exported filename.
    pub name: String,
    /// Frame X coordinate in the sheet.
    pub x: u32,
    /// Frame Y coordinate in the sheet.
    pub y: u32,
    /// Frame width in pixels.
    pub w: u32,
    /// Frame height in pixels.
    pub h: u32,
    /// Frame duration in milliseconds.
    pub duration_ms: u32,
}
#[derive(Debug, Clone, PartialEq)]
/// Playback direction declared by an Aseprite tag.
pub enum AsepriteDirection {
    /// Play frames in ascending order.
    Forward,
    /// Play frames in reverse order.
    Reverse,
    /// Play forward then backward.
    PingPong,
}
#[derive(Debug, Clone)]
/// Frame tag extracted from Aseprite metadata.
pub struct AsepriteTagData {
    /// Tag name.
    pub name: String,
    /// First frame index.
    pub from: usize,
    /// Last frame index.
    pub to: usize,
    /// Playback direction.
    pub direction: AsepriteDirection,
}
#[derive(Debug, Clone)]
/// Parsed Aseprite sheet metadata.
pub struct AsepriteParsed {
    /// All frame rectangles in playback order.
    pub frames: Vec<AsepriteFrameData>,
    /// All parsed frame tags.
    pub tags: Vec<AsepriteTagData>,
    /// Sheet width in pixels, derived from frame bounds when the export omits meta.size.
    pub sheet_width: u32,
    /// Sheet height in pixels, derived from frame bounds when the export omits meta.size.
    pub sheet_height: u32,
}
/// Parse an Aseprite JSON string into frame and tag metadata.
pub fn load_aseprite_json(json_str: &str) -> Result<AsepriteParsed, String> {
    let root: Value =
        serde_json::from_str(json_str).map_err(|e| format!("aseprite: JSON parse error: {}", e))?;
    let frames_val = root.get("frames").ok_or("aseprite: missing 'frames' key")?;
    let mut frames: Vec<AsepriteFrameData> = Vec::new();
    if let Some(arr) = frames_val.as_array() {
        for entry in arr {
            let name = entry
                .get("filename")
                .and_then(Value::as_str)
                .unwrap_or_default()
                .to_string();
            frames.push(parse_frame_entry(entry, name)?);
        }
    } else if let Some(obj) = frames_val.as_object() {
        let mut entries: Vec<(&String, &Value)> = obj.iter().collect();
        entries.sort_by_key(|(k, _)| {
            let base = k.trim_end_matches(".png").trim_end_matches(".jpg");
            base.rsplit_once('_')
                .or_else(|| base.rsplit_once(' '))
                .and_then(|(_, s)| s.parse::<u64>().ok())
                .unwrap_or(0)
        });
        for (name, entry) in entries {
            frames.push(parse_frame_entry(entry, name.clone())?);
        }
    } else {
        return Err("aseprite: 'frames' must be an array or object".to_string());
    }
    let derived_sheet_width = frames
        .iter()
        .map(|frame| frame.x.saturating_add(frame.w))
        .max()
        .unwrap_or(0);
    let derived_sheet_height = frames
        .iter()
        .map(|frame| frame.y.saturating_add(frame.h))
        .max()
        .unwrap_or(0);
    let meta = root.get("meta");
    let size = meta.and_then(|m| m.get("size"));
    let sheet_width = size
        .map(|s| value_u32(s.get("w"), "meta.size.w"))
        .transpose()?
        .unwrap_or(derived_sheet_width);
    let sheet_height = size
        .map(|s| value_u32(s.get("h"), "meta.size.h"))
        .transpose()?
        .unwrap_or(derived_sheet_height);
    let mut tags: Vec<AsepriteTagData> = Vec::new();
    if let Some(tag_arr) = meta
        .and_then(|m| m.get("frameTags"))
        .and_then(Value::as_array)
    {
        for tag_val in tag_arr {
            let name = tag_val
                .get("name")
                .and_then(Value::as_str)
                .ok_or("aseprite: tag missing 'name'")?
                .to_string();
            let from = value_usize(tag_val.get("from"), "tag.from")?;
            let to = value_usize(tag_val.get("to"), "tag.to")?;
            let direction = match tag_val
                .get("direction")
                .and_then(Value::as_str)
                .unwrap_or("forward")
            {
                "reverse" => AsepriteDirection::Reverse,
                "pingpong" => AsepriteDirection::PingPong,
                _ => AsepriteDirection::Forward,
            };
            tags.push(AsepriteTagData {
                name,
                from,
                to,
                direction,
            });
        }
    }
    Ok(AsepriteParsed {
        frames,
        tags,
        sheet_width,
        sheet_height,
    })
}
/// Parse one frame entry object into `AsepriteFrameData`.
fn parse_frame_entry(entry: &Value, name: String) -> Result<AsepriteFrameData, String> {
    let frame_obj = entry
        .get("frame")
        .ok_or("aseprite: frame entry missing 'frame' object")?;
    let x = value_u32(frame_obj.get("x"), "frame.x")?;
    let y = value_u32(frame_obj.get("y"), "frame.y")?;
    let w = value_u32(frame_obj.get("w"), "frame.w")?;
    let h = value_u32(frame_obj.get("h"), "frame.h")?;
    let duration_ms = match entry.get("duration").and_then(Value::as_u64) {
        Some(duration) => {
            u32::try_from(duration).map_err(|_| "aseprite: 'duration' exceeds u32 range")?
        }
        None => 100,
    };
    Ok(AsepriteFrameData {
        name,
        x,
        y,
        w,
        h,
        duration_ms,
    })
}
