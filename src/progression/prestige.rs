//! Owns prestige definitions, reset application, preserved-history rules, and prestige snapshot serialization.
//! Stores the contracts that decide when a profile may prestige and which counters or tracks survive the reset.
//! Exposes public store helpers for authoring prestiges, checking eligibility, applying resets, and querying state.
//! Validates prestige definitions against authored counters, level tracks, and preserved-history configuration.
//! Integrates with achievements, counters, and experience without coupling prestige rules to UI or narrative flow.
//! Open this file when changing rebirth semantics, retained history, or level-gated reset progression behavior.
use super::*;

impl ProgressionStore {
    /// Define one prestige/rebirth path.
    pub fn define_prestige(
        &mut self,
        id: &str,
        definition: PrestigeDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        self.validate_prestige_definition(id, &definition)?;
        self.prestige_definitions.insert(id.to_string(), definition);
        Ok(())
    }

    /// Return whether one profile currently satisfies a prestige condition.
    pub fn can_prestige(
        &self,
        profile_id: &str,
        prestige_id: &str,
    ) -> Result<bool, ProgressionError> {
        let definition = self.prestige_definitions.get(prestige_id).ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "prestige",
                id: prestige_id.to_string(),
            }
        })?;
        self.evaluate_condition(profile_id, &definition.condition)
    }

    /// Apply one prestige reset to a profile and return its updated prestige state.
    pub fn apply_prestige(
        &mut self,
        profile_id: &str,
        prestige_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let definition = self
            .prestige_definitions
            .get(prestige_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "prestige",
                id: prestige_id.to_string(),
            })?;
        if !self.evaluate_condition(profile_id, &definition.condition)? {
            return Err(ProgressionError::InvalidOperation(format!(
                "profile '{}' does not satisfy prestige '{}'",
                profile_id, prestige_id
            )));
        }
        let revision = self.next_revision();
        self.revision = revision;
        let time = self.time;
        let lifetime_snapshot = self.collect_prestige_lifetime_counters(
            profile_id,
            &definition.reset,
            &definition.preserve,
        )?;
        if !definition.preserve.achievements {
            let profile = self.profile_mut(profile_id)?;
            profile.achievements.clear();
        }
        self.apply_prestige_reset(profile_id, &definition.reset)?;
        {
            let profile = self.profile_mut(profile_id)?;
            let state =
                profile
                    .prestiges
                    .entry(prestige_id.to_string())
                    .or_insert(PrestigeProfileState {
                        count: 0,
                        last_applied_at: None,
                        last_applied_revision: None,
                        lifetime_counters: BTreeMap::new(),
                    });
            state.count += 1;
            state.last_applied_at = Some(time);
            state.last_applied_revision = Some(revision);
            for (counter_id, value) in lifetime_snapshot {
                *state.lifetime_counters.entry(counter_id).or_insert(0.0) += value;
            }
        }
        self.refresh_quest_lifecycle(profile_id)?;
        self.push_event(
            "prestige_applied",
            Some(profile_id.to_string()),
            Some(prestige_id.to_string()),
            json!({
                "prestigeId": prestige_id,
                "profileId": profile_id,
                "preservedAchievements": definition.preserve.achievements,
                "preservedLifetimeCounters": definition.preserve.lifetime_counters,
            }),
        );
        self.get_prestige(profile_id, prestige_id)
    }

    /// Return one profile's state for a named prestige path.
    pub fn get_prestige(
        &self,
        profile_id: &str,
        prestige_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        self.profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let definition = self.prestige_definitions.get(prestige_id).ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "prestige",
                id: prestige_id.to_string(),
            }
        })?;
        let state = self
            .profiles
            .get(profile_id)
            .and_then(|profile| profile.prestiges.get(prestige_id))
            .cloned();
        self.prestige_json(profile_id, definition, prestige_id, state.as_ref())
    }

    /// Return all authored prestiges for one profile in deterministic id order.
    pub fn list_prestiges(&self, profile_id: &str) -> Result<Vec<JsonValue>, ProgressionError> {
        self.profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        self.prestige_definitions
            .iter()
            .map(|(prestige_id, definition)| {
                let state = self
                    .profiles
                    .get(profile_id)
                    .and_then(|profile| profile.prestiges.get(prestige_id));
                self.prestige_json(profile_id, definition, prestige_id, state)
            })
            .collect()
    }

    /// Validate that a prestige definition references existing counters, tracks, and preserved-state options.
    pub(crate) fn validate_prestige_definition(
        &self,
        id: &str,
        definition: &PrestigeDefinition,
    ) -> Result<(), ProgressionError> {
        if definition.id != id {
            return Err(ProgressionError::InvalidValue(format!(
                "prestige definition id '{}' must match '{}'",
                definition.id, id
            )));
        }
        self.validate_condition_inner(&definition.condition, 0, &mut Vec::new())?;
        if !self.options.strict {
            return Ok(());
        }
        for track_id in &definition.reset.level_tracks {
            if !self.level_track_definitions.contains_key(track_id) {
                return Err(ProgressionError::MissingDefinition {
                    kind: "level_track",
                    id: track_id.clone(),
                });
            }
        }
        for counter_id in &definition.reset.counters {
            if !self.counter_definitions.contains_key(counter_id) {
                return Err(ProgressionError::MissingDefinition {
                    kind: "counter",
                    id: counter_id.clone(),
                });
            }
        }
        Ok(())
    }

    fn collect_prestige_lifetime_counters(
        &self,
        profile_id: &str,
        reset: &PrestigeResetDefinition,
        preserve: &PrestigePreserveDefinition,
    ) -> Result<BTreeMap<String, f64>, ProgressionError> {
        if !preserve.lifetime_counters {
            return Ok(BTreeMap::new());
        }
        let mut counters = BTreeMap::new();
        for counter_id in &reset.counters {
            counters.insert(
                counter_id.clone(),
                self.get_counter(profile_id, counter_id)?,
            );
        }
        Ok(counters)
    }

    fn apply_prestige_reset(
        &mut self,
        profile_id: &str,
        reset: &PrestigeResetDefinition,
    ) -> Result<(), ProgressionError> {
        let level_tracks = reset.level_tracks.iter().cloned().collect::<BTreeSet<_>>();
        let counters = reset.counters.iter().cloned().collect::<BTreeSet<_>>();

        for track_id in level_tracks {
            let definition = self
                .level_track_definitions
                .get(&track_id)
                .cloned()
                .ok_or_else(|| ProgressionError::MissingDefinition {
                    kind: "level_track",
                    id: track_id.clone(),
                })?;
            let previous = self.get_experience(profile_id, &track_id)?;
            if let Some(profile) = self.profiles.get_mut(profile_id) {
                profile.levels.insert(
                    track_id.clone(),
                    LevelState {
                        experience: 0.0,
                        level: definition.initial_level,
                    },
                );
            }
            self.push_event(
                "prestige_level_track_reset",
                Some(profile_id.to_string()),
                Some(track_id.clone()),
                json!({
                    "trackId": track_id,
                    "oldLevel": previous["level"],
                    "oldExperience": previous["experience"],
                    "newLevel": definition.initial_level,
                    "newExperience": 0.0,
                }),
            );
        }

        for counter_id in counters {
            let definition = self
                .counter_definitions
                .get(&counter_id)
                .cloned()
                .ok_or_else(|| ProgressionError::MissingDefinition {
                    kind: "counter",
                    id: counter_id.clone(),
                })?;
            let old = self.get_counter(profile_id, &counter_id)?;
            let next = sanitize_counter_value(&definition, definition.initial)?;
            if let Some(profile) = self.profiles.get_mut(profile_id) {
                profile
                    .counters
                    .insert(counter_id.clone(), CounterState { value: next });
            }
            self.push_event(
                "prestige_counter_reset",
                Some(profile_id.to_string()),
                Some(counter_id.clone()),
                json!({ "counterId": counter_id, "old": old, "new": next }),
            );
            self.evaluate_counter_quests(profile_id, &counter_id)?;
            self.evaluate_counter_challenges(profile_id, &counter_id)?;
            self.evaluate_counter_achievements(profile_id, &counter_id)?;
            self.sync_counter_bound_leaderboards_silent(profile_id, &counter_id);
        }

        Ok(())
    }

    fn prestige_json(
        &self,
        profile_id: &str,
        definition: &PrestigeDefinition,
        prestige_id: &str,
        state: Option<&PrestigeProfileState>,
    ) -> Result<JsonValue, ProgressionError> {
        let available = self.evaluate_condition(profile_id, &definition.condition)?;
        Ok(json!({
            "id": prestige_id,
            "available": available,
            "count": state.map(|entry| entry.count).unwrap_or(0),
            "last_applied_at": state.and_then(|entry| entry.last_applied_at),
            "last_applied_revision": state.and_then(|entry| entry.last_applied_revision),
            "lifetime_counters": state.map(|entry| entry.lifetime_counters.clone()).unwrap_or_default(),
            "reset": {
                "level_tracks": &definition.reset.level_tracks,
                "counters": &definition.reset.counters,
            },
            "preserve": {
                "achievements": definition.preserve.achievements,
                "lifetime_counters": definition.preserve.lifetime_counters,
            },
            "condition": serde_json::to_value(&definition.condition).unwrap_or(JsonValue::Null),
        }))
    }
}
