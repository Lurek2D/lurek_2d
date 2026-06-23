//! Owns shared validation helpers for pathfinding, tactical fields, steering, and local avoidance modules.
//! Keeps finite number, count, and positive-value checks close to the navigation owners that enforce them.
//! Update this file when movement-facing modules need common limits or structured `PathfindError` guards.

/// Shared safety limits for pathfinding-adjacent movement helpers.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct PathfindValidationLimits {
    /// Maximum number of steering behaviors on one manager.
    pub max_steering_behaviors: usize,
    /// Maximum number of named steering entities on one manager.
    pub max_steering_entities: usize,
    /// Minimum positive value accepted by strict positive checks.
    pub min_positive: f64,
}

impl Default for PathfindValidationLimits {
    fn default() -> Self {
        Self {
            max_steering_behaviors: 64,
            max_steering_entities: 4_096,
            min_positive: 0.000_1,
        }
    }
}

/// Reject NaN and infinite `f32` inputs.
pub fn finite_f32(field: &'static str, value: f32) -> Result<f32, String> {
    if !value.is_finite() {
        return Err(format!(
            "pathfind field '{field}' must be finite, got {value}"
        ));
    }
    Ok(value)
}

/// Reject counts above a configured ceiling.
pub fn validate_count(context: &'static str, count: usize, max: usize) -> Result<usize, String> {
    if count > max {
        return Err(format!(
            "{context} count {count} exceeds configured limit {max}"
        ));
    }
    Ok(count)
}
