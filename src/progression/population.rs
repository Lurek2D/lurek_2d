//! Owns offline population templates, generated virtual profiles, simulation ticks, and materialization helpers.
//! Stores deterministic identity generation, archetype weighting, leaderboard seeding, and activity simulation.
//! Exposes public store helpers for defining templates, generating runs, advancing time, and querying statistics.
//! Validates population templates so seeded generation remains bounded, deterministic, and leaderboard-aware.
//! Simulates virtual profile progress without requiring remote services, hidden threads, or nondeterministic timers.
//! Materializes virtual profiles into canonical store state only when callers explicitly need concrete profile data.
//! Maintains reverse indexes between virtual handles and real profiles so dematerialization stays lossless and safe.
//! Integrates with leaderboards, rivals, and events while keeping population-specific bookkeeping out of `store.rs`.
//! Keeps simulation-side state local to progression so tests can prove seeded replay and budgeted catch-up behavior.
//! Open this file when changing bot generation, offline simulation, or virtual profile persistence boundaries.
use super::*;

impl ProgressionStore {
    /// Define one reusable virtual population template.
    pub fn define_population_template(
        &mut self,
        id: &str,
        definition: PopulationTemplateDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        self.validate_population_template_definition(id, &definition)?;
        self.population_templates.insert(id.to_string(), definition);
        Ok(())
    }

