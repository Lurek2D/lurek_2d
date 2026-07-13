//! Owns authored quest definitions, active quest state, journals, and stage data for profiles.
//! Exposes registration, reveal, accept, fail, complete, and snapshot helpers for canonical quest flow.
//! Stores reverse bindings from counters to objectives so writes refresh only affected active quests.
//! Applies hidden, revealed, available, active, completed, and failed transitions inside engine state.
//! Advances mandatory stage objectives, carries retained journals, and preserves completion history.
//! Emits quest lifecycle, objective, journal, and reward-availability events in deterministic order.
//! Provides public Lua-facing helpers plus crate-local refresh hooks reused by counter and season slices.
//! Reuses shared condition evaluation and reward records without duplicating attribute or counter logic.
//! Keeps branching objective behavior out of store-wide plumbing so quest rules stay cohesive.
//! Open this file when changing quest validation, objective sync, journal retention, or lifecycle semantics.
use super::*;

impl ProgressionStore {
    /// Define one quest and rebuild reverse counter indexes for its objectives.
    pub fn define_quest(
        &mut self,
        id: &str,
        definition: QuestDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        if definition.id != id {
            return Err(ProgressionError::InvalidValue(format!(
                "quest definition id '{}' must match '{}'",
                definition.id, id
            )));
        }
        if self.options.strict {
            for stage in &definition.stages {
                for objective in &stage.objectives {
                    if let Some(counter_id) = &objective.counter_id {
                        if !self.counter_definitions.contains_key(counter_id) {
                            return Err(ProgressionError::MissingDefinition {
                                kind: "counter",
                                id: counter_id.clone(),
                            });
                        }
                    }
                }
            }
        }
        if let Some(condition) = &definition.availability_condition {
            self.validate_condition_inner(condition, 0, &mut Vec::new())?;
        }
        if let Some(condition) = &definition.reveal_condition {
            self.validate_condition_inner(condition, 0, &mut Vec::new())?;
        }
        if let Some(previous) = self
            .quest_definitions
            .insert(id.to_string(), definition.clone())
        {
            for bindings in self.quest_counter_index.values_mut() {
                bindings.retain(|binding| binding.quest_id != previous.id);
            }
            self.quest_counter_index
                .retain(|_, bindings| !bindings.is_empty());
        }
        for (stage_index, stage) in definition.stages.iter().enumerate() {
            for objective in &stage.objectives {
                if let Some(counter_id) = &objective.counter_id {
                    self.quest_counter_index
                        .entry(counter_id.clone())
                        .or_default()
                        .push(QuestCounterBinding {
                            quest_id: id.to_string(),
                            stage_index,
                            objective_id: objective.id.clone(),
                        });
                }
            }
        }
        for bindings in self.quest_counter_index.values_mut() {
            bindings.sort_by(|left, right| {
                left.quest_id
                    .cmp(&right.quest_id)
                    .then(left.stage_index.cmp(&right.stage_index))
                    .then(left.objective_id.cmp(&right.objective_id))
            });
        }
        Ok(())
    }

