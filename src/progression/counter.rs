//! Owns counter definitions, per-profile counter state, and threshold-aware mutation semantics.
//! Exposes canonical helpers that define, add, set, list, and snapshot counters across the engine.
//! Applies finite checks, monotonic rules, bounds, and value normalization before state persists.
//! Refreshes quests, leaderboards, challenges, and achievements after writes so flow stays in sync.
//! Keeps shared counter behavior out of store-wide plumbing so progression inputs stay cohesive.
use super::*;

impl ProgressionStore {
    /// Define one counter.
    pub fn define_counter(
        &mut self,
        id: &str,
        definition: CounterDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        self.counter_definitions.insert(id.to_string(), definition);
        Ok(())
    }

    /// Add `amount` to one counter.
    pub fn add_counter(
        &mut self,
        profile_id: &str,
        counter_id: &str,
        amount: f64,
    ) -> Result<f64, ProgressionError> {
        ensure_finite(amount, "counter amount")?;
        let revision = self.next_revision();
        let threshold_payload = {
            let definition = self
                .counter_definitions
                .get(counter_id)
                .cloned()
                .ok_or_else(|| ProgressionError::MissingDefinition {
                    kind: "counter",
                    id: counter_id.to_string(),
                })?;
            let profile = self.profile_mut(profile_id)?;
            let state = profile
                .counters
                .entry(counter_id.to_string())
                .or_insert(CounterState {
                    value: definition.initial,
                });
            let old = state.value;
            let mut next = state.value + amount;
            if definition.monotonic && next < old {
                return Err(ProgressionError::InvalidOperation(format!(
                    "counter '{}' is monotonic",
                    counter_id
                )));
            }
            next = sanitize_counter_value(&definition, next)?;
            state.value = next;
            Some((old, next, definition.thresholds))
        };
        self.revision = revision;
        if let Some((old, next, thresholds)) = threshold_payload {
            self.push_event(
                "counter_changed",
                Some(profile_id.to_string()),
                Some(counter_id.to_string()),
                json!({ "old": old, "new": next }),
            );
            for threshold in thresholds {
                if old < threshold && next >= threshold {
                    self.push_event(
                        "counter_threshold_entered",
                        Some(profile_id.to_string()),
                        Some(counter_id.to_string()),
                        json!({ "threshold": threshold, "value": next }),
                    );
                }
            }
            self.refresh_quest_lifecycle(profile_id)?;
            self.refresh_counter_leaderboards(profile_id, counter_id)?;
            self.evaluate_counter_quests(profile_id, counter_id)?;
            self.evaluate_counter_challenges(profile_id, counter_id)?;
            self.evaluate_counter_achievements(profile_id, counter_id)?;
            Ok(next)
        } else {
            unreachable!()
        }
    }

    /// Set one counter directly.
    pub fn set_counter(
        &mut self,
        profile_id: &str,
        counter_id: &str,
        value: f64,
    ) -> Result<f64, ProgressionError> {
        let definition = self
            .counter_definitions
            .get(counter_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "counter",
                id: counter_id.to_string(),
            })?;
        let next = sanitize_counter_value(&definition, value)?;
        let old = {
            let profile = self.profile_mut(profile_id)?;
            let state = profile
                .counters
                .entry(counter_id.to_string())
                .or_insert(CounterState {
                    value: definition.initial,
                });
            let old = state.value;
            if definition.monotonic && next < old {
                return Err(ProgressionError::InvalidOperation(format!(
                    "counter '{}' is monotonic",
                    counter_id
                )));
            }
            state.value = next;
            old
        };
        self.bump_revision();
        self.push_event(
            "counter_changed",
            Some(profile_id.to_string()),
            Some(counter_id.to_string()),
            json!({ "old": old, "new": next }),
        );
        self.refresh_quest_lifecycle(profile_id)?;
        self.refresh_counter_leaderboards(profile_id, counter_id)?;
        self.evaluate_counter_quests(profile_id, counter_id)?;
        self.evaluate_counter_challenges(profile_id, counter_id)?;
        self.evaluate_counter_achievements(profile_id, counter_id)?;
        Ok(next)
    }

    /// Return one counter value.
    pub fn get_counter(&self, profile_id: &str, counter_id: &str) -> Result<f64, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        if let Some(state) = profile.counters.get(counter_id) {
            return Ok(state.value);
        }
        let definition = self.counter_definitions.get(counter_id).ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "counter",
                id: counter_id.to_string(),
            }
        })?;
        Ok(definition.initial)
    }

    /// Return one counter snapshot.
    pub fn get_counter_state(
        &self,
        profile_id: &str,
        counter_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        Ok(json!({
            "id": counter_id,
            "value": self.get_counter(profile_id, counter_id)?,
        }))
    }

    /// Return all touched counter states for the profile.
    pub fn list_counters(&self, profile_id: &str) -> Result<Vec<JsonValue>, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        Ok(profile
            .counters
            .iter()
            .map(|(id, state)| json!({ "id": id, "value": state.value }))
            .collect())
    }
}
