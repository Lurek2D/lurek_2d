//! This file owns `SpriteBatch` and `BatchEntry`, the single-texture accumulation layer for grouped sprite draws.
//! It stores the batch texture binding, per-entry source quads, transforms, pivots, and an optional capacity limit.
//! Helpers add entries, expose the borrowed entry slice, and clear retained frame data without rebuilding allocations.
//! Open this file when grouped submission shape changes; sprite state, atlas parsing, and animation live in siblings.

use crate::runtime::resource_keys::TextureKey;
use crate::sprite::limits::SpriteLimits;
use std::collections::BTreeSet;
use std::ops::Range;

/// # Fields
///
/// Deferred sprite draw-call collector bound to a single texture.
pub struct SpriteBatch {
    /// Texture all entries in this batch draw from.
    texture_key: TextureKey,
    /// Accumulated draw entries for this frame.
    entries: Vec<BatchEntry>,
    /// Trusted upper bound on entries; add() returns `None` when full or allocation fails.
    max_entries: usize,
    /// Monotonic content version used by Lua-side caches and synchronization code.
    version: u64,
}
/// # Fields
///
/// A single sprite draw entry with world position, source quad, transform, and origin offset.
#[derive(Debug, Clone, PartialEq)]
pub struct BatchEntry {
    /// World-space X position of this sprite.
    pub x: f32,
    /// World-space Y position of this sprite.
    pub y: f32,
    /// Source quad X in the texture, in pixels.
    pub quad_x: f32,
    /// Source quad Y in the texture, in pixels.
    pub quad_y: f32,
    /// Source quad width in pixels.
    pub quad_w: f32,
    /// Source quad height in pixels.
    pub quad_h: f32,
    /// Rotation in radians counter-clockwise around the origin offset.
    pub rotation: f32,
    /// Horizontal scale factor; 1.0 = no scale.
    pub sx: f32,
    /// Vertical scale factor; 1.0 = no scale.
    pub sy: f32,
    /// X origin offset used as pivot for rotation and scale.
    pub ox: f32,
    /// Y origin offset used as pivot for rotation and scale.
    pub oy: f32,
}
/// Construction and entry management for SpriteBatch.
impl SpriteBatch {
    /// Create a bounded batch; 0 uses a default capacity of 256.
    pub fn new(texture_key: TextureKey, max_entries: usize) -> Self {
        let cap =
            if max_entries > 0 { max_entries } else { 256 }.min(SpriteLimits::MAX_BATCH_ENTRIES);
        SpriteBatch {
            texture_key,
            entries: Vec::new(),
            max_entries: cap,
            version: 1,
        }
    }
    /// Append a BatchEntry; returns `None` when the limit or allocator rejects the entry.
    pub fn add(&mut self, entry: BatchEntry) -> Option<usize> {
        if self.entries.len() >= self.max_entries || self.entries.try_reserve(1).is_err() {
            return None;
        }
        let idx = self.entries.len();
        self.entries.push(entry);
        self.bump_version();
        Some(idx)
    }
    /// Atomically append many entries and return their zero-based index range.
    pub fn add_many(&mut self, entries: Vec<BatchEntry>) -> Result<Range<usize>, String> {
        let start = self.entries.len();
        let end = start
            .checked_add(entries.len())
            .ok_or_else(|| "sprite batch entry count overflow".to_string())?;
        if end > self.max_entries {
            return Err(format!(
                "sprite batch capacity {} exceeded by {} entries",
                self.max_entries, end
            ));
        }
        self.entries
            .try_reserve(entries.len())
            .map_err(|_| "sprite batch allocation failed".to_string())?;
        if !entries.is_empty() {
            self.entries.extend(entries);
            self.bump_version();
        }
        Ok(start..end)
    }
    /// Atomically replace every entry, preserving the configured capacity.
    pub fn set_entries(&mut self, entries: Vec<BatchEntry>) -> Result<usize, String> {
        if entries.len() > self.max_entries {
            return Err(format!(
                "sprite batch capacity {} exceeded by {} entries",
                self.max_entries,
                entries.len()
            ));
        }
        let count = entries.len();
        if self.entries != entries {
            self.entries = entries;
            self.bump_version();
        }
        Ok(count)
    }
    /// Atomically replace selected zero-based entries.
    pub fn update_entries(&mut self, updates: Vec<(usize, BatchEntry)>) -> Result<usize, String> {
        let mut seen = BTreeSet::new();
        for (index, _) in &updates {
            if *index >= self.entries.len() {
                return Err(format!(
                    "sprite batch entry index {} is out of bounds for {} entries",
                    index,
                    self.entries.len()
                ));
            }
            if !seen.insert(*index) {
                return Err(format!("sprite batch entry index {index} is duplicated"));
            }
        }
        let changed = updates
            .iter()
            .filter(|(index, entry)| self.entries[*index] != *entry)
            .count();
        if changed > 0 {
            for (index, entry) in updates {
                self.entries[index] = entry;
            }
            self.bump_version();
        }
        Ok(changed)
    }
    /// Atomically remove selected zero-based entries.
    pub fn remove_entries(&mut self, indices: Vec<usize>) -> Result<usize, String> {
        let mut unique = BTreeSet::new();
        for index in indices {
            if index >= self.entries.len() {
                return Err(format!(
                    "sprite batch entry index {} is out of bounds for {} entries",
                    index,
                    self.entries.len()
                ));
            }
            if !unique.insert(index) {
                return Err(format!("sprite batch entry index {index} is duplicated"));
            }
        }
        let removed = unique.len();
        for index in unique.into_iter().rev() {
            self.entries.remove(index);
        }
        if removed > 0 {
            self.bump_version();
        }
        Ok(removed)
    }
    /// Remove all entries without releasing the underlying allocation.
    pub fn clear(&mut self) {
        if !self.entries.is_empty() {
            self.entries.clear();
            self.bump_version();
        }
    }
    /// Return the TextureKey this batch is bound to.
    pub fn texture_key(&self) -> TextureKey {
        self.texture_key
    }
    /// Return the accumulated entry slice for this frame.
    pub fn entries(&self) -> &[BatchEntry] {
        &self.entries
    }
    /// Return the current number of entries in the batch.
    pub fn len(&self) -> usize {
        self.entries.len()
    }
    /// Return true when the batch contains no entries.
    pub fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }
    /// Return the trusted effective entry cap.
    pub fn buffer_size(&self) -> usize {
        self.max_entries
    }
    /// Return the remaining entry capacity.
    pub fn remaining(&self) -> usize {
        self.max_entries.saturating_sub(self.entries.len())
    }
    /// Return the monotonic content version.
    pub fn version(&self) -> u64 {
        self.version
    }

    fn bump_version(&mut self) {
        self.version = self.version.saturating_add(1);
    }
}
