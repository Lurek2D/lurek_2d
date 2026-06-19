//! Implements goal-oriented action planning over boolean world facts, action effects, and prioritized desired states.
//! Owns GOAP actions, goals, bounded best-first search nodes, and the iteration cap that keeps planning tractable.
//! Searches forward from the current world state, reconstructing ordered action names once a goal state is satisfied.
//! Also exposes mutators for action preconditions, effects, and goal facts so planners can be assembled incrementally.
//! Provides the deliberative planning boundary between symbolic world state and executable action chains.
//! Open this owner when plan search cost, iteration ceilings, or goal satisfaction semantics need shared fixes.

use crate::ai::diagnostics::GoapPlanTrace;
use crate::ai::validation::{
    finite_f64, non_negative, validate_count, AiValidationLimits,
};
use crate::log_msg;
use crate::runtime::log_messages::{GP01, GP02, GP03};
use mlua::RegistryKey;
use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap};

/// Failure taxonomy recorded by the planner when a plan cannot be produced.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum PlanFailureReason {
    /// No goals were available for selection.
    NoGoal,
    /// One or more planner inputs or registrations were invalid.
    InvalidInput(String),
    /// The planner exhausted its configured iteration or node budget.
    BudgetExhausted,
    /// No plan path satisfied the selected goal.
    NoPath,
}

