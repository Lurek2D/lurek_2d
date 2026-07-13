//! Owns profile lifecycle, templates, traits, perks, skills, and the profile-facing identity mutation surface.
//! Stores canonical profile identity, tags, metadata, trait handles, skill levels, and acquired perk ownership.
//! Exposes public store helpers for creating profiles, applying templates, mutating identity, and querying shape.
//! Validates template and trait definitions against authored counters, attributes, resources, and level tracks.
//! Applies template payloads into canonical profile state while preserving caller-selected identity overrides.
//! Owns trait, perk, and skill rules so profile progression stays separate from counters, quests, and snapshots.
//! Spends attribute-backed skill costs and cooldown state here because learned-skill behavior is profile-local.
//! Integrates with quests, achievements, and rewards through store events without pulling those systems inside.
//! Keeps profile-shaped rules out of `store.rs` so identity and advancement changes have a focused maintenance home.
//! Open this file when changing profile creation, template application, traits, perks, or learned-skill behavior.
use super::*;

impl ProgressionStore {
    /// Validate that a profile template only references definitions that already exist in this store.
    pub(crate) fn validate_profile_template_definition(
        &self,
        definition: &ProfileTemplateDefinition,
    ) -> Result<(), ProgressionError> {
        if !self.options.strict {
            return Ok(());
        }
        for counter_id in definition.counters.keys() {
            if !self.counter_definitions.contains_key(counter_id) {
                return Err(ProgressionError::MissingDefinition {
                    kind: "counter",
                    id: counter_id.clone(),
                });
            }
        }
        for attribute_id in definition.attributes.keys() {
            if !self.attribute_definitions.contains_key(attribute_id) {
                return Err(ProgressionError::MissingDefinition {
                    kind: "attribute",
                    id: attribute_id.clone(),
                });
            }
        }
        for resource_id in definition.resources.keys() {
            if !self.resource_definitions.contains_key(resource_id) {
                return Err(ProgressionError::MissingDefinition {
                    kind: "resource",
                    id: resource_id.clone(),
                });
            }
        }
        for track_id in definition.experience.keys() {
            if !self.level_track_definitions.contains_key(track_id) {
                return Err(ProgressionError::MissingDefinition {
                    kind: "level_track",
                    id: track_id.clone(),
                });
            }
        }
        Ok(())
    }

    /// Validate that a trait modifier list only targets authored attribute definitions.
    pub(crate) fn validate_trait_definition(
        &self,
        definition: &TraitDefinition,
    ) -> Result<(), ProgressionError> {
        if !self.options.strict {
            return Ok(());
        }
        for TraitModifierDefinition { target_id, .. } in &definition.modifiers {
            if !self.attribute_definitions.contains_key(target_id) {
                return Err(ProgressionError::MissingDefinition {
                    kind: "attribute",
                    id: target_id.clone(),
                });
            }
        }
        Ok(())
    }

