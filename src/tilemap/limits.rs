//! This file owns limits behavior inside the tilemap subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate limits state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for limits work.

use super::error::TileMapError;

/// Shared safety limits for tilemap storage, importers, rendering helpers, and bounded tile operations.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TileMapLimits {
    /// Maximum number of layers allowed on one tilemap.
    pub max_layers: usize,
    /// Maximum number of cells allowed in one dense layer.
    pub max_tiles_per_layer: u64,
    /// Maximum raw importer input size before parsing.
    pub max_import_bytes: usize,
    /// Maximum decoded importer payload size after decompression.
    pub max_decoded_bytes: usize,
    /// Maximum number of cells allowed in one chunk allocation.
    pub max_chunk_cells: u64,
    /// Maximum number of loaded chunks allowed in one chunk map.
    pub max_chunks: usize,
    /// Maximum number of cells touched by one bounded tile operation.
    pub max_tile_operation_cells: u64,
}

impl Default for TileMapLimits {
    fn default() -> Self {
        Self {
            max_layers: 256,
            max_tiles_per_layer: 16_777_216,
            max_import_bytes: 8 * 1024 * 1024,
            max_decoded_bytes: 64 * 1024 * 1024,
            max_chunk_cells: 1_048_576,
            max_chunks: 1_048_576,
            max_tile_operation_cells: 1_048_576,
        }
    }
}

/// Return the exact dense-layer cell count, rejecting overflow and configured ceilings.
pub(crate) fn checked_layer_cells(
    width: u32,
    height: u32,
    limits: &TileMapLimits,
) -> Result<usize, TileMapError> {
    let cells = u64::from(width)
        .checked_mul(u64::from(height))
        .ok_or(TileMapError::LayerCellOverflow { width, height })?;
    if cells > limits.max_tiles_per_layer {
        return Err(TileMapError::LayerCellLimitExceeded {
            width,
            height,
            cells,
            max_cells: limits.max_tiles_per_layer,
        });
    }
    usize::try_from(cells).map_err(|_| TileMapError::LayerCellLimitExceeded {
        width,
        height,
        cells,
        max_cells: limits.max_tiles_per_layer,
    })
}

/// Return the exact chunk cell count, rejecting overflow and configured ceilings.
pub(crate) fn checked_chunk_cells(
    chunk_size: u32,
    limits: &TileMapLimits,
) -> Result<usize, TileMapError> {
    let cells = u64::from(chunk_size)
        .checked_mul(u64::from(chunk_size))
        .ok_or(TileMapError::ChunkCellOverflow { chunk_size })?;
    if cells > limits.max_chunk_cells {
        return Err(TileMapError::ChunkCellLimitExceeded {
            chunk_size,
            cells,
            max_cells: limits.max_chunk_cells,
        });
    }
    usize::try_from(cells).map_err(|_| TileMapError::ChunkCellLimitExceeded {
        chunk_size,
        cells,
        max_cells: limits.max_chunk_cells,
    })
}
