//! This file owns error behavior inside the tilemap subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate error state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for error work.
//! Serialization, indexing, and boundary checks stay here when they depend on error internals.

use std::fmt;

/// Error returned by safe tilemap constructors, queries, and bounded helpers.
#[derive(Debug, Clone, PartialEq)]
/// # Variants
pub enum TileMapError {
    /// A configured safety limit is zero or cannot be represented by addressable storage.
    InvalidLimitConfiguration { field: &'static str },
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
    /// A chunk allocation would exceed the configured loaded-chunk ceiling.
    MaxChunksExceeded { requested: usize, max_chunks: usize },
    /// A dense map would require more chunks than the configured renderer ceiling.
    ChunkCountLimitExceeded {
        width: u32,
        height: u32,
        chunks: u64,
        max_chunks: usize,
    },
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
    /// A bounded tile operation would touch more cells than allowed by the configured limit.
    TileOperationLimitExceeded { cells: u64, max_cells: u64 },
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
    /// A numeric input crossing a public boundary was not finite.
    NonFiniteFloat { context: &'static str },
    /// A numeric input that is used as a divisor or extent was not positive.
    NonPositiveFloat { context: &'static str, value: f32 },
    /// A list of LOD thresholds was empty, non-finite, or not strictly increasing.
    InvalidLodThresholds,
}

impl fmt::Display for TileMapError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidLimitConfiguration { field } => write!(
                f,
                "tilemap limit '{field}' must be non-zero and addressable",
            ),
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
            Self::MaxChunksExceeded {
                requested,
                max_chunks,
            } => write!(
                f,
                "tilemap requested {} loaded chunks, exceeding limit {}",
                requested, max_chunks
            ),
            Self::ChunkCountLimitExceeded {
                width,
                height,
                chunks,
                max_chunks,
            } => write!(
                f,
                "tilemap {}x{} requires {} chunks, exceeding limit {}",
                width, height, chunks, max_chunks
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
            Self::TileOperationLimitExceeded { cells, max_cells } => write!(
                f,
                "tilemap operation would touch {} cells, exceeding limit {}",
                cells, max_cells
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
            Self::NonFiniteFloat { context } => {
                write!(f, "tilemap {context} must be finite")
            }
            Self::NonPositiveFloat { context, value } => {
                write!(f, "tilemap {context} must be > 0, got {value}")
            }
            Self::InvalidLodThresholds => write!(
                f,
                "tilemap LOD thresholds must be finite, positive, and strictly increasing"
            ),
        }
    }
}

impl std::error::Error for TileMapError {}
