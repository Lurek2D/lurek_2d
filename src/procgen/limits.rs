//! Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps procgen data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how limits data is validated, transformed, or stored before neighboring systems use it.
//! Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on limits behavior while Lua registration stays elsewhere.

use super::error::ProcgenError;

/// Shared safety limits for procgen generators that allocate grids or run bounded iterations.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ProcgenLimits {
    /// Maximum number of grid cells allowed in one generated output.
    pub max_cells: u64,
    /// Maximum number of output bytes allowed in one exported buffer.
    pub max_output_bytes: u64,
    /// Maximum number of iterations allowed for bounded simulation or erosion loops.
    pub max_iterations: u32,
    /// Maximum number of WFC retry attempts allowed in a safe generation call.
    pub max_wfc_attempts: u32,
    /// Maximum number of fractal octaves allowed in safe noise or heightmap calls.
    pub max_octaves: u32,
    /// Maximum raw byte size accepted by strict procgen parsers such as `wfc_llm`.
    pub max_parser_input_bytes: usize,
    /// Maximum number of WFC tiles accepted from strict parsed input.
    pub max_wfc_tiles: usize,
    /// Maximum number of adjacency references accepted from strict parsed input.
    pub max_wfc_adjacency_refs: usize,
}

impl Default for ProcgenLimits {
    fn default() -> Self {
        Self {
            max_cells: 16_777_216,
            max_output_bytes: 268_435_456,
            max_iterations: 10_000,
            max_wfc_attempts: 1_024,
            max_octaves: 64,
            max_parser_input_bytes: 262_144,
            max_wfc_tiles: 1_024,
            max_wfc_adjacency_refs: 16_384,
        }
    }
}

/// Reject zero-sized grids for APIs that require a non-empty grid invariant.
pub(crate) fn validate_non_zero_dimensions(width: u32, height: u32) -> Result<(), ProcgenError> {
    if width == 0 || height == 0 {
        return Err(ProcgenError::InvalidDimensions { width, height });
    }
    Ok(())
}

/// Return the exact cell count for `width × height`, rejecting overflow and configured limits.
pub(crate) fn checked_cell_count(
    width: u32,
    height: u32,
    limits: &ProcgenLimits,
) -> Result<usize, ProcgenError> {
    let cells = u64::from(width)
        .checked_mul(u64::from(height))
        .ok_or(ProcgenError::CellCountOverflow { width, height })?;
    if cells > limits.max_cells {
        return Err(ProcgenError::CellCountLimitExceeded {
            width,
            height,
            cells,
            max_cells: limits.max_cells,
        });
    }
    usize::try_from(cells).map_err(|_| ProcgenError::CellCountLimitExceeded {
        width,
        height,
        cells,
        max_cells: limits.max_cells,
    })
}

/// Return the exact output byte length for `width × height × bytes_per_cell`, rejecting overflow and configured limits.
pub(crate) fn checked_output_bytes(
    width: u32,
    height: u32,
    bytes_per_cell: u64,
    context: &'static str,
    limits: &ProcgenLimits,
) -> Result<usize, ProcgenError> {
    let cells = u64::from(width)
        .checked_mul(u64::from(height))
        .ok_or(ProcgenError::CellCountOverflow { width, height })?;
    let bytes = cells
        .checked_mul(bytes_per_cell)
        .ok_or(ProcgenError::ByteCountOverflow {
            width,
            height,
            bytes_per_cell,
            context,
        })?;
    if bytes > limits.max_output_bytes {
        return Err(ProcgenError::ByteCountLimitExceeded {
            context,
            bytes,
            max_bytes: limits.max_output_bytes,
        });
    }
    usize::try_from(bytes).map_err(|_| ProcgenError::ByteCountLimitExceeded {
        context,
        bytes,
        max_bytes: limits.max_output_bytes,
    })
}

/// Reject NaN and infinite floating-point inputs.
pub(crate) fn validate_finite(field: &'static str, value: f64) -> Result<(), ProcgenError> {
    if !value.is_finite() {
        return Err(ProcgenError::InvalidFloat { field, value });
    }
    Ok(())
}

/// Reject non-positive, NaN, and infinite floating-point inputs.
pub(crate) fn validate_positive(field: &'static str, value: f64) -> Result<(), ProcgenError> {
    validate_finite(field, value)?;
    if value <= 0.0 {
        return Err(ProcgenError::NonPositiveValue { field, value });
    }
    Ok(())
}

/// Reject values outside an inclusive range after confirming they are finite.
pub(crate) fn validate_range(
    field: &'static str,
    value: f64,
    min: f64,
    max: f64,
) -> Result<(), ProcgenError> {
    validate_finite(field, value)?;
    if value < min || value > max {
        return Err(ProcgenError::ValueOutOfRange {
            field,
            min,
            max,
            value,
        });
    }
    Ok(())
}

/// Reject octave counts above the configured procgen ceiling.
pub(crate) fn validate_octaves(octaves: u32, limits: &ProcgenLimits) -> Result<(), ProcgenError> {
    if octaves == 0 || octaves > limits.max_octaves {
        return Err(ProcgenError::MaxOctavesExceeded {
            requested: octaves,
            max: limits.max_octaves,
        });
    }
    Ok(())
}

/// Reject iteration counts above the configured procgen ceiling.
pub(crate) fn validate_iterations(
    iterations: u32,
    limits: &ProcgenLimits,
) -> Result<(), ProcgenError> {
    if iterations > limits.max_iterations {
        return Err(ProcgenError::MaxIterationsExceeded {
            requested: iterations,
            max: limits.max_iterations,
        });
    }
    Ok(())
}

/// Reject WFC retry budgets above the configured procgen ceiling.
pub(crate) fn validate_wfc_attempts(
    attempts: u32,
    limits: &ProcgenLimits,
) -> Result<(), ProcgenError> {
    if attempts > limits.max_wfc_attempts {
        return Err(ProcgenError::MaxAttemptsExceeded {
            requested: attempts,
            max: limits.max_wfc_attempts,
        });
    }
    Ok(())
}

/// Reject counts above the configured ceiling for parser or collection inputs.
pub(crate) fn validate_count(
    context: &'static str,
    count: usize,
    max: usize,
) -> Result<(), ProcgenError> {
    if count > max {
        return Err(ProcgenError::CountLimitExceeded {
            context,
            count,
            max,
        });
    }
    Ok(())
}
