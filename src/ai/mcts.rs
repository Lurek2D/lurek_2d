//! Implements Monte Carlo Tree Search as a reusable decision kernel for sampled action selection under uncertainty.
//! Owns the arena-backed node tree, UCT scoring, rollout budget, RNG state, and selection or expansion workflow.
//! Runs full selection, expansion, rollout, and backpropagation, then returns the most visited root action choice.
//! Provides the sampled planning boundary between abstract action generators and a concrete chosen action id.
//! This file matters when rollout budgets, exploration pressure, or visit accounting stop producing sane choices.
//! Open this owner when search-policy behavior changes without affecting deterministic planners like GOAP or HTN.

use crate::ai::diagnostics::{CallbackErrorTrace, MctsDecisionTrace};
use crate::ai::validation::{finite_f32, validate_count, validate_depth, AiValidationLimits};

/// Configuration for one MCTS search run.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct MCTSConfig {
    /// Number of iterations to execute.
    pub iterations: u32,
    /// Exploration constant used by UCT.
    pub uct_c: f32,
    /// Maximum rollout depth.
    pub rollout_depth: usize,
    /// RNG seed.
    pub seed: u64,
}
/// `Default` provides the standard search parameters.
impl Default for MCTSConfig {
    /// Build the standard search parameters.
    fn default() -> Self {
        Self {
            iterations: 100,
            uct_c: 1.414,
            rollout_depth: 10,
            seed: 42,
        }
    }
}

impl MCTSConfig {
    /// Validate search parameters against shared AI limits.
    pub fn validate(&self, limits: &AiValidationLimits) -> Result<(), String> {
        validate_count(
            "mcts iterations",
            self.iterations as usize,
            limits.max_mcts_iterations as usize,
        )
        .map_err(|err| err.to_string())?;
        finite_f32("mcts uct_c", self.uct_c).map_err(|err| err.to_string())?;
        if self.uct_c < 0.0 {
            return Err("mcts uct_c must be >= 0".to_string());
        }
        validate_depth(
            "mcts rollout depth",
            self.rollout_depth,
            limits.max_mcts_rollout_depth,
        )
        .map_err(|err| err.to_string())?;
        Ok(())
    }
}
/// Internal tree node used by `MCTSEngine`.
struct MCTSNode {
    /// Parent node index.
    parent: Option<usize>,
    /// Child node indices.
    children: Vec<usize>,
    /// Action that produced this node.
    action: Option<i32>,
    /// Visit count.
    visits: u32,
    /// Accumulated rollout score.
    total_score: f64,
    /// Actions not yet expanded from this node.
    untried_actions: Vec<i32>,
}
impl MCTSNode {
    /// Create a new node with the supplied untried actions.
    fn new(parent: Option<usize>, action: Option<i32>, actions: Vec<i32>) -> Self {
        Self {
            parent,
            children: Vec::new(),
            action,
            visits: 0,
            total_score: 0.0,
            untried_actions: actions,
        }
    }
    /// Return the UCT score for this node.
    fn uct(&self, parent_visits: u32, c: f32) -> f64 {
        if self.visits == 0 {
            return f64::INFINITY;
        }
        let q = self.total_score / self.visits as f64;
        let u = c as f64 * ((parent_visits as f64).ln() / self.visits as f64).sqrt();
        q + u
    }
    /// Return `true` when no untried actions remain.
    fn is_fully_expanded(&self) -> bool {
        self.untried_actions.is_empty()
    }
}
/// MCTS search engine with an internal arena-backed tree.
pub struct MCTSEngine {
    /// Search configuration.
    pub config: MCTSConfig,
    /// Arena of nodes for the current search.
    arena: Vec<MCTSNode>,
    /// Internal RNG state.
    rng: u64,
    /// Shared safety limits for MCTS budgets and validation.
    pub limits: AiValidationLimits,
    /// Last structured search trace.
    pub last_trace: MctsDecisionTrace,
}
impl MCTSEngine {
    /// Create a search engine with the provided config.
    pub fn new(config: MCTSConfig) -> Self {
        let limits = AiValidationLimits::default();
        let _ = config.validate(&limits);
        let rng = config.seed;
        Self {
            config,
            arena: Vec::new(),
            rng,
            limits,
            last_trace: MctsDecisionTrace::default(),
        }
    }

