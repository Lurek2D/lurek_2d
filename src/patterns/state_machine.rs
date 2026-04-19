//! Finite-state machine graph and transition logic without Lua coupling.
//!
//! [`StateMachine`] stores state names, transition guards (as string
//! conditions), and history.  Enter/exit/update Lua callbacks are stored
//! in the API layer.

use std::collections::HashMap;

// ── TransitionRule ────────────────────────────────────────────────────────

/// A permitted transition between two states.
///
/// # Fields
/// - `from` — `String`.
/// - `to` — `String`.
/// - `label` — `String`.
/// - `has_guard` — `bool`.
#[derive(Debug, Clone)]
pub struct TransitionRule {
    /// Source state name.
    pub from: String,
    /// Target state name.
    pub to: String,
    /// Human-readable label or trigger name.
    pub label: String,
    /// Whether a Lua guard callback is registered for this transition.
    pub has_guard: bool,
}

// ── StateMachine ──────────────────────────────────────────────────────────

/// Finite-state machine with history stack and transition validation.
///
/// # Fields
/// - `current` — `String`.
/// - `previous` — `Option<String>`.
/// - `history_cap` — `usize`.
#[derive(Debug)]
pub struct StateMachine {
    /// Name of the currently active state.
    pub current: String,
    /// Previously active state (None if no transition has occurred).
    pub previous: Option<String>,
    /// Maximum entries in the state visit history.
    pub history_cap: usize,
    /// All registered state names.
    states: HashMap<String, StateInfo>,
    /// Allowed transitions.
    transitions: Vec<TransitionRule>,
    /// History of visited state names (oldest first).
    history: Vec<String>,
}

#[derive(Debug, Default)]
struct StateInfo {
    /// Whether state has an enter callback registered.
    #[allow(dead_code)]
    has_enter: bool,
    /// Whether state has an exit callback registered.
    #[allow(dead_code)]
    has_exit: bool,
    has_update: bool,
}

impl StateMachine {
    /// Creates a new state machine with the given initial state.
    ///
    /// # Parameters
    /// - `initial` — `&str`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(initial: &str) -> Self {
        let mut states = HashMap::new();
        states.insert(initial.to_string(), StateInfo::default());
        Self {
            current: initial.to_string(),
            previous: None,
            history_cap: 100,
            states,
            transitions: Vec::new(),
            history: vec![initial.to_string()],
        }
    }

    /// Registers a state, optionally marking callback presence.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `has_enter` — `bool`.
    /// - `has_exit` — `bool`.
    /// - `has_update` — `bool`.
    pub fn add_state(&mut self, name: &str, has_enter: bool, has_exit: bool, has_update: bool) {
        self.states.insert(name.to_string(), StateInfo { has_enter, has_exit, has_update });
    }

    /// Whether a state is registered.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn has_state(&self, name: &str) -> bool {
        self.states.contains_key(name)
    }

    /// Returns all registered state names.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn state_names(&self) -> Vec<&str> {
        let mut names: Vec<&str> = self.states.keys().map(String::as_str).collect();
        names.sort();
        names
    }

    /// Registers an allowed transition.
    ///
    /// # Parameters
    /// - `from` — `&str`.
    /// - `to` — `&str`.
    /// - `label` — `&str`.
    /// - `has_guard` — `bool`.
    pub fn add_transition(&mut self, from: &str, to: &str, label: &str, has_guard: bool) {
        self.transitions.push(TransitionRule {
            from: from.to_string(),
            to: to.to_string(),
            label: label.to_string(),
            has_guard,
        });
    }

    /// Whether a direct transition from `from` to `to` is defined.
    ///
    /// # Parameters
    /// - `from` — `&str`.
    /// - `to` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn can_transition(&self, from: &str, to: &str) -> bool {
        self.transitions.iter().any(|t| t.from == from && t.to == to)
            || self.transitions.is_empty() // No transition rules = free FSM
    }

    /// Returns the `TransitionRule` for `from → to`, if defined.
    ///
    /// # Parameters
    /// - `from` — `&str`.
    /// - `to` — `&str`.
    ///
    /// # Returns
    /// `Option<&TransitionRule>`.
    pub fn get_transition<'a>(&'a self, from: &str, to: &str) -> Option<&'a TransitionRule> {
        self.transitions.iter().find(|t| t.from == from && t.to == to)
    }

    /// Advances to a new state and records history.  Does NOT fire Lua callbacks —
    /// that is the API layer's responsibility.  Returns `false` if the transition
    /// is not allowed.
    ///
    /// # Parameters
    /// - `to` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn transition_to(&mut self, to: &str) -> bool {
        if !self.can_transition(&self.current.clone(), to) {
            return false;
        }
        let prev = self.current.clone();
        self.current = to.to_string();
        self.previous = Some(prev.clone());
        // Ensure target state is registered
        self.states.entry(to.to_string()).or_default();
        self.history.push(to.to_string());
        if self.history.len() > self.history_cap {
            self.history.remove(0);
        }
        true
    }

    /// Returns the state visit history (oldest first).
    ///
    /// # Returns
    /// `&[String]`.
    pub fn history(&self) -> &[String] {
        &self.history
    }

    /// Returns reachable state names from the given state.
    ///
    /// # Parameters
    /// - `from` — `&str`.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn reachable_from<'a>(&'a self, from: &str) -> Vec<&'a str> {
        self.transitions.iter()
            .filter(|t| t.from == from)
            .map(|t| t.to.as_str())
            .collect()
    }

    /// Whether the given state has an update callback.
    ///
    /// # Parameters
    /// - `state` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn has_update_callback(&self, state: &str) -> bool {
        self.states.get(state).map(|s| s.has_update).unwrap_or(false)
    }
}

// Tests migrated to tests/rust/unit/patterns_tests.rs
