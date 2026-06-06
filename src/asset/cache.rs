//! Implements a reference-counted asset registry for tracking media lifecycle across runtime systems.
//! Stores normalized metadata, optional text payloads, and ownership counters for shared access.
//! Separates cache bookkeeping from decoded resource ownership handled by feature-specific modules.
//! Supports acquisition, release, and eviction decisions through explicit handle lifecycle updates.
//! Provides metadata and tag-query surfaces for tooling, filtering, and runtime introspection.
//! Preserves deterministic cache semantics so repeated asset flow remains predictable.
//! Serves as the core state container behind the engine-facing `lurek.asset` behavior.

use std::collections::{HashMap, HashSet};

/// Asset type discriminant used by the `lurek.asset` cache registry.
///
/// Governs how `get()` resolves the underlying resource and which
/// `lurek.*` constructor is called on the Lua side.
///
/// # Variants
///
/// - `Image`: raster image path reference.
/// - `Font`: font file path reference.
/// - `Audio`: short SFX source path reference.
/// - `Music`: long music source path reference.
/// - `Text`: plain-text file content cached in memory.
/// - `Toml`: TOML source text cached in memory.
/// - `Json`: JSON source text cached in memory.
/// - `Obj`: OBJ source text cached in memory.
/// - `Shader`: shader source text cached in memory.
/// - `Lua`: Lua source text cached in memory.
/// - `Unknown(String)`: unrecognized type string stored as-is.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AssetType {
    /// Raster image; resolved via `lurek.image.loadImage`.
    Image,
    /// Bitmap or TTF font; resolved via `lurek.font.load`.
    Font,
    /// Short-form sound effect; resolved via `lurek.audio.newSource`.
    Audio,
    /// Long-form background music; resolved via `lurek.audio.newSource`.
    Music,
    /// Plain text file; content is read and cached as a Rust `String`.
    Text,
    /// TOML configuration file; content is read and cached as raw TOML text.
    Toml,
    /// JSON data file; content is read and cached as raw JSON text.
    Json,
    /// Wavefront OBJ geometry; content is read and cached as raw text.
    /// Useful for 2-D collision geometry, minimap outlines, or AI nav meshes.
    Obj,
    /// WGSL or custom shader source text.
    Shader,
    /// Lua script source text (for modding or data-driven logic).
    Lua,
    /// Unrecognised type string; stored by path reference only.
    Unknown(String),
}

impl AssetType {
    /// Parses the Lua-facing lowercase type string into the matching variant.
    pub fn from_type_str(s: &str) -> Self {
        match s {
            "image" => Self::Image,
            "font" => Self::Font,
            "audio" => Self::Audio,
            "music" => Self::Music,
            "text" => Self::Text,
            "toml" => Self::Toml,
            "json" => Self::Json,
            "obj" => Self::Obj,
            "shader" => Self::Shader,
            "lua" => Self::Lua,
            other => Self::Unknown(other.to_string()),
        }
    }

    /// Returns `true` when the type stores its content as in-process text.
    ///
    /// Text-like types (`text`, `toml`, `json`, `obj`, `shader`, `lua`) are read
    /// from disk and stored in `AssetEntry::text_content`. Binary types (`image`,
    /// `font`, `audio`, `music`) store only the path reference.
    pub fn is_text_like(&self) -> bool {
        matches!(
            self,
            Self::Text | Self::Toml | Self::Json | Self::Obj | Self::Shader | Self::Lua
        )
    }

    /// Returns the canonical lowercase string used in stats tables and Lua-side queries.
    pub fn as_str(&self) -> &str {
        match self {
            Self::Image => "image",
            Self::Font => "font",
            Self::Audio => "audio",
            Self::Music => "music",
            Self::Text => "text",
            Self::Toml => "toml",
            Self::Json => "json",
            Self::Obj => "obj",
            Self::Shader => "shader",
            Self::Lua => "lua",
            Self::Unknown(s) => s.as_str(),
        }
    }
}