impl PlanFailureReason {
    /// Return a stable lowercase reason tag for diagnostics and Lua-facing traces.
    pub fn as_str(&self) -> String {
        match self {
            Self::NoGoal => "no_goal".to_string(),
            Self::InvalidInput(detail) => format!("invalid_input:{detail}"),
            Self::BudgetExhausted => "budget_exhausted".to_string(),
            Self::NoPath => "no_path".to_string(),
        }
    }
}
/// One GOAP action with planning metadata and world-state changes.
pub struct GOAPAction {
    /// Unique name identifying this action.
    pub name: String,
    /// Path cost used by the A* planner; lower cost preferred.
    pub cost: f64,
    /// Optional Lua callback invoked when this action is executed.
    pub callback: Option<RegistryKey>,
    /// World-state conditions that must be true before this action can run.
    pub preconditions: HashMap<String, bool>,
    /// World-state changes applied after this action completes successfully.
    pub effects: HashMap<String, bool>,
}
/// One named goal with a priority and desired world state.
pub struct GOAPGoal {
    /// Unique name identifying this goal.
    pub name: String,
    /// Selection weight; the highest-priority unsatisfied goal is planned for.
    pub priority: f64,
    /// Desired world state this goal requires to be satisfied.
    pub state: HashMap<String, bool>,
}
#[derive(Clone)]
/// One A* search node produced while planning toward a goal state.
struct PlanNode {
    /// World state at this search node.
    state: HashMap<String, bool>,
    /// Sequence of action indices selected to reach this node.
    actions: Vec<usize>,
    /// Accumulated action cost from the start.
    cost: f64,
    /// Estimated remaining cost to goal; counts unsatisfied goal conditions.
    heuristic: f64,
}
/// Equality by f-score for min-heap ordering.
impl PartialEq for PlanNode {
    /// Equal when `total()` values are equal (used for heap ordering only).
    fn eq(&self, other: &Self) -> bool {
        self.total() == other.total()
    }
}
/// Marker trait for total-equality semantics used by the binary heap.
impl Eq for PlanNode {}
/// Partial ordering delegates to the total `Ord` implementation.
impl PartialOrd for PlanNode {
    /// Delegate to `Ord::cmp`.
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}
/// Total ordering for min-heap: lower f-score wins.
impl Ord for PlanNode {
    /// Min-heap ordering: lower `total()` wins, ties resolved as `Equal`.
    fn cmp(&self, other: &Self) -> Ordering {
        other
            .total()
            .partial_cmp(&self.total())
            .unwrap_or(Ordering::Equal)
    }
}
impl PlanNode {
    /// Return the combined f-score `cost + heuristic`.
    fn total(&self) -> f64 {
        self.cost + self.heuristic
    }
}
/// GOAP planner that stores actions, goals, and the bounded search configuration.
pub struct GOAPPlanner {
    /// All registered actions available to the planner.
    pub actions: Vec<GOAPAction>,
    /// All registered goals; the highest-priority goal is selected at plan time.
    pub goals: Vec<GOAPGoal>,
    /// Hard cap on A* iterations to prevent runaway planning; default 10 000.
    pub max_iterations: usize,
    /// Shared safety limits for registrations and search budgets.
    pub limits: AiValidationLimits,
    /// Failure reason recorded by the most recent plan call.
    pub last_failure_reason: Option<PlanFailureReason>,
    /// Last structured planning trace.
    pub last_trace: GoapPlanTrace,
}
impl GOAPPlanner {
    /// Create a planner with an empty action and goal lists and `max_iterations = 10 000`.
    pub fn new() -> Self {
        log_msg!(debug, GP01);
        Self {
            actions: Vec::new(),
            goals: Vec::new(),
            max_iterations: 10_000,
            limits: AiValidationLimits::default(),
            last_failure_reason: None,
            last_trace: GoapPlanTrace::default(),
        }
    }
    /// Plan for the highest-priority goal; return ordered action name list or empty on failure.
    pub fn plan(&mut self, world_state: &HashMap<String, bool>, max_depth: usize) -> Vec<String> {
        if let Err(err) = self.validate_registrations() {
            return self.fail(PlanFailureReason::InvalidInput(err));
        }
        let best_goal = self.goals.iter().max_by(|a, b| {
            a.priority
                .partial_cmp(&b.priority)
                .unwrap_or(Ordering::Equal)
        });
        let goal = match best_goal {
            Some(g) => (g.name.clone(), g.state.clone()),
            None => return self.fail(PlanFailureReason::NoGoal),
        };
        self.plan_for_goal(Some(goal.0), &goal.1, world_state, max_depth)
    }
    /// Plan for the goal at `goal_idx`; return ordered action name list or empty on failure.
    pub fn plan_for_goal_idx(
        &mut self,
        goal_idx: usize,
        world_state: &HashMap<String, bool>,
        max_depth: usize,
    ) -> Vec<String> {
        if goal_idx >= self.goals.len() {
            return self.fail(PlanFailureReason::InvalidInput(format!(
                "goal index {} is out of range",
                goal_idx
            )));
        }
        let goal = (
            self.goals[goal_idx].name.clone(),
            self.goals[goal_idx].state.clone(),
        );
        self.plan_for_goal(Some(goal.0), &goal.1, world_state, max_depth)
    }
    /// A* search from `world_state` toward `goal_state` up to `max_depth` actions.
    fn plan_for_goal(
        &mut self,
        goal_name: Option<String>,
        goal_state: &HashMap<String, bool>,
        world_state: &HashMap<String, bool>,
        max_depth: usize,
    ) -> Vec<String> {
        let max_depth = max_depth.min(self.limits.max_goap_depth);
        let max_iterations = self.max_iterations.min(self.limits.max_goap_iterations);
        self.last_trace = GoapPlanTrace {
            selected_goal: goal_name.clone(),
            ..GoapPlanTrace::default()
        };
        self.last_failure_reason = None;
        if self.goal_satisfied(goal_state, world_state) {
            self.last_trace.chosen_plan = Vec::new();
            return Vec::new();
        }
        let mut open = BinaryHeap::new();
        let mut best_costs = HashMap::new();
        open.push(PlanNode {
            state: world_state.clone(),
            actions: Vec::new(),
            cost: 0.0,
            heuristic: self.heuristic(goal_state, world_state),
        });
        best_costs.insert(canonical_state_key(world_state), 0.0);
        let mut iterations = 0;
        let mut expanded_nodes = 1usize;
        while let Some(current) = open.pop() {
            iterations += 1;
            self.last_trace.iterations = iterations;
            self.last_trace.expanded_nodes = expanded_nodes;
            if iterations > max_iterations {
                return self.fail(PlanFailureReason::BudgetExhausted);
            }
            if current.actions.len() >= max_depth {
                continue;
            }
            for (i, action) in self.actions.iter().enumerate() {
                if !self.preconditions_met(&action.preconditions, &current.state) {
                    continue;
                }
                let mut new_state = current.state.clone();
                for (k, v) in &action.effects {
                    new_state.insert(k.clone(), *v);
                }
                let new_cost = current.cost + action.cost;
                let state_key = canonical_state_key(&new_state);
                if best_costs
                    .get(&state_key)
                    .is_some_and(|best_cost| *best_cost <= new_cost)
                {
                    continue;
                }
                best_costs.insert(state_key, new_cost);
                expanded_nodes += 1;
                if expanded_nodes > self.limits.max_goap_nodes {
                    self.last_trace.iterations = iterations;
                    self.last_trace.expanded_nodes = expanded_nodes;
                    return self.fail(PlanFailureReason::BudgetExhausted);
                }
                let mut new_actions = current.actions.clone();
                new_actions.push(i);
                if self.goal_satisfied(goal_state, &new_state) {
                    log_msg!(debug, GP03);
                    let plan: Vec<String> = new_actions
                        .iter()
                        .map(|&idx| self.actions[idx].name.clone())
                        .collect();
                    self.last_trace.chosen_plan = plan.clone();
                    self.last_trace.iterations = iterations;
                    self.last_trace.expanded_nodes = expanded_nodes;
                    return plan;
                }
                open.push(PlanNode {
                    heuristic: self.heuristic(goal_state, &new_state),
                    cost: new_cost,
                    state: new_state,
                    actions: new_actions,
                });
            }
        }
        log_msg!(warn, GP02);
        self.fail(PlanFailureReason::NoPath)
    }
    /// Return `true` when every goal condition is met in `state`.
    fn goal_satisfied(&self, goal: &HashMap<String, bool>, state: &HashMap<String, bool>) -> bool {
        goal.iter().all(|(k, v)| state.get(k) == Some(v))
    }
    /// Return `true` when every precondition is satisfied by `state`.
    fn preconditions_met(
        &self,
        preconds: &HashMap<String, bool>,
        state: &HashMap<String, bool>,
    ) -> bool {
        preconds.iter().all(|(k, v)| state.get(k) == Some(v))
    }
    /// Count unsatisfied goal conditions as a distance-to-goal estimate.
    fn heuristic(&self, goal: &HashMap<String, bool>, state: &HashMap<String, bool>) -> f64 {
        goal.iter()
            .filter(|(k, v)| state.get(*k) != Some(*v))
            .count() as f64
    }
    /// Register a new action with an empty precondition and effect set.
    pub fn add_action(
        &mut self,
        name: String,
        cost: f64,
        callback: Option<RegistryKey>,
    ) -> Result<(), String> {
        validate_count(
            "goap actions",
            self.actions.len() + 1,
            self.limits.max_goap_actions,
        )
        .map_err(|err| err.to_string())?;
        non_negative("goap action cost", cost).map_err(|err| err.to_string())?;
        self.actions.push(GOAPAction {
            name,
            cost,
            callback,
            preconditions: HashMap::new(),
            effects: HashMap::new(),
        });
        Ok(())
    }
    /// Add a precondition entry to the named action; no-op if the action is not found.
    pub fn add_precondition(&mut self, action_name: &str, key: String, value: bool) {
        if let Some(a) = self.actions.iter_mut().find(|a| a.name == action_name) {
            a.preconditions.insert(key, value);
        }
    }
    /// Add an effect entry to the named action; no-op if the action is not found.
    pub fn add_effect(&mut self, action_name: &str, key: String, value: bool) {
        if let Some(a) = self.actions.iter_mut().find(|a| a.name == action_name) {
            a.effects.insert(key, value);
        }
    }
    /// Register a new goal with an empty desired state map.
    pub fn add_goal(&mut self, name: String, priority: f64) -> Result<(), String> {
        validate_count(
            "goap goals",
            self.goals.len() + 1,
            self.limits.max_goap_goals,
        )
        .map_err(|err| err.to_string())?;
        non_negative("goap goal priority", priority).map_err(|err| err.to_string())?;
        self.goals.push(GOAPGoal {
            name,
            priority,
            state: HashMap::new(),
        });
        Ok(())
    }
    /// Add a desired world-state entry to the named goal; no-op if goal is not found.
    pub fn set_goal_state(&mut self, goal_name: &str, key: String, value: bool) {
        if let Some(g) = self.goals.iter_mut().find(|g| g.name == goal_name) {
            g.state.insert(key, value);
        }
    }
    /// Return the current A* iteration cap.
    pub fn get_max_iterations(&self) -> usize {
        self.max_iterations
    }
    /// Set the A* iteration cap to `n`.
    pub fn set_max_iterations(&mut self, n: usize) {
        self.max_iterations = n.min(self.limits.max_goap_iterations);
    }

