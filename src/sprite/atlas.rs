//! TexturePacker JSON atlas importer and named region lookup.
//!
//! Parses both hash-format (`"frames": {}`) and array-format (`"frames": []`)
//! TexturePacker JSON exports and provides O(1) region lookup by name.

use std::collections::HashMap;

// -------------------------------------------------------------------------------
// Types
// -------------------------------------------------------------------------------

/// A single named region within a sprite atlas.
///
/// # Fields
/// - `name` — `String`. The region identifier (matches the source filename key in TexturePacker).
/// - `x` — `u32`. Left edge of the region on the texture, in pixels.
/// - `y` — `u32`. Top edge of the region on the texture, in pixels.
/// - `w` — `u32`. Width of the region, in pixels.
/// - `h` — `u32`. Height of the region, in pixels.
/// - `rotated` — `bool`. Whether the region was rotated 90 degrees during packing.
#[derive(Debug, Clone)]
pub struct AtlasEntry {
    /// The region identifier.
    pub name: String,
    /// Left edge in pixels.
    pub x: u32,
    /// Top edge in pixels.
    pub y: u32,
    /// Width in pixels.
    pub w: u32,
    /// Height in pixels.
    pub h: u32,
    /// Whether the region was packed rotated.
    pub rotated: bool,
}

/// In-memory sprite atlas built from a TexturePacker JSON export.
///
/// Stores all regions in insertion order and provides name-keyed lookup via an
/// internal `HashMap<String, usize>` index.
///
/// # Fields
/// - `entries` — `Vec<AtlasEntry>`. All atlas regions in insertion order.
/// - `name_map` — `HashMap<String, usize>`. Maps region name to `entries` index.
#[derive(Debug, Clone)]
pub struct SpriteAtlas {
    entries: Vec<AtlasEntry>,
    name_map: HashMap<String, usize>,
}

impl SpriteAtlas {
    /// Creates an empty atlas.
    ///
    /// # Returns
    /// `SpriteAtlas`.
    pub fn new() -> Self {
        Self {
            entries: Vec::new(),
            name_map: HashMap::new(),
        }
    }

    /// Adds a region to the atlas.
    ///
    /// If a region with the same name already exists it is overwritten in-place.
    ///
    /// # Parameters
    /// - `entry` — [`AtlasEntry`].
    pub fn add_entry(&mut self, entry: AtlasEntry) {
        if let Some(&idx) = self.name_map.get(&entry.name) {
            self.entries[idx] = entry;
        } else {
            let idx = self.entries.len();
            self.name_map.insert(entry.name.clone(), idx);
            self.entries.push(entry);
        }
    }

    /// Returns the region with the given name, or `None`.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `Option<&AtlasEntry>`.
    pub fn get_entry(&self, name: &str) -> Option<&AtlasEntry> {
        self.name_map.get(name).and_then(|&i| self.entries.get(i))
    }

    /// Returns the region at the given index, or `None`.
    ///
    /// # Parameters
    /// - `index` — `usize`.
    ///
    /// # Returns
    /// `Option<&AtlasEntry>`.
    pub fn get_by_index(&self, index: usize) -> Option<&AtlasEntry> {
        self.entries.get(index)
    }

    /// Returns the number of regions in the atlas.
    ///
    /// # Returns
    /// `usize`.
    pub fn entry_count(&self) -> usize {
        self.entries.len()
    }

    /// Returns all region names in insertion order.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn entry_names(&self) -> Vec<&str> {
        self.entries.iter().map(|e| e.name.as_str()).collect()
    }
}

impl Default for SpriteAtlas {
    fn default() -> Self {
        Self::new()
    }
}

// -------------------------------------------------------------------------------
// JSON parser
// -------------------------------------------------------------------------------