    /// Create a search engine after validating the provided configuration.
    pub fn try_new(config: MCTSConfig) -> Result<Self, String> {
        let limits = AiValidationLimits::default();
        config.validate(&limits)?;
        Ok(Self::new(config))
    }
    /// Return the active config. This function is part of the public API.
    pub fn config(&self) -> &MCTSConfig {
        &self.config
    }
    /// Search for the best action and return its id, or `None` when no actions exist.
    pub fn search<S, FA, FB, FC>(
        &mut self,
        root_state: S,
        get_actions: &mut FA,
        apply_action: &mut FB,
        evaluate: &mut FC,
    ) -> Option<i32>
    where
        S: Clone,
        FA: FnMut(&S) -> Vec<i32>,
        FB: FnMut(&S, i32) -> S,
        FC: FnMut(&S) -> f32,
    {
        self.arena.clear();
        self.last_trace = MctsDecisionTrace::default();
        let root_actions = get_actions(&root_state);
        if root_actions.is_empty() {
            self.last_trace.failure_reason = Some("no_actions".to_string());
            return None;
        }
        self.arena.push(MCTSNode::new(None, None, root_actions));
        let mut invalid_score_count = 0usize;
        let mut iterations_run = 0u32;
        for _ in 0..self.config.iterations.min(self.limits.max_mcts_iterations) {
            if self.arena.len() >= self.limits.max_mcts_nodes {
                self.last_trace.failure_reason = Some("budget_exhausted".to_string());
                break;
            }
            let (node_idx, state) = self.select(0, root_state.clone(), apply_action);
            let (node_idx, state) = self.expand(node_idx, state, get_actions, apply_action);
            let score = self.rollout(&state, get_actions, apply_action, evaluate);
            let score = if score.is_finite() {
                score as f64
            } else {
                invalid_score_count += 1;
                0.0
            };
            self.backpropagate(node_idx, score);
            iterations_run += 1;
        }
        let root = &self.arena[0];
        let chosen_action = root
            .children
            .iter()
            .max_by_key(|&&c| self.arena[c].visits)
            .and_then(|&c| self.arena[c].action);
        self.last_trace.chosen_action = chosen_action;
        self.last_trace.iterations_run = iterations_run;
        self.last_trace.nodes_expanded = self.arena.len();
        self.last_trace.invalid_score_count = invalid_score_count;
        if chosen_action.is_none() && self.last_trace.failure_reason.is_none() {
            self.last_trace.failure_reason = Some("no_choice".to_string());
        }
        chosen_action
    }
    /// Follow UCT until an expandable node is reached.
    fn select<S, FB>(&self, mut idx: usize, mut state: S, apply_action: &mut FB) -> (usize, S)
    where
        S: Clone,
        FB: FnMut(&S, i32) -> S,
    {
        loop {
            let node = &self.arena[idx];
            if !node.is_fully_expanded() || node.children.is_empty() {
                return (idx, state);
            }
            let parent_visits = node.visits;
            let c = self.config.uct_c;
            let Some(&best_child) = node.children.iter().max_by(|&&a, &&b| {
                self.arena[a]
                    .uct(parent_visits, c)
                    .total_cmp(&self.arena[b].uct(parent_visits, c))
            }) else {
                return (idx, state);
            };
            let Some(action) = self.arena[best_child].action else {
                return (idx, state);
            };
            state = apply_action(&state, action);
            idx = best_child;
        }
    }
    /// Expand one untried action from `node_idx`.
    fn expand<S, FA, FB>(
        &mut self,
        node_idx: usize,
        state: S,
        get_actions: &mut FA,
        apply_action: &mut FB,
    ) -> (usize, S)
    where
        S: Clone,
        FA: FnMut(&S) -> Vec<i32>,
        FB: FnMut(&S, i32) -> S,
    {
        if self.arena[node_idx].untried_actions.is_empty() {
            return (node_idx, state);
        }
        let action_idx = self.rand_usize(self.arena[node_idx].untried_actions.len());
        let action = self.arena[node_idx].untried_actions.remove(action_idx);
        let new_state = apply_action(&state, action);
        let child_actions = get_actions(&new_state);
        let child_idx = self.arena.len();
        self.arena
            .push(MCTSNode::new(Some(node_idx), Some(action), child_actions));
        self.arena[node_idx].children.push(child_idx);
        (child_idx, new_state)
    }
    /// Run a random rollout from `state` and return the evaluated score.
    fn rollout<S, FA, FB, FC>(
        &mut self,
        state: &S,
        get_actions: &mut FA,
        apply_action: &mut FB,
        evaluate: &mut FC,
    ) -> f32
    where
        S: Clone,
        FA: FnMut(&S) -> Vec<i32>,
        FB: FnMut(&S, i32) -> S,
        FC: FnMut(&S) -> f32,
    {
        let mut cur = state.clone();
        for _ in 0..self.config.rollout_depth {
            let actions = get_actions(&cur);
            if actions.is_empty() {
                break;
            }
            let i = self.rand_usize(actions.len());
            cur = apply_action(&cur, actions[i]);
        }
        evaluate(&cur)
    }
    /// Propagate a rollout score back to the root.
    fn backpropagate(&mut self, mut idx: usize, score: f64) {
        loop {
            self.arena[idx].visits += 1;
            self.arena[idx].total_score += score;
            match self.arena[idx].parent {
                Some(p) => idx = p,
                None => break,
            }
        }
    }
    /// Sample a random index in `[0, n)`.
    fn rand_usize(&mut self, n: usize) -> usize {
        self.rng ^= self.rng << 13;
        self.rng ^= self.rng >> 7;
        self.rng ^= self.rng << 17;
        (self.rng as usize) % n
    }

    /// Replace the callback errors recorded by the most recent Lua-facing wrapper call.
    pub fn set_last_callback_errors(&mut self, callback_errors: Vec<CallbackErrorTrace>) {
        self.last_trace.callback_errors = callback_errors;
    }
}