/// A single registered asset entry.
///
/// # Fields
///
/// - `path`: filesystem path to the source file.
/// - `asset_type`: type discriminant used by Lua `get()`.
/// - `ref_count`: manual retain/release counter.
/// - `text_content`: cached source text for text-like assets.
/// - `name`: optional display name.
/// - `group`: optional grouping key.
/// - `tags`: searchable tag set.
pub struct AssetEntry {
    /// Filesystem path to the asset.
    pub path: String,
    /// Asset type discriminant.
    pub asset_type: AssetType,
    /// Reference count; the entry is removed when this reaches zero.
    pub ref_count: usize,
    /// Cached file content for text-like types; `None` for binary types.
    pub text_content: Option<String>,
    /// Optional human-readable display name. Defaults to the path file-stem.
    pub name: Option<String>,
    /// Optional group label for bulk operations (e.g. `"ui"`, `"level_1"`).
    pub group: Option<String>,
    /// Searchable tag set (e.g. `"enemy"`, `"sfx"`, `"hud"`).
    pub tags: HashSet<String>,
}

/// Ref-counted asset cache keyed by `u64` handle IDs.
///
/// All mutation is performed through `&mut self` methods. Interior mutability
/// is provided by the `Rc<RefCell<AssetCache>>` wrapper created in
/// `asset_api::register()`.
///
/// # Fields
///
/// - `entries`: map of handle ID to `AssetEntry`.
/// - `next_id`: monotonically increasing handle counter.
pub struct AssetCache {
    entries: HashMap<u64, AssetEntry>,
    next_id: u64,
}

impl AssetCache {
    /// Creates an empty cache with the ID counter starting at `1`.
    pub fn new() -> Self {
        Self {
            entries: HashMap::new(),
            next_id: 1,
        }
    }

    /// Registers a new entry and returns its unique handle ID.
    ///
    /// The initial ref count is `1`. Name, group, and tags can be set after
    /// registration with the corresponding setter methods.
    pub fn register(
        &mut self,
        path: String,
        asset_type: AssetType,
        text_content: Option<String>,
    ) -> u64 {
        let id = self.next_id;
        self.next_id += 1;
        self.entries.insert(
            id,
            AssetEntry {
                path,
                asset_type,
                ref_count: 1,
                text_content,
                name: None,
                group: None,
                tags: HashSet::new(),
            },
        );
        id
    }

    /// Increments the ref count for `id`.
    pub fn inc_ref(&mut self, id: u64) {
        if let Some(e) = self.entries.get_mut(&id) {
            e.ref_count += 1;
        }
    }

    /// Decrements the ref count for `id`; removes the entry when it reaches zero.
    pub fn dec_ref(&mut self, id: u64) {
        if let Some(e) = self.entries.get_mut(&id) {
            e.ref_count = e.ref_count.saturating_sub(1);
            if e.ref_count == 0 {
                self.entries.remove(&id);
            }
        }
    }

    /// Returns a reference to the entry with the given ID, or `None`.
    pub fn get(&self, id: u64) -> Option<&AssetEntry> {
        self.entries.get(&id)
    }

    /// Sets the display name for the entry with the given ID.
    ///
    /// Does nothing when `id` is not present.
    pub fn set_name(&mut self, id: u64, name: String) {
        if let Some(e) = self.entries.get_mut(&id) {
            e.name = Some(name);
        }
    }

    /// Sets the group label for the entry with the given ID.
    ///
    /// Does nothing when `id` is not present.
    pub fn set_group(&mut self, id: u64, group: String) {
        if let Some(e) = self.entries.get_mut(&id) {
            e.group = Some(group);
        }
    }

    /// Adds `tag` to the tag set of the entry with the given ID.
    ///
    /// Does nothing when `id` is not present.
    pub fn add_tag(&mut self, id: u64, tag: &str) {
        if let Some(e) = self.entries.get_mut(&id) {
            e.tags.insert(tag.to_string());
        }
    }