/// Parses a TexturePacker JSON export string and returns a [`SpriteAtlas`].
///
/// Supports both hash-format (`"frames": { "name": {...} }`) and array-format
/// (`"frames": [ { "filename": "name", "frame": {...} } ]`) exports.
///
/// # Parameters
/// - `json_str` — `&str`. Raw TexturePacker JSON.
///
/// # Returns
/// `Result<SpriteAtlas, String>` — `Ok` with the populated atlas or `Err` with a
/// message describing why parsing failed.
pub fn parse_texturepacker_json(json_str: &str) -> Result<SpriteAtlas, String> {
    let value: serde_json::Value =
        serde_json::from_str(json_str).map_err(|e| format!("JSON parse error: {}", e))?;

    let frames = value
        .get("frames")
        .ok_or("Missing 'frames' key in TexturePacker JSON")?;

    let mut atlas = SpriteAtlas::new();

    match frames {
        // Array format: "frames": [ { "filename": "name", "frame": { "x":n, "y":n, "w":n, "h":n }, "rotated": false }, ... ]
        serde_json::Value::Array(arr) => {
            for item in arr {
                let name = item
                    .get("filename")
                    .and_then(|v| v.as_str())
                    .ok_or("Array-format frame missing 'filename'")?
                    .to_owned();
                let entry = parse_frame_entry(name, item)?;
                atlas.add_entry(entry);
            }
        }
        // Hash format: "frames": { "name": { "frame": { "x":n, "y":n, "w":n, "h":n }, "rotated": false }, ... }
        serde_json::Value::Object(map) => {
            for (name, item) in map {
                let entry = parse_frame_entry(name.clone(), item)?;
                atlas.add_entry(entry);
            }
        }
        _ => return Err("'frames' must be an object or array".into()),
    }

    Ok(atlas)
}

/// Extracts an `AtlasEntry` from a single frame record (shared between array and hash formats).
fn parse_frame_entry(name: String, item: &serde_json::Value) -> Result<AtlasEntry, String> {
    let frame = item.get("frame").ok_or_else(|| {
        format!("Frame '{}' missing 'frame' rect object", name)
    })?;

    let x = frame
        .get("x")
        .and_then(|v| v.as_u64())
        .ok_or_else(|| format!("Frame '{}' missing 'frame.x'", name))? as u32;
    let y = frame
        .get("y")
        .and_then(|v| v.as_u64())
        .ok_or_else(|| format!("Frame '{}' missing 'frame.y'", name))? as u32;
    let w = frame
        .get("w")
        .and_then(|v| v.as_u64())
        .ok_or_else(|| format!("Frame '{}' missing 'frame.w'", name))? as u32;
    let h = frame
        .get("h")
        .and_then(|v| v.as_u64())
        .ok_or_else(|| format!("Frame '{}' missing 'frame.h'", name))? as u32;
    let rotated = item
        .get("rotated")
        .and_then(|v| v.as_bool())
        .unwrap_or(false);

    Ok(AtlasEntry { name, x, y, w, h, rotated })
}

// -------------------------------------------------------------------------------
// Tests
// -------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn atlas_hash_format_parses_correctly() {
        let json = r#"{"frames":{"hero.png":{"frame":{"x":0,"y":0,"w":32,"h":32},"rotated":false}}}"#;
        let atlas = parse_texturepacker_json(json).unwrap();
        assert_eq!(atlas.entry_count(), 1);
        let entry = atlas.get_entry("hero.png").unwrap();
        assert_eq!(entry.x, 0);
        assert_eq!(entry.w, 32);
        assert!(!entry.rotated);
    }

    #[test]
    fn atlas_array_format_parses_correctly() {
        let json = r#"{"frames":[{"filename":"bullet.png","frame":{"x":32,"y":0,"w":8,"h":8},"rotated":true}]}"#;
        let atlas = parse_texturepacker_json(json).unwrap();
        let entry = atlas.get_entry("bullet.png").unwrap();
        assert_eq!(entry.x, 32);
        assert!(entry.rotated);
    }

    #[test]
    fn atlas_missing_frames_key_returns_error() {
        let json = r#"{"meta":{}}"#;
        assert!(parse_texturepacker_json(json).is_err());
    }
}
