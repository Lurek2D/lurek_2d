//! Owns pinned rival relationships, rivalry deltas, and overtake event emission derived from leaderboard changes.
//! Stores the profile-local rival contracts that connect chosen rivals to one or more authored leaderboards.
//! Exposes public store helpers for pinning rivals, reading rival snapshots, and querying score or rank deltas.
//! Captures pre-refresh rival relations so score updates can emit stable overtake events after ordering changes.
//! Integrates with leaderboards and the activity feed without introducing matchmaking, social, or network features.
//! Open this file when changing rivalry tracking, delta semantics, or overtake event generation rules.
use super::*;

impl ProgressionStore {
    /// Pin one rival profile for another profile.
    pub fn pin_rival(
        &mut self,
        profile_id: &str,
        rival_profile_id: &str,
        leaderboard_id: Option<String>,
    ) -> Result<JsonValue, ProgressionError> {
        self.profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        self.profiles
            .get(rival_profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(rival_profile_id.to_string()))?;
        if profile_id == rival_profile_id {
            return Err(ProgressionError::InvalidOperation(
                "profile cannot pin itself as a rival".to_string(),
            ));
        }
        if let Some(leaderboard_id) = &leaderboard_id {
            if !self.leaderboard_definitions.contains_key(leaderboard_id) {
                return Err(ProgressionError::MissingDefinition {
                    kind: "leaderboard",
                    id: leaderboard_id.clone(),
                });
            }
        }
        let changed = {
            let profile = self.profile_mut(profile_id)?;
            profile.rivals.insert(
                rival_profile_id.to_string(),
                RivalState {
                    rival_profile_id: rival_profile_id.to_string(),
                    leaderboard_id: leaderboard_id.clone(),
                },
            )
        };
        let rivals = self
            .rival_index
            .entry(rival_profile_id.to_string())
            .or_default();
        if !rivals.iter().any(|candidate| candidate == profile_id) {
            rivals.push(profile_id.to_string());
            rivals.sort();
        }
        self.bump_revision();
        self.push_event(
            "rival_pinned",
            Some(profile_id.to_string()),
            Some(rival_profile_id.to_string()),
            json!({
                "profileId": profile_id,
                "rivalProfileId": rival_profile_id,
                "leaderboardId": leaderboard_id,
                "replaced": changed.is_some(),
            }),
        );
        self.get_rival(profile_id, rival_profile_id)
    }

    /// Return one pinned rival relationship and current delta snapshot.
    pub fn get_rival(
        &self,
        profile_id: &str,
        rival_profile_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        self.profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let rival = profile.rivals.get(rival_profile_id).ok_or_else(|| {
            ProgressionError::InvalidOperation(format!(
                "profile '{}' has not pinned rival '{}'",
                profile_id, rival_profile_id
            ))
        })?;
        Ok(self.rival_json(profile_id, rival))
    }

