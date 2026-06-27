//! Owns learning behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around LearningLimits, default, validate_finite, with helpers kept close to their invariants.
//! Defines how limits data is validated, transformed, or stored before neighboring systems use it.
//! Owns learning behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on limits behavior while Lua registration stays elsewhere.

use super::error::LearningError;

/// Shared safety limits for learning tensors and model allocations.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct LearningLimits {
    /// Maximum elements allowed in a tensor or tensor-shaped output allocation.
    pub max_tensor_elements: usize,
    /// Maximum cells allowed in one Q-table allocation.
    pub max_qtable_cells: usize,
    /// Maximum dense layers allowed in one neural network.
    pub max_layers: usize,
    /// Maximum flattened parameters allowed in one layer or network.
    pub max_params: usize,
    /// Maximum chromosomes allowed in one genetic population.
    pub max_population: usize,
    /// Maximum genes allowed in one chromosome.
    pub max_genome_length: usize,
}

impl Default for LearningLimits {
    fn default() -> Self {
        Self {
            max_tensor_elements: 16_777_216,
            max_qtable_cells: 16_777_216,
            max_layers: 1_024,
            max_params: 16_777_216,
            max_population: 65_536,
            max_genome_length: 4_194_304,
        }
    }
}

/// Reject NaN and infinite floating-point inputs.
pub(crate) fn validate_finite(field: &'static str, value: f64) -> Result<(), LearningError> {
    if !value.is_finite() {
        return Err(LearningError::InvalidFloat { field, value });
    }
    Ok(())
}

/// Reject values outside an inclusive range after confirming they are finite.
pub(crate) fn validate_range(
    field: &'static str,
    value: f64,
    min: f64,
    max: f64,
) -> Result<(), LearningError> {
    validate_finite(field, value)?;
    if value < min || value > max {
        return Err(LearningError::ValueOutOfRange {
            field,
            min,
            max,
            value,
        });
    }
    Ok(())
}

/// Reject zero-valued counts for constructors that require at least one item.
pub(crate) fn validate_non_zero_count(
    field: &'static str,
    value: usize,
) -> Result<(), LearningError> {
    if value == 0 {
        return Err(LearningError::ZeroCount { field });
    }
    Ok(())
}

/// Reject counts that exceed a configured ceiling.
pub(crate) fn enforce_limit(
    context: &'static str,
    count: usize,
    max: usize,
) -> Result<(), LearningError> {
    if count > max {
        return Err(LearningError::CountLimitExceeded {
            context,
            count,
            max,
        });
    }
    Ok(())
}

/// Return `lhs * rhs`, rejecting overflow and configured ceilings.
pub(crate) fn checked_product2(
    lhs: usize,
    rhs: usize,
    context: &'static str,
    max: usize,
) -> Result<usize, LearningError> {
    let count = lhs
        .checked_mul(rhs)
        .ok_or(LearningError::CountOverflow { context })?;
    enforce_limit(context, count, max)?;
    Ok(count)
}

/// Return the exact element count for a tensor shape, rejecting zero axes, overflow, and configured ceilings.
pub(crate) fn checked_tensor_elements(
    shape: &[usize],
    context: &'static str,
    limits: &LearningLimits,
) -> Result<usize, LearningError> {
    if shape.is_empty() {
        return Ok(1);
    }
    let mut count = 1usize;
    for (axis, &dim) in shape.iter().enumerate() {
        if dim == 0 {
            return Err(LearningError::ZeroDimension { context, axis });
        }
        count = count
            .checked_mul(dim)
            .ok_or(LearningError::CountOverflow { context })?;
        enforce_limit(context, count, limits.max_tensor_elements)?;
    }
    Ok(count)
}
