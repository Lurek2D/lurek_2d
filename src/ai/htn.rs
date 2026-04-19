//! Hierarchical Task Network (HTN) Planner.
//!
//! HTN planning decomposes high-level compound tasks into sequences of
//! primitive (executable) actions by applying decomposition methods until
//! only primitive tasks remain. The resulting plan is a flat list of primitive
//! task names that game code executes in order.
//!
//! ## Architecture
//!
//! - [`HTNTask`] — either a `Compound` task (has named decomposition methods)
//!   or a `Primitive` task (directly executable, has an operator name and an
//!   optional precondition/effect pair stored as string keys).
//! - [`HTNMethod`] — one decomposition path for a compound task. Contains an
//!   ordered list of sub-tasks and an optional precondition closure evaluated
//!   against the world-state at planning time.
//! - [`HTNDomain`] — the full task registry for a game (all primitives +
//!   compound tasks with their methods). Typically one domain per agent type.
//! - [`HTNPlanner`] — executes planning against a domain given a root task name
//!   and a world-state snapshot. Returns a `Vec<String>` plan or `None`.
//!
//! ## Typical Usage Sequence
//!
//! 1. Create an `HTNDomain` per agent archetype.
//! 2. Register primitive tasks with expected precondition/effect key names.
//! 3. Register compound tasks with ordered `HTNMethod` decompositions.
//! 4. At decision time: clone the agent's world-state blackboard into a
//!    `HashMap<String, f32>` and call `HTNPlanner::plan(&domain, root, &state)`.
//! 5. Cache the returned plan Vec; execute primitives in sequence, re-planning
//!    when a precondition fails.

use std::collections::HashMap;

// ────────────────────────────────────────────────────────────────────────────
// World State
// ────────────────────────────────────────────────────────────────────────────

/// Snapshot of agent/world boolean and numeric state used during HTN planning.
///
/// Keys are arbitrary strings matching the names used in method preconditions
/// and task effect lists. Values are `f32`; boolean states use `0.0` / `1.0`.
pub type WorldState = HashMap<String, f32>;

// ────────────────────────────────────────────────────────────────────────────
// HTNTask
// ────────────────────────────────────────────────────────────────────────────

/// A hierarchical task — either a compound task (decomposable) or a primitive task (executable).
///
/// # Variants
/// - `Compound` — Compound variant.
/// - `Primitive` — Primitive variant.
pub enum HTNTask {
    /// A compound task that must be decomposed via its methods.
    Compound {
        /// Unique name of this compound task.
        name: String,
        /// Ordered list of decomposition methods; first applicable method wins.
        methods: Vec<HTNMethod>,
    },
    /// A directly executable primitive task with optional state effects.
    Primitive {
        /// Unique name of this primitive task (returned in the plan output).
        name: String,
        /// World-state keys that must be `>= 0.5` to include this task.
        /// Empty = always executable.
        preconditions: Vec<String>,
        /// World-state keys set to `1.0` after executing this primitive.
        effects: Vec<String>,
        /// World-state keys set to `0.0` after executing this primitive.
        effects_clear: Vec<String>,
    },
}

impl HTNTask {
    /// Returns the name of this task.
    ///
    /// # Returns
    /// `&str`.
    pub fn name(&self) -> &str {
        match self {
            Self::Compound { name, .. } => name.as_str(),
            Self::Primitive { name, .. } => name.as_str(),
        }
    }