    /// Return all pinned rivals for one profile in deterministic rival-id order.
    pub fn list_rivals(&self, profile_id: &str) -> Result<Vec<JsonValue>, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        Ok(profile
            .rivals
            .values()
            .map(|rival| self.rival_json(profile_id, rival))
            .collect())
    }

    /// Return one rival delta snapshot for a leaderboard-aware rival relationship.
    pub fn get_rival_delta(
        &self,
        profile_id: &str,
        rival_profile_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let rival = profile.rivals.get(rival_profile_id).ok_or_else(|| {
            ProgressionError::InvalidOperation(format!(
                "profile '{}' has not pinned rival '{}'",
                profile_id, rival_profile_id
            ))
        })?;
        self.rival_delta_json(profile_id, rival)
    }

    fn rival_json(&self, profile_id: &str, rival: &RivalState) -> JsonValue {
        let delta = self
            .rival_delta_json(profile_id, rival)
            .unwrap_or_else(|_| json!({}));
        json!({
            "profile_id": profile_id,
            "rival_profile_id": rival.rival_profile_id,
            "leaderboard_id": rival.leaderboard_id,
            "delta": delta,
        })
    }

    fn rival_delta_json(
        &self,
        profile_id: &str,
        rival: &RivalState,
    ) -> Result<JsonValue, ProgressionError> {
        let leaderboard_id = rival.leaderboard_id.clone().ok_or_else(|| {
            ProgressionError::InvalidOperation(format!(
                "rival '{}' has no leaderboard binding",
                rival.rival_profile_id
            ))
        })?;
        let profile_entry = self.get_leaderboard_entry(profile_id, &leaderboard_id)?;
        let rival_entry = self.get_leaderboard_entry(&rival.rival_profile_id, &leaderboard_id)?;
        let profile_rank = profile_entry["rank"].as_u64().unwrap_or(0);
        let rival_rank = rival_entry["rank"].as_u64().unwrap_or(0);
        let profile_score = profile_entry["score"].as_f64().unwrap_or(0.0);
        let rival_score = rival_entry["score"].as_f64().unwrap_or(0.0);
        Ok(json!({
            "leaderboard_id": leaderboard_id,
            "profile_rank": profile_rank,
            "rival_rank": rival_rank,
            "rank_delta": rival_rank as i64 - profile_rank as i64,
            "profile_score": profile_score,
            "rival_score": rival_score,
            "score_delta": profile_score - rival_score,
        }))
    }

    /// Capture current pinned-rival relations so overtake comparisons can be computed after leaderboard updates.
    pub(crate) fn capture_rival_relations(
        &self,
        leaderboard_id: &str,
        changed_profile_id: &str,
    ) -> Result<Vec<(String, String, bool)>, ProgressionError> {
        let mut relations = Vec::new();
        for (owner_id, profile) in &self.profiles {
            for rival in profile.rivals.values() {
                if rival.leaderboard_id.as_deref() != Some(leaderboard_id) {
                    continue;
                }
                if owner_id != changed_profile_id && rival.rival_profile_id != changed_profile_id {
                    continue;
                }
                let owner_rank = self
                    .get_leaderboard_entry(owner_id, leaderboard_id)
                    .ok()
                    .and_then(|entry| entry["rank"].as_u64())
                    .unwrap_or(0);
                let rival_rank = self
                    .get_leaderboard_entry(&rival.rival_profile_id, leaderboard_id)
                    .ok()
                    .and_then(|entry| entry["rank"].as_u64())
                    .unwrap_or(0);
                let owner_ahead = owner_rank != 0 && rival_rank != 0 && owner_rank < rival_rank;
                relations.push((
                    owner_id.clone(),
                    rival.rival_profile_id.clone(),
                    owner_ahead,
                ));
            }
        }
        Ok(relations)
    }

    /// Emit rivalry events for pinned pairs whose relative ordering changed after a score refresh.
    pub(crate) fn emit_rival_overtake_events(
        &mut self,
        leaderboard_id: &str,
        relations_before: Vec<(String, String, bool)>,
    ) -> Result<(), ProgressionError> {
        for (owner_id, rival_profile_id, owner_ahead_before) in relations_before {
            let owner_rank = self
                .get_leaderboard_entry(&owner_id, leaderboard_id)
                .ok()
                .and_then(|entry| entry["rank"].as_u64())
                .unwrap_or(0);
            let rival_rank = self
                .get_leaderboard_entry(&rival_profile_id, leaderboard_id)
                .ok()
                .and_then(|entry| entry["rank"].as_u64())
                .unwrap_or(0);
            let owner_ahead_after = owner_rank != 0 && rival_rank != 0 && owner_rank < rival_rank;
            if owner_ahead_before == owner_ahead_after {
                continue;
            }
            if owner_ahead_after {
                self.push_event(
                    "profile_overtook_rival",
                    Some(owner_id.clone()),
                    Some(rival_profile_id.clone()),
                    json!({
                        "leaderboardId": leaderboard_id,
                        "profileId": owner_id,
                        "rivalProfileId": rival_profile_id,
                        "profileRank": owner_rank,
                        "rivalRank": rival_rank,
                    }),
                );
            } else {
                self.push_event(
                    "rival_overtook_profile",
                    Some(owner_id.clone()),
                    Some(rival_profile_id.clone()),
                    json!({
                        "leaderboardId": leaderboard_id,
                        "profileId": owner_id,
                        "rivalProfileId": rival_profile_id,
                        "profileRank": owner_rank,
                        "rivalRank": rival_rank,
                    }),
                );
            }
        }
        Ok(())
    }
}