    /// Apply one template to an existing profile after validation, optionally preserving caller-authored identity fields.
    pub(crate) fn apply_profile_template_inner(
        &mut self,
        profile_id: &str,
        template_id: &str,
        preserve_identity_overrides: bool,
    ) -> Result<(), ProgressionError> {
        let template = self
            .profile_templates
            .get(template_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "profile_template",
                id: template_id.to_string(),
            })?;
        self.validate_profile_template_definition(&template)?;
        let mut counters = Vec::with_capacity(template.counters.len());
        for (counter_id, value) in &template.counters {
            let definition = self.counter_definitions.get(counter_id).ok_or_else(|| {
                ProgressionError::MissingDefinition {
                    kind: "counter",
                    id: counter_id.clone(),
                }
            })?;
            counters.push((
                counter_id.clone(),
                sanitize_counter_value(definition, *value)?,
            ));
        }
        let mut attributes = Vec::with_capacity(template.attributes.len());
        for (attribute_id, value) in &template.attributes {
            let definition = self
                .attribute_definitions
                .get(attribute_id)
                .ok_or_else(|| ProgressionError::MissingDefinition {
                    kind: "attribute",
                    id: attribute_id.clone(),
                })?;
            attributes.push((
                attribute_id.clone(),
                bound_value(*value, definition.min, definition.max),
            ));
        }
        let mut resources = Vec::with_capacity(template.resources.len());
        for (resource_id, value) in &template.resources {
            let definition = self.resource_definitions.get(resource_id).ok_or_else(|| {
                ProgressionError::MissingDefinition {
                    kind: "resource",
                    id: resource_id.clone(),
                }
            })?;
            resources.push((
                resource_id.clone(),
                bound_value(*value, Some(definition.min), Some(definition.max)),
            ));
        }
        let mut experience = Vec::with_capacity(template.experience.len());
        for (track_id, value) in &template.experience {
            let definition = self.level_track_definitions.get(track_id).ok_or_else(|| {
                ProgressionError::MissingDefinition {
                    kind: "level_track",
                    id: track_id.clone(),
                }
            })?;
            experience.push((track_id.clone(), compute_level_state(definition, *value)?));
        }
        {
            let profile = self.profile_mut(profile_id)?;
            if let Some(kind) = template.kind {
                if !preserve_identity_overrides || profile.kind == "profile" {
                    profile.kind = kind;
                }
            }
            if let Some(display_name) = template.display_name {
                if !preserve_identity_overrides || profile.display_name == profile.id {
                    profile.display_name = display_name;
                }
            }
            if let Some(avatar) = template.avatar {
                if !preserve_identity_overrides || profile.avatar.is_none() {
                    profile.avatar = Some(avatar);
                }
            }
            for tag in template.tags {
                profile.tags.insert(tag);
            }
            for (key, value) in template.metadata {
                if preserve_identity_overrides {
                    profile.metadata.entry(key).or_insert(value);
                } else {
                    profile.metadata.insert(key, value);
                }
            }
            profile.metadata.insert(
                "__template_id".to_string(),
                JsonValue::String(template_id.to_string()),
            );
            for (counter_id, value) in counters {
                profile.counters.insert(counter_id, CounterState { value });
            }
            for (attribute_id, base) in attributes {
                profile
                    .attributes
                    .insert(attribute_id, AttributeState { base });
            }
            for (resource_id, value) in resources {
                profile
                    .resources
                    .insert(resource_id, ResourceState { value });
            }
            for (track_id, (level, experience)) in experience {
                profile
                    .levels
                    .insert(track_id, LevelState { level, experience });
            }
        }
        Ok(())
    }

    /// Create a new profile or reject duplicate ids.
    pub fn create_profile(
        &mut self,
        id: &str,
        options: ProfileOptions,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        if self.profiles.contains_key(id) {
            return Err(ProgressionError::InvalidOperation(format!(
                "profile '{}' already exists",
                id
            )));
        }
        if self.profiles.len() >= self.options.max_profiles {
            return Err(ProgressionError::LimitExceeded(format!(
                "max_profiles={}",
                self.options.max_profiles
            )));
        }
        let template = options.template.clone();
        let profile = ProfileState::from_options(id, options);
        self.profiles.insert(id.to_string(), profile);
        if let Some(template_id) = template {
            self.apply_profile_template_inner(id, &template_id, true)?;
        }
        self.bump_revision();
        self.push_event(
            "profile_created",
            Some(id.to_string()),
            None,
            json!({ "profileId": id }),
        );
        if let Some(template_id) = self
            .profiles
            .get(id)
            .and_then(|profile| profile.metadata.get("__template_id"))
            .and_then(|value| value.as_str())
        {
            self.push_event(
                "profile_template_applied",
                Some(id.to_string()),
                Some(template_id.to_string()),
                json!({ "profileId": id, "templateId": template_id }),
            );
        }
        Ok(())
    }

    /// Ensure a profile exists, returning whether it was newly created.
    pub fn ensure_profile(
        &mut self,
        id: &str,
        options: ProfileOptions,
    ) -> Result<bool, ProgressionError> {
        if self.profiles.contains_key(id) {
            return Ok(false);
        }
        self.create_profile(id, options)?;
        Ok(true)
    }

    /// Update mutable identity fields for an existing profile.
    pub fn update_profile(
        &mut self,
        id: &str,
        patch: ProfileOptions,
    ) -> Result<(), ProgressionError> {
        let profile = self.profile_mut(id)?;
        if let Some(kind) = patch.kind {
            profile.kind = kind;
        }
        if let Some(display_name) = patch.display_name {
            profile.display_name = display_name;
        }
        if let Some(avatar) = patch.avatar {
            profile.avatar = Some(avatar);
        }
        for tag in patch.tags {
            profile.tags.insert(tag);
        }
        for (key, value) in patch.metadata {
            profile.metadata.insert(key, value);
        }
        self.bump_revision();
        self.push_event(
            "profile_updated",
            Some(id.to_string()),
            None,
            json!({ "profileId": id }),
        );
        Ok(())
    }

    /// Remove one profile and all of its progression state.
    pub fn remove_profile(&mut self, id: &str) -> Result<bool, ProgressionError> {
        let removed = self.profiles.remove(id).is_some();
        if removed {
            if let Some(population_id) = self.virtual_profile_index.get(id).cloned() {
                if let Some(population) = self.populations.get_mut(&population_id) {
                    if let Some(profile) = population.profiles.get_mut(id) {
                        profile.materialized = false;
                    }
                }
            }
            self.bump_revision();
            self.push_event(
                "profile_removed",
                Some(id.to_string()),
                None,
                json!({ "profileId": id }),
            );
        }
        Ok(removed)
    }

    /// Add one tag to a profile.
    pub fn add_profile_tag(&mut self, id: &str, tag: &str) -> Result<(), ProgressionError> {
        let profile = self.profile_mut(id)?;
        profile.tags.insert(tag.to_string());
        self.bump_revision();
        self.push_event(
            "profile_tag_added",
            Some(id.to_string()),
            None,
            json!({ "tag": tag }),
        );
        self.refresh_quest_lifecycle(id)?;
        Ok(())
    }

    /// Remove one tag from a profile.
    pub fn remove_profile_tag(&mut self, id: &str, tag: &str) -> Result<(), ProgressionError> {
        let profile = self.profile_mut(id)?;
        profile.tags.remove(tag);
        self.bump_revision();
        self.push_event(
            "profile_tag_removed",
            Some(id.to_string()),
            None,
            json!({ "tag": tag }),
        );
        self.refresh_quest_lifecycle(id)?;
        Ok(())
    }

    /// Set one metadata field on a profile.
    pub fn set_profile_metadata(
        &mut self,
        id: &str,
        key: &str,
        value: JsonValue,
    ) -> Result<(), ProgressionError> {
        let profile = self.profile_mut(id)?;
        profile.metadata.insert(key.to_string(), value);
        self.bump_revision();
        self.push_event(
            "profile_metadata_set",
            Some(id.to_string()),
            None,
            json!({ "key": key }),
        );
        Ok(())
    }

    /// Remove one metadata field from a profile.
    pub fn remove_profile_metadata(&mut self, id: &str, key: &str) -> Result<(), ProgressionError> {
        let profile = self.profile_mut(id)?;
        profile.metadata.remove(key);
        self.bump_revision();
        self.push_event(
            "profile_metadata_removed",
            Some(id.to_string()),
            None,
            json!({ "key": key }),
        );
        Ok(())
    }

    /// Return whether a profile exists.
    pub fn has_profile(&self, id: &str) -> bool {
        self.profiles.contains_key(id)
    }

    /// Return a serializable profile snapshot.
    pub fn get_profile_snapshot(&self, id: &str) -> Result<JsonValue, ProgressionError> {
        let profile = self
            .profiles
            .get(id)
            .ok_or_else(|| ProgressionError::MissingProfile(id.to_string()))?;
        Ok(json!({
            "id": profile.id,
            "kind": profile.kind,
            "display_name": profile.display_name,
            "avatar": profile.avatar,
            "tags": profile.tags.iter().cloned().collect::<Vec<_>>(),
            "metadata": profile.metadata,
            "counter_count": profile.counters.len(),
            "attribute_count": profile.attributes.len(),
            "resource_count": profile.resources.len(),
            "modifier_count": profile.modifiers.len(),
            "skill_count": profile.skills.len(),
            "trait_count": profile.active_traits.len(),
            "perk_count": profile.acquired_perks.len(),
            "prestige_count": profile.prestiges.len(),
            "collection_count": profile.collections.len(),
            "rival_count": profile.rivals.len(),
            "challenge_count": profile.challenges.len(),
            "quest_count": profile.quests.len(),
            "achievement_count": profile.achievements.len(),
            "leaderboard_score_count": profile.leaderboard_scores.len(),
            "reward_count": profile.rewards.len(),
        }))
    }

    /// Return profile snapshots in deterministic id order.
    pub fn list_profiles(&self) -> Vec<JsonValue> {
        self.profiles
            .values()
            .map(|profile| {
                json!({
                    "id": profile.id,
                    "kind": profile.kind,
                    "display_name": profile.display_name,
                    "tags": profile.tags.iter().cloned().collect::<Vec<_>>(),
                })
            })
            .collect()
    }

    /// Return the current profile count.
    pub fn count_profiles(&self) -> usize {
        self.profiles.len()
    }

    /// Define one reusable profile template.
    pub fn define_profile_template(
        &mut self,
        id: &str,
        definition: ProfileTemplateDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        self.validate_profile_template_definition(&definition)?;
        self.profile_templates.insert(id.to_string(), definition);
        Ok(())
    }

    /// Apply one authored template to an existing profile.
    pub fn apply_profile_template(
        &mut self,
        profile_id: &str,
        template_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        self.apply_profile_template_inner(profile_id, template_id, false)?;
        self.bump_revision();
        self.push_event(
            "profile_template_applied",
            Some(profile_id.to_string()),
            Some(template_id.to_string()),
            json!({ "profileId": profile_id, "templateId": template_id }),
        );
        self.get_profile_snapshot(profile_id)
    }

    /// Define one reusable trait.
    pub fn define_trait(
        &mut self,
        id: &str,
        definition: TraitDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        self.validate_trait_definition(&definition)?;
        self.trait_definitions.insert(id.to_string(), definition);
        Ok(())
    }

    /// Apply one trait and all of its authored modifiers.
    pub fn apply_trait(
        &mut self,
        profile_id: &str,
        trait_id: &str,
    ) -> Result<bool, ProgressionError> {
        let definition = self
            .trait_definitions
            .get(trait_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "trait",
                id: trait_id.to_string(),
            })?;
        let mut handles = Vec::with_capacity(definition.modifiers.len());
        let start_modifier_id = self.next_modifier_id;
        {
            let profile = self.profile_mut(profile_id)?;
            if profile.active_traits.contains_key(trait_id) {
                return Ok(false);
            }
            for (index, modifier) in definition.modifiers.into_iter().enumerate() {
                let handle = format!("mod_{}", start_modifier_id + index as u64);
                handles.push(handle.clone());
                profile.modifiers.insert(
                    handle.clone(),
                    ModifierState {
                        handle,
                        target_id: modifier.target_id,
                        layer: modifier.layer.unwrap_or_else(|| "final_add".to_string()),
                        value: modifier.value,
                        remaining: None,
                        source: Some(format!("trait:{trait_id}")),
                        tags: vec!["trait".to_string(), trait_id.to_string()],
                    },
                );
            }
            profile
                .active_traits
                .insert(trait_id.to_string(), handles.clone());
        }
        self.next_modifier_id = start_modifier_id + handles.len() as u64;
        self.bump_revision();
        self.push_event(
            "trait_applied",
            Some(profile_id.to_string()),
            Some(trait_id.to_string()),
            json!({ "traitId": trait_id, "modifierHandles": handles }),
        );
        Ok(true)
    }

    /// Remove one active trait and its modifiers.
    pub fn remove_trait(
        &mut self,
        profile_id: &str,
        trait_id: &str,
    ) -> Result<bool, ProgressionError> {
        let removed_handles = {
            let profile = self.profile_mut(profile_id)?;
            let Some(handles) = profile.active_traits.remove(trait_id) else {
                return Ok(false);
            };
            for handle in &handles {
                profile.modifiers.remove(handle);
            }
            handles
        };
        self.bump_revision();
        self.push_event(
            "trait_removed",
            Some(profile_id.to_string()),
            Some(trait_id.to_string()),
            json!({ "traitId": trait_id, "modifierHandles": removed_handles }),
        );
        Ok(true)
    }

    /// Return whether a trait is active on the profile.
    pub fn has_trait(&self, profile_id: &str, trait_id: &str) -> Result<bool, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        Ok(profile.active_traits.contains_key(trait_id))
    }

    /// Return active trait ids in deterministic order.
    pub fn list_traits(&self, profile_id: &str) -> Result<Vec<String>, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        Ok(profile.active_traits.keys().cloned().collect())
    }

    /// Define one perk unlock.
    pub fn define_perk(
        &mut self,
        id: &str,
        definition: PerkDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        if self.options.strict {
            if let Some(track_id) = &definition.track_id {
                if !self.level_track_definitions.contains_key(track_id) {
                    return Err(ProgressionError::MissingDefinition {
                        kind: "level_track",
                        id: track_id.clone(),
                    });
                }
            }
            for trait_id in &definition.trait_ids {
                if !self.trait_definitions.contains_key(trait_id) {
                    return Err(ProgressionError::MissingDefinition {
                        kind: "trait",
                        id: trait_id.clone(),
                    });
                }
            }
        }
        self.perk_definitions.insert(id.to_string(), definition);
        Ok(())
    }

    /// Define one skill track.
    pub fn define_skill(
        &mut self,
        id: &str,
        definition: SkillDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        if definition.max_level == 0 {
            return Err(ProgressionError::InvalidValue(format!(
                "skill '{}' max_level must be >= 1",
                id
            )));
        }
        ensure_finite(definition.cost, "skill cost")?;
        ensure_finite(definition.cooldown, "skill cooldown")?;
        if definition.cost < 0.0 || definition.cooldown < 0.0 {
            return Err(ProgressionError::InvalidValue(format!(
                "skill '{}' cost and cooldown must be >= 0",
                id
            )));
        }
        if self.options.strict {
            if let Some(resource_id) = &definition.resource_id {
                if !self.attribute_definitions.contains_key(resource_id) {
                    return Err(ProgressionError::MissingDefinition {
                        kind: "attribute",
                        id: resource_id.clone(),
                    });
                }
            }
        }
        self.skill_definitions.insert(id.to_string(), definition);
        Ok(())
    }

    /// Increase one skill by one level up to its configured cap.
    pub fn learn_skill(
        &mut self,
        profile_id: &str,
        skill_id: &str,
    ) -> Result<bool, ProgressionError> {
        let definition = self
            .skill_definitions
            .get(skill_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "skill",
                id: skill_id.to_string(),
            })?;
        let new_level = {
            let profile = self.profile_mut(profile_id)?;
            let state = profile
                .skills
                .entry(skill_id.to_string())
                .or_insert(SkillState {
                    level: 0,
                    cooldown_remaining: 0.0,
                });
            if state.level >= definition.max_level {
                return Ok(false);
            }
            state.level += 1;
            state.level
        };
        self.bump_revision();
        self.push_event(
            "skill_learned",
            Some(profile_id.to_string()),
            Some(skill_id.to_string()),
            json!({ "skillId": skill_id, "level": new_level }),
        );
        Ok(true)
    }

    /// Use one learned skill, spending its optional attribute cost and starting cooldown.
    pub fn use_skill(
        &mut self,
        profile_id: &str,
        skill_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let definition = self
            .skill_definitions
            .get(skill_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "skill",
                id: skill_id.to_string(),
            })?;
        let state = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?
            .skills
            .get(skill_id)
            .cloned()
            .unwrap_or(SkillState {
                level: 0,
                cooldown_remaining: 0.0,
            });
        if state.level < 1 {
            return Ok(json!({ "ok": false, "reason": "not learned" }));
        }
        if state.cooldown_remaining > 0.0 {
            return Ok(json!({
                "ok": false,
                "reason": "on cooldown",
                "cooldown_remaining": state.cooldown_remaining,
            }));
        }
        if let Some(resource_id) = &definition.resource_id {
            let current = self.get_attribute(profile_id, resource_id, AttributeMode::Effective)?;
            if current < definition.cost {
                return Ok(json!({ "ok": false, "reason": "not enough resource" }));
            }
            let base = self.get_attribute(profile_id, resource_id, AttributeMode::Base)?;
            let _ = self.set_attribute_base(profile_id, resource_id, base - definition.cost)?;
        }
        let cooldown = {
            let profile = self.profile_mut(profile_id)?;
            let state = profile
                .skills
                .entry(skill_id.to_string())
                .or_insert(SkillState {
                    level: 0,
                    cooldown_remaining: 0.0,
                });
            state.cooldown_remaining = definition.cooldown;
            state.cooldown_remaining
        };
        self.bump_revision();
        self.push_event(
            "skill_used",
            Some(profile_id.to_string()),
            Some(skill_id.to_string()),
            json!({
                "skillId": skill_id,
                "cooldown": cooldown,
                "cost": definition.cost,
                "resourceId": definition.resource_id,
            }),
        );
        Ok(json!({ "ok": true, "cooldown_remaining": cooldown }))
    }

    /// Return the current learned level for one skill.
    pub fn get_skill_level(
        &self,
        profile_id: &str,
        skill_id: &str,
    ) -> Result<u32, ProgressionError> {
        if !self.skill_definitions.contains_key(skill_id) {
            return Err(ProgressionError::MissingDefinition {
                kind: "skill",
                id: skill_id.to_string(),
            });
        }
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        Ok(profile
            .skills
            .get(skill_id)
            .map(|state| state.level)
            .unwrap_or(0))
    }

    /// Return remaining cooldown seconds for one skill.
    pub fn get_skill_cooldown(
        &self,
        profile_id: &str,
        skill_id: &str,
    ) -> Result<f64, ProgressionError> {
        if !self.skill_definitions.contains_key(skill_id) {
            return Err(ProgressionError::MissingDefinition {
                kind: "skill",
                id: skill_id.to_string(),
            });
        }
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        Ok(profile
            .skills
            .get(skill_id)
            .map(|state| state.cooldown_remaining)
            .unwrap_or(0.0))
    }

    /// Acquire one perk if its requirements are satisfied.
    pub fn acquire_perk(
        &mut self,
        profile_id: &str,
        perk_id: &str,
    ) -> Result<bool, ProgressionError> {
        let definition = self.perk_definitions.get(perk_id).cloned().ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "perk",
                id: perk_id.to_string(),
            }
        })?;
        {
            let profile = self
                .profiles
                .get(profile_id)
                .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
            if profile.acquired_perks.contains(perk_id) {
                return Ok(false);
            }
        }
        if definition.require_level > 0 {
            let track_id = definition.track_id.as_ref().ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "perk '{}' requires a track_id when require_level > 0",
                    perk_id
                ))
            })?;
            if self.get_level(profile_id, track_id)? < definition.require_level {
                return Ok(false);
            }
        }
        for trait_id in &definition.trait_ids {
            let _ = self.apply_trait(profile_id, trait_id)?;
        }
        {
            let profile = self.profile_mut(profile_id)?;
            profile.acquired_perks.insert(perk_id.to_string());
        }
        self.bump_revision();
        self.push_event(
            "perk_acquired",
            Some(profile_id.to_string()),
            Some(perk_id.to_string()),
            json!({ "perkId": perk_id, "traits": definition.trait_ids }),
        );
        Ok(true)
    }

    /// Return whether a perk was acquired by the profile.
    pub fn has_perk(&self, profile_id: &str, perk_id: &str) -> Result<bool, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        Ok(profile.acquired_perks.contains(perk_id))
    }
}
