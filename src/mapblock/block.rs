//! Map block definition: tile slots, edge connection points, and per-block metadata.
//!
//! - `MapBlock` holds a grid of `MapTile` slots and a set of edge constraint descriptors.
//! - `BlockMeta` carries the name, weight, group membership, and tileset reference.
//! - Blocks are loaded from TOML files under `content/maps/blocks/`.
//! - Exposed to Lua via `lurek.mapblock.define(spec)` for runtime registration.

use super::config::MapBlockConfig;
use super::constraints::EdgeConstraint;
use super::layer::BlockLayer;
use std::collections::HashMap;

/// Cardinal direction for block edges.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Edge {
    /// North edge (top).
    North,
    /// East edge (right).
    East,
    /// South edge (bottom).
    South,
    /// West edge (left).
    West,
}

/// A composable map block containing layers of tiles with edge constraints.
#[derive(Debug, Clone)]
pub struct MapBlock {
    /// Block name/identifier.
    pub name: String,
    /// Width in tiles.
    width: u32,
    /// Height in tiles.
    height: u32,
    /// Layers (1..=10), index 0 = bottom.
    layers: Vec<BlockLayer>,
    /// Number of slots per tile from config.
    slot_count: usize,
    /// Edge type IDs: `(Edge, segment_index) -> edge_type_id`.
    sides: HashMap<(Edge, u32), u32>,
    /// Block weight for random selection (higher = more likely).
    pub weight: f32,
    /// If true, this block must be placed on the map edge.
    pub edge_only: bool,
    /// If true, this block cannot be placed on the map edge.
    pub interior_only: bool,
    /// Number of vertical levels this block spans (for multi-level maps).
    pub level_span: u32,
    /// Legacy segment size (for compatibility with existing mapgen).
    pub segment_size: u32,
}

impl MapBlock {
    /// Create a new map block with given dimensions and layer count.
    pub fn new(width: u32, height: u32, layer_count: u32, config: &MapBlockConfig) -> Self {
        let slot_count = config.slot_count();
        let layer_count = layer_count.clamp(1, config.max_layers);
        let layers = (0..layer_count)
            .map(|_| BlockLayer::new(width, height, slot_count))
            .collect();

        Self {
            name: String::new(),
            width,
            height,
            layers,
            slot_count,
            sides: HashMap::new(),
            weight: 1.0,
            edge_only: false,
            interior_only: false,
            level_span: 1,
            segment_size: width,
        }
    }

    /// Create a block from legacy mapgen format (single layer, raw GID data).
    pub fn from_legacy(
        width: u32,
        height: u32,
        segment_size: u32,
        tile_data: &[Vec<u32>],
        sides: &HashMap<(Edge, u32), u32>,
        name: &str,
        weight: f32,
    ) -> Self {
        let slot_count = 1; // Legacy uses single slot (floor only)
        let mut layers = Vec::new();

        for layer_data in tile_data {
            let mut layer = BlockLayer::new(width, height, slot_count);
            for y in 0..height {
                for x in 0..width {
                    let idx = (y * width + x) as usize;
                    if idx < layer_data.len() && layer_data[idx] != 0 {
                        layer.set_tile_slot(x, y, 0, 1, layer_data[idx]);
                    }
                }
            }
            layers.push(layer);
        }

        if layers.is_empty() {
            layers.push(BlockLayer::new(width, height, slot_count));
        }

        Self {
            name: name.to_string(),
            width,
            height,
            layers,
            slot_count,
            sides: sides.clone(),
            weight,
            edge_only: false,
            interior_only: false,
            level_span: 1,
            segment_size,
        }
    }

    /// Get the block width in tile units.
    pub fn get_width(&self) -> u32 {
        self.width
    }

    /// Get the block height in tile units.
    pub fn get_height(&self) -> u32 {
        self.height
    }

    /// Get the total number of tile layers.
    pub fn get_layer_count(&self) -> u32 {
        self.layers.len() as u32
    }

    /// Get an immutable tile layer by index.
    pub fn get_layer(&self, index: usize) -> Option<&BlockLayer> {
        self.layers.get(index)
    }

    /// Get a mutable tile layer by index.
    pub fn get_layer_mut(&mut self, index: usize) -> Option<&mut BlockLayer> {
        self.layers.get_mut(index)
    }

    /// Add a new empty layer. Returns false if max layers reached.
    pub fn add_layer(&mut self, max_layers: u32) -> bool {
        if self.layers.len() < max_layers as usize {
            self.layers
                .push(BlockLayer::new(self.width, self.height, self.slot_count));
            true
        } else {
            false
        }
    }

    /// Set a tile slot value at (layer, x, y, slot).
    pub fn set_tile(
        &mut self,
        layer: usize,
        x: u32,
        y: u32,
        slot_index: usize,
        tileset_id: u32,
        gid: u32,
    ) {
        if let Some(l) = self.layers.get_mut(layer) {
            l.set_tile_slot(x, y, slot_index, tileset_id, gid);
        }
    }

    /// Get a tile GID at (layer, x, y, slot).
    pub fn get_tile(&self, layer: usize, x: u32, y: u32, slot_index: usize) -> u32 {
        self.layers
            .get(layer)
            .map(|l| l.get_tile_gid(x, y, slot_index))
            .unwrap_or(0)
    }

    /// Legacy get_tile for single-slot blocks (slot 0, layer 0).
    pub fn get_tile_legacy(&self, _layer: usize, x: u32, y: u32) -> u32 {
        self.get_tile(0, x, y, 0)
    }

    /// Set edge type for a given side and segment index.
    pub fn set_edge(&mut self, edge: Edge, segment: u32, edge_type: u32) {
        self.sides.insert((edge, segment), edge_type);
    }

    /// Get edge type for a given side and segment index.
    pub fn get_edge(&self, edge: Edge, segment: u32) -> Option<u32> {
        self.sides.get(&(edge, segment)).copied()
    }

    /// Get all edge constraints for this block.
    pub fn get_edge_constraints(&self) -> Vec<EdgeConstraint> {
        self.sides
            .iter()
            .map(|((edge, seg), edge_type)| EdgeConstraint {
                edge: *edge,
                segment: *seg,
                edge_type: *edge_type,
            })
            .collect()
    }

    /// Set the display name of this block.
    pub fn set_name(&mut self, name: &str) {
        self.name = name.to_string();
    }

    /// Get the display name of this block.
    pub fn get_name(&self) -> &str {
        &self.name
    }

    /// Get number of segments along an edge (width / segment_size or height / segment_size).
    pub fn segments_horizontal(&self) -> u32 {
        if self.segment_size > 0 {
            self.width / self.segment_size
        } else {
            1
        }
    }

    /// Get number of segments along vertical edge.
    pub fn segments_vertical(&self) -> u32 {
        if self.segment_size > 0 {
            self.height / self.segment_size
        } else {
            1
        }
    }
}
