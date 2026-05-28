//! Named block groups for weighted random selection and themed zone filling.
//!
//! - Data type: `MapGroup`.
//! - Implementation: `MapGroup`.

use super::block::MapBlock;
use super::script::MapScript;

/// A named collection of blocks and scripts used together for generation.
#[derive(Debug, Clone)]
pub struct MapGroup {
    /// Group identifier.
    name: String,
    /// Blocks belonging to this group.
    blocks: Vec<MapBlock>,
    /// Scripts that can be run with this group's blocks.
    scripts: Vec<MapScript>,
}

impl MapGroup {
    /// Create an empty group with the given name.
    pub fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            blocks: Vec::new(),
            scripts: Vec::new(),
        }
    }

    /// Append a map block to this group.
    pub fn add_block(&mut self, block: MapBlock) {
        self.blocks.push(block);
    }

    /// Get an immutable block by index.
    pub fn get_block(&self, index: usize) -> Option<&MapBlock> {
        self.blocks.get(index)
    }

    /// Get a mutable map block by index.
    pub fn get_block_mut(&mut self, index: usize) -> Option<&mut MapBlock> {
        self.blocks.get_mut(index)
    }

    /// Get the total number of blocks in this group.
    pub fn block_count(&self) -> usize {
        self.blocks.len()
    }

    /// Remove a map block at the given index.
    pub fn remove_block(&mut self, index: usize) {
        if index < self.blocks.len() {
            self.blocks.remove(index);
        }
    }

    /// Add a map script to this group.
    pub fn add_script(&mut self, script: MapScript) {
        self.scripts.push(script);
    }

    /// Get an immutable script by index.
    pub fn get_script(&self, index: usize) -> Option<&MapScript> {
        self.scripts.get(index)
    }

    /// Get the number of scripts in this group.
    pub fn script_count(&self) -> usize {
        self.scripts.len()
    }

    /// Get this group's display name.
    pub fn name(&self) -> &str {
        &self.name
    }

    /// Set this group's display name.
    pub fn set_name(&mut self, name: &str) {
        self.name = name.to_string();
    }

    /// Get all map blocks in this group as a slice.
    pub fn blocks(&self) -> &[MapBlock] {
        &self.blocks
    }

    /// Get all scripts in this group as a slice.
    pub fn scripts(&self) -> &[MapScript] {
        &self.scripts
    }

    /// Find a block index by block name.
    pub fn find_block(&self, name: &str) -> Option<usize> {
        self.blocks.iter().position(|b| b.get_name() == name)
    }
}
