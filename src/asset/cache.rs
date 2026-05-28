//! Ref-counted asset cache.
//! Stores asset entries keyed by numeric handle IDs.

use std::collections::HashMap;

/// Discriminant for a cached asset type.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AssetType {
    Image,
    Font,
    Audio,
    Text,
    Unknown(String),
}

impl AssetType {
    /// Parses the Lua-facing type string into an `AssetType` variant.
    pub fn from_type_str(s: &str) -> Self {
        match s {
            "image" => Self::Image,
            "font" => Self::Font,
            "audio" => Self::Audio,
            "text" => Self::Text,
            other => Self::Unknown(other.to_string()),
        }
    }

    /// Returns the canonical string representation used in stats tables.
    pub fn as_str(&self) -> &str {
        match self {
            Self::Image => "image",
            Self::Font => "font",
            Self::Audio => "audio",
            Self::Text => "text",
            Self::Unknown(s) => s.as_str(),
        }
    }
}

/// A single cached asset entry.
pub struct AssetEntry {
    /// Filesystem path for this asset.
    pub path: String,
    /// Asset type discriminant.
    pub asset_type: AssetType,
    /// Current reference count. Entry is removed when this reaches zero.
    pub ref_count: usize,
    /// Cached text content for `AssetType::Text` assets; `None` for all others.
    pub text_content: Option<String>,
}

/// Ref-counted asset cache keyed by handle IDs.
pub struct AssetCache {
    entries: HashMap<u64, AssetEntry>,
    next_id: u64,
}

impl AssetCache {
    /// Creates an empty cache.
    pub fn new() -> Self {
        Self {
            entries: HashMap::new(),
            next_id: 1,
        }
    }

    /// Registers a new asset entry and returns its unique handle ID.
    ///
    /// The initial ref count is 1.
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

    /// Removes all entries from the cache.
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
