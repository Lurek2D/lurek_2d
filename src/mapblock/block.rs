//! This file owns the atomic mapblock model, combining tile layers, edge sockets, footprint cells, and author metadata.
//! `MapBlock` stores dimensions, layers, slot count, side rules, custom sockets, weight flags, and vertical span data.
//! `Edge` also lives here because block-local side identity is part of geometry and compatibility ownership.
//! Legacy construction remains here so old raw layer data can be upgraded into the modern layered block structure.
//! Tile setters and getters stay here because `MapBlock` is the first owner above `BlockLayer` for authored content.
//! Footprint normalization and transformed socket maps belong here because rotation and mirroring start at block scope.
//! Segment counts, transformed sizes, and legacy socket derivation stay local because they describe one block's geometry.
//! Open it when block semantics change; candidate search, scripts, and result export build directly on this owner.

use super::config::MapBlockConfig;
use super::constraints::EdgeConstraint;
use super::layer::BlockLayer;
use std::collections::{HashMap, HashSet};
use std::error::Error;
use std::fmt;

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

/// Hard ceilings that prevent pathological mapblock allocations and malformed geometry payloads.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct MapBlockLimits {
    /// Maximum tile width accepted for one block.
    pub max_block_width: u32,
    /// Maximum tile height accepted for one block.
    pub max_block_height: u32,
    /// Maximum tile cells accepted for one block layer.
    pub max_cells_per_block: usize,
    /// Maximum layer count accepted for one block.
    pub max_layers: u32,
    /// Maximum slot count accepted per tile.
    pub max_slots_per_tile: usize,
    /// Maximum number of cells accepted in a normalized footprint.
    pub max_footprint_cells: usize,
}

impl Default for MapBlockLimits {
    fn default() -> Self {
        Self {
            max_block_width: 8_192,
            max_block_height: 8_192,
            max_cells_per_block: 4_194_304,
            max_layers: 64,
            max_slots_per_tile: 512,
            max_footprint_cells: 4_194_304,
        }
    }
}

impl MapBlockLimits {
    /// Validate one layer shape and return the checked cell count.
    pub fn validate_layer(
        &self,
        width: u32,
        height: u32,
        slot_count: usize,
    ) -> Result<usize, MapBlockError> {
        if width == 0 {
            return Err(MapBlockError::ZeroWidth);
        }
        if height == 0 {
            return Err(MapBlockError::ZeroHeight);
        }
        if width > self.max_block_width || height > self.max_block_height {
            return Err(MapBlockError::DimensionsTooLarge {
                width,
                height,
                max_width: self.max_block_width,
                max_height: self.max_block_height,
            });
        }
        if slot_count == 0 {
            return Err(MapBlockError::ZeroSlots);
        }
        if slot_count > self.max_slots_per_tile {
            return Err(MapBlockError::TooManySlots {
                slots: slot_count,
                max_slots: self.max_slots_per_tile,
            });
        }

        let count = width
            .checked_mul(height)
            .ok_or(MapBlockError::CellCountOverflow { width, height })?
            as usize;
        if count > self.max_cells_per_block {
            return Err(MapBlockError::TooManyCells {
                cells: count,
                max_cells: self.max_cells_per_block,
            });
        }
        Ok(count)
    }
}

