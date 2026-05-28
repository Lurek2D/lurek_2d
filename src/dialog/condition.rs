//! Dialog gate conditions: guards that control branch and topic visibility.
//!
//! - `Condition` is an enum with variants for flag checks, stat comparisons, and Lua callbacks.
//! - Evaluated lazily at the point where the dialog engine requests the next node.
//! - Lua callback conditions receive the current `DialogState` as a table argument.
//! - Composed with `And` / `Or` / `Not` wrappers for complex gating logic.

use std::collections::HashMap;

/// Context provided to gate evaluation.
#[derive(Debug, Clone, Default)]
pub struct GateContext {
    /// Current FSM state name, if any.
    pub fsm_state: Option<String>,
    /// Current behavior tree status, if any.
    pub bt_status: Option<String>,
    /// Named utility scores.
    pub utility_scores: HashMap<String, f64>,
}

/// A condition that guards whether a dialog branch is available.
#[derive(Debug, Clone)]
pub enum DialogueCondition {
    /// Branch requires this FSM state.
    FsmState(String),
    /// Branch requires this BT status.
    BtStatus(String),
    /// Branch requires utility score above threshold.
    UtilityAbove { key: String, threshold: f64 },
    /// Branch requires utility score below threshold.
    UtilityBelow { key: String, threshold: f64 },
    /// All conditions must pass.
    All(Vec<DialogueCondition>),
    /// At least one condition must pass.
    Any(Vec<DialogueCondition>),
    /// Always passes (no guard).
    Always,
}

impl DialogueCondition {
    /// Evaluate this condition against the provided context.
    pub fn evaluate(&self, ctx: &GateContext) -> bool {
        match self {
            Self::FsmState(s) => ctx.fsm_state.as_deref() == Some(s.as_str()),
            Self::BtStatus(s) => ctx.bt_status.as_deref() == Some(s.as_str()),
            Self::UtilityAbove { key, threshold } => {
                ctx.utility_scores.get(key).copied().unwrap_or(0.0) > *threshold
            }
            Self::UtilityBelow { key, threshold } => {
                ctx.utility_scores.get(key).copied().unwrap_or(0.0) < *threshold
            }
            Self::All(conditions) => conditions.iter().all(|c| c.evaluate(ctx)),
            Self::Any(conditions) => conditions.iter().any(|c| c.evaluate(ctx)),
            Self::Always => true,
        }
    }
}
