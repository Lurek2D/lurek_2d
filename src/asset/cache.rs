//! `src/asset/cache.rs` owns ref-counted asset bookkeeping, including registration, lookup, tagging, and eviction.
//! It defines `AssetType`, `AssetEntry`, and `AssetCache`, keeping asset identity and lifecycle under one owner.
//! Normalized path keys live here so repeated registrations of the same typed asset resolve to one shared cache entry.
//! Reference increments, decrements, and zero-count removal are handled here, keeping lifetime behavior explicit.
//! Search helpers for names, groups, tags, and types also live here, giving tools and runtime systems one query surface.
//! Text-like assets may retain source content in memory here, while binary assets keep only path and metadata references.
//! Open this file when asset identity, retention policy, cache queries, or metadata semantics need engine-wide changes.

use std::collections::{HashMap, HashSet};
use std::path::{Component, Path};
use std::time::SystemTime;

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
/// - `SpriteSheet`: spritesheet metadata or file path reference.
/// - `Atlas`: atlas metadata or file path reference.
/// - `Animation`: animation metadata or file path reference.
/// - `Spine`: Spine skeleton metadata or file path reference.
/// - `TileMap`: tilemap metadata or file path reference.
/// - `TileSet`: tileset metadata or file path reference.
/// - `Unknown(String)`: unrecognized type string stored as-is.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
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
    /// Spritesheet asset; resolved by sprite-specific systems.
    SpriteSheet,
    /// Texture atlas asset; resolved by sprite-specific systems.
    Atlas,
    /// Frame animation asset; resolved by animation-specific systems.
    Animation,
    /// Spine skeleton or animation asset; resolved by spine-specific systems.
    Spine,
    /// Tilemap asset; resolved by tilemap-specific systems.
    TileMap,
    /// Tileset asset; resolved by tileset-specific systems.
    TileSet,
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
            "spritesheet" => Self::SpriteSheet,
            "atlas" => Self::Atlas,
            "animation" => Self::Animation,
            "spine" => Self::Spine,
            "tilemap" => Self::TileMap,
            "tileset" => Self::TileSet,
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
            Self::SpriteSheet => "spritesheet",
            Self::Atlas => "atlas",
            Self::Animation => "animation",
            Self::Spine => "spine",
            Self::TileMap => "tilemap",
            Self::TileSet => "tileset",
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
/// - `revision`: reload revision, starting at `1` for registered entries.
/// - `watched`: true when live reload monitoring is requested for this entry.
/// - `last_modified`: last observed file modification timestamp for watched reload checks.
#[derive(Clone)]
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
    /// Monotonic revision incremented whenever `reload()` refreshes the entry.
    pub revision: u64,
    /// Whether runtime live-reload monitoring is requested for this entry.
    pub watched: bool,
    /// Last observed source file modification time.
    pub last_modified: Option<SystemTime>,
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
    keys: HashMap<AssetKey, u64>,
    next_id: u64,
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct AssetKey {
    path: String,
    asset_type: String,
}

impl AssetKey {
    fn new(path: &str, asset_type: &AssetType) -> Self {
        Self {
            path: normalize_asset_path(path),
            asset_type: asset_type.as_str().to_string(),
        }
    }
}

fn normalize_asset_path(path: &str) -> String {
    if let Ok(canonical) = std::fs::canonicalize(path) {
        let canonical = canonical.to_string_lossy().replace('\\', "/");
        return if cfg!(windows) {
            canonical.to_lowercase()
        } else {
            canonical
        };
    }

    let mut normalized_parts: Vec<String> = Vec::new();
    for component in Path::new(path).components() {
        match component {
            Component::CurDir => {}
            Component::ParentDir => {
                if normalized_parts.last().is_some_and(|part| part != "..") {
                    normalized_parts.pop();
                } else {
                    normalized_parts.push("..".to_string());
                }
            }
            Component::Normal(part) => {
                normalized_parts.push(part.to_string_lossy().into_owned());
            }
            Component::RootDir => {
                normalized_parts.clear();
                normalized_parts.push(String::new());
            }
            Component::Prefix(prefix) => {
                normalized_parts.clear();
                normalized_parts.push(prefix.as_os_str().to_string_lossy().into_owned());
            }
        }
    }

    let normalized = normalized_parts.join("/");
    if cfg!(windows) {
        normalized.to_lowercase()
    } else {
        normalized
    }
}

