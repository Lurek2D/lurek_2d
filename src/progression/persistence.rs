//! Owns progression snapshot transport, retained change records, and bounded changeset envelope validation.
//! Stores the rules for exporting retained revisions, applying envelopes, acknowledging history, and compaction.
//! Exposes public persistence helpers that keep sync payloads deterministic, versioned, and transport-neutral.
//! Validates record counts and serialized sizes before export or import so malformed payloads fail early.
//! Encodes merge-policy outcomes, conflict reports, and source-target revision metadata for caller inspection.
//! Integrates with the main store snapshot model without adding backend concerns, auth state, or network code.
//! Keeps offline sync semantics local to progression so tests can prove replay, ack, and compaction behavior.
//! Open this file when changing save transport, incremental replication, or retained-history validation rules.
use super::*;
use crate::progression::{
    ChangesetApplyOptions, ChangesetConflict, ChangesetEnvelope, ChangesetMergePolicy,
};

const MAX_CHANGESET_RECORDS: usize = 1024;
const MAX_CHANGESET_RECORD_BYTES: usize = 256 * 1024;
const MAX_CHANGESET_TOTAL_BYTES: usize = 2 * 1024 * 1024;

impl ProgressionStore {
    /// Export a bounded changeset envelope containing retained records after `revision`.
    pub fn export_changeset(
        &self,
        revision: u64,
        max_records: Option<usize>,
    ) -> Result<ChangesetEnvelope, ProgressionError> {
        if matches!(max_records, Some(0)) {
            return Err(ProgressionError::InvalidValue(
                "changeset max_records must be >= 1".to_string(),
            ));
        }
        let mut records = self.export_changes_since(revision);
        let mut truncated = false;
        if let Some(limit) = max_records {
            if records.len() > limit {
                let keep_from = records.len() - limit;
                records = records.split_off(keep_from);
                truncated = true;
            }
        }
        let to_revision = records
            .last()
            .map(|record| record.revision)
            .unwrap_or(revision);
        let envelope = ChangesetEnvelope {
            schema_version: self.schema_version,
            definition_hash: self.definition_hash(),
            from_revision: revision,
            to_revision,
            truncated,
            records,
        };
        self.validate_change_records(&envelope.records)?;
        Ok(envelope)
    }

    /// Apply a validated changeset envelope with optional schema and definition-hash checks.
    pub fn apply_changeset_envelope(
        &mut self,
        envelope: ChangesetEnvelope,
        require_definition_hash_match: bool,
        require_schema_match: bool,
    ) -> Result<JsonValue, ProgressionError> {
        self.apply_changeset_envelope_with_options(
            envelope,
            ChangesetApplyOptions {
                require_definition_hash_match,
                require_schema_match,
                merge_policy: ChangesetMergePolicy::Replace,
            },
        )
    }