    /// Validate one authored population template and return a report.
    pub fn validate_population_template(&self, id: &str) -> Result<JsonValue, ProgressionError> {
        let definition = self.population_templates.get(id).ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "population_template",
                id: id.to_string(),
            }
        })?;
        let mut errors = Vec::new();
        if let Err(err) = self.validate_population_template_definition(id, definition) {
            errors.push(err.to_string());
        }
        Ok(json!({
            "ok": errors.is_empty(),
            "template_id": id,
            "errors": errors,
        }))
    }

    /// Generate one population instance from a template.
    pub fn generate_population(
        &mut self,
        template_id: &str,
        population_id: Option<String>,
    ) -> Result<JsonValue, ProgressionError> {
        let template = self
            .population_templates
            .get(template_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "population_template",
                id: template_id.to_string(),
            })?;
        let id = match population_id {
            Some(id) => id,
            None => self.next_population_id(template_id),
        };
        validate_id(&id)?;
        if self.populations.contains_key(&id) {
            return Err(ProgressionError::InvalidOperation(format!(
                "population '{}' already exists",
                id
            )));
        }
        let state = self.build_population_state(&id, &template)?;
        let generated_count = state.generated_count;
        self.register_population_index(&state);
        self.populations.insert(id.clone(), state);
        self.bump_revision();
        self.push_event(
            "population_generated",
            None,
            Some(template_id.to_string()),
            json!({
                "populationId": id,
                "templateId": template_id,
                "generatedCount": generated_count,
            }),
        );
        self.get_population(&id)
    }

    /// Return one population snapshot by population id or virtual profile id.
    pub fn get_population(&self, handle_or_id: &str) -> Result<JsonValue, ProgressionError> {
        let population = self.population_by_handle(handle_or_id)?;
        Ok(self.population_json(population))
    }

    /// Update one generated population by a logical time delta in seconds.
    pub fn update_population(
        &mut self,
        handle_or_id: &str,
        seconds: f64,
    ) -> Result<JsonValue, ProgressionError> {
        ensure_finite(seconds, "population dt")?;
        if seconds < 0.0 {
            return Err(ProgressionError::InvalidValue(
                "population dt must be >= 0".to_string(),
            ));
        }
        let population_id = self.resolve_population_id(handle_or_id)?;
        let template_id = self
            .populations
            .get(&population_id)
            .map(|population| population.template_id.clone())
            .ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "population '{}' does not exist",
                    population_id
                ))
            })?;
        let template = self
            .population_templates
            .get(&template_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "population_template",
                id: template_id.clone(),
            })?;
        let old_time = self
            .populations
            .get(&population_id)
            .map(|population| population.logical_time)
            .unwrap_or(0.0);
        let paused = self
            .populations
            .get(&population_id)
            .map(|population| population.paused)
            .unwrap_or(false);
        if paused || seconds <= 0.0 {
            return Ok(json!({
                "population_id": population_id,
                "template_id": template_id,
                "paused": paused,
                "dt": seconds,
                "logical_time": old_time,
                "updated_profiles": 0,
                "score_updates": 0,
            }));
        }
        let new_time = old_time + seconds;
        let seed = self.options.seed;
        let mut updated_profiles = 0usize;
        let mut score_updates = 0usize;
        {
            let population = self.population_mut_by_id(&population_id)?;
            population.logical_time = new_time;
            for profile in population.profiles.values_mut() {
                if profile.materialized || !profile.active {
                    continue;
                }
                updated_profiles += 1;
                let Some(archetype) = template
                    .archetypes
                    .iter()
                    .find(|candidate| candidate.id == profile.archetype_id)
                else {
                    continue;
                };
                let activity = if archetype.activity.max >= archetype.activity.min {
                    (archetype.activity.min + archetype.activity.max) as f64 / 2.0
                } else {
                    archetype.activity.min as f64
                };
                for (leaderboard_id, leaderboard_definition) in &template.leaderboards {
                    let Some(score) = profile.leaderboard_scores.get_mut(leaderboard_id) else {
                        continue;
                    };
                    let noise = stable_signed_unit(
                        seed,
                        &[
                            population_id.as_str(),
                            profile.profile_id.as_str(),
                            leaderboard_id.as_str(),
                            &format!("{new_time:.6}"),
                        ],
                    );
                    let drift = (profile.base_skill - *score)
                        * leaderboard_definition.progression.mean_reversion
                        * seconds.max(1.0);
                    let volatility = leaderboard_definition.progression.volatility
                        * (1.0 + activity / 10.0)
                        * noise
                        * seconds.max(1.0);
                    *score += drift + volatility;
                    score_updates += 1;
                }
            }
        }
        self.bump_revision();
        self.push_event(
            "population_updated",
            None,
            Some(population_id.clone()),
            json!({
                "populationId": population_id,
                "templateId": template_id,
                "dt": seconds,
                "logicalTimeBefore": old_time,
                "logicalTimeAfter": new_time,
                "updatedProfiles": updated_profiles,
                "scoreUpdates": score_updates,
            }),
        );
        Ok(json!({
            "population_id": population_id,
            "template_id": template_id,
            "paused": false,
            "dt": seconds,
            "logical_time": new_time,
            "updated_profiles": updated_profiles,
            "score_updates": score_updates,
        }))
    }

    /// Advance one population until an absolute logical time.
    pub fn simulate_population_until(
        &mut self,
        handle_or_id: &str,
        logical_time: f64,
    ) -> Result<JsonValue, ProgressionError> {
        ensure_finite(logical_time, "population logical_time")?;
        let current_time = self.population_by_handle(handle_or_id)?.logical_time;
        if logical_time < current_time {
            return Err(ProgressionError::InvalidValue(format!(
                "population logical_time {} must be >= current time {}",
                logical_time, current_time
            )));
        }
        self.update_population(handle_or_id, logical_time - current_time)
    }

    /// Pause one population simulation stream.
    pub fn pause_population(&mut self, handle_or_id: &str) -> Result<JsonValue, ProgressionError> {
        let population_id = self.resolve_population_id(handle_or_id)?;
        {
            let population = self.population_mut_by_id(&population_id)?;
            population.paused = true;
        }
        let snapshot = self.get_population(&population_id)?;
        self.bump_revision();
        self.push_event(
            "population_paused",
            None,
            Some(population_id.clone()),
            json!({ "populationId": snapshot["id"] }),
        );
        Ok(snapshot)
    }

    /// Resume one paused population simulation stream.
    pub fn resume_population(&mut self, handle_or_id: &str) -> Result<JsonValue, ProgressionError> {
        let population_id = self.resolve_population_id(handle_or_id)?;
        {
            let population = self.population_mut_by_id(&population_id)?;
            population.paused = false;
        }
        let snapshot = self.get_population(&population_id)?;
        self.bump_revision();
        self.push_event(
            "population_resumed",
            None,
            Some(population_id.clone()),
            json!({ "populationId": snapshot["id"] }),
        );
        Ok(snapshot)
    }

    /// Remove one generated population instance.
    pub fn remove_population(
        &mut self,
        handle_or_id: &str,
        remove_materialized_profiles: bool,
    ) -> Result<bool, ProgressionError> {
        let population_id = self.resolve_population_id(handle_or_id)?;
        let Some(population) = self.populations.remove(&population_id) else {
            return Ok(false);
        };
        for profile_id in population.profiles.keys() {
            self.virtual_profile_index.remove(profile_id);
            if remove_materialized_profiles
                && population
                    .profiles
                    .get(profile_id)
                    .map(|profile| profile.materialized)
                    .unwrap_or(false)
            {
                self.profiles.remove(profile_id);
            }
        }
        self.bump_revision();
        self.push_event(
            "population_removed",
            None,
            Some(population_id.clone()),
            json!({
                "populationId": population_id,
                "templateId": population.template_id,
                "removeMaterializedProfiles": remove_materialized_profiles,
            }),
        );
        Ok(true)
    }

    /// Rebuild one generated population from its authored template.
    pub fn regenerate_population(
        &mut self,
        handle_or_id: &str,
        remove_materialized_profiles: bool,
    ) -> Result<JsonValue, ProgressionError> {
        let population_id = self.resolve_population_id(handle_or_id)?;
        let existing = self
            .populations
            .get(&population_id)
            .cloned()
            .ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "population '{}' does not exist",
                    population_id
                ))
            })?;
        let template = self
            .population_templates
            .get(&existing.template_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "population_template",
                id: existing.template_id.clone(),
            })?;
        for profile in existing.profiles.values() {
            self.virtual_profile_index.remove(&profile.profile_id);
            if remove_materialized_profiles && profile.materialized {
                self.profiles.remove(&profile.profile_id);
            }
        }
        let state = self.build_population_state(&population_id, &template)?;
        self.register_population_index(&state);
        self.populations.insert(population_id.clone(), state);
        self.bump_revision();
        self.push_event(
            "population_regenerated",
            None,
            Some(population_id.clone()),
            json!({
                "populationId": population_id,
                "templateId": template.id,
                "removeMaterializedProfiles": remove_materialized_profiles,
            }),
        );
        self.get_population(&population_id)
    }

    /// Return aggregate score statistics for one generated population.
    pub fn get_population_statistics(
        &self,
        handle_or_id: &str,
        leaderboard_id: Option<&str>,
    ) -> Result<JsonValue, ProgressionError> {
        let population = self.population_by_handle(handle_or_id)?;
        let mut leaderboards = BTreeMap::new();
        for configured_id in population
            .profiles
            .values()
            .flat_map(|profile| profile.leaderboard_scores.keys().cloned())
            .collect::<BTreeSet<_>>()
        {
            if leaderboard_id.is_some() && leaderboard_id != Some(configured_id.as_str()) {
                continue;
            }
            let mut scores = population
                .profiles
                .values()
                .filter_map(|profile| profile.leaderboard_scores.get(&configured_id).copied())
                .collect::<Vec<_>>();
            scores.sort_by(|left, right| left.total_cmp(right));
            let count = scores.len();
            let average = if count == 0 {
                0.0
            } else {
                scores.iter().sum::<f64>() / count as f64
            };
            leaderboards.insert(
                configured_id,
                json!({
                    "count": count,
                    "min": scores.first().copied(),
                    "max": scores.last().copied(),
                    "average": average,
                }),
            );
        }
        Ok(json!({
            "population_id": population.id,
            "template_id": population.template_id,
            "logical_time": population.logical_time,
            "leaderboards": leaderboards,
        }))
    }

    /// List generated virtual profiles for one population.
    pub fn list_population_profiles(
        &self,
        handle_or_id: &str,
        materialized: Option<bool>,
        limit: Option<usize>,
    ) -> Result<Vec<JsonValue>, ProgressionError> {
        let population = self.population_by_handle(handle_or_id)?;
        let cap = limit.unwrap_or(population.profiles.len());
        Ok(population
            .profiles
            .values()
            .filter(|profile| {
                materialized
                    .map(|wanted| profile.materialized == wanted)
                    .unwrap_or(true)
            })
            .take(cap)
            .map(|profile| self.virtual_profile_json(population, profile))
            .collect())
    }

    /// Materialize one virtual population profile as a normal profile.
    pub fn materialize_population_profile(
        &mut self,
        profile_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        if self.profiles.contains_key(profile_id) {
            let virtual_profile = self.virtual_profile(profile_id)?;
            if virtual_profile.materialized {
                return self.get_profile_snapshot(profile_id);
            }
            return Err(ProgressionError::InvalidOperation(format!(
                "profile '{}' already exists",
                profile_id
            )));
        }
        let population_id = self.resolve_population_id(profile_id)?;
        let template_id = self
            .populations
            .get(&population_id)
            .map(|population| population.template_id.clone())
            .ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "population '{}' does not exist",
                    population_id
                ))
            })?;
        let virtual_profile = self.virtual_profile(profile_id)?.clone();
        if self.profiles.len() >= self.options.max_profiles {
            return Err(ProgressionError::LimitExceeded(format!(
                "max_profiles={}",
                self.options.max_profiles
            )));
        }
        let mut profile = ProfileState::from_options(
            profile_id,
            ProfileOptions {
                kind: Some("virtual_population_profile".to_string()),
                display_name: Some(virtual_profile.display_name.clone()),
                avatar: virtual_profile.avatar.clone(),
                tags: virtual_profile.tags.clone(),
                metadata: BTreeMap::from([
                    ("population_id".to_string(), json!(population_id)),
                    ("population_template_id".to_string(), json!(template_id)),
                    (
                        "population_archetype_id".to_string(),
                        json!(virtual_profile.archetype_id),
                    ),
                    ("virtual_profile".to_string(), json!(true)),
                ]),
                template: None,
            },
        );
        profile.leaderboard_scores = virtual_profile.leaderboard_scores.clone();
        self.profiles.insert(profile_id.to_string(), profile);
        if let Some(population) = self.populations.get_mut(&population_id) {
            if let Some(profile) = population.profiles.get_mut(profile_id) {
                profile.materialized = true;
            }
        }
        self.bump_revision();
        self.push_event(
            "virtual_profile_materialized",
            Some(profile_id.to_string()),
            Some(population_id.clone()),
            json!({
                "populationId": population_id,
                "profileId": profile_id,
            }),
        );
        self.get_profile_snapshot(profile_id)
    }

    /// Dematerialize one virtual population profile and optionally remove the real profile state.
    pub fn dematerialize_population_profile(
        &mut self,
        profile_id: &str,
        remove_profile: bool,
    ) -> Result<bool, ProgressionError> {
        let population_id = self.resolve_population_id(profile_id)?;
        let Some(population) = self.populations.get_mut(&population_id) else {
            return Ok(false);
        };
        let Some(virtual_profile) = population.profiles.get_mut(profile_id) else {
            return Ok(false);
        };
        if !virtual_profile.materialized {
            return Ok(false);
        }
        virtual_profile.materialized = false;
        if remove_profile {
            self.profiles.remove(profile_id);
        }
        self.bump_revision();
        self.push_event(
            "virtual_profile_dematerialized",
            Some(profile_id.to_string()),
            Some(population_id.clone()),
            json!({
                "populationId": population_id,
                "profileId": profile_id,
                "removeProfile": remove_profile,
            }),
        );
        Ok(true)
    }

    /// Validate that a population template is deterministic, bounded, and references authored leaderboard state.
    pub(crate) fn validate_population_template_definition(
        &self,
        id: &str,
        definition: &PopulationTemplateDefinition,
    ) -> Result<(), ProgressionError> {
        if definition.id != id {
            return Err(ProgressionError::InvalidValue(format!(
                "population template definition id '{}' must match '{}'",
                definition.id, id
            )));
        }
        validate_id(&definition.id_prefix)?;
        if definition.count == 0 {
            return Err(ProgressionError::InvalidValue(format!(
                "population template '{}' count must be >= 1",
                id
            )));
        }
        let mode = definition.identity.name_generator.mode.as_str();
        if !matches!(mode, "" | "parts") {
            return Err(ProgressionError::InvalidValue(format!(
                "population template '{}' name generator mode '{}' is unsupported",
                id, mode
            )));
        }
        if mode == "parts"
            && (definition.identity.name_generator.prefixes.is_empty()
                || definition.identity.name_generator.suffixes.is_empty())
        {
            return Err(ProgressionError::InvalidValue(format!(
                "population template '{}' parts generator requires prefixes and suffixes",
                id
            )));
        }
        if definition.archetypes.is_empty() {
            return Err(ProgressionError::InvalidValue(format!(
                "population template '{}' requires at least one archetype",
                id
            )));
        }
        let mut archetype_ids = BTreeSet::new();
        for archetype in &definition.archetypes {
            validate_id(&archetype.id)?;
            if !archetype_ids.insert(archetype.id.clone()) {
                return Err(ProgressionError::InvalidValue(format!(
                    "population template '{}' contains duplicate archetype '{}'",
                    id, archetype.id
                )));
            }
            if archetype.weight == 0 {
                return Err(ProgressionError::InvalidValue(format!(
                    "population archetype '{}' weight must be >= 1",
                    archetype.id
                )));
            }
            if archetype.activity.max < archetype.activity.min {
                return Err(ProgressionError::InvalidValue(format!(
                    "population archetype '{}' activity max must be >= min",
                    archetype.id
                )));
            }
            ensure_finite(archetype.skill.mean, "population archetype skill mean")?;
            ensure_finite(
                archetype.skill.deviation,
                "population archetype skill deviation",
            )?;
            if archetype.skill.deviation < 0.0 {
                return Err(ProgressionError::InvalidValue(format!(
                    "population archetype '{}' skill deviation must be >= 0",
                    archetype.id
                )));
            }
        }
        if definition.leaderboards.is_empty() {
            return Err(ProgressionError::InvalidValue(format!(
                "population template '{}' requires at least one leaderboard",
                id
            )));
        }
        for (leaderboard_id, leaderboard_definition) in &definition.leaderboards {
            validate_id(leaderboard_id)?;
            if self.options.strict && !self.leaderboard_definitions.contains_key(leaderboard_id) {
                return Err(ProgressionError::MissingDefinition {
                    kind: "leaderboard",
                    id: leaderboard_id.clone(),
                });
            }
            if !matches!(
                leaderboard_definition.initial_score.distribution.as_str(),
                "" | "normal"
            ) {
                return Err(ProgressionError::InvalidValue(format!(
                    "population leaderboard '{}' initial distribution '{}' is unsupported",
                    leaderboard_id, leaderboard_definition.initial_score.distribution
                )));
            }
            if !matches!(
                leaderboard_definition.progression.mode.as_str(),
                "" | "bounded_random_walk"
            ) {
                return Err(ProgressionError::InvalidValue(format!(
                    "population leaderboard '{}' progression mode '{}' is unsupported",
                    leaderboard_id, leaderboard_definition.progression.mode
                )));
            }
            ensure_finite(
                leaderboard_definition.progression.volatility,
                "population leaderboard volatility",
            )?;
            ensure_finite(
                leaderboard_definition.progression.mean_reversion,
                "population leaderboard mean_reversion",
            )?;
            if leaderboard_definition.progression.volatility < 0.0 {
                return Err(ProgressionError::InvalidValue(format!(
                    "population leaderboard '{}' volatility must be >= 0",
                    leaderboard_id
                )));
            }
            if leaderboard_definition.progression.mean_reversion < 0.0 {
                return Err(ProgressionError::InvalidValue(format!(
                    "population leaderboard '{}' mean_reversion must be >= 0",
                    leaderboard_id
                )));
            }
        }
        Ok(())
    }

    fn population_by_handle(
        &self,
        handle_or_id: &str,
    ) -> Result<&PopulationState, ProgressionError> {
        let id = self.resolve_population_id(handle_or_id)?;
        self.populations.get(&id).ok_or_else(|| {
            ProgressionError::InvalidOperation(format!("population '{}' does not exist", id))
        })
    }

    fn population_mut_by_id(&mut self, id: &str) -> Result<&mut PopulationState, ProgressionError> {
        self.populations.get_mut(id).ok_or_else(|| {
            ProgressionError::InvalidOperation(format!("population '{}' does not exist", id))
        })
    }

    fn resolve_population_id(&self, handle_or_id: &str) -> Result<String, ProgressionError> {
        if self.populations.contains_key(handle_or_id) {
            return Ok(handle_or_id.to_string());
        }
        if let Some(population_id) = self.virtual_profile_index.get(handle_or_id) {
            return Ok(population_id.clone());
        }
        Err(ProgressionError::InvalidOperation(format!(
            "population or virtual profile '{}' does not exist",
            handle_or_id
        )))
    }

    fn virtual_profile(&self, profile_id: &str) -> Result<&VirtualProfileState, ProgressionError> {
        let population_id = self.resolve_population_id(profile_id)?;
        self.populations
            .get(&population_id)
            .and_then(|population| population.profiles.get(profile_id))
            .ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "virtual profile '{}' does not exist",
                    profile_id
                ))
            })
    }

    fn next_population_id(&self, template_id: &str) -> String {
        let mut suffix = 1usize;
        loop {
            let candidate = format!("{}_{}", template_id, suffix);
            if !self.populations.contains_key(&candidate) {
                return candidate;
            }
            suffix += 1;
        }
    }

    fn build_population_state(
        &self,
        population_id: &str,
        template: &PopulationTemplateDefinition,
    ) -> Result<PopulationState, ProgressionError> {
        self.validate_population_template_definition(&template.id, template)?;
        let mut profiles = BTreeMap::new();
        for index in 0..template.count {
            let profile_id = format!("{}{}", template.id_prefix, index + 1);
            validate_id(&profile_id)?;
            if profiles.contains_key(&profile_id)
                || self.virtual_profile_index.contains_key(&profile_id)
            {
                return Err(ProgressionError::InvalidOperation(format!(
                    "virtual profile '{}' already exists",
                    profile_id
                )));
            }
            let archetype = select_population_archetype(
                &template.archetypes,
                self.options.seed,
                population_id,
                index,
            )?;
            let display_name = generate_population_name(
                &template.id_prefix,
                index,
                &template.identity,
                self.options.seed,
                population_id,
            );
            let avatar = select_optional_string(
                &template.identity.avatars,
                self.options.seed,
                &[population_id, "avatar", &index.to_string()],
            );
            let base_skill = archetype.skill.mean
                + archetype.skill.deviation
                    * stable_signed_unit(
                        self.options.seed,
                        &[
                            population_id,
                            "base_skill",
                            &archetype.id,
                            &index.to_string(),
                        ],
                    );
            let mut leaderboard_scores = BTreeMap::new();
            for (leaderboard_id, leaderboard_definition) in &template.leaderboards {
                let offset = match leaderboard_definition.initial_score.distribution.as_str() {
                    "" | "normal" => {
                        stable_gaussianish(
                            self.options.seed,
                            &[population_id, leaderboard_id, "initial", &index.to_string()],
                        ) * archetype.skill.deviation
                    }
                    other => {
                        return Err(ProgressionError::InvalidValue(format!(
                            "population leaderboard '{}' initial distribution '{}' is unsupported",
                            leaderboard_id, other
                        )))
                    }
                };
                leaderboard_scores.insert(leaderboard_id.clone(), base_skill + offset);
            }
            profiles.insert(
                profile_id.clone(),
                VirtualProfileState {
                    profile_id,
                    display_name,
                    avatar,
                    tags: template.identity.tags.clone(),
                    archetype_id: archetype.id.clone(),
                    base_skill,
                    active: true,
                    materialized: false,
                    leaderboard_scores,
                },
            );
        }
        Ok(PopulationState {
            id: population_id.to_string(),
            template_id: template.id.clone(),
            logical_time: 0.0,
            paused: false,
            generated_count: template.count,
            profiles,
        })
    }

    fn register_population_index(&mut self, population: &PopulationState) {
        for profile_id in population.profiles.keys() {
            self.virtual_profile_index
                .insert(profile_id.clone(), population.id.clone());
        }
    }

    fn population_json(&self, population: &PopulationState) -> JsonValue {
        let materialized_count = population
            .profiles
            .values()
            .filter(|profile| profile.materialized)
            .count();
        let active_count = population
            .profiles
            .values()
            .filter(|profile| profile.active)
            .count();
        json!({
            "id": population.id,
            "template_id": population.template_id,
            "logical_time": population.logical_time,
            "paused": population.paused,
            "generated_count": population.generated_count,
            "active_count": active_count,
            "materialized_count": materialized_count,
            "profiles": population
                .profiles
                .values()
                .take(10)
                .map(|profile| self.virtual_profile_json(population, profile))
                .collect::<Vec<_>>(),
        })
    }

    fn virtual_profile_json(
        &self,
        population: &PopulationState,
        profile: &VirtualProfileState,
    ) -> JsonValue {
        json!({
            "population_id": population.id,
            "template_id": population.template_id,
            "profile_id": profile.profile_id,
            "display_name": profile.display_name,
            "avatar": profile.avatar,
            "tags": profile.tags,
            "archetype_id": profile.archetype_id,
            "base_skill": profile.base_skill,
            "active": profile.active,
            "materialized": profile.materialized,
            "leaderboard_scores": profile.leaderboard_scores,
        })
    }
}