    fn validate_registrations(&self) -> Result<(), String> {
        validate_count("goap actions", self.actions.len(), self.limits.max_goap_actions)
            .map_err(|err| err.to_string())?;
        validate_count("goap goals", self.goals.len(), self.limits.max_goap_goals)
            .map_err(|err| err.to_string())?;
        for action in &self.actions {
            finite_f64("goap action cost", action.cost).map_err(|err| err.to_string())?;
            non_negative("goap action cost", action.cost).map_err(|err| err.to_string())?;
        }
        for goal in &self.goals {
            finite_f64("goap goal priority", goal.priority).map_err(|err| err.to_string())?;
            non_negative("goap goal priority", goal.priority).map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    fn fail(&mut self, reason: PlanFailureReason) -> Vec<String> {
        self.last_failure_reason = Some(reason.clone());
        self.last_trace.failure_reason = Some(reason.as_str());
        Vec::new()
    }
}
/// `Default` delegates to `GOAPPlanner::new`.
impl Default for GOAPPlanner {
    /// `Default` delegates to `GOAPPlanner::new`.
    fn default() -> Self {
        Self::new()
    }
}

fn canonical_state_key(state: &HashMap<String, bool>) -> String {
    let mut entries: Vec<_> = state.iter().collect();
    entries.sort_by(|(ka, _), (kb, _)| ka.cmp(kb));
    let mut key = String::new();
    for (name, value) in entries {
        key.push_str(name);
        key.push('=');
        key.push(if *value { '1' } else { '0' });
        key.push(';');
    }
    key
}