    /// Removes `tag` from the tag set of the entry with the given ID.
    ///
    /// Returns `true` when the tag was present and removed.
    pub fn remove_tag(&mut self, id: u64, tag: &str) -> bool {
        if let Some(e) = self.entries.get_mut(&id) {
            e.tags.remove(tag)
        } else {
            false
        }
    }

    /// Returns `true` when the entry with the given ID has the given tag.
    pub fn has_tag(&self, id: u64, tag: &str) -> bool {
        self.entries.get(&id).is_some_and(|e| e.tags.contains(tag))
    }

    /// Returns the current ref count for `id`, or `0` when not present.
    pub fn ref_count(&self, id: u64) -> usize {
        self.entries.get(&id).map_or(0, |e| e.ref_count)
    }

    /// Returns `true` if `id` is still present in the cache.
    pub fn is_loaded(&self, id: u64) -> bool {
        self.entries.contains_key(&id)
    }

    /// Total number of live entries.
    pub fn loaded_count(&self) -> usize {
        self.entries.len()
    }

    /// Sum of all ref counts across all live entries.
    pub fn total_refs(&self) -> usize {
        self.entries.values().map(|e| e.ref_count).sum()
    }

    /// Returns all IDs whose display name contains `substr` (case-insensitive).
    ///
    /// When no explicit name is set, the path file-stem is used for comparison.
    pub fn find_by_name(&self, substr: &str) -> Vec<u64> {
        let lower = substr.to_lowercase();
        let mut ids: Vec<u64> = self
            .entries
            .iter()
            .filter(|(_, e)| {
                let stem = e.name.as_deref().unwrap_or_else(|| {
                    // Safe: path is always a valid string; worst case empty str.
                    std::path::Path::new(e.path.as_str())
                        .file_stem()
                        .and_then(|s| s.to_str())
                        .unwrap_or("")
                });
                stem.to_lowercase().contains(&lower)
            })
            .map(|(id, _)| *id)
            .collect();
        ids.sort_unstable();
        ids
    }

    /// Returns all IDs whose group label exactly matches `group`.
    pub fn find_by_group(&self, group: &str) -> Vec<u64> {
        let mut ids: Vec<u64> = self
            .entries
            .iter()
            .filter(|(_, e)| e.group.as_deref() == Some(group))
            .map(|(id, _)| *id)
            .collect();
        ids.sort_unstable();
        ids
    }

    /// Returns all IDs that have `tag` in their tag set.
    pub fn find_by_tag(&self, tag: &str) -> Vec<u64> {
        let mut ids: Vec<u64> = self
            .entries
            .iter()
            .filter(|(_, e)| e.tags.contains(tag))
            .map(|(id, _)| *id)
            .collect();
        ids.sort_unstable();
        ids
    }

    /// Returns all IDs whose asset type string matches `type_str` exactly.
    pub fn find_by_type(&self, type_str: &str) -> Vec<u64> {
        let mut ids: Vec<u64> = self
            .entries
            .iter()
            .filter(|(_, e)| e.asset_type.as_str() == type_str)
            .map(|(id, _)| *id)
            .collect();
        ids.sort_unstable();
        ids
    }

    /// Returns all unique group labels currently in the cache (sorted).
    pub fn unique_groups(&self) -> Vec<String> {
        let mut groups: Vec<String> = self
            .entries
            .values()
            .filter_map(|e| e.group.clone())
            .collect::<std::collections::HashSet<_>>()
            .into_iter()
            .collect();
        groups.sort();
        groups
    }

    /// Removes all entries from the cache, regardless of ref counts.
    pub fn clear(&mut self) {
        self.entries.clear();
    }

    /// Returns an iterator over all `(id, entry)` pairs.
    pub fn iter(&self) -> impl Iterator<Item = (&u64, &AssetEntry)> {
        self.entries.iter()
    }
}

impl Default for AssetCache {
    fn default() -> Self {
        Self::new()
    }
}
