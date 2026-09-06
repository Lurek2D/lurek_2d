//! This file owns limits behavior inside the tilemap subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate limits state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for limits work.

use super::error::TileMapError;

/// Shared safety limits for tilemap storage, importers, rendering helpers, and bounded tile operations.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
/// # Fields
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
    /// Maximum number of objects in one imported Tiled object layer.
    pub max_objects: usize,
    /// Maximum number of polygon points in one imported Tiled object.
    pub max_points_per_object: usize,
    /// Maximum number of polygon points across one imported Tiled map.
    pub max_total_object_points: usize,
}

impl TileMapLimits {
    /// Validate that every configured ceiling permits at least one bounded allocation.
    pub fn validate(&self) -> Result<(), TileMapError> {
        let checks = [
            ("max_layers", self.max_layers as u128),
            ("max_tiles_per_layer", self.max_tiles_per_layer as u128),
            ("max_import_bytes", self.max_import_bytes as u128),
            ("max_decoded_bytes", self.max_decoded_bytes as u128),
            ("max_chunk_cells", self.max_chunk_cells as u128),
            ("max_chunks", self.max_chunks as u128),
            (
                "max_tile_operation_cells",
                self.max_tile_operation_cells as u128,
            ),
            ("max_objects", self.max_objects as u128),
            ("max_points_per_object", self.max_points_per_object as u128),
            (
                "max_total_object_points",
                self.max_total_object_points as u128,
            ),
        ];
        for (field, value) in checks {
            if value == 0 {
                return Err(TileMapError::InvalidLimitConfiguration { field });
            }
        }
        if self.max_tiles_per_layer > usize::MAX as u64 {
            return Err(TileMapError::InvalidLimitConfiguration {
                field: "max_tiles_per_layer",
            });
        }
        if self.max_chunk_cells > usize::MAX as u64 {
            return Err(TileMapError::InvalidLimitConfiguration {
                field: "max_chunk_cells",
            });
        }
        if self.max_decoded_bytes < self.max_import_bytes {
            return Err(TileMapError::InvalidLimitConfiguration {
                field: "max_decoded_bytes",
            });
        }
        Ok(())
    }
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
            max_objects: 100_000,
            max_points_per_object: 16_384,
            max_total_object_points: 1_000_000,
        }
    }
}

/// Return the exact dense-layer cell count, rejecting overflow and configured ceilings.
pub(crate) fn checked_layer_cells(
    width: u32,
    height: u32,
    limits: &TileMapLimits,
) -> Result<usize, TileMapError> {
    limits.validate()?;
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
    limits.validate()?;
    // Chunk coordinates are represented as i32 in the sparse map.  Reject a
    // size that cannot participate in div_euclid/rem_euclid without narrowing.
    if chunk_size > i32::MAX as u32 {
        return Err(TileMapError::InvalidChunkSize { chunk_size });
    }
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

/// Return the number of chunks required by a dense map without overflowing.
pub(crate) fn checked_chunk_count(
    width: u32,
    height: u32,
    chunk_size: u32,
    limits: &TileMapLimits,
) -> Result<usize, TileMapError> {
    limits.validate()?;
    if chunk_size == 0 {
        return Err(TileMapError::InvalidChunkSize { chunk_size });
    }
    let cols = u64::from(width)
        .checked_add(u64::from(chunk_size) - 1)
        .ok_or(TileMapError::ChunkCountLimitExceeded {
            width,
            height,
            chunks: u64::MAX,
            max_chunks: limits.max_chunks,
        })?
        / u64::from(chunk_size);
    let rows = u64::from(height)
        .checked_add(u64::from(chunk_size) - 1)
        .ok_or(TileMapError::ChunkCountLimitExceeded {
            width,
            height,
            chunks: u64::MAX,
            max_chunks: limits.max_chunks,
        })?
        / u64::from(chunk_size);
    let chunks = cols
        .checked_mul(rows)
        .ok_or(TileMapError::ChunkCountLimitExceeded {
            width,
            height,
            chunks: u64::MAX,
            max_chunks: limits.max_chunks,
        })?;
    if chunks > limits.max_chunks as u64 {
        return Err(TileMapError::ChunkCountLimitExceeded {
            width,
            height,
            chunks,
            max_chunks: limits.max_chunks,
        });
    }
    usize::try_from(chunks).map_err(|_| TileMapError::ChunkCountLimitExceeded {
        width,
        height,
        chunks,
        max_chunks: limits.max_chunks,
    })
}

/// Compute a row-major index with checked arithmetic.
pub(crate) fn checked_flat_index(width: u32, x: u32, y: u32, len: usize) -> Option<usize> {
    if x >= width {
        return None;
    }
    let index = u64::from(y)
        .checked_mul(u64::from(width))?
        .checked_add(u64::from(x))?;
    let index = usize::try_from(index).ok()?;
    (index < len).then_some(index)
}