    /// Returns `true` if this is a primitive task.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_primitive(&self) -> bool {
        matches!(self, Self::Primitive { .. })
    }

    /// Checks whether a primitive's preconditions are satisfied in the given state.
    /// Always returns `true` for compound tasks.
    ///
    /// # Parameters
    /// - `state` — `&WorldState`.
    ///
    /// # Returns
    /// `bool`.
    pub fn preconditions_met(&self, state: &WorldState) -> bool {
        match self {
            Self::Primitive { preconditions, .. } => {
                preconditions.iter().all(|k| state.get(k).copied().unwrap_or(0.0) >= 0.5)
            }
            Self::Compound { .. } => true,
        }
    }

    /// Applies this primitive's effects to a mutable world-state clone.
    /// No-ops for compound tasks.
    ///
    /// # Parameters
    /// - `state` — `&mut WorldState`.
    pub fn apply_effects(&self, state: &mut WorldState) {
        if let Self::Primitive { effects, effects_clear, .. } = self {
            for k in effects       { state.insert(k.clone(), 1.0); }
            for k in effects_clear { state.insert(k.clone(), 0.0); }
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// HTNMethod
// ────────────────────────────────────────────────────────────────────────────

/// One decomposition pathway for a compound task.
///
/// A method applies when all of its precondition keys are `>= 0.5` in the
/// current world state. Its `sub_tasks` list replaces the compound task in
/// the planning stack.
///
/// # Fields
/// - `name` — `String`.
/// - `preconditions` — `Vec<String>`.
/// - `sub_tasks` — `Vec<String>`.
pub struct HTNMethod {
    /// Descriptive name for this method (used for debug/logging).
    pub name: String,
    /// World-state keys that must be `>= 0.5` for this method to trigger.
    pub preconditions: Vec<String>,
    /// Ordered task names to push onto the planning stack when this method applies.
    pub sub_tasks: Vec<String>,
}

impl HTNMethod {
    /// Creates a method with no preconditions (always applicable).
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `sub_tasks` — `Vec<&str>`.
    ///
    /// # Returns
    /// `Self`.
    pub fn always(name: &str, sub_tasks: Vec<&str>) -> Self {
        Self {
            name: name.to_string(),
            preconditions: Vec::new(),
            sub_tasks: sub_tasks.into_iter().map(|s| s.to_string()).collect(),
        }
    }

    /// Creates a method with preconditions.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `preconditions` — `Vec<&str>`.
    /// - `sub_tasks` — `Vec<&str>`.
    ///
    /// # Returns
    /// `Self`.
    pub fn with_preconditions(name: &str, preconditions: Vec<&str>, sub_tasks: Vec<&str>) -> Self {
        Self {
            name: name.to_string(),
            preconditions: preconditions.into_iter().map(|s| s.to_string()).collect(),
            sub_tasks: sub_tasks.into_iter().map(|s| s.to_string()).collect(),
        }
    }

    /// Returns `true` if this method's preconditions are satisfied in `state`.
    ///
    /// # Parameters
    /// - `state` — `&WorldState`.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_applicable(&self, state: &WorldState) -> bool {
        self.preconditions.iter().all(|k| state.get(k).copied().unwrap_or(0.0) >= 0.5)
    }
}

// ────────────────────────────────────────────────────────────────────────────
// HTNDomain
// ────────────────────────────────────────────────────────────────────────────

/// Registry of all HTN tasks for an agent archetype.
///
/// One domain per agent type. Tasks are registered at game startup; planning
/// queries the domain at runtime without mutating it.
///
/// # Fields
/// - `tasks` — `HashMap<String, HTNTask>`.
#[derive(Default)]
pub struct HTNDomain {
    tasks: HashMap<String, HTNTask>,
}

impl HTNDomain {
    /// Creates an empty domain.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self::default()
    }

    /// Registers an `HTNTask` in the domain. Overwrites any existing task with the same name.
    ///
    /// # Parameters
    /// - `task` — `HTNTask`.
    pub fn register(&mut self, task: HTNTask) {
        self.tasks.insert(task.name().to_string(), task);
    }

    /// Convenience: registers a primitive task with given preconditions and effects.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `preconditions` — `Vec<&str>`.
    /// - `effects` — `Vec<&str>`.
    /// - `effects_clear` — `Vec<&str>`.
    pub fn add_primitive(&mut self, name: &str, preconditions: Vec<&str>, effects: Vec<&str>, effects_clear: Vec<&str>) {
        self.register(HTNTask::Primitive {
            name: name.to_string(),
            preconditions: preconditions.into_iter().map(|s| s.to_string()).collect(),
            effects: effects.into_iter().map(|s| s.to_string()).collect(),
            effects_clear: effects_clear.into_iter().map(|s| s.to_string()).collect(),
        });
    }

    /// Convenience: registers a compound task with a list of methods.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `methods` — `Vec<HTNMethod>`.
    pub fn add_compound(&mut self, name: &str, methods: Vec<HTNMethod>) {
        self.register(HTNTask::Compound {
            name: name.to_string(),
            methods,
        });
    }

    /// Looks up a task by name.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `Option<&HTNTask>`.
    pub fn get(&self, name: &str) -> Option<&HTNTask> {
        self.tasks.get(name)
    }

    /// Returns the number of registered tasks.
    ///
    /// # Returns
    /// `usize`.
    pub fn task_count(&self) -> usize {
        self.tasks.len()
    }
}