    /// Apply a validated changeset envelope using explicit merge-policy options and return any detected conflicts.
    pub fn apply_changeset_envelope_with_options(
        &mut self,
        envelope: ChangesetEnvelope,
        options: ChangesetApplyOptions,
    ) -> Result<JsonValue, ProgressionError> {
        self.validate_changeset_envelope(
            &envelope,
            options.require_definition_hash_match,
            options.require_schema_match,
        )?;
        if envelope.records.is_empty() {
            return Ok(self.changeset_apply_result(
                false,
                "empty",
                &envelope,
                (self.revision, self.revision),
                &options,
                &[],
            ));
        }
        let latest = envelope
            .records
            .iter()
            .max_by_key(|record| record.revision)
            .cloned()
            .ok_or_else(|| {
                ProgressionError::InvalidValue("changeset missing latest record".to_string())
            })?;
        let remote = ProgressionStore::from_snapshot(latest.snapshot.clone())?;
        let conflicts = self.collect_changeset_conflicts(&envelope, &remote);
        let target_revision_before = self.revision;
        match options.merge_policy {
            ChangesetMergePolicy::Replace => {
                self.load_snapshot(latest.snapshot)?;
                self.last_recorded_change_revision = self.revision;
                Ok(self.changeset_apply_result(
                    true,
                    if conflicts.is_empty() {
                        "applied"
                    } else {
                        "replaced_with_conflicts"
                    },
                    &envelope,
                    (target_revision_before, self.revision),
                    &options,
                    &conflicts,
                ))
            }
            ChangesetMergePolicy::KeepLocal => {
                if !conflicts.is_empty() {
                    return Ok(self.changeset_apply_result(
                        false,
                        "kept_local_due_to_conflicts",
                        &envelope,
                        (target_revision_before, self.revision),
                        &options,
                        &conflicts,
                    ));
                }
                if latest.revision <= self.revision {
                    return Ok(self.changeset_apply_result(
                        false,
                        "stale_source",
                        &envelope,
                        (target_revision_before, self.revision),
                        &options,
                        &conflicts,
                    ));
                }
                self.load_snapshot(latest.snapshot)?;
                self.last_recorded_change_revision = self.revision;
                Ok(self.changeset_apply_result(
                    true,
                    "applied",
                    &envelope,
                    (target_revision_before, self.revision),
                    &options,
                    &conflicts,
                ))
            }
            ChangesetMergePolicy::RejectConflicts => {
                if !conflicts.is_empty() {
                    return Ok(self.changeset_apply_result(
                        false,
                        "conflict",
                        &envelope,
                        (target_revision_before, self.revision),
                        &options,
                        &conflicts,
                    ));
                }
                if latest.revision <= self.revision {
                    return Ok(self.changeset_apply_result(
                        false,
                        "stale_source",
                        &envelope,
                        (target_revision_before, self.revision),
                        &options,
                        &conflicts,
                    ));
                }
                self.load_snapshot(latest.snapshot)?;
                self.last_recorded_change_revision = self.revision;
                Ok(self.changeset_apply_result(
                    true,
                    "applied",
                    &envelope,
                    (target_revision_before, self.revision),
                    &options,
                    &conflicts,
                ))
            }
        }
    }

    /// Drop acknowledged retained change records at or below `revision`.
    pub fn acknowledge_changes_through(&mut self, revision: u64) -> JsonValue {
        let before_count = self.change_log.len();
        while self
            .change_log
            .front()
            .map(|record| record.revision <= revision)
            .unwrap_or(false)
        {
            self.change_log.pop_front();
        }
        let after_count = self.change_log.len();
        json!({
            "acknowledgedThrough": revision,
            "removedCount": before_count.saturating_sub(after_count),
            "remainingCount": after_count,
            "oldestRemainingRevision": self.change_log.front().map(|record| record.revision),
            "latestRemainingRevision": self.change_log.back().map(|record| record.revision),
        })
    }

    /// Compact the retained change log to at most `max_records` newest records.
    pub fn compact_changes(&mut self, max_records: usize) -> Result<JsonValue, ProgressionError> {
        if max_records == 0 {
            return Err(ProgressionError::InvalidValue(
                "changeset max_records must be >= 1".to_string(),
            ));
        }
        let before_count = self.change_log.len();
        while self.change_log.len() > max_records {
            self.change_log.pop_front();
        }
        let after_count = self.change_log.len();
        Ok(json!({
            "maxRecords": max_records,
            "beforeCount": before_count,
            "afterCount": after_count,
            "removedCount": before_count.saturating_sub(after_count),
            "oldestRemainingRevision": self.change_log.front().map(|record| record.revision),
            "latestRemainingRevision": self.change_log.back().map(|record| record.revision),
        }))
    }

