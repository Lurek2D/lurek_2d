//! This file owns tabular Q-learning state, including the flat Q-table, exploration rate, and episode counters.
//! `QLearner` keeps discrete state-action values in one row-major table so updates and greedy lookups stay cheap.
//! Epsilon-greedy action choice, deterministic RNG state, and Bellman updates live here because they directly mutate learner-owned state.
//! Serialization and deserialization also stay here so saved tables preserve dimensions, hyperparameters, and RNG state on reload.
//! Open it when discrete RL policy changes; bandits, environments, and neural optimizers are owned by sibling files.

use crate::learning::{
    error::LearningError,
    limits::{
        checked_product2, validate_finite, validate_non_zero_count, validate_range, LearningLimits,
    },
    rng::{LearningRng, LearningRngSnapshot, LEARNING_RNG_VERSION},
};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
struct QLearnerEnvelope {
    version: u32,
    state_count: usize,
    action_count: usize,
    qtable: Vec<Vec<f64>>,
    alpha: f64,
    gamma: f64,
    epsilon: f64,
    epsilon_decay: f64,
    episode_count: u64,
    rng_state: u64,
}

/// Q-learning agent with a flat `state × action` value table.
pub struct QLearner {
    /// Total number of discrete states.
    pub(crate) state_count: usize,
    /// Total number of discrete actions per state.
    pub(crate) action_count: usize,
    /// Flat Q-table of size `state_count × action_count`, row-major.
    pub(crate) qtable: Vec<f64>,
    /// Learning rate α in `[0, 1]`; default 0.1.
    pub(crate) alpha: f64,
    /// Discount factor γ in `[0, 1]`; default 0.9.
    pub(crate) gamma: f64,
    /// Exploration probability; action chosen randomly when `rand < epsilon`.
    pub epsilon: f64,
    /// Multiplicative decay applied to `epsilon` at the end of each episode.
    pub(crate) epsilon_decay: f64,
    /// Number of episodes completed since creation.
    pub episode_count: u64,
    /// Deterministic RNG used by epsilon-greedy exploration.
    rng: LearningRng,
}

impl QLearner {
    /// Create a zeroed Q-table for `state_count` states and `action_count` actions.
    pub fn new(state_count: usize, action_count: usize) -> Self {
        Self::new_with_seed(state_count, action_count, 0)
    }

    /// Create a zeroed Q-table with an explicit deterministic RNG seed.
    pub fn new_with_seed(state_count: usize, action_count: usize, seed: u64) -> Self {
        Self::try_new_with_seed(state_count, action_count, seed)
            .expect("QLearner::new_with_seed received invalid dimensions")
    }

    /// Create a zeroed Q-table after validating dimensions and allocation limits.
    pub fn try_new(state_count: usize, action_count: usize) -> Result<Self, LearningError> {
        Self::try_new_with_seed(state_count, action_count, 0)
    }

    /// Create a zeroed Q-table with an explicit deterministic seed after validation.
    pub fn try_new_with_seed(
        state_count: usize,
        action_count: usize,
        seed: u64,
    ) -> Result<Self, LearningError> {
        validate_non_zero_count("Q-learner state_count", state_count)?;
        validate_non_zero_count("Q-learner action_count", action_count)?;
        let limits = LearningLimits::default();
        let qtable_len = checked_product2(
            state_count,
            action_count,
            "Q-table cells",
            limits.max_qtable_cells,
        )?;
        let learner = Self {
            state_count,
            action_count,
            qtable: vec![0.0; qtable_len],
            alpha: 0.1,
            gamma: 0.9,
            epsilon: 0.1,
            epsilon_decay: 0.995,
            episode_count: 0,
            rng: LearningRng::new(seed),
        };
        learner.validate_hyperparams()?;
        Ok(learner)
    }

    /// Return a randomly chosen action (explore) or the greedy best action (exploit).
    pub fn choose_action(&mut self, state: usize) -> usize {
        self.try_choose_action(state).unwrap_or(0)
    }

    /// Return a randomly chosen action (explore) or the greedy best action (exploit).
    pub fn try_choose_action(&mut self, state: usize) -> Result<usize, LearningError> {
        self.validate_hyperparams()?;
        self.validate_state_index(state)?;
        if self.rng.next_f64() < self.epsilon {
            self.rng.next_index(self.action_count)
        } else {
            self.try_best_action(state)
        }
    }

    /// Return the action with the highest Q-value for `state`; ties broken by index.
    pub fn best_action(&self, state: usize) -> usize {
        self.try_best_action(state).unwrap_or(0)
    }