/// Validation and construction failures for mapblock authored content.
#[derive(Debug, Clone, PartialEq)]
pub enum MapBlockError {
    /// Block width cannot be zero.
    ZeroWidth,
    /// Block height cannot be zero.
    ZeroHeight,
    /// Block layer count cannot be zero.
    ZeroLayerCount,
    /// Width/height exceed configured safety ceilings.
    DimensionsTooLarge {
        width: u32,
        height: u32,
        max_width: u32,
        max_height: u32,
    },
    /// `width * height` overflowed while computing the layer allocation size.
    CellCountOverflow { width: u32, height: u32 },
    /// The checked cell count exceeded the allowed ceiling.
    TooManyCells { cells: usize, max_cells: usize },
    /// Layer count exceeded the accepted limit.
    TooManyLayers { layers: u32, max_layers: u32 },
    /// Tile slot count cannot be zero.
    ZeroSlots,
    /// Slot count exceeded the accepted limit.
    TooManySlots { slots: usize, max_slots: usize },
    /// A layer index was outside the authored layer array.
    LayerIndexOutOfBounds { layer: usize, layer_count: usize },
    /// Tile coordinates were outside the block bounds.
    TileCoordinatesOutOfBounds {
        x: u32,
        y: u32,
        width: u32,
        height: u32,
    },
    /// Slot index was outside the configured slot count.
    SlotIndexOutOfBounds { slot: usize, slot_count: usize },
    /// Legacy import supplied a malformed tile layer payload.
    MalformedLegacyTileLayer {
        layer_index: usize,
        expected: usize,
        actual: usize,
    },
    /// Weight must be finite and non-negative.
    InvalidWeight { weight: f32 },
    /// Footprints must contain at least one occupied cell.
    EmptyFootprint,
    /// Footprints exceeded the accepted safety ceiling.
    TooManyFootprintCells { cells: usize, max_cells: usize },
    /// Socket coordinates must refer to normalized footprint cells.
    SocketOutsideFootprint { x: i32, y: i32, edge: Edge },
    /// Edge segment indices must stay within the transformed footprint span.
    EdgeSegmentOutOfRange {
        edge: Edge,
        segment: u32,
        max_segments: u32,
    },
    /// Vertical span must be at least one level.
    ZeroLevelSpan,
}

impl fmt::Display for MapBlockError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::ZeroWidth => write!(f, "mapblock width must be greater than zero"),
            Self::ZeroHeight => write!(f, "mapblock height must be greater than zero"),
            Self::ZeroLayerCount => write!(f, "mapblock layer count must be greater than zero"),
            Self::DimensionsTooLarge {
                width,
                height,
                max_width,
                max_height,
            } => write!(
                f,
                "mapblock dimensions {width}x{height} exceed the limit {max_width}x{max_height}"
            ),
            Self::CellCountOverflow { width, height } => {
                write!(f, "mapblock cell count overflow for {width}x{height}")
            }
            Self::TooManyCells { cells, max_cells } => {
                write!(
                    f,
                    "mapblock cell count {cells} exceeds the limit {max_cells}"
                )
            }
            Self::TooManyLayers { layers, max_layers } => {
                write!(
                    f,
                    "mapblock layer count {layers} exceeds the limit {max_layers}"
                )
            }
            Self::ZeroSlots => write!(f, "mapblock slot count must be greater than zero"),
            Self::TooManySlots { slots, max_slots } => {
                write!(
                    f,
                    "mapblock slot count {slots} exceeds the limit {max_slots}"
                )
            }
            Self::LayerIndexOutOfBounds { layer, layer_count } => write!(
                f,
                "mapblock layer index {layer} is outside the available layer count {layer_count}"
            ),
            Self::TileCoordinatesOutOfBounds {
                x,
                y,
                width,
                height,
            } => write!(
                f,
                "mapblock tile coordinates ({x}, {y}) are outside the block bounds {width}x{height}"
            ),
            Self::SlotIndexOutOfBounds { slot, slot_count } => write!(
                f,
                "mapblock slot index {slot} is outside the slot count {slot_count}"
            ),
            Self::MalformedLegacyTileLayer {
                layer_index,
                expected,
                actual,
            } => write!(
                f,
                "legacy tile layer {layer_index} has {actual} entries but expected {expected}"
            ),
            Self::InvalidWeight { weight } => {
                write!(
                    f,
                    "mapblock weight must be finite and non-negative, got {weight}"
                )
            }
            Self::EmptyFootprint => write!(f, "mapblock footprint must contain at least one cell"),
            Self::TooManyFootprintCells { cells, max_cells } => write!(
                f,
                "mapblock footprint cell count {cells} exceeds the limit {max_cells}"
            ),
            Self::SocketOutsideFootprint { x, y, edge } => write!(
                f,
                "socket {:?} at ({x}, {y}) is outside the normalized footprint",
                edge
            ),
            Self::EdgeSegmentOutOfRange {
                edge,
                segment,
                max_segments,
            } => write!(
                f,
                "edge {:?} segment {} is outside the valid range 0..{}",
                edge, segment, max_segments
            ),
            Self::ZeroLevelSpan => write!(f, "mapblock level span must be at least one"),
        }
    }
}

