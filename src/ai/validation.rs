//! Owns shared AI sizing, traversal, and numeric validation limits used by planners, steering, trees, and scoring helpers.
//! It centralizes checked counts and finite-value policy so AI owners share one narrow validation contract.
//! Open it when AI ceilings or numeric hardening rules change across the subsystem.

use super::error::AiError;

/// Shared safety limits for AI registries, planners, steering, trees, and callback-heavy evaluators.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct AiValidationLimits {
    /// Maximum number of agents allowed in one AI world.
    pub max_agents: usize,
    /// Maximum number of behavior-tree nodes accepted by strict helpers.
    pub max_bt_nodes: usize,
    /// Maximum behavior-tree depth accepted by strict helpers.
    pub max_bt_depth: usize,
    /// Maximum number of GOAP actions in one planner.
    pub max_goap_actions: usize,
    /// Maximum number of GOAP goals in one planner.
    pub max_goap_goals: usize,
    /// Maximum action depth allowed during one GOAP search.
    pub max_goap_depth: usize,
    /// Maximum planning iterations allowed during one GOAP search.
    pub max_goap_iterations: usize,
    /// Maximum expanded GOAP nodes allowed during one search.
    pub max_goap_nodes: usize,
    /// Maximum number of utility actions in one evaluator.
    pub max_utility_actions: usize,
    /// Maximum number of considerations allowed on one utility action.
    pub max_utility_considerations: usize,
    /// Maximum number of steering behaviors on one manager.
    pub max_steering_behaviors: usize,
    /// Maximum number of named steering entities on one manager.
    pub max_steering_entities: usize,
    /// Maximum number of MCTS iterations allowed in one search.
    pub max_mcts_iterations: u32,
    /// Maximum number of MCTS nodes allowed in one search tree.
    pub max_mcts_nodes: usize,
    /// Maximum rollout depth allowed in one MCTS search.
    pub max_mcts_rollout_depth: usize,
    /// Minimum positive value accepted by strict positive checks.
    pub min_positive: f64,
    /// Maximum callback invocations allowed in one evaluator pulse.
    pub max_callbacks_per_frame: usize,
}

impl Default for AiValidationLimits {
    fn default() -> Self {
        Self {
            max_agents: 65_536,
            max_bt_nodes: 4_096,
            max_bt_depth: 128,
            max_goap_actions: 256,
            max_goap_goals: 128,
            max_goap_depth: 64,
            max_goap_iterations: 10_000,
            max_goap_nodes: 20_000,
            max_utility_actions: 128,
            max_utility_considerations: 64,
            max_steering_behaviors: 64,
            max_steering_entities: 4_096,
            max_mcts_iterations: 10_000,
            max_mcts_nodes: 50_000,
            max_mcts_rollout_depth: 256,
            min_positive: 0.000_1,
            max_callbacks_per_frame: 4_096,
        }
    }
}

/// Reject NaN and infinite `f32` inputs.
pub fn finite_f32(field: &'static str, value: f32) -> Result<f32, AiError> {
    if !value.is_finite() {
        return Err(AiError::InvalidFloat {
            field,
            value: f64::from(value),
        });
    }
    Ok(value)
}

/// Reject NaN and infinite `f64` inputs.
pub fn finite_f64(field: &'static str, value: f64) -> Result<f64, AiError> {
    if !value.is_finite() {
        return Err(AiError::InvalidFloat { field, value });
    }
    Ok(value)
}

/// Reject negative inputs after confirming finiteness.
pub fn non_negative(field: &'static str, value: f64) -> Result<f64, AiError> {
    finite_f64(field, value)?;
    if value < 0.0 {
        return Err(AiError::NegativeValue { field, value });
    }
    Ok(value)
}

/// Reject non-positive inputs after confirming finiteness.
pub fn positive_nonzero(
    field: &'static str,
    value: f64,
    limits: &AiValidationLimits,
) -> Result<f64, AiError> {
    finite_f64(field, value)?;
    if value < limits.min_positive {
        return Err(AiError::NonPositiveValue { field, value });
    }
    Ok(value)
}

/// Reject counts above a configured ceiling.
pub fn validate_count(
    context: &'static str,
    count: usize,
    max: usize,
) -> Result<usize, AiError> {
    if count > max {
        return Err(AiError::CountLimitExceeded {
            context,
            count,
            max,
        });
    }
    Ok(count)
}

/// Reject depths above a configured ceiling.
pub fn validate_depth(
    context: &'static str,
    depth: usize,
    max: usize,
) -> Result<usize, AiError> {
    if depth > max {
        return Err(AiError::DepthLimitExceeded {
            context,
            depth,
            max,
        });
    }
    Ok(depth)
}