    /// Return the action with the highest Q-value for `state`; ties broken by index.
    pub fn try_best_action(&self, state: usize) -> Result<usize, LearningError> {
        self.validate_state_index(state)?;
        if self.action_count == 0 {
            return Err(LearningError::ZeroCount {
                field: "Q-learner action_count",
            });
        }
        let base = state * self.action_count;
        let mut best_idx = 0;
        let mut best_val = f64::NEG_INFINITY;
        for a in 0..self.action_count {
            let val = self.qtable[base + a];
            validate_finite("Q-value", val)?;
            if val > best_val {
                best_val = val;
                best_idx = a;
            }
        }
        Ok(best_idx)
    }

    /// Apply a Bellman update: `Q[s,a] ← Q[s,a] + α(r + γ·max Q[s'] − Q[s,a])`.
    pub fn learn(&mut self, state: usize, action: usize, reward: f64, next_state: usize) {
        let _ = self.try_learn(state, action, reward, next_state);
    }

    /// Apply a Bellman update after validating indices, reward, and hyperparameters.
    pub fn try_learn(
        &mut self,
        state: usize,
        action: usize,
        reward: f64,
        next_state: usize,
    ) -> Result<(), LearningError> {
        self.validate_hyperparams()?;
        self.validate_state_index(state)?;
        self.validate_action_index(action)?;
        self.validate_state_index(next_state)?;
        validate_finite("Q-learner reward", reward)?;
        let idx = state * self.action_count + action;
        let max_next = self.try_max_q(next_state)?;
        let old = self.qtable[idx];
        self.qtable[idx] = old + self.alpha * (reward + self.gamma * max_next - old);
        validate_finite("Q-table cell", self.qtable[idx])?;
        Ok(())
    }

    /// Decay epsilon and increment `episode_count`; call once at the end of each episode.
    pub fn end_episode(&mut self) {
        let _ = self.try_end_episode();
    }

    /// Decay epsilon and increment `episode_count` after validating hyperparameters.
    pub fn try_end_episode(&mut self) -> Result<(), LearningError> {
        self.validate_hyperparams()?;
        self.epsilon *= self.epsilon_decay;
        validate_finite("Q-learner epsilon", self.epsilon)?;
        self.episode_count += 1;
        Ok(())
    }

    /// Return Q[state, action]; returns 0.0 if indices are out of bounds.
    pub fn get_q(&self, state: usize, action: usize) -> f64 {
        if state >= self.state_count || action >= self.action_count {
            return 0.0;
        }
        self.qtable[state * self.action_count + action]
    }

    /// Set Q[state, action] to `value`; no-op if indices are out of bounds.
    pub fn set_q(&mut self, state: usize, action: usize, value: f64) {
        let _ = self.try_set_q(state, action, value);
    }

    /// Set Q[state, action] to `value` after validating indices and finite numeric policy.
    pub fn try_set_q(
        &mut self,
        state: usize,
        action: usize,
        value: f64,
    ) -> Result<(), LearningError> {
        self.validate_state_index(state)?;
        self.validate_action_index(action)?;
        validate_finite("Q-table cell", value)?;
        self.qtable[state * self.action_count + action] = value;
        Ok(())
    }

    /// Return the current exact RNG snapshot for reproducible replay.
    pub fn rng_snapshot(&self) -> LearningRngSnapshot {
        self.rng.snapshot()
    }

    /// Restore the internal exploration RNG from an exact saved snapshot.
    pub fn restore_rng_snapshot(
        &mut self,
        snapshot: LearningRngSnapshot,
    ) -> Result<(), LearningError> {
        self.rng.restore(snapshot)
    }

    /// Validate hyperparameter ranges and numeric policy.
    pub fn validate_hyperparams(&self) -> Result<(), LearningError> {
        validate_range("Q-learner alpha", self.alpha, 0.0, 1.0)?;
        validate_range("Q-learner gamma", self.gamma, 0.0, 1.0)?;
        validate_range("Q-learner epsilon", self.epsilon, 0.0, 1.0)?;
        validate_range("Q-learner epsilon_decay", self.epsilon_decay, 0.0, 1.0)?;
        Ok(())
    }