// ────────────────────────────────────────────────────────────────────────────
// HTNPlanner
// ────────────────────────────────────────────────────────────────────────────

/// Stateless HTN planner. Executes planning via recursive decomposition.
///
/// Planning is purely functional: it takes a domain, a root task name, and a
/// world-state snapshot; it returns a flat `Vec<String>` of primitive task names
/// (in execution order) or `None` if no valid plan was found.
///
/// The planner clones the world-state before each `Primitive` task to simulate
/// effects without modifying the caller's state. A depth limit of 128 prevents
/// infinite decomposition on cyclic compound tasks.
pub struct HTNPlanner;

impl HTNPlanner {
    /// Plans from `root_task` against `domain` and `initial_state`.
    ///
    /// Returns the sequence of primitive task names, or `None` if planning fails.
    ///
    /// # Parameters
    /// - `domain` — `&HTNDomain`.
    /// - `root_task` — `&str`.
    /// - `initial_state` — `&WorldState`.
    ///
    /// # Returns
    /// `Option<Vec<String>>`.
    pub fn plan(domain: &HTNDomain, root_task: &str, initial_state: &WorldState) -> Option<Vec<String>> {
        let mut plan = Vec::new();
        let mut state = initial_state.clone();
        let stack: Vec<String> = vec![root_task.to_string()];
        if Self::decompose(domain, stack, &mut state, &mut plan, 0) {
            Some(plan)
        } else {
            None
        }
    }

    /// Internal recursive decomposition. Returns `true` when the stack is fully resolved.
    fn decompose(
        domain: &HTNDomain,
        mut stack: Vec<String>,
        state: &mut WorldState,
        plan: &mut Vec<String>,
        depth: usize,
    ) -> bool {
        if depth > 128 { return false; }
        while let Some(task_name) = stack.last().cloned() {
            stack.pop();
            let task = match domain.get(&task_name) {
                Some(t) => t,
                None => return false, // Unknown task
            };

            match task {
                HTNTask::Primitive { .. } => {
                    if !task.preconditions_met(state) {
                        return false;
                    }
                    task.apply_effects(state);
                    plan.push(task.name().to_string());
                }
                HTNTask::Compound { methods, .. } => {
                    let applicable: &HTNMethod = methods.iter()
                        .find(|m| m.is_applicable(state))?;
                    // Push sub-tasks in reverse so the stack pops them left-to-right
                    let mut subtasks: Vec<String> = applicable.sub_tasks.clone();
                    subtasks.reverse();
                    stack.extend(subtasks);
                    // Recurse for the remaining stack
                    return Self::decompose(domain, stack, state, plan, depth + 1);
                }
            }
        }
        true
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample_domain() -> HTNDomain {
        let mut d = HTNDomain::new();
        d.add_task(HTNTask::Primitive {
            name: "eat".into(),
            preconditions: vec![("hungry".into(), true)],
            effects: vec![("hungry".into(), false)],
        });
        d.add_task(HTNTask::Compound {
            name: "satisfy_hunger".into(),
            methods: vec![HTNMethod {
                name: "use_eat".into(),
                conditions: vec![("hungry".into(), true)],
                sub_tasks: vec!["eat".into()],
            }],
        });
        d
    }

    #[test]
    fn decompose_single_primitive() {
        let d = sample_domain();
        let mut state = HashMap::new();
        state.insert("hungry".to_string(), true);
        let plan = HTNPlanner::plan(&d, "eat", &state);
        assert!(plan.is_some());
        assert_eq!(plan.unwrap(), vec!["eat"]);
    }

    #[test]
    fn decompose_compound_task() {
        let d = sample_domain();
        let mut state = HashMap::new();
        state.insert("hungry".to_string(), true);
        let plan = HTNPlanner::plan(&d, "satisfy_hunger", &state);
        assert!(plan.is_some());
        assert_eq!(plan.unwrap(), vec!["eat"]);
    }

    #[test]
    fn precondition_not_met_returns_none() {
        let d = sample_domain();
        let state = HashMap::new(); // hungry not set
        let plan = HTNPlanner::plan(&d, "eat", &state);
        assert!(plan.is_none());
    }
}
