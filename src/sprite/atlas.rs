//! This file owns `AtlasEntry` and `SpriteAtlas`, the named-region model for packed sprite texture content.
//! It stores ordered entries, a name-to-index lookup map, and rotation or flip metadata needed to decode atlas output.
//! Parser functions turn TexturePacker and Aseprite JSON payloads into atlas records, so import policy lives here.
//! Lookup helpers support name access, index access, name listing, and atlas construction from engine texture regions.
//! Open this file when packed-region semantics or atlas import rules change, not single-sprite transform behavior.

use crate::animation::aseprite::load_aseprite_json;
use crate::sprite::SpriteLimits;
use std::collections::HashMap;

fn json_u32(value: Option<&serde_json::Value>, field: &str, name: &str) -> Result<u32, String> {
    let raw = value
        .and_then(|v| v.as_u64())
        .ok_or_else(|| format!("Frame '{}' missing '{}'", name, field))?;
    u32::try_from(raw).map_err(|_| format!("Frame '{}' '{}' exceeds u32 range", name, field))
}

/// Returns the maximum container nesting depth in a JSON value without allocating derived data.
fn json_depth(value: &serde_json::Value) -> usize {
    match value {
        serde_json::Value::Array(items) => 1 + items.iter().map(json_depth).max().unwrap_or(0),
        serde_json::Value::Object(fields) => 1 + fields.values().map(json_depth).max().unwrap_or(0),
        _ => 0,
    }
}
/// # Fields
///
/// Named sub-region of a texture atlas with pixel coordinates, size, and flip/rotate flags.
#[derive(Debug, Clone)]
pub struct AtlasEntry {
    /// Region name used as the lookup key in SpriteAtlas.
    pub name: String,
    /// Left pixel coordinate of the region in the source texture.
    pub x: u32,
    /// Top pixel coordinate of the region in the source texture.
    pub y: u32,
    /// Width of the region in pixels.
    pub w: u32,
    /// Height of the region in pixels.
    pub h: u32,
    /// True when the source packer stored this region rotated 90° clockwise.
    pub rotated: bool,
    /// True when the region should be rendered horizontally flipped.
    pub flip_x: bool,
    /// True when the region should be rendered vertically flipped.
    pub flip_y: bool,
}
/// Flip accessor for AtlasEntry.
impl AtlasEntry {
    /// Clone this entry with the flip_x and flip_y flags replaced by the given values.
    pub fn get_flipped(&self, flip_x: bool, flip_y: bool) -> AtlasEntry {
        let mut cloned = self.clone();
        cloned.flip_x = flip_x;
        cloned.flip_y = flip_y;
        cloned
    }
}
/// # Fields
///
/// Named-region lookup table backed by a Vec for ordered access and a HashMap for O(1) lookup.
#[derive(Debug, Clone)]
pub struct SpriteAtlas {
    /// Ordered entry array; index matches name_map values.
    entries: Vec<AtlasEntry>,
    /// Name-to-index map for O(1) lookup by region name.
    name_map: HashMap<String, usize>,
}
/// Construction and lookup methods for SpriteAtlas.
impl SpriteAtlas {
    /// Create an empty atlas with no entries.
    pub fn new() -> Self {
        Self {
            entries: Vec::new(),
            name_map: HashMap::new(),
        }
    }
    /// Build a SpriteAtlas from a sprite `TextureAtlas`, sorting regions by name.
    pub fn from_texture_atlas(atlas: &crate::sprite::TextureAtlas) -> Self {
        let mut out = Self::new();
        let mut regions = atlas.get_regions();
        regions.sort_by(|a, b| a.name.cmp(&b.name));
        for region in regions {
            out.add_entry(AtlasEntry {
                name: region.name.clone(),
                x: region.x,
                y: region.y,
                w: region.w,
                h: region.h,
                rotated: false,
                flip_x: false,
                flip_y: false,
            });
        }
        out
    }
    /// Insert or replace an entry by name; updates both the Vec and the name map.
    pub fn add_entry(&mut self, entry: AtlasEntry) {
        if let Some(&idx) = self.name_map.get(&entry.name) {
            self.entries[idx] = entry;
        } else {
            let idx = self.entries.len();
            self.name_map.insert(entry.name.clone(), idx);
            self.entries.push(entry);
        }
    }
    /// Look up a region by name; returns None when not present.
    pub fn get_entry(&self, name: &str) -> Option<&AtlasEntry> {
        self.name_map.get(name).and_then(|&i| self.entries.get(i))
    }
    /// Return the entry at the given insertion-order index, or None when out of bounds.
    pub fn get_by_index(&self, index: usize) -> Option<&AtlasEntry> {
        self.entries.get(index)
    }
    /// Return the total number of entries in this atlas.
    pub fn entry_count(&self) -> usize {
        self.entries.len()
    }
    /// Return all entry names in insertion order.
    pub fn entry_names(&self) -> Vec<&str> {
        self.entries.iter().map(|e| e.name.as_str()).collect()
    }
    /// Ensure every atlas region fits within a supplied source image.
    pub fn validate_bounds(&self, width: u32, height: u32) -> Result<(), String> {
        for entry in &self.entries {
            if entry.w == 0 || entry.h == 0 {
                return Err(format!("entry '{}' has zero size", entry.name));
            }
            let right = entry
                .x
                .checked_add(entry.w)
                .ok_or_else(|| format!("entry '{}' overflows x + w", entry.name))?;
            let bottom = entry
                .y
                .checked_add(entry.h)
                .ok_or_else(|| format!("entry '{}' overflows y + h", entry.name))?;
            if right > width || bottom > height {
                return Err(format!(
                    "entry '{}' is outside source image bounds",
                    entry.name
                ));
            }
        }
        Ok(())
    }
}
/// Default delegates to new().
impl Default for SpriteAtlas {
    /// Return an empty SpriteAtlas.
    fn default() -> Self {
        Self::new()
    }
}
/// Parse a TexturePacker JSON string (array or object frames format) into a SpriteAtlas; returns Err on malformed input.
pub fn parse_texturepacker_json(json_str: &str) -> Result<SpriteAtlas, String> {
    if json_str.len() > SpriteLimits::MAX_ATLAS_JSON_BYTES {
        return Err(format!(
            "atlas JSON exceeds {} bytes",
            SpriteLimits::MAX_ATLAS_JSON_BYTES
        ));
    }
    let value: serde_json::Value =
        serde_json::from_str(json_str).map_err(|e| format!("JSON parse error: {}", e))?;
    if json_depth(&value) > SpriteLimits::MAX_ATLAS_JSON_DEPTH {
        return Err(format!(
            "atlas JSON nesting exceeds {} levels",
            SpriteLimits::MAX_ATLAS_JSON_DEPTH
        ));
    }
    let frames = value
        .get("frames")
        .ok_or("Missing 'frames' key in TexturePacker JSON")?;
    let mut atlas = SpriteAtlas::new();
    match frames {
        serde_json::Value::Array(arr) => {
            for item in arr {
                if atlas.entry_count() >= SpriteLimits::MAX_ATLAS_ENTRIES {
                    return Err("atlas has too many entries".into());
                }
                let name = item
                    .get("filename")
                    .and_then(|v| v.as_str())
                    .ok_or("Array-format frame missing 'filename'")?
                    .to_owned();
                if atlas.get_entry(&name).is_some() {
                    return Err(format!("duplicate frame name '{}'", name));
                }
                let entry = parse_frame_entry(name, item)?;
                atlas.add_entry(entry);
            }
        }
        serde_json::Value::Object(map) => {
            let mut sorted: Vec<_> = map.iter().collect();
            sorted.sort_by(|a, b| a.0.cmp(b.0));
            for (name, item) in sorted {
                if atlas.entry_count() >= SpriteLimits::MAX_ATLAS_ENTRIES {
                    return Err("atlas has too many entries".into());
                }
                let entry = parse_frame_entry(name.clone(), item)?;
                atlas.add_entry(entry);
            }
        }
        _ => return Err("'frames' must be an object or array".into()),
    }
    Ok(atlas)
}
/// Extract a single AtlasEntry from a TexturePacker JSON frame value using the given name.
fn parse_frame_entry(name: String, item: &serde_json::Value) -> Result<AtlasEntry, String> {
    if name.is_empty() || name.len() > SpriteLimits::MAX_NAME_BYTES {
        return Err("frame name is empty or too long".into());
    }
    let frame = item
        .get("frame")
        .ok_or_else(|| format!("Frame '{}' missing 'frame' rect object", name))?;
    let x = json_u32(frame.get("x"), "frame.x", &name)?;
    let y = json_u32(frame.get("y"), "frame.y", &name)?;
    let w = json_u32(frame.get("w"), "frame.w", &name)?;
    let h = json_u32(frame.get("h"), "frame.h", &name)?;
    if w == 0 || h == 0 {
        return Err(format!("Frame '{}' has zero size", name));
    }
    x.checked_add(w)
        .ok_or_else(|| format!("Frame '{}' overflows x + w", name))?;
    y.checked_add(h)
        .ok_or_else(|| format!("Frame '{}' overflows y + h", name))?;
    let rotated = item
        .get("rotated")
        .and_then(|v| v.as_bool())
        .unwrap_or(false);
    Ok(AtlasEntry {
        name,
        x,
        y,
        w,
        h,
        rotated,
        flip_x: false,
        flip_y: false,
    })
}
/// Parse an Aseprite JSON string (array or object frames format) into a SpriteAtlas; returns Err on malformed input.
pub fn parse_aseprite_json(json_str: &str) -> Result<SpriteAtlas, String> {
    if json_str.len() > SpriteLimits::MAX_ATLAS_JSON_BYTES {
        return Err(format!(
            "Aseprite atlas JSON exceeds {} bytes",
            SpriteLimits::MAX_ATLAS_JSON_BYTES
        ));
    }
    let value: serde_json::Value =
        serde_json::from_str(json_str).map_err(|e| format!("Aseprite JSON parse error: {e}"))?;
    if json_depth(&value) > SpriteLimits::MAX_ATLAS_JSON_DEPTH {
        return Err(format!(
            "Aseprite atlas JSON nesting exceeds {} levels",
            SpriteLimits::MAX_ATLAS_JSON_DEPTH
        ));
    }
    let mut atlas = SpriteAtlas::new();
    let parsed = load_aseprite_json(json_str).map_err(|e| match e.strip_prefix("aseprite: ") {
        Some(msg) => format!("Aseprite {}", msg),
        None => e,
    })?;
    for frame in parsed.frames {
        if atlas.entry_count() >= SpriteLimits::MAX_ATLAS_ENTRIES {
            return Err("Aseprite atlas has too many entries".into());
        }
        if frame.name.is_empty() {
            return Err("Aseprite array frame missing 'filename'".into());
        }
        if frame.name.len() > SpriteLimits::MAX_NAME_BYTES {
            return Err("Aseprite frame name is too long".into());
        }
        if atlas.get_entry(&frame.name).is_some() {
            return Err(format!("duplicate frame name '{}'", frame.name));
        }
        if frame.w == 0
            || frame.h == 0
            || frame.x.checked_add(frame.w).is_none()
            || frame.y.checked_add(frame.h).is_none()
        {
            return Err(format!(
                "Aseprite frame '{}' has invalid bounds",
                frame.name
            ));
        }
        atlas.add_entry(AtlasEntry {
            name: frame.name,
            x: frame.x,
            y: frame.y,
            w: frame.w,
            h: frame.h,
            rotated: false,
            flip_x: false,
            flip_y: false,
        });
    }
    Ok(atlas)
}
