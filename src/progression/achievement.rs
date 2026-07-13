//! Owns authored achievement definitions plus per-profile unlock state and queued reward records.
//! Exposes the store entrypoints that define achievements, unlock them, and query earned snapshots.
//! Tracks repeatable completions, hidden presentation flags, and counter-trigger reverse indexes.
//! Re-evaluates authored conditions before mutating profile records or emitting unlock-side events.
//! Keeps achievement lifecycle rules out of `store.rs` so shared mutation plumbing stays narrower.
//! Open this file when changing achievement authoring, unlock semantics, or reward-producing trophies.
use super::*;

impl ProgressionStore {
    /// Define one achievement and update reverse trigger indexes.
    pub fn define_achievement(
        &mut self,
        id: &str,
        definition: AchievementDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        if definition.id != id {
            return Err(ProgressionError::InvalidValue(format!(
                "achievement definition id '{}' must match '{}'",
                definition.id, id
            )));
        }
        if let Some(trigger) = &definition.counter_trigger {
            validate_id(&trigger.counter_id)?;
            ensure_finite(trigger.value, "achievement counter trigger value")?;
        }
        if let Some(condition) = &definition.condition {
            self.validate_condition_inner(condition, 0, &mut Vec::new())?;
        }

        if let Some(previous) = self
            .achievement_definitions
            .insert(id.to_string(), definition.clone())
        {
            if let Some(trigger) = previous.counter_trigger {
                if let Some(ids) = self.achievement_counter_index.get_mut(&trigger.counter_id) {
                    ids.retain(|candidate| candidate != id);
                    if ids.is_empty() {
                        self.achievement_counter_index.remove(&trigger.counter_id);
                    }
                }
            }
        }

        if let Some(trigger) = &definition.counter_trigger {
            let ids = self
                .achievement_counter_index
                .entry(trigger.counter_id.clone())
                .or_default();
            if !ids.iter().any(|candidate| candidate == id) {
                ids.push(id.to_string());
                ids.sort();
            }
        }
        Ok(())
    }

    /// Unlock one achievement manually.
    pub fn unlock_achievement(
        &mut self,
        profile_id: &str,
        achievement_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let definition = self
            .achievement_definitions
            .get(achievement_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "achievement",
                id: achievement_id.to_string(),
            })?;
        self.apply_achievement_unlock(profile_id, &definition)?;
        self.get_achievement(profile_id, achievement_id)
    }

    /// Return one achievement state snapshot for a profile.
    pub fn get_achievement(
        &self,
        profile_id: &str,
        achievement_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let definition = self
            .achievement_definitions
            .get(achievement_id)
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "achievement",
                id: achievement_id.to_string(),
            })?;
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let state = profile.achievements.get(achievement_id);
        Ok(json!({
            "id": achievement_id,
            "title": definition.title,
            "description": definition.description,
            "hidden": definition.hidden,
            "repeatable": definition.repeatable,
            "unlock_count": state.map(|entry| entry.unlock_count).unwrap_or(0),
            "unlocked": state.map(|entry| entry.unlocked).unwrap_or(false),
        }))
    }

    /// Return all touched achievement states for a profile in deterministic order.
    pub fn list_achievements(&self, profile_id: &str) -> Result<Vec<JsonValue>, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let mut ids = BTreeSet::new();
        ids.extend(profile.achievements.keys().cloned());
        ids.into_iter()
            .map(|achievement_id| self.get_achievement(profile_id, &achievement_id))
            .collect::<Result<Vec<_>, _>>()
    }

    /// Re-evaluate every achievement that listens to one counter.
    pub(crate) fn evaluate_counter_achievements(
        &mut self,
        profile_id: &str,
        counter_id: &str,
    ) -> Result<(), ProgressionError> {
        let Some(achievement_ids) = self.achievement_counter_index.get(counter_id).cloned() else {
            return Ok(());
        };
        let counter_value = self.get_counter(profile_id, counter_id)?;
        for achievement_id in achievement_ids {
            let Some(definition) = self.achievement_definitions.get(&achievement_id).cloned()
            else {
                continue;
            };
            let Some(trigger) = &definition.counter_trigger else {
                continue;
            };
            if compare_f64(counter_value, trigger.op, trigger.value) {
                self.apply_achievement_unlock(profile_id, &definition)?;
            }
        }
        Ok(())
    }

    /// Apply one unlock, queue any reward payload, and emit the canonical events.
    pub(crate) fn apply_achievement_unlock(
        &mut self,
        profile_id: &str,
        definition: &AchievementDefinition,
    ) -> Result<(), ProgressionError> {
        if let Some(condition) = &definition.condition {
            if !self.evaluate_condition(profile_id, condition)? {
                return Ok(());
            }
        }
        let (unlock_count, reward_record) = {
            let profile = self.profile_mut(profile_id)?;
            let state =
                profile
                    .achievements
                    .entry(definition.id.clone())
                    .or_insert(AchievementState {
                        unlock_count: 0,
                        unlocked: false,
                    });
            if state.unlocked && !definition.repeatable {
                return Ok(());
            }
            state.unlock_count += 1;
            state.unlocked = true;
            let reward_record = definition.reward_payload.as_ref().map(|payload| {
                let reward_id = format!("achievement:{}:{}", definition.id, state.unlock_count);
                let record = RewardRecord {
                    id: reward_id.clone(),
                    source_kind: "achievement".to_string(),
                    source_id: definition.id.clone(),
                    payload: payload.clone(),
                    state: RewardState::Pending,
                    external_receipt: None,
                };
                profile.rewards.insert(reward_id, record.clone());
                record
            });
            (state.unlock_count, reward_record)
        };
        self.bump_revision();
        self.push_event(
            "achievement_unlocked",
            Some(profile_id.to_string()),
            Some(definition.id.clone()),
            json!({ "achievementId": definition.id, "unlockCount": unlock_count }),
        );
        if let Some(reward) = reward_record {
            self.push_event(
                "reward_available",
                Some(profile_id.to_string()),
                Some(reward.id.clone()),
                json!({
                    "rewardId": reward.id,
                    "sourceKind": reward.source_kind,
                    "sourceId": reward.source_id,
                }),
            );
        }
        self.sync_collections_for_achievement(profile_id, &definition.id)?;
        self.refresh_quest_lifecycle(profile_id)?;
        Ok(())
    }
}