impl Error for MapBlockError {}

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
        Self::try_new(width, height, layer_count, config)
            .expect("MapBlock::new received invalid dimensions or configuration")
    }

    /// Create a new map block after validating dimensions and checked layer allocation math.
    pub fn try_new(
        width: u32,
        height: u32,
        layer_count: u32,
        config: &MapBlockConfig,
    ) -> Result<Self, MapBlockError> {
        if layer_count == 0 {
            return Err(MapBlockError::ZeroLayerCount);
        }
        let limits = MapBlockLimits::default();
        let slot_count = config.slot_count();
        if layer_count > config.max_layers {
            return Err(MapBlockError::TooManyLayers {
                layers: layer_count,
                max_layers: config.max_layers,
            });
        }
        if layer_count > limits.max_layers {
            return Err(MapBlockError::TooManyLayers {
                layers: layer_count,
                max_layers: limits.max_layers,
            });
        }
        limits.validate_layer(width, height, slot_count)?;
        let layers = (0..layer_count)
            .map(|_| BlockLayer::try_new(width, height, slot_count))
            .collect::<Result<Vec<_>, _>>()?;
        let segment_size = config.default_segment_size.max(1);

        let block = Self {
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
        };
        block.validate()?;
        Ok(block)
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
        Self::try_from_legacy(width, height, segment_size, tile_data, sides, name, weight)
            .expect("legacy mapblock input failed validation")
    }

    /// Create a block from legacy mapgen data after validating dimensions and layer payload sizes.
    pub fn try_from_legacy(
        width: u32,
        height: u32,
        segment_size: u32,
        tile_data: &[Vec<u32>],
        sides: &HashMap<(Edge, u32), u32>,
        name: &str,
        weight: f32,
    ) -> Result<Self, MapBlockError> {
        let limits = MapBlockLimits::default();
        let slot_count = 1; // Legacy uses single slot (floor only)
        let expected_cells = limits.validate_layer(width, height, slot_count)?;
        let mut layers = Vec::new();

        for (layer_index, layer_data) in tile_data.iter().enumerate() {
            if layer_data.len() != expected_cells {
                return Err(MapBlockError::MalformedLegacyTileLayer {
                    layer_index,
                    expected: expected_cells,
                    actual: layer_data.len(),
                });
            }
            let mut layer = BlockLayer::try_new(width, height, slot_count)?;
            for y in 0..height {
                for x in 0..width {
                    let idx = (y * width + x) as usize;
                    if layer_data[idx] != 0 {
                        layer.set_tile_slot(x, y, 0, 1, layer_data[idx]);
                    }
                }
            }
            layers.push(layer);
        }

        if layers.is_empty() {
            layers.push(BlockLayer::try_new(width, height, slot_count)?);
        }

        let block = Self {
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
        };
        block.validate_weight(weight)?;
        block.validate()?;
        Ok(block)
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
        self.try_add_layer(max_layers).is_ok()
    }

    /// Add a new empty layer after validating the configured layer ceiling.
    pub fn try_add_layer(&mut self, max_layers: u32) -> Result<(), MapBlockError> {
        let allowed_layers = max_layers.min(MapBlockLimits::default().max_layers);
        if self.layers.len() as u32 >= allowed_layers {
            return Err(MapBlockError::TooManyLayers {
                layers: self.layers.len() as u32 + 1,
                max_layers: allowed_layers,
            });
        }
        self.layers
            .push(BlockLayer::new(self.width, self.height, self.slot_count));
        Ok(())
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
        let _ = self.try_set_tile(layer, x, y, slot_index, tileset_id, gid);
    }

    /// Set a tile slot value after validating the addressed layer, tile, and slot.
    pub fn try_set_tile(
        &mut self,
        layer: usize,
        x: u32,
        y: u32,
        slot_index: usize,
        tileset_id: u32,
        gid: u32,
    ) -> Result<(), MapBlockError> {
        let layer_count = self.layers.len();
        let Some(l) = self.layers.get_mut(layer) else {
            return Err(MapBlockError::LayerIndexOutOfBounds { layer, layer_count });
        };
        if x >= self.width || y >= self.height {
            return Err(MapBlockError::TileCoordinatesOutOfBounds {
                x,
                y,
                width: self.width,
                height: self.height,
            });
        }
        if slot_index >= self.slot_count {
            return Err(MapBlockError::SlotIndexOutOfBounds {
                slot: slot_index,
                slot_count: self.slot_count,
            });
        }
        l.set_tile_slot(x, y, slot_index, tileset_id, gid);
        Ok(())
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
        let _ = self.try_set_edge(edge, segment, edge_type);
    }

    /// Set edge type for a given side and segment index after validating the segment span.
    pub fn try_set_edge(
        &mut self,
        edge: Edge,
        segment: u32,
        edge_type: u32,
    ) -> Result<(), MapBlockError> {
        self.validate_edge_segment(edge, segment)?;
        self.sides.insert((edge, segment), edge_type);
        Ok(())
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
        self.weight = if weight.is_finite() {
            weight.max(0.0)
        } else {
            0.0
        };
    }

    /// Set the random selection weight after validating finiteness and sign.
    pub fn set_weight_checked(&mut self, weight: f32) -> Result<(), MapBlockError> {
        self.validate_weight(weight)?;
        self.weight = weight;
        Ok(())
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

    /// Validate block geometry, sockets, and weight without mutating state.
    pub fn validate(&self) -> Result<(), MapBlockError> {
        let limits = MapBlockLimits::default();
        limits.validate_layer(self.width, self.height, self.slot_count)?;
        if self.layers.is_empty() {
            return Err(MapBlockError::ZeroLayerCount);
        }
        if self.layers.len() as u32 > limits.max_layers {
            return Err(MapBlockError::TooManyLayers {
                layers: self.layers.len() as u32,
                max_layers: limits.max_layers,
            });
        }
        self.validate_weight(self.weight)?;
        if self.level_span == 0 {
            return Err(MapBlockError::ZeroLevelSpan);
        }
        if self.footprint.is_empty() {
            return Err(MapBlockError::EmptyFootprint);
        }

        let normalized = Self::normalize_cells(&self.footprint);
        if normalized.len() > limits.max_footprint_cells {
            return Err(MapBlockError::TooManyFootprintCells {
                cells: normalized.len(),
                max_cells: limits.max_footprint_cells,
            });
        }

        let footprint_lookup: HashSet<_> = normalized.iter().copied().collect();
        for &(edge, segment) in self.sides.keys() {
            self.validate_edge_segment(edge, segment)?;
        }
        for &(x, y, edge) in self.sockets.keys() {
            if !footprint_lookup.contains(&(x, y)) {
                return Err(MapBlockError::SocketOutsideFootprint { x, y, edge });
            }
        }
        Ok(())
    }

    fn validate_edge_segment(&self, edge: Edge, segment: u32) -> Result<(), MapBlockError> {
        let max_segments = self.edge_segment_count(edge);
        if segment >= max_segments {
            return Err(MapBlockError::EdgeSegmentOutOfRange {
                edge,
                segment,
                max_segments,
            });
        }
        Ok(())
    }

    fn edge_segment_count(&self, edge: Edge) -> u32 {
        let (width, height) = self.footprint_bounds();
        match edge {
            Edge::North | Edge::South => width.max(1),
            Edge::East | Edge::West => height.max(1),
        }
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

    fn validate_weight(&self, weight: f32) -> Result<(), MapBlockError> {
        if !weight.is_finite() || weight < 0.0 {
            return Err(MapBlockError::InvalidWeight { weight });
        }
        Ok(())
    }
}
