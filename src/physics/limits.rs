//! Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around PhysicsLimits, default, validate_finite, with helpers kept close to their invariants.
//! Defines how limits data is validated, transformed, or stored before neighboring systems use it.
//! Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on limits behavior while Lua registration stays elsewhere.

use super::error::PhysicsError;

/// Shared safety limits for physics geometry, terrain allocations, and bounded stepping.
/// # Fields
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct PhysicsLimits {
    /// Maximum number of bodies allowed in one world.
    pub max_bodies: usize,
    /// Maximum lifetime body slots before the world must be cleared or reset.
    /// Stable numeric body IDs are never reused, so this bounds tombstone growth.
    pub max_body_slots: usize,
    /// Maximum number of extra colliders allowed on one body.
    pub max_colliders_per_body: usize,
    /// Maximum number of joints allowed in one world.
    pub max_joints: usize,
    /// Maximum number of zones allowed in one world.
    pub max_zones: usize,
    /// Maximum lifetime additive gravity-vector slots retained by one world.
    pub max_gravity_vectors: usize,
    /// Maximum lifetime authored flow-field slots retained by one world.
    pub max_flow_fields: usize,
    /// Maximum number of terrain cells allowed in one grid allocation.
    pub max_terrain_cells: u64,
    /// Maximum number of liquid cells allowed in one grid allocation.
    pub max_liquid_cells: u64,
    /// Maximum number of terrain cells one connected-component terrain scan may inspect.
    pub max_terrain_component_scan_cells: u64,
    /// Maximum connected components returned by one terrain component query.
    pub max_terrain_component_results: usize,
    /// Maximum cells retained across the returned terrain component vectors.
    pub max_terrain_component_cells: usize,
    /// Maximum number of non-empty liquid cells a single step call may process.
    pub max_active_liquid_cells: u64,
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
    /// Maximum fixed substeps allowed by one public pacing call.
    pub max_fixed_steps: u32,
    /// Maximum solver iterations accepted by one world.
    pub max_solver_iterations: usize,
    /// Maximum CCD substeps accepted by one world.
    pub max_ccd_substeps: usize,
    /// Maximum begin, end, or collision events retained for one public step call.
    pub max_contact_events: usize,
    /// Maximum hits returned by one all-hit spatial query or beam trace.
    pub max_query_hits: usize,
    /// Maximum reflection segments permitted for one beam trace.
    pub max_beam_bounces: usize,
    /// Maximum lifetime ballistic projectile slots retained by one world.
    pub max_ballistic_projectile_slots: usize,
    /// Maximum body shape snapshots emitted by one debug extraction.
    pub max_debug_shapes: usize,
    /// Maximum sampled points returned by one ballistic arc trace.
    pub max_ballistic_samples: usize,
    /// Minimum allowed positive terrain cell size.
    pub min_cell_size: f32,
}

impl Default for PhysicsLimits {
    fn default() -> Self {
        Self {
            max_bodies: 131_072,
            max_body_slots: 262_144,
            max_colliders_per_body: 128,
            max_joints: 131_072,
            max_zones: 4_096,
            max_gravity_vectors: 4_096,
            max_flow_fields: 4_096,
            max_terrain_cells: 16_777_216,
            max_liquid_cells: 4_194_304,
            max_terrain_component_scan_cells: 1_048_576,
            max_terrain_component_results: 65_536,
            max_terrain_component_cells: 1_048_576,
            max_active_liquid_cells: 1_048_576,
            max_output_bytes: 268_435_456,
            max_polygon_vertices: 8,
            max_chain_vertices: 4_096,
            min_step_dt: 1.0 / 20_000.0,
            max_step_dt: 0.25,
            max_fixed_steps: 256,
            max_solver_iterations: 128,
            max_ccd_substeps: 128,
            max_contact_events: 65_536,
            max_query_hits: 65_536,
            max_beam_bounces: 128,
            max_ballistic_projectile_slots: 65_536,
            max_debug_shapes: 65_536,
            max_ballistic_samples: 16_384,
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

/// Return the exact liquid cell count, rejecting overflow and configured ceilings.
pub(crate) fn checked_liquid_cells(
    width: u32,
    height: u32,
    limits: &PhysicsLimits,
) -> Result<usize, PhysicsError> {
    let cells = u64::from(width)
        .checked_mul(u64::from(height))
        .ok_or(PhysicsError::LiquidCellOverflow { width, height })?;
    if cells > limits.max_liquid_cells {
        return Err(PhysicsError::LiquidCellLimitExceeded {
            width,
            height,
            cells,
            max_cells: limits.max_liquid_cells,
        });
    }
    usize::try_from(cells).map_err(|_| PhysicsError::LiquidCellLimitExceeded {
        width,
        height,
        cells,
        max_cells: limits.max_liquid_cells,
    })
}

/// Return the exact terrain cell budget for one connected-component scan, rejecting configured ceilings.
pub(crate) fn checked_terrain_component_scan_cells(
    cells: u64,
    limits: &PhysicsLimits,
) -> Result<usize, PhysicsError> {
    if cells > limits.max_terrain_component_scan_cells {
        return Err(PhysicsError::CountLimitExceeded {
            context: "physics terrain component scan",
            count: usize::try_from(cells).unwrap_or(usize::MAX),
            max: usize::try_from(limits.max_terrain_component_scan_cells).unwrap_or(usize::MAX),
        });
    }
    usize::try_from(cells).map_err(|_| PhysicsError::CountLimitExceeded {
        context: "physics terrain component scan",
        count: usize::MAX,
        max: usize::try_from(limits.max_terrain_component_scan_cells).unwrap_or(usize::MAX),
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
