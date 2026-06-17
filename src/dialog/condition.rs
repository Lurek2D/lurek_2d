//! Provides reusable gate rules that decide whether dialog options are eligible under the current runtime context. `dialog/condition` delivers the condition implementation for the dialog subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Encodes state and threshold checks as portable data so narrative gating stays configurable and data-first. The file owns or coordinates data contracts including `GateContext`, `DialogueCondition`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Supports composable all-or-any logic for layered progression constraints across branching conversations. Public callable behavior is centered on no named public items, while method-level behavior such as `evaluate` stays attached to the local data model and invariants.

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