    fn validate_changeset_envelope(
        &self,
        envelope: &ChangesetEnvelope,
        require_definition_hash_match: bool,
        require_schema_match: bool,
    ) -> Result<(), ProgressionError> {
        if require_schema_match && envelope.schema_version != self.schema_version {
            return Err(ProgressionError::InvalidValue(format!(
                "changeset schema_version {} does not match store schema_version {}",
                envelope.schema_version, self.schema_version
            )));
        }
        if require_definition_hash_match && envelope.definition_hash != self.definition_hash() {
            return Err(ProgressionError::InvalidOperation(format!(
                "changeset definition_hash '{}' does not match store definition_hash '{}'",
                envelope.definition_hash,
                self.definition_hash()
            )));
        }
        self.validate_change_records(&envelope.records)?;
        let mut previous_revision = envelope.from_revision;
        for record in &envelope.records {
            if record.revision <= previous_revision {
                return Err(ProgressionError::InvalidValue(format!(
                    "changeset revisions must be strictly increasing after {}",
                    previous_revision
                )));
            }
            previous_revision = record.revision;
        }
        if envelope.to_revision < envelope.from_revision {
            return Err(ProgressionError::InvalidValue(format!(
                "changeset to_revision {} must be >= from_revision {}",
                envelope.to_revision, envelope.from_revision
            )));
        }
        let expected_to_revision = envelope
            .records
            .last()
            .map(|record| record.revision)
            .unwrap_or(envelope.from_revision);
        if envelope.to_revision != expected_to_revision {
            return Err(ProgressionError::InvalidValue(format!(
                "changeset to_revision {} does not match latest record revision {}",
                envelope.to_revision, expected_to_revision
            )));
        }
        Ok(())
    }

    fn collect_changeset_conflicts(
        &self,
        envelope: &ChangesetEnvelope,
        remote: &ProgressionStore,
    ) -> Vec<ChangesetConflict> {
        if self.revision <= envelope.from_revision {
            return Vec::new();
        }
        let mut conflicts = Vec::new();
        for profile_id in self.profiles.keys() {
            if remote.profiles.contains_key(profile_id) {
                continue;
            }
            conflicts.push(ChangesetConflict {
                kind: "profile_missing_in_source".to_string(),
                profile_id: Some(profile_id.clone()),
                definition_id: None,
                local_revision: self.revision,
                source_revision: envelope.to_revision,
                details: json!({
                    "reason": "local profile would be removed by incoming snapshot",
                }),
            });
        }
        for (profile_id, local_profile) in &self.profiles {
            let Some(remote_profile) = remote.profiles.get(profile_id) else {
                continue;
            };
            let mut quest_conflict_count = 0usize;
            for (quest_id, local_quest) in &local_profile.quests {
                let Some(remote_quest) = remote_profile.quests.get(quest_id) else {
                    continue;
                };
                let local_json = serde_json::to_value(local_quest).unwrap_or(JsonValue::Null);
                let remote_json = serde_json::to_value(remote_quest).unwrap_or(JsonValue::Null);
                if local_json == remote_json {
                    continue;
                }
                quest_conflict_count += 1;
                conflicts.push(ChangesetConflict {
                    kind: "quest_branch_diverged".to_string(),
                    profile_id: Some(profile_id.clone()),
                    definition_id: Some(quest_id.clone()),
                    local_revision: self.revision,
                    source_revision: envelope.to_revision,
                    details: json!({
                        "localStatus": local_quest.status,
                        "remoteStatus": remote_quest.status,
                        "localStageIndex": local_quest.current_stage_index,
                        "remoteStageIndex": remote_quest.current_stage_index,
                    }),
                });
            }
            let local_json = serde_json::to_value(local_profile).unwrap_or(JsonValue::Null);
            let remote_json = serde_json::to_value(remote_profile).unwrap_or(JsonValue::Null);
            if local_json == remote_json {
                continue;
            }
            let mut domains = changed_profile_domains(local_profile, remote_profile);
            if quest_conflict_count > 0 {
                domains.retain(|domain| *domain != "quests");
            }
            if domains.is_empty() {
                continue;
            }
            conflicts.push(ChangesetConflict {
                kind: "profile_state_diverged".to_string(),
                profile_id: Some(profile_id.clone()),
                definition_id: None,
                local_revision: self.revision,
                source_revision: envelope.to_revision,
                details: json!({
                    "domains": domains,
                }),
            });
        }
        conflicts
    }

