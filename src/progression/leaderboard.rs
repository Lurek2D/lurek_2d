//! Owns leaderboard definitions, score mutation, rank queries, and threshold-style leaderboard event emission.
//! Stores deterministic ordering rules, tie handling, partitions, and query shaping for offline ranked state.
//! Exposes public store helpers for authoring leaderboards, submitting scores, and reading ranked projections.
//! Recomputes counter-bound leaderboards after source mutations while avoiding duplicate synchronization events.
//! Integrates with rivals, seasons, and virtual populations without depending on UI tables or online services.
//! Keeps ranking semantics local to progression so tests can prove ordering, ranges, and around-profile queries.
//! Open this file when changing score ownership, ranking behavior, or leaderboard-derived progression events.
use super::*;

impl ProgressionStore {
    /// Define one leaderboard and update automatic counter indexes.
    pub fn define_leaderboard(
        &mut self,
        id: &str,
        definition: LeaderboardDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        if definition.id != id {
            return Err(ProgressionError::InvalidValue(format!(
                "leaderboard definition id '{}' must match '{}'",
                definition.id, id
            )));
        }
        if let Some(max_entries) = definition.max_entries {
            if max_entries == 0 {
                return Err(ProgressionError::InvalidValue(format!(
                    "leaderboard '{}' max_entries must be >= 1",
                    id
                )));
            }
        }
        if let Some(counter_id) = &definition.counter_id {
            validate_id(counter_id)?;
            if self.options.strict && !self.counter_definitions.contains_key(counter_id) {
                return Err(ProgressionError::MissingDefinition {
                    kind: "counter",
                    id: counter_id.clone(),
                });
            }
        }
        if let Some(previous) = self
            .leaderboard_definitions
            .insert(id.to_string(), definition.clone())
        {
            if let Some(counter_id) = previous.counter_id {
                if let Some(ids) = self.leaderboard_counter_index.get_mut(&counter_id) {
                    ids.retain(|candidate| candidate != id);
                    if ids.is_empty() {
                        self.leaderboard_counter_index.remove(&counter_id);
                    }
                }
            }
        }
        if let Some(counter_id) = &definition.counter_id {
            let ids = self
                .leaderboard_counter_index
                .entry(counter_id.clone())
                .or_default();
            if !ids.iter().any(|candidate| candidate == id) {
                ids.push(id.to_string());
                ids.sort();
            }
        }
        Ok(())
    }

