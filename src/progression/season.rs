//! Owns authored seasons, archive snapshots, reset application, and season lifecycle serialization helpers.
//! Stores season definitions, active windows, archive outputs, and reset targets for counters and leaderboards.
//! Exposes public store helpers for defining seasons, starting runs, ending runs, and querying archives or status.
//! Validates season definitions against existing counters and leaderboards before any runtime lifecycle changes.
//! Applies configured resets and archive snapshots against logical time so offline tests can prove exact behavior.
//! Integrates with leaderboards and counters without coupling season rules to rewards, UI, or external services.
//! Open this file when changing season boundaries, archive contents, or reset semantics for cyclical progression.
use super::*;

impl ProgressionStore {
    /// Define one season lifecycle and its rollover targets.
    pub fn define_season(
        &mut self,
        id: &str,
        definition: SeasonDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        self.validate_season_definition(id, &definition)?;
        self.season_definitions.insert(id.to_string(), definition);
        self.season_states
            .entry(id.to_string())
            .or_insert(SeasonState {
                id: id.to_string(),
                active: false,
                started_at: None,
                ended_at: None,
                archive_count: 0,
            });
        Ok(())
    }

    /// Start one authored season at the current logical time or an explicit override.
    pub fn start_season(
        &mut self,
        id: &str,
        time_override: Option<f64>,
    ) -> Result<JsonValue, ProgressionError> {
        let definition = self.season_definitions.get(id).cloned().ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "season",
                id: id.to_string(),
            }
        })?;
        let started_at = match time_override {
            Some(value) => {
                ensure_finite(value, "season start time")?;
                value.max(0.0)
            }
            None => self.time.max(definition.starts_at),
        };
        {
            let state = self
                .season_states
                .entry(id.to_string())
                .or_insert(SeasonState {
                    id: id.to_string(),
                    active: false,
                    started_at: None,
                    ended_at: None,
                    archive_count: 0,
                });
            if state.active {
                return Err(ProgressionError::InvalidOperation(format!(
                    "season '{}' is already active",
                    id
                )));
            }
            state.active = true;
            state.started_at = Some(started_at);
            state.ended_at = None;
        }
        self.bump_revision();
        self.push_event(
            "season_started",
            None,
            Some(id.to_string()),
            json!({
                "seasonId": id,
                "startedAt": started_at,
                "scheduledStart": definition.starts_at,
                "scheduledEnd": definition.ends_at,
            }),
        );
        self.get_season(id)
    }

    /// End one active season, optionally archiving its pre-reset snapshot.
    pub fn end_season(
        &mut self,
        id: &str,
        time_override: Option<f64>,
        archive_override: Option<bool>,
    ) -> Result<JsonValue, ProgressionError> {
        let definition = self.season_definitions.get(id).cloned().ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "season",
                id: id.to_string(),
            }
        })?;
        let ended_at = match time_override {
            Some(value) => {
                ensure_finite(value, "season end time")?;
                value.max(0.0)
            }
            None => self.time.max(definition.ends_at),
        };
        let (started_at, archive_index) = {
            let state = self.season_states.get_mut(id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "season '{}' has not been initialized",
                    id
                ))
            })?;
            if !state.active {
                return Err(ProgressionError::InvalidOperation(format!(
                    "season '{}' is not active",
                    id
                )));
            }
            state.active = false;
            state.ended_at = Some(ended_at);
            (state.started_at, state.archive_count + 1)
        };

        let should_archive = archive_override.unwrap_or(definition.archive);
        let archived_snapshot = if should_archive {
            Some(self.export_snapshot())
        } else {
            None
        };

        let revision = self.next_revision();
        self.revision = revision;
        self.apply_season_reset(&definition.reset)?;

        if let Some(snapshot) = archived_snapshot {
            let archives = self.season_archives.entry(id.to_string()).or_default();
            archives.push(SeasonArchiveRecord {
                id: id.to_string(),
                archive_index,
                started_at,
                ended_at,
                revision,
                snapshot,
            });
            if let Some(state) = self.season_states.get_mut(id) {
                state.archive_count = archives.len() as u32;
            }
        }

        self.push_event(
            "season_ended",
            None,
            Some(id.to_string()),
            json!({
                "seasonId": id,
                "startedAt": started_at,
                "endedAt": ended_at,
                "archived": should_archive,
                "archiveCount": self.season_states.get(id).map(|state| state.archive_count).unwrap_or(0),
            }),
        );
        self.get_season(id)
    }

    /// Return one authored season with current runtime state.
    pub fn get_season(&self, id: &str) -> Result<JsonValue, ProgressionError> {
        let definition =
            self.season_definitions
                .get(id)
                .ok_or_else(|| ProgressionError::MissingDefinition {
                    kind: "season",
                    id: id.to_string(),
                })?;
        let state = self.season_states.get(id).cloned().unwrap_or(SeasonState {
            id: id.to_string(),
            active: false,
            started_at: None,
            ended_at: None,
            archive_count: self
                .season_archives
                .get(id)
                .map(|entries| entries.len() as u32)
                .unwrap_or(0),
        });
        Ok(self.season_json(definition, &state))
    }

    /// Return authored seasons in deterministic id order, with optional active-state filtering.
    pub fn list_seasons(&self, active_only: Option<bool>) -> Vec<JsonValue> {
        self.season_definitions
            .values()
            .filter_map(|definition| {
                let state =
                    self.season_states
                        .get(&definition.id)
                        .cloned()
                        .unwrap_or(SeasonState {
                            id: definition.id.clone(),
                            active: false,
                            started_at: None,
                            ended_at: None,
                            archive_count: self
                                .season_archives
                                .get(&definition.id)
                                .map(|entries| entries.len() as u32)
                                .unwrap_or(0),
                        });
                if active_only.is_some() && active_only != Some(state.active) {
                    return None;
                }
                Some(self.season_json(definition, &state))
            })
            .collect()
    }

    /// Return retained archive records for one season, or the latest entry when requested.
    pub fn get_season_archive(
        &self,
        id: &str,
        latest_only: bool,
    ) -> Result<JsonValue, ProgressionError> {
        if !self.season_definitions.contains_key(id) {
            return Err(ProgressionError::MissingDefinition {
                kind: "season",
                id: id.to_string(),
            });
        }
        let archives = self
            .season_archives
            .get(id)
            .cloned()
            .unwrap_or_default()
            .into_iter()
            .map(|record| self.season_archive_json(record))
            .collect::<Vec<_>>();
        if latest_only {
            return Ok(archives.into_iter().last().unwrap_or(JsonValue::Null));
        }
        Ok(JsonValue::Array(archives))
    }

    /// Validate that a season definition references existing counters and leaderboards for reset/archive behavior.
    pub(crate) fn validate_season_definition(
        &self,
        id: &str,
        definition: &SeasonDefinition,
    ) -> Result<(), ProgressionError> {
        if definition.id != id {
            return Err(ProgressionError::InvalidValue(format!(
                "season definition id '{}' must match '{}'",
                definition.id, id
            )));
        }
        ensure_finite(definition.starts_at, "season starts_at")?;
        ensure_finite(definition.ends_at, "season ends_at")?;
        if definition.ends_at < definition.starts_at {
            return Err(ProgressionError::InvalidValue(format!(
                "season '{}' ends_at must be >= starts_at",
                id
            )));
        }
        if !self.options.strict {
            return Ok(());
        }
        for leaderboard_id in &definition.reset.leaderboards {
            if !self.leaderboard_definitions.contains_key(leaderboard_id) {
                return Err(ProgressionError::MissingDefinition {
                    kind: "leaderboard",
                    id: leaderboard_id.clone(),
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

    fn apply_season_reset(
        &mut self,
        reset: &SeasonResetDefinition,
    ) -> Result<(), ProgressionError> {
        let leaderboard_ids = reset.leaderboards.iter().cloned().collect::<BTreeSet<_>>();
        let counter_ids = reset.counters.iter().cloned().collect::<BTreeSet<_>>();

        for counter_id in &counter_ids {
            let definition = self
                .counter_definitions
                .get(counter_id)
                .cloned()
                .ok_or_else(|| ProgressionError::MissingDefinition {
                    kind: "counter",
                    id: counter_id.clone(),
                })?;
            let profile_ids = self.profiles.keys().cloned().collect::<Vec<_>>();
            for profile_id in profile_ids {
                let old = self.get_counter(&profile_id, counter_id)?;
                let next = sanitize_counter_value(&definition, definition.initial)?;
                if (old - next).abs() <= f64::EPSILON {
                    continue;
                }
                if let Some(profile) = self.profiles.get_mut(&profile_id) {
                    profile
                        .counters
                        .insert(counter_id.clone(), CounterState { value: next });
                }
                self.push_event(
                    "season_counter_reset",
                    Some(profile_id.clone()),
                    Some(counter_id.clone()),
                    json!({ "counterId": counter_id, "old": old, "new": next }),
                );
                self.refresh_quest_lifecycle(&profile_id)?;
                self.evaluate_counter_quests(&profile_id, counter_id)?;
                self.evaluate_counter_challenges(&profile_id, counter_id)?;
                self.evaluate_counter_achievements(&profile_id, counter_id)?;
                self.sync_counter_bound_leaderboards_silent(&profile_id, counter_id);
            }
        }

        if !leaderboard_ids.is_empty() {
            for profile in self.profiles.values_mut() {
                for leaderboard_id in &leaderboard_ids {
                    profile.leaderboard_scores.remove(leaderboard_id);
                }
            }
            for leaderboard_id in leaderboard_ids {
                self.push_event(
                    "season_leaderboard_reset",
                    None,
                    Some(leaderboard_id.clone()),
                    json!({ "leaderboardId": leaderboard_id }),
                );
            }
        }
        Ok(())
    }

    fn season_json(&self, definition: &SeasonDefinition, state: &SeasonState) -> JsonValue {
        json!({
            "id": definition.id,
            "starts_at": definition.starts_at,
            "ends_at": definition.ends_at,
            "reset": {
                "leaderboards": &definition.reset.leaderboards,
                "counters": &definition.reset.counters,
            },
            "archive": definition.archive,
            "active": state.active,
            "started_at": state.started_at,
            "ended_at": state.ended_at,
            "archive_count": state.archive_count,
        })
    }

    fn season_archive_json(&self, record: SeasonArchiveRecord) -> JsonValue {
        json!({
            "id": record.id,
            "archive_index": record.archive_index,
            "started_at": record.started_at,
            "ended_at": record.ended_at,
            "revision": record.revision,
            "snapshot": record.snapshot,
        })
    }
}
