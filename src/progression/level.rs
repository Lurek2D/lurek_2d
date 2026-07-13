//! Owns level-track progression, stored experience totals, and normalized level snapshots for profiles.
//! Exposes the store entrypoints that add XP, set absolute XP, set explicit levels, and query state.
//! Applies authored track bounds, carry-over policy, and capped level advancement in canonical data.
//! Emits level and experience events so downstream systems observe one deterministic growth sequence.
//! Open this file when changing XP accumulation, level caps, carry-over semantics, or level snapshots.
use super::*;

impl ProgressionStore {
    /// Add experience to one level track and emit any resulting level-up event.
    pub fn add_experience(
        &mut self,
        profile_id: &str,
        track_id: &str,
        amount: f64,
    ) -> Result<JsonValue, ProgressionError> {
        ensure_finite(amount, "experience amount")?;
        let definition = self
            .level_track_definitions
            .get(track_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "level_track",
                id: track_id.to_string(),
            })?;
        let (experience, level, old_level) = {
            let profile = self.profile_mut(profile_id)?;
            let state = profile
                .levels
                .entry(track_id.to_string())
                .or_insert(LevelState {
                    experience: 0.0,
                    level: definition.initial_level,
                });
            state.experience = (state.experience + amount).max(0.0);
            let old_level = state.level;
            while state.level < definition.max_level
                && state.experience >= xp_threshold_for(&definition, state.level)
            {
                if definition.carry_over {
                    state.experience -= xp_threshold_for(&definition, state.level);
                }
                state.level += 1;
            }
            if definition.allow_level_down {
                while state.level > definition.initial_level && state.experience < 0.0 {
                    state.level -= 1;
                }
            }
            (state.experience, state.level, old_level)
        };
        self.bump_revision();
        self.push_event(
            "experience_changed",
            Some(profile_id.to_string()),
            Some(track_id.to_string()),
            json!({ "experience": experience, "level": level }),
        );
        if level > old_level {
            self.push_event(
                "level_gained",
                Some(profile_id.to_string()),
                Some(track_id.to_string()),
                json!({ "from": old_level, "to": level }),
            );
        }
        Ok(json!({
            "track_id": track_id,
            "experience": experience,
            "level": level,
        }))
    }

    /// Set absolute experience for one level track.
    pub fn set_experience(
        &mut self,
        profile_id: &str,
        track_id: &str,
        value: f64,
    ) -> Result<JsonValue, ProgressionError> {
        let current = self.get_experience(profile_id, track_id)?;
        let current_value = current
            .get("experience")
            .and_then(JsonValue::as_f64)
            .unwrap_or(0.0);
        self.add_experience(profile_id, track_id, value - current_value)
    }

    /// Return current experience state for one level track.
    pub fn get_experience(
        &self,
        profile_id: &str,
        track_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let definition = self.level_track_definitions.get(track_id).ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "level_track",
                id: track_id.to_string(),
            }
        })?;
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let state = profile.levels.get(track_id).cloned().unwrap_or(LevelState {
            experience: 0.0,
            level: definition.initial_level,
        });
        Ok(json!({
            "track_id": track_id,
            "experience": state.experience,
            "level": state.level,
            "to_next": xp_threshold_for(definition, state.level),
        }))
    }

    /// Return current level for one track.
    pub fn get_level(&self, profile_id: &str, track_id: &str) -> Result<u32, ProgressionError> {
        let snapshot = self.get_experience(profile_id, track_id)?;
        Ok(snapshot
            .get("level")
            .and_then(JsonValue::as_u64)
            .unwrap_or(0) as u32)
    }

    /// Set the current level directly and normalize stored experience to the start of that level.
    pub fn set_level(
        &mut self,
        profile_id: &str,
        track_id: &str,
        level: u32,
    ) -> Result<JsonValue, ProgressionError> {
        let definition = self
            .level_track_definitions
            .get(track_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "level_track",
                id: track_id.to_string(),
            })?;
        if level < definition.initial_level || level > definition.max_level {
            return Err(ProgressionError::InvalidValue(format!(
                "level {} outside {}..={}",
                level, definition.initial_level, definition.max_level
            )));
        }
        {
            let profile = self.profile_mut(profile_id)?;
            profile.levels.insert(
                track_id.to_string(),
                LevelState {
                    experience: 0.0,
                    level,
                },
            );
        }
        self.bump_revision();
        self.push_event(
            "experience_changed",
            Some(profile_id.to_string()),
            Some(track_id.to_string()),
            json!({ "experience": 0.0, "level": level }),
        );
        Ok(json!({
            "track_id": track_id,
            "experience": 0.0,
            "level": level,
        }))
    }

    /// Return XP needed for the next level boundary.
    pub fn get_experience_to_next_level(
        &self,
        profile_id: &str,
        track_id: &str,
    ) -> Result<f64, ProgressionError> {
        let definition = self.level_track_definitions.get(track_id).ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "level_track",
                id: track_id.to_string(),
            }
        })?;
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let state = profile.levels.get(track_id).cloned().unwrap_or(LevelState {
            experience: 0.0,
            level: definition.initial_level,
        });
        Ok((xp_threshold_for(definition, state.level) - state.experience).max(0.0))
    }
}
