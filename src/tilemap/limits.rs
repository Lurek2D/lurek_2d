//! Owns shared tilemap sizing and validation limits used by safe constructors, importers, and bounded queries.
//! It centralizes checked arithmetic and default safety ceilings so tilemap owners share one resource policy.
//! Open this file when tilemap budgets or query guards change across storage, rendering, and importer code.

use super::error::TileMapError;

/// Shared safety limits for tilemap storage, importers, rendering helpers, and collision queries.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TileMapLimits {
    /// Maximum number of layers allowed on one tilemap.
    pub max_layers: usize,
    /// Maximum number of cells allowed in one dense layer.
    pub max_tiles_per_layer: u64,
    /// Maximum number of pixels allowed in one debug image export.
    pub max_image_pixels: u64,
    /// Maximum raw importer input size before parsing.
    pub max_import_bytes: usize,
    /// Maximum decoded importer payload size after decompression.
    pub max_decoded_bytes: usize,
    /// Maximum number of cells allowed in one chunk allocation.
    pub max_chunk_cells: u64,
    /// Maximum number of loaded chunks allowed in one chunk map.
    pub max_chunks: usize,
    /// Maximum number of tile checks allowed in one collision query.
    pub max_collision_tile_checks: u64,
}

impl Default for TileMapLimits {
    fn default() -> Self {
        Self {
            max_layers: 256,
            max_tiles_per_layer: 16_777_216,
            max_image_pixels: 67_108_864,
            max_import_bytes: 8 * 1024 * 1024,
            max_decoded_bytes: 64 * 1024 * 1024,
            max_chunk_cells: 1_048_576,
            max_chunks: 1_048_576,
            max_collision_tile_checks: 1_048_576,
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

/// Return the exact debug-image pixel count, rejecting overflow and configured ceilings.
pub(crate) fn checked_image_pixels(
    width_tiles: u32,
    height_tiles: u32,
    tile_size: u32,
    limits: &TileMapLimits,
) -> Result<(u32, u32), TileMapError> {
    let width_px = u64::from(width_tiles)
        .checked_mul(u64::from(tile_size))
        .ok_or(TileMapError::ImagePixelOverflow {
            width_tiles,
            height_tiles,
            tile_size,
        })?;
    let height_px = u64::from(height_tiles)
        .checked_mul(u64::from(tile_size))
        .ok_or(TileMapError::ImagePixelOverflow {
            width_tiles,
            height_tiles,
            tile_size,
        })?;
    let pixels = width_px
        .checked_mul(height_px)
        .ok_or(TileMapError::ImagePixelOverflow {
            width_tiles,
            height_tiles,
            tile_size,
        })?;
    if pixels > limits.max_image_pixels {
        return Err(TileMapError::ImagePixelLimitExceeded {
            pixels,
            max_pixels: limits.max_image_pixels,
        });
    }
    let width_px = u32::try_from(width_px).map_err(|_| TileMapError::ImagePixelOverflow {
        width_tiles,
        height_tiles,
        tile_size,
    })?;
    let height_px = u32::try_from(height_px).map_err(|_| TileMapError::ImagePixelOverflow {
        width_tiles,
        height_tiles,
        tile_size,
    })?;
    Ok((width_px, height_px))
}

/// Reject NaN and infinite floating-point values.
pub(crate) fn validate_finite(field: &'static str, value: f64) -> Result<(), TileMapError> {
    if !value.is_finite() {
        return Err(TileMapError::InvalidFloat { field, value });
    }
    Ok(())
}

/// Reject non-positive rectangle dimensions after confirming the value is finite.
pub(crate) fn validate_positive_rect(field: &'static str, value: f64) -> Result<(), TileMapError> {
    validate_finite(field, value)?;
    if value <= 0.0 {
        return Err(TileMapError::NonPositiveRect { field, value });
    }
    Ok(())
}
