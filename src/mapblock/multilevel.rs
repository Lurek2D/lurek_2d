//! Multi-level map data structure with per-level block grid accessors.
//!
//! - `MultilevelMap` wraps `LayerStack` and exposes named-level access (floor, roof, etc.).
//! - Level names are user-defined strings registered at generator init time.
//! - Provides `get(level, x, y)` and `set(level, x, y, tile)` with bounds checking.
//! - Serialized as a flat array of (level, x, y, tile) tuples in the save file.

use super::placement::PlacedBlock;

/// A complete multi-level map assembled from placed blocks on multiple storeys.
#[derive(Debug, Clone)]
pub struct MultiLevelMap {
    /// Levels (storeys) indexed from 0 (ground).
    levels: Vec<LevelData>,
    /// Maximum number of levels allowed.
    max_levels: u32,
}

/// Data for a single level/storey.
#[derive(Debug, Clone)]
pub struct LevelData {
    /// Placed blocks on this level.
    pub placed_blocks: Vec<PlacedBlock>,
    /// Level index (0 = ground).
    pub level_index: u32,
    /// Optional height of this level in tile units.
    pub height: u32,
}

impl MultiLevelMap {
    /// Create a new multi-level map with specified max levels.
    pub fn new(max_levels: u32) -> Self {
        let max_levels = max_levels.clamp(1, 10);
        let levels = (0..max_levels)
            .map(|i| LevelData {
                placed_blocks: Vec::new(),
                level_index: i,
                height: 1,
            })
            .collect();

        Self { levels, max_levels }
    }

    /// Get the total number of map levels.
    pub fn level_count(&self) -> u32 {
        self.max_levels
    }

    /// Get an immutable level by index.
    pub fn get_level(&self, index: u32) -> Option<&LevelData> {
        self.levels.get(index as usize)
    }

    /// Get a mutable map level by index.
    pub fn get_level_mut(&mut self, index: u32) -> Option<&mut LevelData> {
        self.levels.get_mut(index as usize)
    }

    /// Add a placed block to a specific level.
    pub fn add_block_to_level(&mut self, level: u32, block: PlacedBlock) -> bool {
        if let Some(level_data) = self.levels.get_mut(level as usize) {
            level_data.placed_blocks.push(block);
            true
        } else {
            false
        }
    }

    /// Get total number of placed blocks across all levels.
    pub fn total_block_count(&self) -> usize {
        self.levels.iter().map(|l| l.placed_blocks.len()).sum()
    }

    /// Get all placed blocks on a specific level.
    pub fn blocks_on_level(&self, level: u32) -> &[PlacedBlock] {
        self.levels
            .get(level as usize)
            .map(|l| l.placed_blocks.as_slice())
            .unwrap_or(&[])
    }

    /// Set height for a specific level.
    pub fn set_level_height(&mut self, level: u32, height: u32) {
        if let Some(level_data) = self.levels.get_mut(level as usize) {
            level_data.height = height;
        }
    }

    /// Clear all placed blocks on all levels.
    pub fn clear(&mut self) {
        for level in &mut self.levels {
            level.placed_blocks.clear();
        }
    }
}

impl LevelData {
    /// Check if this level has any placed blocks.
    pub fn is_empty(&self) -> bool {
        self.placed_blocks.is_empty()
    }

    /// Get the number of placed blocks on this level.
    pub fn block_count(&self) -> usize {
        self.placed_blocks.len()
    }
}