    /// Submit one score to a leaderboard and return the updated entry snapshot.
    pub fn submit_score(
        &mut self,
        profile_id: &str,
        leaderboard_id: &str,
        score: f64,
    ) -> Result<JsonValue, ProgressionError> {
        ensure_finite(score, "leaderboard score")?;
        let definition = self
            .leaderboard_definitions
            .get(leaderboard_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "leaderboard",
                id: leaderboard_id.to_string(),
            })?;
        let old_rank = self
            .get_leaderboard_entry(profile_id, leaderboard_id)
            .ok()
            .and_then(|entry| entry["rank"].as_u64())
            .unwrap_or(0);
        let old_score = self
            .profiles
            .get(profile_id)
            .and_then(|profile| profile.leaderboard_scores.get(leaderboard_id))
            .copied();
        let rival_relations_before = self.capture_rival_relations(leaderboard_id, profile_id)?;
        {
            let profile = self.profile_mut(profile_id)?;
            profile
                .leaderboard_scores
                .insert(leaderboard_id.to_string(), score);
        }
        self.bump_revision();
        self.push_event(
            "leaderboard_score_submitted",
            Some(profile_id.to_string()),
            Some(leaderboard_id.to_string()),
            json!({ "leaderboardId": leaderboard_id, "score": score, "oldScore": old_score }),
        );
        let entry = self.get_leaderboard_entry(profile_id, leaderboard_id)?;
        let new_rank = entry["rank"].as_u64().unwrap_or(0);
        self.emit_leaderboard_threshold_events(
            profile_id,
            leaderboard_id,
            old_rank,
            new_rank,
            score,
        );
        self.emit_rival_overtake_events(leaderboard_id, rival_relations_before)?;
        if old_rank != 0 && old_rank != new_rank {
            self.push_event(
                "leaderboard_rank_changed",
                Some(profile_id.to_string()),
                Some(leaderboard_id.to_string()),
                json!({
                    "leaderboardId": leaderboard_id,
                    "oldRank": old_rank,
                    "newRank": new_rank,
                    "score": score,
                    "sort": match definition.sort { LeaderboardSort::Descending => "descending", LeaderboardSort::Ascending => "ascending" },
                }),
            );
        }
        Ok(entry)
    }

    /// Return one leaderboard entry snapshot for a profile.
    pub fn get_leaderboard_entry(
        &self,
        profile_id: &str,
        leaderboard_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let definition = self
            .leaderboard_definitions
            .get(leaderboard_id)
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "leaderboard",
                id: leaderboard_id.to_string(),
            })?;
        let ordered = self.compute_leaderboard_rows(leaderboard_id, definition)?;
        let row = ordered
            .iter()
            .find(|row| row.profile_id == profile_id)
            .ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "profile '{}' has no score on leaderboard '{}'",
                    profile_id, leaderboard_id
                ))
            })?;
        Ok(json!({
            "leaderboard_id": leaderboard_id,
            "profile_id": row.profile_id,
            "score": row.score,
            "rank": row.rank,
            "percentile": row.percentile,
        }))
    }

    /// Return the top rows for one leaderboard in deterministic order.
    pub fn list_leaderboard_top(
        &self,
        leaderboard_id: &str,
        limit: Option<usize>,
    ) -> Result<Vec<JsonValue>, ProgressionError> {
        let definition = self
            .leaderboard_definitions
            .get(leaderboard_id)
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "leaderboard",
                id: leaderboard_id.to_string(),
            })?;
        let cap = limit.unwrap_or_else(|| definition.max_entries.unwrap_or(10));
        let rows = self.compute_leaderboard_rows(leaderboard_id, definition)?;
        Ok(rows
            .into_iter()
            .take(cap)
            .map(|row| self.leaderboard_row_json(leaderboard_id, row))
            .collect())
    }

    /// Return rows starting at one-based `start_rank` for one leaderboard.
    pub fn list_leaderboard_range(
        &self,
        leaderboard_id: &str,
        start_rank: u64,
        limit: Option<usize>,
    ) -> Result<Vec<JsonValue>, ProgressionError> {
        let definition = self
            .leaderboard_definitions
            .get(leaderboard_id)
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "leaderboard",
                id: leaderboard_id.to_string(),
            })?;
        if start_rank == 0 {
            return Err(ProgressionError::InvalidValue(
                "leaderboard start_rank must be >= 1".to_string(),
            ));
        }
        let cap = limit.unwrap_or_else(|| definition.max_entries.unwrap_or(10));
        let rows = self.compute_leaderboard_rows(leaderboard_id, definition)?;
        Ok(rows
            .into_iter()
            .filter(|row| row.rank >= start_rank)
            .take(cap)
            .map(|row| self.leaderboard_row_json(leaderboard_id, row))
            .collect())
    }

    /// Return rows centered around one profile's current rank.
    pub fn list_leaderboard_around_profile(
        &self,
        leaderboard_id: &str,
        profile_id: &str,
        before: Option<usize>,
        after: Option<usize>,
    ) -> Result<Vec<JsonValue>, ProgressionError> {
        let definition = self
            .leaderboard_definitions
            .get(leaderboard_id)
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "leaderboard",
                id: leaderboard_id.to_string(),
            })?;
        let rows = self.compute_leaderboard_rows(leaderboard_id, definition)?;
        let center_index = rows
            .iter()
            .position(|row| row.profile_id == profile_id)
            .ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "profile '{}' has no score on leaderboard '{}'",
                    profile_id, leaderboard_id
                ))
            })?;
        let before = before.unwrap_or(2);
        let after = after.unwrap_or(2);
        let start = center_index.saturating_sub(before);
        let end = (center_index + after + 1).min(rows.len());
        Ok(rows[start..end]
            .iter()
            .cloned()
            .map(|row| self.leaderboard_row_json(leaderboard_id, row))
            .collect())
    }

    /// Re-submit scores for every leaderboard bound to one counter after that counter changes.
    pub(crate) fn refresh_counter_leaderboards(
        &mut self,
        profile_id: &str,
        counter_id: &str,
    ) -> Result<(), ProgressionError> {
        let Some(leaderboard_ids) = self.leaderboard_counter_index.get(counter_id).cloned() else {
            return Ok(());
        };
        let score = self.get_counter(profile_id, counter_id)?;
        for leaderboard_id in leaderboard_ids {
            self.submit_score(profile_id, &leaderboard_id, score)?;
        }
        Ok(())
    }

    /// Refresh counter-bound leaderboards without emitting duplicate counter-side synchronization events.
    pub(crate) fn sync_counter_bound_leaderboards_silent(
        &mut self,
        profile_id: &str,
        counter_id: &str,
    ) {
        let Some(leaderboard_ids) = self.leaderboard_counter_index.get(counter_id).cloned() else {
            return;
        };
        let Ok(score) = self.get_counter(profile_id, counter_id) else {
            return;
        };
        if let Some(profile) = self.profiles.get_mut(profile_id) {
            for leaderboard_id in leaderboard_ids {
                profile.leaderboard_scores.insert(leaderboard_id, score);
            }
        }
    }

    fn emit_leaderboard_threshold_events(
        &mut self,
        profile_id: &str,
        leaderboard_id: &str,
        old_rank: u64,
        new_rank: u64,
        score: f64,
    ) {
        for threshold in [3_u64, 10, 30, 100] {
            let was_in = old_rank != 0 && old_rank <= threshold;
            let now_in = new_rank != 0 && new_rank <= threshold;
            if !was_in && now_in {
                self.push_event(
                    "leaderboard_top_entered",
                    Some(profile_id.to_string()),
                    Some(leaderboard_id.to_string()),
                    json!({
                        "leaderboardId": leaderboard_id,
                        "threshold": threshold,
                        "oldRank": if old_rank == 0 { JsonValue::Null } else { json!(old_rank) },
                        "newRank": new_rank,
                        "score": score,
                    }),
                );
            } else if was_in && !now_in {
                self.push_event(
                    "leaderboard_top_left",
                    Some(profile_id.to_string()),
                    Some(leaderboard_id.to_string()),
                    json!({
                        "leaderboardId": leaderboard_id,
                        "threshold": threshold,
                        "oldRank": old_rank,
                        "newRank": if new_rank == 0 { JsonValue::Null } else { json!(new_rank) },
                        "score": score,
                    }),
                );
            }
        }
    }

    fn leaderboard_row_json(&self, leaderboard_id: &str, row: LeaderboardRow) -> JsonValue {
        json!({
            "leaderboard_id": leaderboard_id,
            "profile_id": row.profile_id,
            "score": row.score,
            "rank": row.rank,
            "percentile": row.percentile,
        })
    }

    fn compute_leaderboard_rows(
        &self,
        leaderboard_id: &str,
        definition: &LeaderboardDefinition,
    ) -> Result<Vec<LeaderboardRow>, ProgressionError> {
        let mut rows = self
            .profiles
            .values()
            .filter_map(|profile| {
                profile
                    .leaderboard_scores
                    .get(leaderboard_id)
                    .copied()
                    .map(|score| (profile.id.clone(), score))
            })
            .collect::<Vec<_>>();
        for population in self.populations.values() {
            for profile in population.profiles.values() {
                if profile.materialized || !profile.active {
                    continue;
                }
                if let Some(score) = profile.leaderboard_scores.get(leaderboard_id).copied() {
                    rows.push((profile.profile_id.clone(), score));
                }
            }
        }
        rows.sort_by(|left, right| {
            let score_order = match definition.sort {
                LeaderboardSort::Descending => right.1.total_cmp(&left.1),
                LeaderboardSort::Ascending => left.1.total_cmp(&right.1),
            };
            score_order.then(left.0.cmp(&right.0))
        });

        let total = rows.len().max(1) as f64;
        let mut result = Vec::with_capacity(rows.len());
        let mut previous_score: Option<f64> = None;
        let mut previous_rank: u64 = 0;
        let mut dense_rank: u64 = 0;
        for (index, (profile_id, score)) in rows.into_iter().enumerate() {
            let rank = if let Some(previous_score) = previous_score {
                let same_score = (previous_score - score).abs() <= f64::EPSILON;
                match definition.rank_mode {
                    LeaderboardRankMode::Ordinal => index as u64 + 1,
                    LeaderboardRankMode::Dense => {
                        if same_score {
                            previous_rank
                        } else {
                            dense_rank += 1;
                            dense_rank
                        }
                    }
                    LeaderboardRankMode::Competition => {
                        if same_score {
                            previous_rank
                        } else {
                            index as u64 + 1
                        }
                    }
                }
            } else {
                dense_rank = 1;
                1
            };
            previous_score = Some(score);
            previous_rank = rank;
            result.push(LeaderboardRow {
                profile_id,
                score,
                rank,
                percentile: ((total - (index as f64 + 1.0)) / total).max(0.0),
            });
        }
        Ok(result)
    }
}
