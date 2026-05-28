//! Carcassonne-style edge constraints for matching adjacent map blocks.
//!
//! - Data types: `EdgeConstraint`, `NeighborRules`.
//! - Function: `opposite_edge`.

use super::block::Edge;
use std::collections::{HashMap, HashSet};

/// A single edge constraint on a block.
#[derive(Debug, Clone)]
pub struct EdgeConstraint {
    /// Which edge this constraint applies to.
    pub edge: Edge,
    /// Segment index along the edge.
    pub segment: u32,
    /// Edge type identifier.
    pub edge_type: u32,
}

/// Rules for neighbor matching between blocks.
#[derive(Debug, Clone)]
pub struct NeighborRules {
    /// Compatibility map: edge_type → set of compatible edge_types.
    compatibility: HashMap<u32, HashSet<u32>>,
    /// Block indices that must be placed on map edges.
    edge_required: HashSet<usize>,
    /// Block indices that must not be placed on map edges.
    interior_only: HashSet<usize>,
}

impl NeighborRules {
    /// Create empty neighbor rules.
    pub fn new() -> Self {
        Self {
            compatibility: HashMap::new(),
            edge_required: HashSet::new(),
            interior_only: HashSet::new(),
        }
    }

    /// Add a bidirectional compatibility rule: type_a matches type_b and vice versa.
    pub fn add_compatible(&mut self, type_a: u32, type_b: u32) {
        self.compatibility
            .entry(type_a)
            .or_default()
            .insert(type_b);
        self.compatibility
            .entry(type_b)
            .or_default()
            .insert(type_a);
    }

    /// Add a one-directional compatibility rule: type_a matches type_b (but not reverse).
    pub fn add_compatible_one_way(&mut self, type_a: u32, type_b: u32) {
        self.compatibility
            .entry(type_a)
            .or_default()
            .insert(type_b);
    }

    /// Check if two edge types are compatible.
    pub fn is_compatible(&self, type_a: u32, type_b: u32) -> bool {
        // Same type always matches.
        if type_a == type_b {
            return true;
        }
        // Type 0 (wildcard/unset) matches anything.
        if type_a == 0 || type_b == 0 {
            return true;
        }
        self.compatibility
            .get(&type_a)
            .map(|set| set.contains(&type_b))
            .unwrap_or(false)
    }

    /// Mark a block index as requiring edge placement.
    pub fn set_edge_required(&mut self, block_index: usize) {
        self.edge_required.insert(block_index);
        self.interior_only.remove(&block_index);
    }

    /// Mark a block index as interior-only (cannot be on edge).
    pub fn set_interior_only(&mut self, block_index: usize) {
        self.interior_only.insert(block_index);
        self.edge_required.remove(&block_index);
    }

    /// Check if a block index requires edge placement.
    pub fn is_edge_required(&self, block_index: usize) -> bool {
        self.edge_required.contains(&block_index)
    }

    /// Check if a block index is interior-only.
    pub fn is_interior_only(&self, block_index: usize) -> bool {
        self.interior_only.contains(&block_index)
    }

    /// Get all compatible types for a given edge type.
    pub fn get_compatible(&self, edge_type: u32) -> Option<&HashSet<u32>> {
        self.compatibility.get(&edge_type)
    }

    /// Clear all compatibility and constraint rules.
    pub fn clear(&mut self) {
        self.compatibility.clear();
        self.edge_required.clear();
        self.interior_only.clear();
    }
}

impl Default for NeighborRules {
    fn default() -> Self {
        Self::new()
    }
}

/// Return the opposite edge direction.
pub fn opposite_edge(edge: Edge) -> Edge {
    match edge {
        Edge::North => Edge::South,
        Edge::South => Edge::North,
        Edge::East => Edge::West,
        Edge::West => Edge::East,
    }
}
