//! This file owns shared physics sizing and validation limits used by safe constructors, stepping, terrain, and shape helpers.
//! It centralizes checked arithmetic and numeric policy so physics owners share one resource and finite-value contract.
//! Open it when ceilings or validation rules change across world, body, shape, zone, or terrain code.

use super::error::PhysicsError;

/// Shared safety limits for physics geometry, terrain allocations, and bounded stepping.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct PhysicsLimits {
    /// Maximum number of bodies allowed in one world.
    pub max_bodies: usize,
    /// Maximum number of extra colliders allowed on one body.
    pub max_colliders_per_body: usize,
    /// Maximum number of joints allowed in one world.
    pub max_joints: usize,
    /// Maximum number of zones allowed in one world.
    pub max_zones: usize,
    /// Maximum number of terrain cells allowed in one grid allocation.
    pub max_terrain_cells: u64,
    /// Maximum output bytes allowed in one terrain RGBA export.
    pub max_output_bytes: u64,
    /// Maximum number of polygon vertices accepted by strict constructors.
    pub max_polygon_vertices: usize,
    /// Maximum number of chain vertices accepted by strict constructors.
    pub max_chain_vertices: usize,
    /// Minimum allowed positive physics step dt.
    pub min_step_dt: f32,
    /// Maximum allowed dt passed into one call to `World::step`.
    pub max_step_dt: f32,
    /// Minimum allowed positive terrain cell size.
    pub min_cell_size: f32,
}

impl Default for PhysicsLimits {
    fn default() -> Self {
        Self {
            max_bodies: 131_072,
            max_colliders_per_body: 128,
            max_joints: 131_072,
            max_zones: 4_096,
            max_terrain_cells: 16_777_216,
            max_output_bytes: 268_435_456,
            max_polygon_vertices: 8,
            max_chain_vertices: 4_096,
            min_step_dt: 1.0 / 20_000.0,
            max_step_dt: 0.25,
            min_cell_size: 0.000_1,
        }
    }
}

/// Reject NaN and infinite floating-point inputs.
pub(crate) fn validate_finite(field: &'static str, value: f64) -> Result<(), PhysicsError> {
    if !value.is_finite() {
        return Err(PhysicsError::InvalidFloat { field, value });
    }
    Ok(())
}

/// Reject non-positive floating-point inputs after confirming they are finite.
pub(crate) fn validate_positive(field: &'static str, value: f64) -> Result<(), PhysicsError> {
    validate_finite(field, value)?;
    if value <= 0.0 {
        return Err(PhysicsError::NonPositiveValue { field, value });
    }
    Ok(())
}

/// Reject values outside an inclusive range after confirming they are finite.
pub(crate) fn validate_range(
    field: &'static str,
    value: f64,
    min: f64,
    max: f64,
) -> Result<(), PhysicsError> {
    validate_finite(field, value)?;
    if value < min || value > max {
        return Err(PhysicsError::ValueOutOfRange {
            field,
            min,
            max,
            value,
        });
    }
    Ok(())
}

/// Return the exact terrain cell count, rejecting overflow and configured ceilings.
pub(crate) fn checked_terrain_cells(
    width: u32,
    height: u32,
    limits: &PhysicsLimits,
) -> Result<usize, PhysicsError> {
    let cells = u64::from(width)
        .checked_mul(u64::from(height))
        .ok_or(PhysicsError::TerrainCellOverflow { width, height })?;
    if cells > limits.max_terrain_cells {
        return Err(PhysicsError::TerrainCellLimitExceeded {
            width,
            height,
            cells,
            max_cells: limits.max_terrain_cells,
        });
    }
    usize::try_from(cells).map_err(|_| PhysicsError::TerrainCellLimitExceeded {
        width,
        height,
        cells,
        max_cells: limits.max_terrain_cells,
    })
}

/// Return the exact RGBA byte count for one terrain export, rejecting overflow and configured ceilings.
pub(crate) fn checked_terrain_image_bytes(
    width: u32,
    height: u32,
    limits: &PhysicsLimits,
) -> Result<usize, PhysicsError> {
    let cells = u64::from(width)
        .checked_mul(u64::from(height))
        .ok_or(PhysicsError::TerrainCellOverflow { width, height })?;
    let bytes = cells
        .checked_mul(4)
        .ok_or(PhysicsError::TerrainImageByteOverflow { width, height })?;
    if bytes > limits.max_output_bytes {
        return Err(PhysicsError::TerrainImageByteLimitExceeded {
            bytes,
            max_bytes: limits.max_output_bytes,
        });
    }
    usize::try_from(bytes).map_err(|_| PhysicsError::TerrainImageByteLimitExceeded {
        bytes,
        max_bytes: limits.max_output_bytes,
    })
}
