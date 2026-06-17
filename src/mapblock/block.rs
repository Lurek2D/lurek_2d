//! Fundamental mapblock unit combining tile payloads, edge sockets, and metadata. `mapblock/block` delivers the block implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Carries the data needed to match blocks during procedural placement. The file owns or coordinates data contracts including `Edge`, `MapBlock`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Stores selection weighting, naming, and tileset references for later output. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `from_legacy`, `get_width`, `get_height`, `get_layer_count`, `get_layer`, and 25 more stays attached to the local data model and invariants.
//! Encodes the local shape and slot content that downstream stages consume. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! Keeps neighbor semantics alongside the block so validation stays data-driven. External integration uses `super`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
//! Acts as the atomic building piece for the entire mapblock pipeline. The file boundary separates mapblock implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

use super::config::MapBlockConfig;
use super::constraints::EdgeConstraint;
use super::layer::BlockLayer;
use std::collections::{HashMap, HashSet};

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
    /// Placement footprint cells in local grid coordinates.
    footprint: Vec<(i32, i32)>,
    /// Per-cell socket definitions `(cell_x, cell_y, edge) -> edge_type_id`.
    sockets: HashMap<(i32, i32, Edge), u32>,
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
        let segment_size = config.default_segment_size.max(1);

        Self {
            name: String::new(),
            width,
            height,
            layers,
            slot_count,
            sides: HashMap::new(),
            footprint: Self::rect_footprint_for_dims(width, height, segment_size),
            sockets: HashMap::new(),
            weight: 1.0,
            edge_only: false,
            interior_only: false,
            level_span: 1,
            segment_size,
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
            footprint: Self::rect_footprint_for_dims(width, height, segment_size),
            sockets: HashMap::new(),
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

    /// Set the random selection weight.
    pub fn set_weight(&mut self, weight: f32) {
        self.weight = weight.max(0.0);
    }

    /// Return the random selection weight.
    pub fn get_weight(&self) -> f32 {
        self.weight
    }

    /// Replace the placement footprint with custom occupied cells.
    pub fn set_footprint(&mut self, cells: &[(i32, i32)]) {
        if cells.is_empty() {
            self.footprint = vec![(0, 0)];
            return;
        }
        self.footprint = Self::normalize_cells(cells);
    }

    /// Return the placement footprint cells.
    pub fn footprint(&self) -> &[(i32, i32)] {
        &self.footprint
    }

    /// Return whether the local footprint contains a cell.
    pub fn is_footprint_cell(&self, x: i32, y: i32) -> bool {
        self.footprint.contains(&(x, y))
    }

    /// Set a per-cell socket type on one footprint edge.
    pub fn set_socket(&mut self, cell_x: i32, cell_y: i32, edge: Edge, edge_type: u32) {
        self.sockets.insert((cell_x, cell_y, edge), edge_type);
    }

    /// Return a previously registered per-cell socket type.
    pub fn get_socket(&self, cell_x: i32, cell_y: i32, edge: Edge) -> Option<u32> {
        self.sockets.get(&(cell_x, cell_y, edge)).copied()
    }

    /// Return the normalized footprint cells after transform.
    pub fn transformed_footprint(&self, rotation: u32, mirrored: bool) -> Vec<(i32, i32)> {
        let transformed: Vec<_> = self
            .footprint
            .iter()
            .map(|&(x, y)| Self::transform_point(x, y, rotation, mirrored))
            .collect();
        Self::normalize_cells(&transformed)
    }

    /// Return the transformed footprint width/height in placement cells.
    pub fn transformed_footprint_size(&self, rotation: u32, mirrored: bool) -> (u32, u32) {
        let cells = self.transformed_footprint(rotation, mirrored);
        Self::cell_bounds(&cells)
    }

    /// Return the transformed tile width/height in tiles.
    pub fn transformed_tile_size(&self, rotation: u32) -> (u32, u32) {
        if rotation % 2 == 1 {
            (self.height, self.width)
        } else {
            (self.width, self.height)
        }
    }

    /// Resolve the socket type on a transformed footprint edge.
    pub fn transformed_socket(
        &self,
        cell_x: i32,
        cell_y: i32,
        edge: Edge,
        rotation: u32,
        mirrored: bool,
    ) -> u32 {
        let sockets = self.transformed_socket_map(rotation, mirrored);
        sockets.get(&(cell_x, cell_y, edge)).copied().unwrap_or(0)
    }

    /// Return all transformed sockets in normalized footprint coordinates.
    pub fn transformed_socket_map(
        &self,
        rotation: u32,
        mirrored: bool,
    ) -> HashMap<(i32, i32, Edge), u32> {
        let transformed_cells = self.transformed_footprint(rotation, mirrored);
        let transformed_lookup: HashSet<_> = transformed_cells.iter().copied().collect();
        let raw_cells: Vec<_> = self
            .footprint
            .iter()
            .map(|&(x, y)| Self::transform_point(x, y, rotation, mirrored))
            .collect();
        let (raw_min_x, raw_min_y) = Self::min_xy(&raw_cells);
        let mut raw_map = HashMap::new();

        for (&(x, y, edge), &edge_type) in &self.sockets {
            let (tx, ty) = Self::transform_point(x, y, rotation, mirrored);
            let tedge = Self::transform_edge(edge, rotation, mirrored);
            raw_map.insert((tx, ty, tedge), edge_type);
        }

        let legacy = self.legacy_socket_map();
        for (&(x, y, edge), &edge_type) in &legacy {
            let (tx, ty) = Self::transform_point(x, y, rotation, mirrored);
            let tedge = Self::transform_edge(edge, rotation, mirrored);
            raw_map.entry((tx, ty, tedge)).or_insert(edge_type);
        }

        let mut normalized = HashMap::new();
        for ((x, y, edge), edge_type) in raw_map {
            let nx = x - raw_min_x;
            let ny = y - raw_min_y;
            if transformed_lookup.contains(&(nx, ny)) {
                normalized.insert((nx, ny, edge), edge_type);
            }
        }
        normalized
    }

    /// Return the number of placement cells across the transformed block width.
    pub fn segments_horizontal(&self) -> u32 {
        let cells = Self::normalize_cells(&self.footprint);
        Self::cell_bounds(&cells).0
    }

    /// Return the number of placement cells across the transformed block height.
    pub fn segments_vertical(&self) -> u32 {
        let cells = Self::normalize_cells(&self.footprint);
        Self::cell_bounds(&cells).1
    }

    /// Return the placement-cell bounds of the normalized footprint.
    pub fn footprint_bounds(&self) -> (u32, u32) {
        Self::cell_bounds(&self.footprint)
    }

    fn rect_footprint_for_dims(width: u32, height: u32, segment_size: u32) -> Vec<(i32, i32)> {
        let seg = segment_size.max(1);
        let cells_w = width.max(1).div_ceil(seg);
        let cells_h = height.max(1).div_ceil(seg);
        let mut cells = Vec::new();
        for y in 0..cells_h as i32 {
            for x in 0..cells_w as i32 {
                cells.push((x, y));
            }
        }
        Self::normalize_cells(&cells)
    }

    fn normalize_cells(cells: &[(i32, i32)]) -> Vec<(i32, i32)> {
        if cells.is_empty() {
            return vec![(0, 0)];
        }
        let (min_x, min_y) = Self::min_xy(cells);
        let mut normalized: Vec<_> = cells.iter().map(|&(x, y)| (x - min_x, y - min_y)).collect();
        normalized.sort_unstable();
        normalized.dedup();
        normalized
    }

    fn min_xy(cells: &[(i32, i32)]) -> (i32, i32) {
        let min_x = cells.iter().map(|c| c.0).min().unwrap_or(0);
        let min_y = cells.iter().map(|c| c.1).min().unwrap_or(0);
        (min_x, min_y)
    }

    fn cell_bounds(cells: &[(i32, i32)]) -> (u32, u32) {
        if cells.is_empty() {
            return (1, 1);
        }
        let max_x = cells.iter().map(|c| c.0).max().unwrap_or(0);
        let max_y = cells.iter().map(|c| c.1).max().unwrap_or(0);
        ((max_x + 1).max(1) as u32, (max_y + 1).max(1) as u32)
    }

    fn transform_point(x: i32, y: i32, rotation: u32, mirrored: bool) -> (i32, i32) {
        let (mut tx, mut ty) = if mirrored { (-x, y) } else { (x, y) };
        for _ in 0..(rotation % 4) {
            (tx, ty) = (ty, -tx);
        }
        (tx, ty)
    }

    fn transform_edge(edge: Edge, rotation: u32, mirrored: bool) -> Edge {
        let mut transformed = if mirrored {
            match edge {
                Edge::East => Edge::West,
                Edge::West => Edge::East,
                other => other,
            }
        } else {
            edge
        };
        for _ in 0..(rotation % 4) {
            transformed = match transformed {
                Edge::North => Edge::East,
                Edge::East => Edge::South,
                Edge::South => Edge::West,
                Edge::West => Edge::North,
            };
        }
        transformed
    }

    fn legacy_socket_map(&self) -> HashMap<(i32, i32, Edge), u32> {
        let mut sockets = HashMap::new();
        let cells = &self.footprint;
        let lookup: HashSet<_> = cells.iter().copied().collect();
        let (foot_w, foot_h) = self.footprint_bounds();

        for &(x, y) in cells {
            if !lookup.contains(&(x, y - 1)) {
                let segment = x as u32;
                if segment < foot_w {
                    if let Some(edge_type) = self.get_edge(Edge::North, segment) {
                        sockets.insert((x, y, Edge::North), edge_type);
                    }
                }
            }
            if !lookup.contains(&(x + 1, y)) {
                let segment = y as u32;
                if segment < foot_h {
                    if let Some(edge_type) = self.get_edge(Edge::East, segment) {
                        sockets.insert((x, y, Edge::East), edge_type);
                    }
                }
            }
            if !lookup.contains(&(x, y + 1)) {
                let segment = x as u32;
                if segment < foot_w {
                    if let Some(edge_type) = self.get_edge(Edge::South, segment) {
                        sockets.insert((x, y, Edge::South), edge_type);
                    }
                }
            }
            if !lookup.contains(&(x - 1, y)) {
                let segment = y as u32;
                if segment < foot_h {
                    if let Some(edge_type) = self.get_edge(Edge::West, segment) {
                        sockets.insert((x, y, Edge::West), edge_type);
                    }
                }
            }
        }

        sockets
    }
}