fn asset_modified(path: &str) -> Option<SystemTime> {
    std::fs::metadata(path)
        .and_then(|metadata| metadata.modified())
        .ok()
}

impl AssetCache {
    /// Creates an empty cache with the ID counter starting at `1`.
    pub fn new() -> Self {
        Self {
            entries: HashMap::new(),
            keys: HashMap::new(),
            next_id: 1,
        }
    }

    /// Registers or reuses an entry and returns its unique handle ID.
    ///
    /// When the same `(normalized path, asset type)` pair is already present,
    /// the existing entry is retained and its ref count is incremented.
    /// Otherwise, a new entry is created with initial ref count `1`.
    pub fn register(
        &mut self,
        path: String,
        asset_type: AssetType,
        text_content: Option<String>,
    ) -> u64 {
        let key = AssetKey::new(&path, &asset_type);
        if let Some(id) = self.keys.get(&key).copied() {
            self.inc_ref(id);
            return id;
        }

        let id = self.next_id;
        self.next_id += 1;
        self.entries.insert(
            id,
            AssetEntry {
                last_modified: asset_modified(&path),
                path,
                asset_type,
                ref_count: 1,
                text_content,
                name: None,
                group: None,
                tags: HashSet::new(),
                revision: 1,
                watched: false,
            },
        );
        self.keys.insert(key, id);
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
        let removal_key = if let Some(e) = self.entries.get_mut(&id) {
            e.ref_count = e.ref_count.saturating_sub(1);
            (e.ref_count == 0).then(|| AssetKey::new(&e.path, &e.asset_type))
        } else {
            None
        };

        if let Some(key) = removal_key {
            self.entries.remove(&id);
            self.keys.remove(&key);
        }
    }

    /// Returns a reference to the entry with the given ID, or `None`.
    pub fn get(&self, id: u64) -> Option<&AssetEntry> {
        self.entries.get(&id)
    }

    /// Returns a mutable reference to an entry with the given ID, or `None`.
    pub fn get_mut(&mut self, id: u64) -> Option<&mut AssetEntry> {
        self.entries.get_mut(&id)
    }

    /// Returns the current revision for `id`, or `0` when not present.
    pub fn revision(&self, id: u64) -> u64 {
        self.entries.get(&id).map_or(0, |e| e.revision)
    }

    /// Marks an entry as watched for live reload.
    ///
    /// Returns `true` when the entry exists.
    pub fn watch(&mut self, id: u64) -> bool {
        if let Some(e) = self.entries.get_mut(&id) {
            e.watched = true;
            e.last_modified = asset_modified(&e.path);
            true
        } else {
            false
        }
    }

    /// Returns `true` when a watched entry's source timestamp changed.
    pub fn watched_changed(&self, id: u64) -> bool {
        self.entries.get(&id).is_some_and(|entry| {
            entry.watched
                && asset_modified(&entry.path).is_some_and(|modified| {
                    entry
                        .last_modified
                        .is_some_and(|last_modified| modified != last_modified)
                })
        })
    }

    /// Replaces cached text content and increments the entry revision.
    ///
    /// Binary assets pass `None`; the cache only records their path and revision.
    pub fn reload(&mut self, id: u64, text_content: Option<String>) -> Option<u64> {
        let entry = self.entries.get_mut(&id)?;
        entry.text_content = text_content;
        entry.revision = entry.revision.saturating_add(1);
        entry.last_modified = asset_modified(&entry.path);
        Some(entry.revision)
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
        self.keys.clear();
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
