//! Owns ai behavior with explicit state, validation, and crate-local integration boundaries. for engine changes.
//! Keeps ai data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how diagnostics data is validated, transformed, or stored before neighboring systems use it.
//! Owns ai behavior with explicit state, validation, and crate-local integration boundaries. for engine changes.

/// One recorded callback error emitted by an AI subsystem.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct CallbackErrorTrace {
    /// Subsystem-local context such as `utility.scorer.attack` or `world.custom.hero`.
    pub context: String,
    /// Error message captured from the callback boundary.
    pub message: String,
}

/// One traced utility consideration contribution.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct UtilityConsiderationTrace {
    /// Consideration name.
    pub name: String,
    /// Raw score returned by the callback before shaping.
    pub raw_score: f64,
    /// Final clamped score contributed by the consideration.
    pub final_score: f64,
    /// Configured consideration weight.
    pub weight: f64,
    /// Whether the raw callback value had to be neutralized.
    pub invalid_input: bool,
}

/// One traced utility action evaluation.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct UtilityActionTrace {
    /// Action name.
    pub name: String,
    /// Raw action scorer output before clamping.
    pub raw_score: f64,
    /// Combined consideration multiplier applied to the base score.
    pub consideration_score: f64,
    /// Momentum multiplier applied to the action.
    pub momentum_multiplier: f64,
    /// Final action score used for ranking.
    pub final_score: f64,
    /// Whether the raw scorer output had to be neutralized.
    pub invalid_scorer: bool,
    /// Traced consideration details.
    pub considerations: Vec<UtilityConsiderationTrace>,
}

/// Last utility-AI evaluation trace.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct UtilityDecisionTrace {
    /// Chosen action name when evaluation succeeded.
    pub chosen_action: Option<String>,
    /// Number of callbacks consumed by the evaluation pulse.
    pub callbacks_used: usize,
    /// Action-by-action scoring details.
    pub actions: Vec<UtilityActionTrace>,
    /// Callback errors recorded during the evaluation pulse.
    pub callback_errors: Vec<CallbackErrorTrace>,
}

/// Last GOAP planning trace.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct GoapPlanTrace {
    /// Selected goal name when one was available.
    pub selected_goal: Option<String>,
    /// Action names chosen for the final plan.
    pub chosen_plan: Vec<String>,
    /// Iterations consumed by the most recent search.
    pub iterations: usize,
    /// Nodes expanded by the most recent search.
    pub expanded_nodes: usize,
    /// Failure reason string when planning did not succeed.
    pub failure_reason: Option<String>,
}

/// Captures the last MCTS search outcome, counters, and callback failures.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct MctsDecisionTrace {
    /// Chosen action id when search succeeded.
    pub chosen_action: Option<i32>,
    /// Iterations completed by the search.
    pub iterations_run: u32,
    /// Total nodes allocated in the current arena.
    pub nodes_expanded: usize,
    /// Number of rollout scores neutralized for being non-finite.
    pub invalid_score_count: usize,
    /// Callback errors recorded at the Lua boundary.
    pub callback_errors: Vec<CallbackErrorTrace>,
    /// Failure reason string when search could not produce a usable choice.
    pub failure_reason: Option<String>,
}
