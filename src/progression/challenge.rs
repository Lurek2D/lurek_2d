//! Owns reusable challenge templates, per-profile challenge runs, expiry logic, and counter-driven progress updates.
//! Stores authored challenge contracts alongside runtime state transitions for activation, completion, and timeout.
//! Exposes the public store entrypoints that create runs, mutate progress, query snapshots, and list active work.
//! Validates challenge definitions against existing counters, reward payloads, and authored time-window invariants.
//! Re-evaluates counter-bound challenges after mutations so offline progression remains deterministic and evented.
//! Expires active runs against the logical store clock instead of any wall-clock or platform-driven scheduler.
//! Integrates with rewards, events, and retained profile state without depending on rendering, UI, or networking.
//! Open this file when changing challenge authoring, lifecycle rules, or reward-bearing engagement mechanics.
use super::*;

impl ProgressionStore {
    /// Define one reusable challenge template.
    pub fn define_challenge_template(
        &mut self,
        id: &str,
        definition: ChallengeTemplateDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        self.validate_challenge_template_definition(id, &definition)?;
        if let Some(previous) = self
            .challenge_template_definitions
            .insert(id.to_string(), definition.clone())
        {
            if let Some(counter_id) = previous.counter_id {
                if let Some(entries) = self.challenge_counter_index.get_mut(&counter_id) {
                    entries.retain(|candidate| candidate != id);
                    if entries.is_empty() {
                        self.challenge_counter_index.remove(&counter_id);
                    }
                }
            }
        }
        if let Some(counter_id) = &definition.counter_id {
            let entries = self
                .challenge_counter_index
                .entry(counter_id.clone())
                .or_default();
            if !entries.iter().any(|candidate| candidate == id) {
                entries.push(id.to_string());
                entries.sort();
            }
        }
        Ok(())
    }