    /// Accept a quest for the profile if it is currently available.
    pub fn accept_quest(
        &mut self,
        profile_id: &str,
        quest_id: &str,
    ) -> Result<(), ProgressionError> {
        let definition = self
            .quest_definitions
            .get(quest_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "quest",
                id: quest_id.to_string(),
            })?;
        self.refresh_quest_lifecycle_for(profile_id, quest_id)?;
        let current = self.get_quest_state(profile_id, quest_id)?;
        let retry_failed = if current["status"] == "failed" {
            let revealed_override = self
                .profiles
                .get(profile_id)
                .and_then(|profile| profile.quests.get(quest_id))
                .map(|quest| quest.revealed_override)
                .unwrap_or(definition.reveal_condition.is_none());
            self.compute_inactive_quest_status(profile_id, &definition, revealed_override)?
                == "available"
        } else {
            false
        };
        if current["status"] != "available" && !retry_failed {
            return Err(ProgressionError::InvalidOperation(format!(
                "quest '{}' is not currently available for profile '{}'",
                quest_id, profile_id
            )));
        }
        let completion_count = self
            .profiles
            .get(profile_id)
            .and_then(|profile| profile.quests.get(quest_id))
            .map(|quest| quest.completion_count)
            .unwrap_or(0);
        let revealed_override = self
            .profiles
            .get(profile_id)
            .and_then(|profile| profile.quests.get(quest_id))
            .map(|quest| quest.revealed_override)
            .unwrap_or(definition.reveal_condition.is_none());
        let existing_journal = self
            .profiles
            .get(profile_id)
            .and_then(|profile| profile.quests.get(quest_id))
            .map(|quest| quest.journal.clone())
            .unwrap_or_default();
        let next_journal_index = self
            .profiles
            .get(profile_id)
            .and_then(|profile| profile.quests.get(quest_id))
            .map(|quest| quest.next_journal_index)
            .unwrap_or(0);
        let mut objectives = BTreeMap::new();
        if let Some(stage) = definition.stages.first() {
            for objective in &stage.objectives {
                objectives.insert(
                    objective.id.clone(),
                    QuestObjectiveState {
                        current: 0.0,
                        status: "pending".to_string(),
                        visible: objective.visible,
                    },
                );
            }
        }
        let profile = self.profile_mut(profile_id)?;
        profile.quests.insert(
            quest_id.to_string(),
            QuestState {
                status: "active".to_string(),
                current_stage_index: 0,
                objectives,
                completion_count,
                revealed_override,
                journal: existing_journal,
                next_journal_index,
            },
        );
        self.bump_revision();
        self.push_event(
            "quest_started",
            Some(profile_id.to_string()),
            Some(quest_id.to_string()),
            json!({ "questId": quest_id }),
        );
        self.sync_active_stage_counter_objectives(profile_id, quest_id)?;
        Ok(())
    }

    /// Mark an active quest as completed.
    pub fn complete_quest(
        &mut self,
        profile_id: &str,
        quest_id: &str,
    ) -> Result<(), ProgressionError> {
        self.finish_quest(profile_id, quest_id)
    }

    /// Mark an active quest as failed.
    pub fn fail_quest(&mut self, profile_id: &str, quest_id: &str) -> Result<(), ProgressionError> {
        {
            let profile = self.profile_mut(profile_id)?;
            let quest = profile.quests.get_mut(quest_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "quest '{}' is not active for profile '{}'",
                    quest_id, profile_id
                ))
            })?;
            quest.status = "failed".to_string();
        }
        self.bump_revision();
        self.push_event(
            "quest_failed",
            Some(profile_id.to_string()),
            Some(quest_id.to_string()),
            json!({ "questId": quest_id }),
        );
        self.refresh_quest_lifecycle(profile_id)?;
        Ok(())
    }

    /// Reveal a quest manually for the profile.
    pub fn reveal_quest(
        &mut self,
        profile_id: &str,
        quest_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let completion_count = self
            .profiles
            .get(profile_id)
            .and_then(|profile| profile.quests.get(quest_id))
            .map(|quest| quest.completion_count)
            .unwrap_or(0);
        {
            let profile = self.profile_mut(profile_id)?;
            let quest = profile
                .quests
                .entry(quest_id.to_string())
                .or_insert(QuestState {
                    status: "hidden".to_string(),
                    current_stage_index: 0,
                    objectives: BTreeMap::new(),
                    completion_count,
                    revealed_override: false,
                    journal: Vec::new(),
                    next_journal_index: 0,
                });
            quest.revealed_override = true;
        }
        self.refresh_quest_lifecycle_for(profile_id, quest_id)?;
        self.get_quest_state(profile_id, quest_id)
    }

    /// Append one canonical journal entry to a quest and return it.
    pub fn add_quest_journal_entry(
        &mut self,
        profile_id: &str,
        quest_id: &str,
        text: &str,
        tag: Option<String>,
    ) -> Result<QuestJournalEntry, ProgressionError> {
        if text.is_empty() {
            return Err(ProgressionError::InvalidValue(
                "quest journal text must not be empty".to_string(),
            ));
        }
        let max_journal_entries = self
            .quest_definitions
            .get(quest_id)
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "quest",
                id: quest_id.to_string(),
            })?
            .max_journal_entries;
        let entry = {
            let profile = self.profile_mut(profile_id)?;
            let quest = profile.quests.get_mut(quest_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "quest '{}' is not materialized for profile '{}'",
                    quest_id, profile_id
                ))
            })?;
            let entry = QuestJournalEntry {
                index: quest.next_journal_index,
                text: text.to_string(),
                tag: tag.unwrap_or_default(),
            };
            quest.next_journal_index += 1;
            quest.journal.push(entry.clone());
            if let Some(max_entries) = max_journal_entries {
                while quest.journal.len() > max_entries {
                    quest.journal.remove(0);
                }
            }
            entry
        };
        self.bump_revision();
        self.push_event(
            "quest_journal_entry_added",
            Some(profile_id.to_string()),
            Some(quest_id.to_string()),
            json!({ "questId": quest_id, "index": entry.index, "tag": entry.tag }),
        );
        Ok(entry)
    }

    /// Return retained quest journal entries in authored order.
    pub fn list_quest_journal_entries(
        &self,
        profile_id: &str,
        quest_id: &str,
    ) -> Result<Vec<QuestJournalEntry>, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let quest = profile.quests.get(quest_id).ok_or_else(|| {
            ProgressionError::InvalidOperation(format!(
                "quest '{}' is not materialized for profile '{}'",
                quest_id, profile_id
            ))
        })?;
        Ok(quest.journal.clone())
    }

    /// Refresh synthesized hidden, revealed, and available quest states for one profile.
    pub fn refresh_quest_lifecycle(&mut self, profile_id: &str) -> Result<(), ProgressionError> {
        let quest_ids = self.quest_definitions.keys().cloned().collect::<Vec<_>>();
        for quest_id in quest_ids {
            self.refresh_quest_lifecycle_for(profile_id, &quest_id)?;
        }
        Ok(())
    }

    /// Set progress on one active quest objective.
    pub fn set_quest_objective(
        &mut self,
        profile_id: &str,
        quest_id: &str,
        objective_id: &str,
        value: f64,
    ) -> Result<JsonValue, ProgressionError> {
        ensure_finite(value, "objective value")?;
        let definition = self
            .quest_definitions
            .get(quest_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "quest",
                id: quest_id.to_string(),
            })?;
        let (
            event_type,
            event_payload,
            current_stage_index,
            current_value,
            current_status,
            should_complete_quest,
        ) = {
            let profile = self.profile_mut(profile_id)?;
            let quest = profile.quests.get_mut(quest_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "quest '{}' is not active for profile '{}'",
                    quest_id, profile_id
                ))
            })?;
            let stage = definition
                .stages
                .get(quest.current_stage_index)
                .ok_or_else(|| {
                    ProgressionError::InvalidOperation(format!(
                        "quest '{}' has no current stage",
                        quest_id
                    ))
                })?;
            let objective_definition = stage
                .objectives
                .iter()
                .find(|objective| objective.id == objective_id)
                .ok_or_else(|| {
                    ProgressionError::InvalidOperation(format!(
                        "quest '{}' stage '{}' does not define objective '{}'",
                        quest_id, stage.id, objective_id
                    ))
                })?;

            {
                let state = quest.objectives.entry(objective_id.to_string()).or_insert(
                    QuestObjectiveState {
                        current: 0.0,
                        status: "pending".to_string(),
                        visible: objective_definition.visible,
                    },
                );
                state.current = value.clamp(0.0, objective_definition.required);
                state.status = if state.current >= objective_definition.required {
                    "done".to_string()
                } else if state.current > 0.0 {
                    "active".to_string()
                } else {
                    "pending".to_string()
                };
            }

            let stage_complete = stage.objectives.iter().all(|objective| {
                if !objective.mandatory {
                    return true;
                }
                quest
                    .objectives
                    .get(&objective.id)
                    .map(|state| matches!(state.status.as_str(), "done" | "skipped"))
                    .unwrap_or(false)
            });

            let mut event_type = None;
            let mut event_payload = None;
            let mut should_complete_quest = false;
            if stage_complete {
                if quest.current_stage_index + 1 < definition.stages.len() {
                    quest.current_stage_index += 1;
                    quest.objectives.clear();
                    for objective in &definition.stages[quest.current_stage_index].objectives {
                        quest.objectives.insert(
                            objective.id.clone(),
                            QuestObjectiveState {
                                current: 0.0,
                                status: "pending".to_string(),
                                visible: objective.visible,
                            },
                        );
                    }
                    event_type = Some("quest_advanced".to_string());
                    event_payload = Some(json!({ "stageIndex": quest.current_stage_index }));
                } else {
                    should_complete_quest = true;
                }
            }
            let current_state =
                quest
                    .objectives
                    .get(objective_id)
                    .cloned()
                    .unwrap_or(QuestObjectiveState {
                        current: 0.0,
                        status: "pending".to_string(),
                        visible: objective_definition.visible,
                    });
            (
                event_type,
                event_payload,
                quest.current_stage_index,
                current_state.current,
                current_state.status,
                should_complete_quest,
            )
        };
        let mut status = if should_complete_quest {
            self.finish_quest(profile_id, quest_id)?;
            "completed".to_string()
        } else {
            self.bump_revision();
            if let Some(event_type) = event_type.clone() {
                self.push_event(
                    &event_type,
                    Some(profile_id.to_string()),
                    Some(quest_id.to_string()),
                    event_payload.clone().unwrap_or_else(|| json!({})),
                );
            }
            self.push_event(
                "quest_objective_changed",
                Some(profile_id.to_string()),
                Some(quest_id.to_string()),
                json!({
                    "objectiveId": objective_id,
                    "value": current_value,
                    "status": current_status
                }),
            );
            self.get_quest_state(profile_id, quest_id)?
                .get("status")
                .and_then(JsonValue::as_str)
                .unwrap_or("active")
                .to_string()
        };
        if should_complete_quest {
            self.push_event(
                "quest_objective_changed",
                Some(profile_id.to_string()),
                Some(quest_id.to_string()),
                json!({
                    "objectiveId": objective_id,
                    "value": current_value,
                    "status": current_status
                }),
            );
        }
        if event_type.as_deref() == Some("quest_advanced") {
            self.sync_active_stage_counter_objectives(profile_id, quest_id)?;
            status = self
                .get_quest_state(profile_id, quest_id)?
                .get("status")
                .and_then(JsonValue::as_str)
                .unwrap_or("active")
                .to_string();
        }
        Ok(json!({
            "quest_id": quest_id,
            "status": status,
            "current_stage_index": current_stage_index,
            "objectives": self.get_quest_state(profile_id, quest_id)?["objectives"].clone(),
        }))
    }

    /// Override one objective status directly.
    pub fn set_quest_objective_status(
        &mut self,
        profile_id: &str,
        quest_id: &str,
        objective_id: &str,
        status: &str,
    ) -> Result<JsonValue, ProgressionError> {
        if !matches!(status, "pending" | "active" | "done" | "skipped" | "failed") {
            return Err(ProgressionError::InvalidValue(format!(
                "unsupported quest objective status '{}'",
                status
            )));
        }
        let current = self
            .get_quest_state(profile_id, quest_id)?
            .get("objectives")
            .and_then(JsonValue::as_array)
            .and_then(|objectives| {
                objectives
                    .iter()
                    .find(|objective| objective["id"] == objective_id)
                    .and_then(|objective| objective["current"].as_f64())
            })
            .unwrap_or(0.0);
        let definition = self
            .quest_definitions
            .get(quest_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "quest",
                id: quest_id.to_string(),
            })?;
        let required = definition
            .stages
            .iter()
            .flat_map(|stage| stage.objectives.iter())
            .find(|objective| objective.id == objective_id)
            .map(|objective| objective.required)
            .ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "quest '{}' does not define objective '{}'",
                    quest_id, objective_id
                ))
            })?;
        let value = match status {
            "done" | "skipped" => required,
            "pending" => 0.0,
            "active" => {
                if required <= 0.0 {
                    0.0
                } else {
                    current.clamp(0.0, required).max(required.min(1.0))
                }
            }
            "failed" => current.clamp(0.0, required),
            _ => current,
        };
        let mut snapshot = self.set_quest_objective(profile_id, quest_id, objective_id, value)?;
        {
            let profile = self.profile_mut(profile_id)?;
            let quest = profile.quests.get_mut(quest_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "quest '{}' is not active for profile '{}'",
                    quest_id, profile_id
                ))
            })?;
            let state = quest.objectives.get_mut(objective_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "quest '{}' objective '{}' is not active",
                    quest_id, objective_id
                ))
            })?;
            state.status = status.to_string();
        }
        self.bump_revision();
        self.push_event(
            "quest_objective_status_changed",
            Some(profile_id.to_string()),
            Some(quest_id.to_string()),
            json!({ "objectiveId": objective_id, "status": status }),
        );
        snapshot["objectives"] = self.get_quest_state(profile_id, quest_id)?["objectives"].clone();
        Ok(snapshot)
    }

    /// Override one objective visibility directly.
    pub fn set_quest_objective_visibility(
        &mut self,
        profile_id: &str,
        quest_id: &str,
        objective_id: &str,
        visible: bool,
    ) -> Result<JsonValue, ProgressionError> {
        {
            let profile = self.profile_mut(profile_id)?;
            let quest = profile.quests.get_mut(quest_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "quest '{}' is not active for profile '{}'",
                    quest_id, profile_id
                ))
            })?;
            let state = quest.objectives.get_mut(objective_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "quest '{}' objective '{}' is not active",
                    quest_id, objective_id
                ))
            })?;
            state.visible = visible;
        }
        self.bump_revision();
        self.push_event(
            "quest_objective_visibility_changed",
            Some(profile_id.to_string()),
            Some(quest_id.to_string()),
            json!({ "objectiveId": objective_id, "visible": visible }),
        );
        self.get_quest_state(profile_id, quest_id)
    }

    /// Return one quest state snapshot.
    pub fn get_quest_state(
        &self,
        profile_id: &str,
        quest_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let definition = self.quest_definitions.get(quest_id).ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "quest",
                id: quest_id.to_string(),
            }
        })?;
        let quest = profile.quests.get(quest_id);
        let (status, current_stage_index, completion_count, revealed_override, journal) =
            match quest {
                Some(quest) => (
                    quest.status.clone(),
                    quest.current_stage_index,
                    quest.completion_count,
                    quest.revealed_override,
                    quest.journal.clone(),
                ),
                None => {
                    let status =
                        self.compute_inactive_quest_status(profile_id, definition, false)?;
                    (status, 0, 0, false, Vec::new())
                }
            };
        let revealed = status != "hidden";
        let available = status == "available";
        let objectives = quest
            .map(|quest| {
                quest
                    .objectives
                    .iter()
                    .map(|(id, state)| {
                        json!({
                            "id": id,
                            "current": state.current,
                            "status": state.status,
                            "visible": state.visible,
                        })
                    })
                    .collect::<Vec<_>>()
            })
            .unwrap_or_default();
        Ok(json!({
            "quest_id": quest_id,
            "status": status,
            "current_stage_index": current_stage_index,
            "completion_count": completion_count,
            "revealed": revealed,
            "available": available,
            "revealed_override": revealed_override,
            "journal": journal,
            "objectives": objectives,
        }))
    }

    /// Sync active quest objectives that mirror the changed counter for the targeted profile.
    pub(crate) fn evaluate_counter_quests(
        &mut self,
        profile_id: &str,
        counter_id: &str,
    ) -> Result<(), ProgressionError> {
        let Some(bindings) = self.quest_counter_index.get(counter_id).cloned() else {
            return Ok(());
        };
        let counter_value = self.get_counter(profile_id, counter_id)?;
        for binding in bindings {
            let should_sync = self
                .profiles
                .get(profile_id)
                .and_then(|profile| profile.quests.get(&binding.quest_id))
                .map(|quest| {
                    quest.status == "active" && quest.current_stage_index == binding.stage_index
                })
                .unwrap_or(false);
            if !should_sync {
                continue;
            }
            let current = self
                .profiles
                .get(profile_id)
                .and_then(|profile| profile.quests.get(&binding.quest_id))
                .and_then(|quest| quest.objectives.get(&binding.objective_id))
                .map(|state| state.current)
                .unwrap_or(0.0);
            if (current - counter_value).abs() <= f64::EPSILON {
                continue;
            }
            self.set_quest_objective(
                profile_id,
                &binding.quest_id,
                &binding.objective_id,
                counter_value,
            )?;
        }
        Ok(())
    }

    /// Refresh one inactive quest materialization so reveal and availability state match current facts.
    pub(crate) fn refresh_quest_lifecycle_for(
        &mut self,
        profile_id: &str,
        quest_id: &str,
    ) -> Result<(), ProgressionError> {
        let definition = self
            .quest_definitions
            .get(quest_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "quest",
                id: quest_id.to_string(),
            })?;
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let current = profile.quests.get(quest_id).cloned();
        if let Some(state) = &current {
            if matches!(state.status.as_str(), "active" | "completed" | "failed") {
                return Ok(());
            }
        }
        let revealed_override = current
            .as_ref()
            .map(|state| state.revealed_override)
            .unwrap_or(false);
        let target_status =
            self.compute_inactive_quest_status(profile_id, &definition, revealed_override)?;
        let old_status = current
            .as_ref()
            .map(|state| state.status.clone())
            .unwrap_or_else(|| "hidden".to_string());

        if target_status == "hidden" && current.is_none() {
            return Ok(());
        }
        if old_status == target_status {
            return Ok(());
        }

        let completion_count = current
            .as_ref()
            .map(|state| state.completion_count)
            .unwrap_or(0);
        let current_stage_index = current
            .as_ref()
            .map(|state| state.current_stage_index)
            .unwrap_or(0);
        let objectives = current
            .as_ref()
            .map(|state| state.objectives.clone())
            .unwrap_or_default();
        let journal = current
            .as_ref()
            .map(|state| state.journal.clone())
            .unwrap_or_default();
        let next_journal_index = current
            .as_ref()
            .map(|state| state.next_journal_index)
            .unwrap_or(0);

        {
            let profile = self.profile_mut(profile_id)?;
            if target_status == "hidden" {
                profile.quests.remove(quest_id);
            } else {
                profile.quests.insert(
                    quest_id.to_string(),
                    QuestState {
                        status: target_status.clone(),
                        current_stage_index,
                        objectives,
                        completion_count,
                        revealed_override,
                        journal,
                        next_journal_index,
                    },
                );
            }
        }
        self.bump_revision();
        if old_status == "hidden" && (target_status == "revealed" || target_status == "available") {
            self.push_event(
                "quest_revealed",
                Some(profile_id.to_string()),
                Some(quest_id.to_string()),
                json!({ "questId": quest_id }),
            );
        }
        if old_status != "available" && target_status == "available" {
            self.push_event(
                "quest_available",
                Some(profile_id.to_string()),
                Some(quest_id.to_string()),
                json!({ "questId": quest_id }),
            );
        }
        Ok(())
    }

    /// Compute the hidden, revealed, or available state for one inactive quest definition.
    pub(crate) fn compute_inactive_quest_status(
        &self,
        profile_id: &str,
        definition: &QuestDefinition,
        revealed_override: bool,
    ) -> Result<String, ProgressionError> {
        let revealed = revealed_override
            || match &definition.reveal_condition {
                Some(condition) => self.evaluate_condition(profile_id, condition)?,
                None => true,
            };
        if !revealed {
            return Ok("hidden".to_string());
        }
        let available = match &definition.availability_condition {
            Some(condition) => self.evaluate_condition(profile_id, condition)?,
            None => true,
        };
        Ok(if available {
            "available".to_string()
        } else {
            "revealed".to_string()
        })
    }

    /// Seed or refresh active stage objectives from their bound counter values for one quest.
    pub(crate) fn sync_active_stage_counter_objectives(
        &mut self,
        profile_id: &str,
        quest_id: &str,
    ) -> Result<(), ProgressionError> {
        let Some((stage_index, objectives)) = self
            .profiles
            .get(profile_id)
            .and_then(|profile| profile.quests.get(quest_id))
            .map(|quest| {
                (
                    quest.current_stage_index,
                    quest.objectives.keys().cloned().collect::<Vec<_>>(),
                )
            })
        else {
            return Ok(());
        };
        let definition = self
            .quest_definitions
            .get(quest_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "quest",
                id: quest_id.to_string(),
            })?;
        let Some(stage) = definition.stages.get(stage_index) else {
            return Ok(());
        };
        for objective_id in objectives {
            let Some(objective) = stage
                .objectives
                .iter()
                .find(|objective| objective.id == objective_id)
            else {
                continue;
            };
            let Some(counter_id) = &objective.counter_id else {
                continue;
            };
            let value = self.get_counter(profile_id, counter_id)?;
            self.set_quest_objective(profile_id, quest_id, &objective_id, value)?;
        }
        Ok(())
    }

    /// Finalize one quest, emit completion events, and queue any authored reward record.
    pub(crate) fn finish_quest(
        &mut self,
        profile_id: &str,
        quest_id: &str,
    ) -> Result<(), ProgressionError> {
        let definition = self
            .quest_definitions
            .get(quest_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "quest",
                id: quest_id.to_string(),
            })?;
        let (completion_count, reward_record) = {
            let profile = self.profile_mut(profile_id)?;
            let quest = profile.quests.get_mut(quest_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "quest '{}' is not active for profile '{}'",
                    quest_id, profile_id
                ))
            })?;
            if quest.status == "completed" {
                return Ok(());
            }
            quest.status = "completed".to_string();
            quest.completion_count += 1;
            let reward_record = definition.reward_payload.as_ref().map(|payload| {
                let reward_id = format!("quest:{}:{}", quest_id, quest.completion_count);
                let record = RewardRecord {
                    id: reward_id.clone(),
                    source_kind: "quest".to_string(),
                    source_id: quest_id.to_string(),
                    payload: payload.clone(),
                    state: RewardState::Pending,
                    external_receipt: None,
                };
                profile.rewards.insert(reward_id, record.clone());
                record
            });
            (quest.completion_count, reward_record)
        };
        self.bump_revision();
        self.push_event(
            "quest_completed",
            Some(profile_id.to_string()),
            Some(quest_id.to_string()),
            json!({ "questId": quest_id, "completionCount": completion_count }),
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
        self.refresh_quest_lifecycle(profile_id)?;
        Ok(())
    }
}
