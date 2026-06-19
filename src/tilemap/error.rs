//! Owns typed validation and safety errors shared by tilemap constructors, queries, and import helpers.
//! It keeps failure reasons explicit so safe `try_*` APIs can reject invalid dimensions, limits, and paths consistently.
//! Open this file when tilemap callers need clearer diagnostics or when a new tilemap owner joins the shared safety contract.

use std::fmt;

/// Error returned by safe tilemap constructors, queries, and bounded helpers.
#[derive(Debug, Clone, PartialEq)]
pub enum TileMapError {
    /// Tile size must be strictly positive on both axes.
    InvalidTileSize { tile_width: u32, tile_height: u32 },
    /// Chunk size must be strictly positive.
    InvalidChunkSize { chunk_size: u32 },
    /// Width × height overflowed before a layer cell count could be computed.
    LayerCellOverflow { width: u32, height: u32 },
    /// Layer cell count exceeded the configured limit.
    LayerCellLimitExceeded {
        width: u32,
        height: u32,
        cells: u64,
        max_cells: u64,
    },
    /// Adding another layer would exceed the configured layer ceiling.
    MaxLayersExceeded { requested: usize, max_layers: usize },
    /// Chunk size × chunk size overflowed before a cell count could be computed.
    ChunkCellOverflow { chunk_size: u32 },
    /// Chunk cell count exceeded the configured chunk limit.
    ChunkCellLimitExceeded {
        chunk_size: u32,
        cells: u64,
        max_cells: u64,
    },
    /// A computed image pixel count overflowed.
    ImagePixelOverflow {
        width_tiles: u32,
        height_tiles: u32,
        tile_size: u32,
    },
    /// A computed image pixel count exceeded the configured image limit.
    ImagePixelLimitExceeded { pixels: u64, max_pixels: u64 },
    /// The requested layer index is outside the current layer list.
    InvalidLayerIndex { layer: usize, layer_count: usize },
    /// The requested tile coordinate is outside the layer bounds.
    InvalidTileCoord {
        layer: usize,
        x: u32,
        y: u32,
        width: u32,
        height: u32,
    },
    /// A world-space input must be finite.
    InvalidFloat { field: &'static str, value: f64 },
    /// A world-space rectangle size must be strictly positive.
    NonPositiveRect { field: &'static str, value: f64 },
    /// A collision query would scan more tiles than allowed by the configured limit.
    CollisionQueryLimitExceeded { checks: u64, max_checks: u64 },
    /// A raw importer input exceeded the configured byte budget before parsing.
    OversizedInput {
        context: &'static str,
        bytes: usize,
        max_bytes: usize,
    },
    /// A parsed or decoded payload exceeded the configured byte budget.
    DecodedBytesLimitExceeded {
        context: &'static str,
        bytes: usize,
        max_bytes: usize,
    },
    /// A parsed tile-entry count did not match the exact size required by a strict layer.
    InvalidLength {
        context: &'static str,
        expected: usize,
        actual: usize,
    },
    /// External tilesets require an explicit policy instead of a silent stub.
    ExternalTilesetRequiresPolicy { source: String },
    /// A resource path violated the safe asset-path policy.
    UnsafeResourcePath { path: String, reason: String },
}

impl fmt::Display for TileMapError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidTileSize {
                tile_width,
                tile_height,
            } => write!(
                f,
                "tilemap tile size must be > 0 on both axes, got {}x{}",
                tile_width, tile_height
            ),
            Self::InvalidChunkSize { chunk_size } => {
                write!(f, "tilemap chunk size must be > 0, got {}", chunk_size)
            }
            Self::LayerCellOverflow { width, height } => write!(
                f,
                "tilemap layer dimensions {}x{} overflow cell count",
                width, height
            ),
            Self::LayerCellLimitExceeded {
                width,
                height,
                cells,
                max_cells,
            } => write!(
                f,
                "tilemap layer {}x{} requires {} cells, exceeding limit {}",
                width, height, cells, max_cells
            ),
            Self::MaxLayersExceeded {
                requested,
                max_layers,
            } => write!(
                f,
                "tilemap requested {} layers, exceeding limit {}",
                requested, max_layers
            ),
            Self::ChunkCellOverflow { chunk_size } => write!(
                f,
                "tilemap chunk size {} overflows chunk cell count",
                chunk_size
            ),
            Self::ChunkCellLimitExceeded {
                chunk_size,
                cells,
                max_cells,
            } => write!(
                f,
                "tilemap chunk size {} requires {} cells, exceeding limit {}",
                chunk_size, cells, max_cells
            ),
            Self::ImagePixelOverflow {
                width_tiles,
                height_tiles,
                tile_size,
            } => write!(
                f,
                "tilemap image size {}x{} tiles at tile size {} overflows pixel count",
                width_tiles, height_tiles, tile_size
            ),
            Self::ImagePixelLimitExceeded { pixels, max_pixels } => write!(
                f,
                "tilemap image requires {} pixels, exceeding limit {}",
                pixels, max_pixels
            ),
            Self::InvalidLayerIndex { layer, layer_count } => write!(
                f,
                "tilemap layer index {} is out of range for {} layer(s)",
                layer, layer_count
            ),
            Self::InvalidTileCoord {
                layer,
                x,
                y,
                width,
                height,
            } => write!(
                f,
                "tilemap coord ({}, {}) is out of bounds for layer {} sized {}x{}",
                x, y, layer, width, height
            ),
            Self::InvalidFloat { field, value } => {
                write!(f, "tilemap field '{}' must be finite, got {}", field, value)
            }
            Self::NonPositiveRect { field, value } => {
                write!(
                    f,
                    "tilemap rect field '{}' must be > 0, got {}",
                    field, value
                )
            }
            Self::CollisionQueryLimitExceeded { checks, max_checks } => write!(
                f,
                "tilemap collision query would inspect {} tiles, exceeding limit {}",
                checks, max_checks
            ),
            Self::OversizedInput {
                context,
                bytes,
                max_bytes,
            } => write!(
                f,
                "{} input uses {} bytes, exceeding limit {}",
                context, bytes, max_bytes
            ),
            Self::DecodedBytesLimitExceeded {
                context,
                bytes,
                max_bytes,
            } => write!(
                f,
                "{} decoded {} bytes, exceeding limit {}",
                context, bytes, max_bytes
            ),
            Self::InvalidLength {
                context,
                expected,
                actual,
            } => write!(
                f,
                "{} length mismatch: expected {}, got {}",
                context, expected, actual
            ),
            Self::ExternalTilesetRequiresPolicy { source } => write!(
                f,
                "external TSX '{}' requires an explicit load policy",
                source
            ),
            Self::UnsafeResourcePath { path, reason } => {
                write!(f, "unsafe tilemap resource path '{}': {}", path, reason)
            }
        }
    }
}

impl std::error::Error for TileMapError {}