    /// Activate one challenge template for a profile.
    pub fn activate_challenge(
        &mut self,
        profile_id: &str,
        template_id: &str,
        time_override: Option<f64>,
    ) -> Result<JsonValue, ProgressionError> {
        self.profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let definition = self
            .challenge_template_definitions
            .get(template_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "challenge_template",
                id: template_id.to_string(),
            })?;
        let started_at = match time_override {
            Some(value) => {
                ensure_finite(value, "challenge start time")?;
                value.max(0.0)
            }
            None => self.time,
        };
        let (completion_count, last_completed_at) = self
            .profiles
            .get(profile_id)
            .and_then(|profile| profile.challenges.get(template_id))
            .map(|state| {
                if state.status == "active" {
                    Err(ProgressionError::InvalidOperation(format!(
                        "challenge '{}' is already active for profile '{}'",
                        template_id, profile_id
                    )))
                } else if state.status == "completed" && !definition.repeatable {
                    Err(ProgressionError::InvalidOperation(format!(
                        "challenge '{}' is not repeatable for profile '{}'",
                        template_id, profile_id
                    )))
                } else {
                    Ok((state.completion_count, state.last_completed_at))
                }
            })
            .transpose()?
            .unwrap_or((0, None));
        if let Some(limit) = definition.max_completions {
            if completion_count >= limit {
                return Err(ProgressionError::InvalidOperation(format!(
                    "challenge '{}' reached max_completions={} for profile '{}'",
                    template_id, limit, profile_id
                )));
            }
        }
        let ends_at = definition.duration.map(|duration| started_at + duration);
        {
            let profile = self.profile_mut(profile_id)?;
            profile.challenges.insert(
                template_id.to_string(),
                ChallengeState {
                    status: "active".to_string(),
                    current: 0.0,
                    started_at,
                    ends_at,
                    completion_count,
                    last_completed_at,
                },
            );
        }
        self.bump_revision();
        self.push_event(
            "challenge_started",
            Some(profile_id.to_string()),
            Some(template_id.to_string()),
            json!({
                "challengeId": template_id,
                "startedAt": started_at,
                "endsAt": ends_at,
            }),
        );
        if let Some(counter_id) = &definition.counter_id {
            let value = self.get_counter(profile_id, counter_id)?;
            return self.set_challenge_progress(profile_id, template_id, value);
        }
        self.get_challenge(profile_id, template_id)
    }

    /// Set one challenge's progress directly.
    pub fn set_challenge_progress(
        &mut self,
        profile_id: &str,
        template_id: &str,
        value: f64,
    ) -> Result<JsonValue, ProgressionError> {
        ensure_finite(value, "challenge progress")?;
        let definition = self
            .challenge_template_definitions
            .get(template_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "challenge_template",
                id: template_id.to_string(),
            })?;
        let time = self.time;
        let (changed, current, status, completion_count, reward_record) = {
            let profile = self.profile_mut(profile_id)?;
            let state = profile.challenges.get_mut(template_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "challenge '{}' is not active for profile '{}'",
                    template_id, profile_id
                ))
            })?;
            if state.status != "active" {
                return Err(ProgressionError::InvalidOperation(format!(
                    "challenge '{}' is not active for profile '{}'",
                    template_id, profile_id
                )));
            }
            let next = value.clamp(0.0, definition.required);
            let changed = (state.current - next).abs() > f64::EPSILON;
            state.current = next;
            let mut reward_record = None;
            if state.current >= definition.required {
                state.status = "completed".to_string();
                state.completion_count += 1;
                state.last_completed_at = Some(time);
                reward_record = definition.reward_payload.as_ref().map(|payload| {
                    let reward_id = format!("challenge:{}:{}", template_id, state.completion_count);
                    let record = RewardRecord {
                        id: reward_id.clone(),
                        source_kind: "challenge".to_string(),
                        source_id: template_id.to_string(),
                        payload: payload.clone(),
                        state: RewardState::Pending,
                        external_receipt: None,
                    };
                    profile.rewards.insert(reward_id, record.clone());
                    record
                });
            }
            (
                changed,
                state.current,
                state.status.clone(),
                state.completion_count,
                reward_record,
            )
        };
        if !changed {
            return self.get_challenge(profile_id, template_id);
        }
        self.bump_revision();
        self.push_event(
            "challenge_progress_changed",
            Some(profile_id.to_string()),
            Some(template_id.to_string()),
            json!({
                "challengeId": template_id,
                "value": current,
                "required": definition.required,
                "status": status,
            }),
        );
        if status == "completed" {
            self.push_event(
                "challenge_completed",
                Some(profile_id.to_string()),
                Some(template_id.to_string()),
                json!({
                    "challengeId": template_id,
                    "completionCount": completion_count,
                }),
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
        }
        self.get_challenge(profile_id, template_id)
    }

    /// Return one challenge snapshot for a profile.
    pub fn get_challenge(
        &self,
        profile_id: &str,
        template_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        self.profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let definition = self
            .challenge_template_definitions
            .get(template_id)
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "challenge_template",
                id: template_id.to_string(),
            })?;
        let state = self
            .profiles
            .get(profile_id)
            .and_then(|profile| profile.challenges.get(template_id));
        Ok(self.challenge_json(profile_id, definition, state))
    }

    /// Return challenge snapshots for one profile in deterministic template-id order.
    pub fn list_challenges(
        &self,
        profile_id: &str,
        status_filter: Option<&str>,
    ) -> Result<Vec<JsonValue>, ProgressionError> {
        self.profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        if let Some(status) = status_filter {
            if !matches!(status, "inactive" | "active" | "completed" | "expired") {
                return Err(ProgressionError::InvalidValue(format!(
                    "unsupported challenge status filter '{}'",
                    status
                )));
            }
        }
        Ok(self
            .challenge_template_definitions
            .values()
            .filter_map(|definition| {
                let state = self
                    .profiles
                    .get(profile_id)
                    .and_then(|profile| profile.challenges.get(&definition.id));
                let snapshot = self.challenge_json(profile_id, definition, state);
                if let Some(status) = status_filter {
                    if snapshot["status"].as_str() != Some(status) {
                        return None;
                    }
                }
                Some(snapshot)
            })
            .collect())
    }

    /// Validate that a challenge template references supported counters, windows, and reward data before storage.
    pub(crate) fn validate_challenge_template_definition(
        &self,
        id: &str,
        definition: &ChallengeTemplateDefinition,
    ) -> Result<(), ProgressionError> {
        if definition.id != id {
            return Err(ProgressionError::InvalidValue(format!(
                "challenge template definition id '{}' must match '{}'",
                definition.id, id
            )));
        }
        ensure_finite(definition.required, "challenge required")?;
        if definition.required <= 0.0 {
            return Err(ProgressionError::InvalidValue(format!(
                "challenge '{}' required must be > 0",
                id
            )));
        }
        if let Some(duration) = definition.duration {
            ensure_finite(duration, "challenge duration")?;
            if duration <= 0.0 {
                return Err(ProgressionError::InvalidValue(format!(
                    "challenge '{}' duration must be > 0",
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
        if matches!(definition.max_completions, Some(0)) {
            return Err(ProgressionError::InvalidValue(format!(
                "challenge '{}' max_completions must be >= 1",
                id
            )));
        }
        Ok(())
    }

    /// Re-evaluate all counter-bound challenge runs for one profile after a counter mutation.
    pub(crate) fn evaluate_counter_challenges(
        &mut self,
        profile_id: &str,
        counter_id: &str,
    ) -> Result<(), ProgressionError> {
        let Some(template_ids) = self.challenge_counter_index.get(counter_id).cloned() else {
            return Ok(());
        };
        let counter_value = self.get_counter(profile_id, counter_id)?;
        for template_id in template_ids {
            let should_sync = self
                .profiles
                .get(profile_id)
                .and_then(|profile| profile.challenges.get(&template_id))
                .map(|state| state.status == "active")
                .unwrap_or(false);
            if !should_sync {
                continue;
            }
            let current = self
                .profiles
                .get(profile_id)
                .and_then(|profile| profile.challenges.get(&template_id))
                .map(|state| state.current)
                .unwrap_or(0.0);
            if (current - counter_value).abs() <= f64::EPSILON {
                continue;
            }
            self.set_challenge_progress(profile_id, &template_id, counter_value)?;
        }
        Ok(())
    }

    /// Expire active challenge runs whose authored end time is already behind the store clock.
    pub(crate) fn expire_active_challenges(&mut self) -> Result<(), ProgressionError> {
        let expired = self
            .profiles
            .iter()
            .flat_map(|(profile_id, profile)| {
                profile
                    .challenges
                    .iter()
                    .filter(|(_, state)| {
                        state.status == "active"
                            && state
                                .ends_at
                                .map(|ends_at| ends_at <= self.time)
                                .unwrap_or(false)
                    })
                    .map(|(template_id, _)| (profile_id.clone(), template_id.clone()))
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();
        for (profile_id, template_id) in expired {
            {
                let profile = self.profile_mut(&profile_id)?;
                let state = profile.challenges.get_mut(&template_id).ok_or_else(|| {
                    ProgressionError::InvalidOperation(format!(
                        "challenge '{}' is not materialized for profile '{}'",
                        template_id, profile_id
                    ))
                })?;
                if state.status != "active" {
                    continue;
                }
                state.status = "expired".to_string();
            }
            self.bump_revision();
            self.push_event(
                "challenge_expired",
                Some(profile_id.clone()),
                Some(template_id.clone()),
                json!({
                    "challengeId": template_id,
                    "time": self.time,
                }),
            );
        }
        Ok(())
    }

    fn challenge_json(
        &self,
        profile_id: &str,
        definition: &ChallengeTemplateDefinition,
        state: Option<&ChallengeState>,
    ) -> JsonValue {
        let status = state
            .map(|state| state.status.clone())
            .unwrap_or_else(|| "inactive".to_string());
        let current = state.map(|state| state.current).unwrap_or(0.0);
        let completion = if definition.required <= 0.0 {
            1.0
        } else {
            (current / definition.required).clamp(0.0, 1.0)
        };
        let ends_at = state.and_then(|state| state.ends_at);
        json!({
            "id": definition.id,
            "profile_id": profile_id,
            "title": definition.title,
            "description": definition.description,
            "status": status,
            "current": current,
            "required": definition.required,
            "completion": completion,
            "counter_id": definition.counter_id,
            "duration": definition.duration,
            "repeatable": definition.repeatable,
            "max_completions": definition.max_completions,
            "completion_count": state.map(|state| state.completion_count).unwrap_or(0),
            "started_at": state.map(|state| state.started_at),
            "ends_at": ends_at,
            "expires_in": ends_at.map(|value| (value - self.time).max(0.0)),
            "last_completed_at": state.and_then(|state| state.last_completed_at),
            "tags": definition.tags.clone(),
            "reward_payload": definition.reward_payload.clone(),
        })
    }
}
