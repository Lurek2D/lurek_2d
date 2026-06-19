//! Owns the utility-AI scorer that ranks candidate actions through response curves and per-action consideration data.
//! Defines response-curve variants, considerations, actions, and the last-evaluation score snapshot for inspection.
//! Calls action scorers, applies momentum bonuses, and records the chosen action so later systems can read results.
//! Provides the continuous scoring boundary between raw Lua evaluations and one selected utility-driven action.
//! Open this owner when nonlinear score shaping, momentum behavior, or action-evaluation bookkeeping needs changes.

use crate::ai::diagnostics::{
    CallbackErrorTrace, UtilityActionTrace, UtilityConsiderationTrace, UtilityDecisionTrace,
};
use crate::ai::validation::{finite_f64, validate_count, AiValidationLimits};
use mlua::prelude::*;
use mlua::RegistryKey;
/// Response-curve variant used to transform raw consideration inputs.
#[derive(Debug, Clone, PartialEq)]
pub enum ResponseCurve {
    /// Output = p1 * input + p2.
    Linear,
    /// Output = p1 * input² + p2 * input + p3.
    Quadratic,
    /// Sigmoid: 1 / (1 + exp(−p1 * (input − p2))).
    Logistic,
    /// Log-odds transform, clamped to avoid infinities.
    Logit,
    /// Returns p2 when input ≥ p1, otherwise p3.
    Step,
    /// Delegates to a Lua callback identified by `callback_id`.
    Custom {
        /// Registry index of the Lua curve callback.
        callback_id: u32,
    },
}
impl ResponseCurve {
    /// Parse a string tag into a `ResponseCurve`; unknown strings map to `Linear`.
    pub fn parse_str(s: &str) -> Self {
        match s {
            "quadratic" => Self::Quadratic,
            "logistic" => Self::Logistic,
            "logit" => Self::Logit,
            "step" => Self::Step,
            _ => Self::Linear,
        }
    }
    /// Evaluate the curve at `input` using shape parameters p1, p2, p3.
    pub fn apply(&self, input: f64, p1: f64, p2: f64, p3: f64) -> f64 {
        match self {
            Self::Linear => p1 * input + p2,
            Self::Quadratic => p1 * input * input + p2 * input + p3,
            Self::Logistic => 1.0 / (1.0 + (-p1 * (input - p2)).exp()),
            Self::Logit => {
                let clamped = input.clamp(0.001, 0.999);
                (clamped / (1.0 - clamped)).ln() * p1 + p2
            }
            Self::Step => {
                if input >= p1 {
                    p2
                } else {
                    p3
                }
            }
            Self::Custom { .. } => input,
        }
    }
}
/// One consideration that transforms a raw Lua score into a weighted utility value.
pub struct Consideration {
    /// Unique name for this consideration, used for debug display.
    pub name: String,
    /// Lua callback that returns a raw input score in `[0, 1]`.
    pub callback: RegistryKey,
    /// Response curve that maps the raw input to a utility value.
    pub curve: ResponseCurve,
    /// First shape parameter for the response curve.
    pub p1: f64,
    /// Second shape parameter for the response curve.
    pub p2: f64,
    /// Third shape parameter for the response curve.
    pub p3: f64,
    /// Multiplicative weight applied to the curve output before product scoring.
    pub weight: f64,
}
/// One candidate action scored by the utility-AI system.
pub struct UAAction {
    /// Unique name identifying this action.
    pub name: String,
    /// Lua scorer callback returning the overall action utility.
    pub scorer: RegistryKey,
    /// Ordered list of considerations whose outputs are multiplied together.
    pub considerations: Vec<Consideration>,
    /// Bonus multiplier added to the score when this action was selected last tick.
    pub momentum_bonus: f64,
}
/// Utility-AI runtime that stores actions and the latest evaluation results.
pub struct UtilityAI {
    /// All registered actions evaluated each tick.
    pub actions: Vec<UAAction>,
    /// Index of the action selected on the last `evaluate` call.
    pub last_action: Option<usize>,
    /// Per-action weighted scores from the last `evaluate` call.
    pub last_scores: Vec<f64>,
    /// Shared safety limits for scoring width and callback budgets.
    pub limits: AiValidationLimits,
    /// Last structured evaluation trace.
    pub last_trace: UtilityDecisionTrace,
}
impl UtilityAI {
    /// Create a `UtilityAI` with no actions.
    pub fn new() -> Self {
        Self {
            actions: Vec::new(),
            last_action: None,
            last_scores: Vec::new(),
            limits: AiValidationLimits::default(),
            last_trace: UtilityDecisionTrace::default(),
        }
    }
    /// Register a new action with an empty consideration list.
    pub fn add_action(
        &mut self,
        name: String,
        scorer: RegistryKey,
        momentum_bonus: f64,
    ) -> Result<(), String> {
        validate_count(
            "utility actions",
            self.actions.len() + 1,
            self.limits.max_utility_actions,
        )
        .map_err(|err| err.to_string())?;
        finite_f64("utility momentum_bonus", momentum_bonus).map_err(|err| err.to_string())?;
        self.actions.push(UAAction {
            name,
            scorer,
            considerations: Vec::new(),
            momentum_bonus,
        });
        Ok(())
    }
    #[allow(clippy::too_many_arguments)]
    /// Append a consideration to the named action; no-op if the action is not found.
    pub fn add_consideration(
        &mut self,
        action_name: &str,
        name: String,
        callback: RegistryKey,
        curve: &str,
        p1: f64,
        p2: f64,
        p3: f64,
        weight: f64,
    ) -> Result<(), String> {
        if let Some(a) = self.actions.iter_mut().find(|a| a.name == action_name) {
            validate_count(
                "utility considerations",
                a.considerations.len() + 1,
                self.limits.max_utility_considerations,
            )
            .map_err(|err| err.to_string())?;
            finite_f64("utility consideration p1", p1).map_err(|err| err.to_string())?;
            finite_f64("utility consideration p2", p2).map_err(|err| err.to_string())?;
            finite_f64("utility consideration p3", p3).map_err(|err| err.to_string())?;
            finite_f64("utility consideration weight", weight).map_err(|err| err.to_string())?;
            a.considerations.push(Consideration {
                name,
                callback,
                curve: ResponseCurve::parse_str(curve),
                p1,
                p2,
                p3,
                weight,
            });
        }
        Ok(())
    }
    /// Return the name of the action selected on the last `evaluate` call, or `None`.
    pub fn last_action_name(&self) -> Option<&str> {
        self.last_action
            .and_then(|i| self.actions.get(i))
            .map(|a| a.name.as_str())
    }
    /// Call all action scorers, apply momentum, and return the best action name.
    pub fn evaluate(&mut self, lua: &Lua) -> LuaResult<Option<String>> {
        if self.actions.is_empty() {
            self.last_trace = UtilityDecisionTrace::default();
            return Ok(None);
        }
        let previous_action = self.last_action;
        let mut best_idx = None;
        let mut best_score = f64::NEG_INFINITY;
        let mut scores = Vec::with_capacity(self.actions.len());
        let mut trace = UtilityDecisionTrace::default();
        for (i, action) in self.actions.iter().enumerate() {
            if trace.callbacks_used >= self.limits.max_callbacks_per_frame {
                trace.callback_errors.push(CallbackErrorTrace {
                    context: "utility.frame_budget".to_string(),
                    message: format!(
                        "utility evaluate exceeded callback budget {}",
                        self.limits.max_callbacks_per_frame
                    ),
                });
                scores.push(0.0);
                trace.actions.push(UtilityActionTrace {
                    name: action.name.clone(),
                    ..UtilityActionTrace::default()
                });
                continue;
            }
            let func: LuaFunction = lua.registry_value(&action.scorer)?;
            trace.callbacks_used += 1;
            let raw_score = match func.call::<_, f64>(()) {
                Ok(score) => score,
                Err(err) => {
                    trace.callback_errors.push(CallbackErrorTrace {
                        context: format!("utility.scorer.{}", action.name),
                        message: err.to_string(),
                    });
                    0.0
                }
            };
            let invalid_scorer = finite_f64("utility scorer", raw_score).is_err();
            let clamped_base = if invalid_scorer {
                0.0
            } else {
                raw_score.clamp(0.0, 1.0)
            };
            let mut consideration_product = 1.0;
            let mut consideration_traces = Vec::with_capacity(action.considerations.len());
            for consideration in &action.considerations {
                if trace.callbacks_used >= self.limits.max_callbacks_per_frame {
                    trace.callback_errors.push(CallbackErrorTrace {
                        context: format!("utility.consideration.{}", consideration.name),
                        message: format!(
                            "utility evaluate exceeded callback budget {}",
                            self.limits.max_callbacks_per_frame
                        ),
                    });
                    consideration_product = 0.0;
                    break;
                }
                let func: LuaFunction = lua.registry_value(&consideration.callback)?;
                trace.callbacks_used += 1;
                let raw_score = match func.call::<_, f64>(()) {
                    Ok(score) => score,
                    Err(err) => {
                        trace.callback_errors.push(CallbackErrorTrace {
                            context: format!("utility.consideration.{}", consideration.name),
                            message: err.to_string(),
                        });
                        0.0
                    }
                };
                let invalid_input = finite_f64("utility consideration score", raw_score).is_err();
                let raw = if invalid_input {
                    0.0
                } else {
                    raw_score.clamp(0.0, 1.0)
                };
                let curved = consideration
                    .curve
                    .apply(raw, consideration.p1, consideration.p2, consideration.p3)
                    .clamp(0.0, 1.0);
                let final_score = (curved * consideration.weight).clamp(0.0, 1.0);
                consideration_product *= final_score;
                consideration_traces.push(UtilityConsiderationTrace {
                    name: consideration.name.clone(),
                    raw_score,
                    final_score,
                    weight: consideration.weight,
                    invalid_input,
                });
            }
            let momentum_multiplier = if previous_action == Some(i) {
                action.momentum_bonus.max(0.0)
            } else {
                1.0
            };
            let final_score = clamped_base * consideration_product * momentum_multiplier;
            scores.push(final_score);
            trace.actions.push(UtilityActionTrace {
                name: action.name.clone(),
                raw_score,
                consideration_score: consideration_product,
                momentum_multiplier,
                final_score,
                invalid_scorer,
                considerations: consideration_traces,
            });
            if final_score > best_score {
                best_score = final_score;
                best_idx = Some(i);
            }
        }
        self.last_scores = scores;
        self.last_action = best_idx;
        trace.chosen_action = best_idx.map(|idx| self.actions[idx].name.clone());
        self.last_trace = trace;
        Ok(best_idx.map(|idx| self.actions[idx].name.clone()))
    }
}
/// `Default` delegates to `UtilityAI::new`.
impl Default for UtilityAI {
    /// `Default` delegates to `UtilityAI::new`.
    fn default() -> Self {
        Self::new()
    }
}