    /// Serialize the learner to a versioned JSON envelope.
    pub fn serialize(&self) -> String {
        let qtable: Vec<Vec<f64>> = self
            .qtable
            .chunks(self.action_count.max(1))
            .map(|row| row.to_vec())
            .collect();
        let envelope = QLearnerEnvelope {
            version: LEARNING_RNG_VERSION,
            state_count: self.state_count,
            action_count: self.action_count,
            qtable,
            alpha: self.alpha,
            gamma: self.gamma,
            epsilon: self.epsilon,
            epsilon_decay: self.epsilon_decay,
            episode_count: self.episode_count,
            rng_state: self.rng_snapshot().state,
        };
        serde_json::to_string(&envelope)
            .unwrap_or_else(|_| "{\"version\":1,\"qtable\":[]}".to_string())
    }

    /// Parse a JSON Q-table string and overwrite the current learner state.
    pub fn deserialize(&mut self, json: &str) -> Result<(), String> {
        self.try_deserialize(json).map_err(|e| e.to_string())
    }

    /// Parse a JSON Q-table string and overwrite the current learner state.
    pub fn try_deserialize(&mut self, json: &str) -> Result<(), LearningError> {
        let value = serde_json::from_str::<serde_json::Value>(json).map_err(|_| {
            LearningError::InvalidLength {
                context: "Q-learner JSON",
                expected: 1,
                actual: 0,
            }
        })?;
        if value.is_array() {
            let rows = serde_json::from_value::<Vec<Vec<f64>>>(value).map_err(|_| {
                LearningError::InvalidLength {
                    context: "Q-learner legacy JSON rows",
                    expected: self.state_count,
                    actual: 0,
                }
            })?;
            self.apply_rows(rows)?;
            return Ok(());
        }
        let envelope = serde_json::from_str::<QLearnerEnvelope>(json).map_err(|_| {
            LearningError::InvalidLength {
                context: "Q-learner envelope",
                expected: 1,
                actual: 0,
            }
        })?;
        if envelope.version != LEARNING_RNG_VERSION {
            return Err(LearningError::UnsupportedVersion {
                context: "Q-learner envelope",
                version: envelope.version,
            });
        }
        if envelope.state_count != self.state_count {
            return Err(LearningError::InvalidLength {
                context: "Q-learner state count",
                expected: self.state_count,
                actual: envelope.state_count,
            });
        }
        if envelope.action_count != self.action_count {
            return Err(LearningError::InvalidLength {
                context: "Q-learner action count",
                expected: self.action_count,
                actual: envelope.action_count,
            });
        }
        self.alpha = envelope.alpha;
        self.gamma = envelope.gamma;
        self.epsilon = envelope.epsilon;
        self.epsilon_decay = envelope.epsilon_decay;
        self.episode_count = envelope.episode_count;
        self.validate_hyperparams()?;
        self.rng.restore(LearningRngSnapshot {
            version: envelope.version,
            state: envelope.rng_state,
        })?;
        self.apply_rows(envelope.qtable)
    }

    fn apply_rows(&mut self, rows: Vec<Vec<f64>>) -> Result<(), LearningError> {
        if rows.len() != self.state_count {
            return Err(LearningError::InvalidLength {
                context: "Q-learner state rows",
                expected: self.state_count,
                actual: rows.len(),
            });
        }
        for (state, row) in rows.iter().enumerate() {
            if row.len() != self.action_count {
                return Err(LearningError::InvalidLength {
                    context: "Q-learner action row",
                    expected: self.action_count,
                    actual: row.len(),
                });
            }
            let base = state * self.action_count;
            for (action, &value) in row.iter().enumerate() {
                validate_finite("Q-table cell", value)?;
                self.qtable[base + action] = value;
            }
        }
        Ok(())
    }

    fn validate_state_index(&self, state: usize) -> Result<(), LearningError> {
        if state >= self.state_count {
            return Err(LearningError::IndexOutOfBounds {
                context: "Q-learner state",
                index: state,
                len: self.state_count,
            });
        }
        Ok(())
    }

    fn validate_action_index(&self, action: usize) -> Result<(), LearningError> {
        if action >= self.action_count {
            return Err(LearningError::IndexOutOfBounds {
                context: "Q-learner action",
                index: action,
                len: self.action_count,
            });
        }
        Ok(())
    }

    fn try_max_q(&self, state: usize) -> Result<f64, LearningError> {
        self.validate_state_index(state)?;
        if self.action_count == 0 {
            return Err(LearningError::ZeroCount {
                field: "Q-learner action_count",
            });
        }
        let base = state * self.action_count;
        let mut max_val = f64::NEG_INFINITY;
        for a in 0..self.action_count {
            let val = self.qtable[base + a];
            validate_finite("Q-value", val)?;
            if val > max_val {
                max_val = val;
            }
        }
        Ok(max_val)
    }
}