    fn changeset_apply_result(
        &self,
        applied: bool,
        reason: &str,
        envelope: &ChangesetEnvelope,
        target_revisions: (u64, u64),
        options: &ChangesetApplyOptions,
        conflicts: &[ChangesetConflict],
    ) -> JsonValue {
        let (target_revision_before, target_revision_after) = target_revisions;
        json!({
            "applied": applied,
            "revision": target_revision_after,
            "changeCount": envelope.records.len(),
            "schemaVersion": envelope.schema_version,
            "definitionHash": envelope.definition_hash,
            "sourceRevision": envelope.to_revision,
            "sourceFromRevision": envelope.from_revision,
            "targetRevisionBefore": target_revision_before,
            "targetRevisionAfter": target_revision_after,
            "truncated": envelope.truncated,
            "reason": reason,
            "mergePolicy": options.merge_policy,
            "requireSchemaMatch": options.require_schema_match,
            "requireDefinitionHashMatch": options.require_definition_hash_match,
            "conflictCount": conflicts.len(),
            "conflicts": conflicts,
        })
    }

    /// Validate record count and serialized byte limits before exporting or applying a retained changeset.
    pub(crate) fn validate_change_records(
        &self,
        records: &[ChangeRecord],
    ) -> Result<(), ProgressionError> {
        if records.len() > MAX_CHANGESET_RECORDS {
            return Err(ProgressionError::LimitExceeded(format!(
                "changeset record count {} exceeds limit {}",
                records.len(),
                MAX_CHANGESET_RECORDS
            )));
        }
        let mut total_bytes = 0usize;
        for (index, record) in records.iter().enumerate() {
            let encoded = serde_json::to_vec(&record.snapshot).map_err(|err| {
                ProgressionError::InvalidValue(format!(
                    "changeset record {} snapshot serialization failed: {}",
                    index, err
                ))
            })?;
            let record_bytes = encoded.len();
            if record_bytes > MAX_CHANGESET_RECORD_BYTES {
                return Err(ProgressionError::LimitExceeded(format!(
                    "changeset record {} is {} bytes and exceeds limit {}",
                    index, record_bytes, MAX_CHANGESET_RECORD_BYTES
                )));
            }
            total_bytes = total_bytes.saturating_add(record_bytes);
            if total_bytes > MAX_CHANGESET_TOTAL_BYTES {
                return Err(ProgressionError::LimitExceeded(format!(
                    "changeset payload is {} bytes and exceeds limit {}",
                    total_bytes, MAX_CHANGESET_TOTAL_BYTES
                )));
            }
        }
        Ok(())
    }
}

fn changed_profile_domains(local: &ProfileState, remote: &ProfileState) -> Vec<&'static str> {
    let mut domains = Vec::new();
    if !same_json(&local.tags, &remote.tags) || !same_json(&local.metadata, &remote.metadata) {
        domains.push("identity");
    }
    if !same_json(&local.counters, &remote.counters) {
        domains.push("counters");
    }
    if !same_json(&local.attributes, &remote.attributes) {
        domains.push("attributes");
    }
    if !same_json(&local.resources, &remote.resources) {
        domains.push("resources");
    }
    if !same_json(&local.modifiers, &remote.modifiers) {
        domains.push("modifiers");
    }
    if !same_json(&local.levels, &remote.levels) {
        domains.push("levels");
    }
    if !same_json(&local.skills, &remote.skills) {
        domains.push("skills");
    }
    if !same_json(&local.active_traits, &remote.active_traits)
        || !same_json(&local.acquired_perks, &remote.acquired_perks)
    {
        domains.push("traits_perks");
    }
    if !same_json(&local.prestiges, &remote.prestiges) {
        domains.push("prestiges");
    }
    if !same_json(&local.collections, &remote.collections) {
        domains.push("collections");
    }
    if !same_json(&local.rivals, &remote.rivals) {
        domains.push("rivals");
    }
    if !same_json(&local.challenges, &remote.challenges) {
        domains.push("challenges");
    }
    if !same_json(&local.quests, &remote.quests) {
        domains.push("quests");
    }
    if !same_json(&local.achievements, &remote.achievements) {
        domains.push("achievements");
    }
    if !same_json(&local.leaderboard_scores, &remote.leaderboard_scores) {
        domains.push("leaderboards");
    }
    if !same_json(&local.rewards, &remote.rewards) {
        domains.push("rewards");
    }
    domains
}

fn same_json<T: serde::Serialize>(left: &T, right: &T) -> bool {
    serde_json::to_value(left).ok() == serde_json::to_value(right).ok()
}
