//! Owns deterministic progression store state, shared tables, retained events, and change history.
//! Stores profiles, authored definitions, revision counters, snapshots, and transaction bookkeeping.
//! Exposes creation, snapshot, update, and cross-slice helpers reused by focused progression owners.
//! Applies shared validation, event buffering, change retention, and revision bumps at store root.
//! Defines private structs for counters, attributes, quests, rewards, populations, rivals, and peers.
//! Keeps serialization, migration snapshots, and debug export close to the data they persist and replay.
//! Integrates focused owners for profile, counter, attribute, quest, level, formula, and reward logic.
//! Leaves domain rules in sibling files and keeps only the seams those owners depend on together.
//! Avoids renderer, network, audio, and Lua conversion concerns so progression state stays headless.
//! Provides mutation plumbing that Rust tests, Lua bindings, changesets, and evidence artifacts use.
//! Retains store-wide helpers for ids, bounds, formulas, deterministic sampling, and population setup.
//! Open this file when a change touches shared tables, snapshots, transactions, or multi-slice coordination.
use crate::progression::types::{
    AchievementDefinition, AttributeDefinition, AttributeMode, ChallengeTemplateDefinition,
    ChangeRecord, CollectionDefinition, CollectionItemDefinition, ComparisonOp, CounterDefinition,
    CounterKind, DerivedValueDefinition, DerivedValueInput, EventRecord, LeaderboardDefinition,
    LeaderboardRankMode, LeaderboardSort, LevelTrackDefinition, ModifierAddOptions, PerkDefinition,
    PopulationArchetypeDefinition, PopulationTemplateDefinition, PrestigeDefinition,
    PrestigePreserveDefinition, PrestigeResetDefinition, ProfileOptions, ProfileTemplateDefinition,
    ProgressionCondition, ProgressionStoreOptions, QuestDefinition, QuestJournalEntry,
    ResourceDefinition, RewardRecord, RewardState, SeasonArchiveRecord, SeasonDefinition,
    SeasonResetDefinition, SeasonState, SkillDefinition, TraitDefinition, TraitModifierDefinition,
};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value as JsonValue};
use sha1::{Digest, Sha1};
use std::collections::{BTreeMap, BTreeSet, VecDeque};
use thiserror::Error;

use self::formula::{parse_formula_expression, FormulaExpr};

/// Stable error type returned by progression domain operations.
#[derive(Debug, Error)]
pub enum ProgressionError {
    /// The requested profile does not exist.
    #[error("profile '{0}' does not exist")]
    MissingProfile(String),
    /// The requested definition does not exist.
    #[error("{kind} definition '{id}' does not exist")]
    MissingDefinition { kind: &'static str, id: String },
    /// The requested id is invalid.
    #[error("invalid id: {0}")]
    InvalidId(String),
    /// The store hit a configured bound.
    #[error("store limit exceeded: {0}")]
    LimitExceeded(String),
    /// The provided value is outside the supported domain.
    #[error("invalid value: {0}")]
    InvalidValue(String),
    /// The requested operation conflicts with authored state.
    #[error("invalid operation: {0}")]
    InvalidOperation(String),
}

/// Summary returned after a committed mutation batch.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChangeSummary {
    /// Store revision assigned to the committed batch.
    pub revision: u64,
    /// Number of low-level operations applied in the batch.
    pub changes: usize,
}

/// Human-readable explanation of one attribute value.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AttributeExplanation {
    /// Base value before modifiers.
    pub base: f64,
    /// Sum of additive modifier contributions.
    pub modifier_total: f64,
    /// Effective bounded value.
    pub effective: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct CounterState {
    value: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ModifierState {
    handle: String,
    target_id: String,
    layer: String,
    value: f64,
    remaining: Option<f64>,
    source: Option<String>,
    tags: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct AttributeState {
    base: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ResourceState {
    value: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct LevelState {
    experience: f64,
    level: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct SkillState {
    level: u32,
    cooldown_remaining: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct PrestigeProfileState {
    count: u32,
    last_applied_at: Option<f64>,
    last_applied_revision: Option<u64>,
    lifetime_counters: BTreeMap<String, f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct QuestObjectiveState {
    current: f64,
    status: String,
    visible: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct QuestState {
    status: String,
    current_stage_index: usize,
    objectives: BTreeMap<String, QuestObjectiveState>,
    completion_count: u32,
    revealed_override: bool,
    journal: Vec<QuestJournalEntry>,
    next_journal_index: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ChallengeState {
    status: String,
    current: f64,
    started_at: f64,
    ends_at: Option<f64>,
    completion_count: u32,
    last_completed_at: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct QuestCounterBinding {
    quest_id: String,
    stage_index: usize,
    objective_id: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct AchievementState {
    unlock_count: u32,
    unlocked: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct CollectionItemState {
    collected: bool,
    discovered: bool,
}

#[derive(Debug, Clone)]
struct LeaderboardRow {
    profile_id: String,
    score: f64,
    rank: u64,
    percentile: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct RivalState {
    rival_profile_id: String,
    leaderboard_id: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct VirtualProfileState {
    profile_id: String,
    display_name: String,
    avatar: Option<String>,
    tags: Vec<String>,
    archetype_id: String,
    base_skill: f64,
    active: bool,
    materialized: bool,
    leaderboard_scores: BTreeMap<String, f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct PopulationState {
    id: String,
    template_id: String,
    logical_time: f64,
    paused: bool,
    generated_count: usize,
    profiles: BTreeMap<String, VirtualProfileState>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ProfileState {
    id: String,
    kind: String,
    display_name: String,
    avatar: Option<String>,
    tags: BTreeSet<String>,
    metadata: BTreeMap<String, JsonValue>,
    counters: BTreeMap<String, CounterState>,
    attributes: BTreeMap<String, AttributeState>,
    resources: BTreeMap<String, ResourceState>,
    modifiers: BTreeMap<String, ModifierState>,
    levels: BTreeMap<String, LevelState>,
    skills: BTreeMap<String, SkillState>,
    active_traits: BTreeMap<String, Vec<String>>,
    acquired_perks: BTreeSet<String>,
    prestiges: BTreeMap<String, PrestigeProfileState>,
    collections: BTreeMap<String, BTreeMap<String, CollectionItemState>>,
    rivals: BTreeMap<String, RivalState>,
    challenges: BTreeMap<String, ChallengeState>,
    quests: BTreeMap<String, QuestState>,
    achievements: BTreeMap<String, AchievementState>,
    leaderboard_scores: BTreeMap<String, f64>,
    rewards: BTreeMap<String, RewardRecord>,
}

impl ProfileState {
    fn from_options(id: &str, options: ProfileOptions) -> Self {
        Self {
            id: id.to_string(),
            kind: options.kind.unwrap_or_else(|| "profile".to_string()),
            display_name: options.display_name.unwrap_or_else(|| id.to_string()),
            avatar: options.avatar,
            tags: options.tags.into_iter().collect(),
            metadata: options.metadata,
            counters: BTreeMap::new(),
            attributes: BTreeMap::new(),
            resources: BTreeMap::new(),
            modifiers: BTreeMap::new(),
            levels: BTreeMap::new(),
            skills: BTreeMap::new(),
            active_traits: BTreeMap::new(),
            acquired_perks: BTreeSet::new(),
            prestiges: BTreeMap::new(),
            collections: BTreeMap::new(),
            rivals: BTreeMap::new(),
            challenges: BTreeMap::new(),
            quests: BTreeMap::new(),
            achievements: BTreeMap::new(),
            leaderboard_scores: BTreeMap::new(),
            rewards: BTreeMap::new(),
        }
    }
}

/// One queued progression mutation used by transactions.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ProgressionOperation {
    /// Add to a counter value.
    AddCounter {
        /// Target profile id.
        profile_id: String,
        /// Counter id.
        counter_id: String,
        /// Delta amount.
        amount: f64,
    },
    /// Set a counter value directly.
    SetCounter {
        /// Target profile id.
        profile_id: String,
        /// Counter id.
        counter_id: String,
        /// New value.
        value: f64,
    },
    /// Set attribute base value.
    SetAttributeBase {
        /// Target profile id.
        profile_id: String,
        /// Attribute id.
        attribute_id: String,
        /// New base value.
        value: f64,
    },
    /// Set a resource value directly.
    SetResource {
        /// Target profile id.
        profile_id: String,
        /// Resource id.
        resource_id: String,
        /// New resource value.
        value: f64,
    },
    /// Add a modifier to one attribute target.
    AddModifier {
        /// Target profile id.
        profile_id: String,
        /// Attribute id modified by this entry.
        target_id: String,
        /// Add options for the modifier.
        options: ModifierAddOptions,
    },
    /// Set quest objective progress directly.
    SetQuestObjective {
        /// Target profile id.
        profile_id: String,
        /// Quest id.
        quest_id: String,
        /// Objective id.
        objective_id: String,
        /// New progress value.
        value: f64,
    },
    /// Add experience to a named track.
    AddExperience {
        /// Target profile id.
        profile_id: String,
        /// Track id.
        track_id: String,
        /// XP amount.
        amount: f64,
    },
    /// Submit one leaderboard score.
    SubmitScore {
        /// Target profile id.
        profile_id: String,
        /// Leaderboard id.
        leaderboard_id: String,
        /// Submitted score.
        score: f64,
    },
}

/// Transaction object used to batch operations into a single revision.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ProgressionTransaction {
    /// Optional caller-supplied transaction id.
    pub id: Option<String>,
    operations: Vec<ProgressionOperation>,
}

impl ProgressionTransaction {
    /// Create an empty transaction.
    pub fn new(id: Option<String>) -> Self {
        Self {
            id,
            operations: Vec::new(),
        }
    }

    /// Append one counter-add operation.
    pub fn add_counter(&mut self, profile_id: String, counter_id: String, amount: f64) {
        self.operations.push(ProgressionOperation::AddCounter {
            profile_id,
            counter_id,
            amount,
        });
    }

    /// Append one counter-set operation.
    pub fn set_counter(&mut self, profile_id: String, counter_id: String, value: f64) {
        self.operations.push(ProgressionOperation::SetCounter {
            profile_id,
            counter_id,
            value,
        });
    }

    /// Append one attribute-base set operation.
    pub fn set_attribute_base(&mut self, profile_id: String, attribute_id: String, value: f64) {
        self.operations
            .push(ProgressionOperation::SetAttributeBase {
                profile_id,
                attribute_id,
                value,
            });
    }

    /// Append one resource-set operation.
    pub fn set_resource(&mut self, profile_id: String, resource_id: String, value: f64) {
        self.operations.push(ProgressionOperation::SetResource {
            profile_id,
            resource_id,
            value,
        });
    }

    /// Append one modifier-add operation.
    pub fn add_modifier(
        &mut self,
        profile_id: String,
        target_id: String,
        options: ModifierAddOptions,
    ) {
        self.operations.push(ProgressionOperation::AddModifier {
            profile_id,
            target_id,
            options,
        });
    }

    /// Append one quest-objective set operation.
    pub fn set_quest_objective(
        &mut self,
        profile_id: String,
        quest_id: String,
        objective_id: String,
        value: f64,
    ) {
        self.operations
            .push(ProgressionOperation::SetQuestObjective {
                profile_id,
                quest_id,
                objective_id,
                value,
            });
    }

    /// Append one experience-add operation.
    pub fn add_experience(&mut self, profile_id: String, track_id: String, amount: f64) {
        self.operations.push(ProgressionOperation::AddExperience {
            profile_id,
            track_id,
            amount,
        });
    }

    /// Append one leaderboard score submission.
    pub fn submit_score(&mut self, profile_id: String, leaderboard_id: String, score: f64) {
        self.operations.push(ProgressionOperation::SubmitScore {
            profile_id,
            leaderboard_id,
            score,
        });
    }

    /// Return the queued operations.
    pub fn operations(&self) -> &[ProgressionOperation] {
        &self.operations
    }
}

/// Headless progression store used by `lurek.progression`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProgressionStore {
    options: ProgressionStoreOptions,
    revision: u64,
    schema_version: u32,
    time: f64,
    next_modifier_id: u64,
    next_event_sequence: u64,
    profiles: BTreeMap<String, ProfileState>,
    profile_templates: BTreeMap<String, ProfileTemplateDefinition>,
    trait_definitions: BTreeMap<String, TraitDefinition>,
    perk_definitions: BTreeMap<String, PerkDefinition>,
    skill_definitions: BTreeMap<String, SkillDefinition>,
    counter_definitions: BTreeMap<String, CounterDefinition>,
    attribute_definitions: BTreeMap<String, AttributeDefinition>,
    resource_definitions: BTreeMap<String, ResourceDefinition>,
    level_track_definitions: BTreeMap<String, LevelTrackDefinition>,
    derived_value_definitions: BTreeMap<String, DerivedValueDefinition>,
    leaderboard_definitions: BTreeMap<String, LeaderboardDefinition>,
    leaderboard_counter_index: BTreeMap<String, Vec<String>>,
    season_definitions: BTreeMap<String, SeasonDefinition>,
    season_states: BTreeMap<String, SeasonState>,
    season_archives: BTreeMap<String, Vec<SeasonArchiveRecord>>,
    prestige_definitions: BTreeMap<String, PrestigeDefinition>,
    collection_definitions: BTreeMap<String, CollectionDefinition>,
    collection_achievement_index: BTreeMap<String, Vec<(String, String)>>,
    rival_index: BTreeMap<String, Vec<String>>,
    population_templates: BTreeMap<String, PopulationTemplateDefinition>,
    populations: BTreeMap<String, PopulationState>,
    virtual_profile_index: BTreeMap<String, String>,
    challenge_template_definitions: BTreeMap<String, ChallengeTemplateDefinition>,
    challenge_counter_index: BTreeMap<String, Vec<String>>,
    quest_definitions: BTreeMap<String, QuestDefinition>,
    quest_counter_index: BTreeMap<String, Vec<QuestCounterBinding>>,
    achievement_definitions: BTreeMap<String, AchievementDefinition>,
    achievement_counter_index: BTreeMap<String, Vec<String>>,
    events: VecDeque<EventRecord>,
    #[serde(skip, default)]
    change_log: VecDeque<ChangeRecord>,
    #[serde(skip, default)]
    last_recorded_change_revision: u64,
}

#[path = "achievement.rs"]
mod achievement;
#[path = "attribute.rs"]
mod attribute;
#[path = "challenge.rs"]
mod challenge;
#[path = "collection.rs"]
mod collection;
#[path = "condition.rs"]
mod condition;
#[path = "counter.rs"]
mod counter;
#[path = "event.rs"]
mod event;
#[path = "formula.rs"]
mod formula;
#[path = "leaderboard.rs"]
mod leaderboard;
#[path = "level.rs"]
mod level;
#[path = "persistence.rs"]
mod persistence;
#[path = "population.rs"]
mod population;
#[path = "prestige.rs"]
mod prestige;
#[path = "profile.rs"]
mod profile;
#[path = "quest.rs"]
mod quest;
#[path = "reward.rs"]
mod reward;
#[path = "rival.rs"]
mod rival;
#[path = "season.rs"]
mod season;

impl ProgressionStore {
    /// Create a new empty progression store.
    pub fn new(options: ProgressionStoreOptions) -> Result<Self, ProgressionError> {
        validate_id(&options.id)?;
        if options.event_capacity == 0 {
            return Err(ProgressionError::InvalidValue(
                "event_capacity must be >= 1".to_string(),
            ));
        }
        if options.change_capacity == 0 {
            return Err(ProgressionError::InvalidValue(
                "change_capacity must be >= 1".to_string(),
            ));
        }
        if options.max_profiles == 0 {
            return Err(ProgressionError::InvalidValue(
                "max_profiles must be >= 1".to_string(),
            ));
        }
        Ok(Self {
            options,
            revision: 0,
            schema_version: 1,
            time: 0.0,
            next_modifier_id: 1,
            next_event_sequence: 1,
            profiles: BTreeMap::new(),
            profile_templates: BTreeMap::new(),
            trait_definitions: BTreeMap::new(),
            perk_definitions: BTreeMap::new(),
            skill_definitions: BTreeMap::new(),
            counter_definitions: BTreeMap::new(),
            attribute_definitions: BTreeMap::new(),
            resource_definitions: BTreeMap::new(),
            level_track_definitions: BTreeMap::new(),
            derived_value_definitions: BTreeMap::new(),
            leaderboard_definitions: BTreeMap::new(),
            leaderboard_counter_index: BTreeMap::new(),
            season_definitions: BTreeMap::new(),
            season_states: BTreeMap::new(),
            season_archives: BTreeMap::new(),
            prestige_definitions: BTreeMap::new(),
            collection_definitions: BTreeMap::new(),
            collection_achievement_index: BTreeMap::new(),
            rival_index: BTreeMap::new(),
            population_templates: BTreeMap::new(),
            populations: BTreeMap::new(),
            virtual_profile_index: BTreeMap::new(),
            challenge_template_definitions: BTreeMap::new(),
            challenge_counter_index: BTreeMap::new(),
            quest_definitions: BTreeMap::new(),
            quest_counter_index: BTreeMap::new(),
            achievement_definitions: BTreeMap::new(),
            achievement_counter_index: BTreeMap::new(),
            events: VecDeque::new(),
            change_log: VecDeque::new(),
            last_recorded_change_revision: 0,
        })
    }

    /// Return the store id.
    pub fn id(&self) -> &str {
        &self.options.id
    }

    /// Return the current store revision.
    pub fn revision(&self) -> u64 {
        self.revision
    }

    /// Return the schema version carried by this store.
    pub fn schema_version(&self) -> u32 {
        self.schema_version
    }

    /// Return a deterministic hash of the authored definitions.
    pub fn definition_hash(&self) -> String {
        let payload = serde_json::to_vec(&json!({
            "counters": self.counter_definitions,
            "profile_templates": self.profile_templates,
            "traits": self.trait_definitions,
            "perks": self.perk_definitions,
            "skills": self.skill_definitions,
            "attributes": self.attribute_definitions,
            "resources": self.resource_definitions,
            "levels": self.level_track_definitions,
            "derived_values": self.derived_value_definitions,
            "leaderboards": self.leaderboard_definitions,
            "seasons": self.season_definitions,
            "prestiges": self.prestige_definitions,
            "collections": self.collection_definitions,
            "population_templates": self.population_templates,
            "challenge_templates": self.challenge_template_definitions,
            "quests": self.quest_definitions,
            "achievements": self.achievement_definitions,
        }))
        .unwrap_or_default();
        let mut hasher = Sha1::new();
        hasher.update(payload);
        format!("{:x}", hasher.finalize())
    }

    /// Return the current logical time in seconds.
    pub fn time(&self) -> f64 {
        self.time
    }

    /// Set the current logical time.
    pub fn set_time(&mut self, seconds: f64) -> Result<(), ProgressionError> {
        ensure_finite(seconds, "time")?;
        self.time = seconds.max(0.0);
        self.expire_active_challenges()?;
        Ok(())
    }

    /// Advance logical time by `seconds`.
    pub fn advance_time(&mut self, seconds: f64) -> Result<(), ProgressionError> {
        ensure_finite(seconds, "time delta")?;
        if seconds < 0.0 {
            return Err(ProgressionError::InvalidValue(
                "time delta must be >= 0".to_string(),
            ));
        }
        self.time += seconds;
        self.expire_modifiers(seconds);
        self.tick_skill_cooldowns(seconds);
        self.expire_active_challenges()?;
        Ok(())
    }

    /// Clear all mutable state while keeping authored definitions.
    pub fn clear(&mut self) {
        self.profiles.clear();
        self.season_states.clear();
        self.season_archives.clear();
        self.populations.clear();
        self.virtual_profile_index.clear();
        self.events.clear();
        self.change_log.clear();
        self.revision = 0;
        self.next_modifier_id = 1;
        self.next_event_sequence = 1;
        self.time = 0.0;
        self.last_recorded_change_revision = 0;
    }

    /// Return lightweight store stats.
    pub fn stats(&self) -> JsonValue {
        json!({
            "profiles": self.profiles.len(),
            "profileTemplates": self.profile_templates.len(),
            "traitDefinitions": self.trait_definitions.len(),
            "perkDefinitions": self.perk_definitions.len(),
            "skillDefinitions": self.skill_definitions.len(),
            "counterDefinitions": self.counter_definitions.len(),
            "attributeDefinitions": self.attribute_definitions.len(),
            "resourceDefinitions": self.resource_definitions.len(),
            "levelTrackDefinitions": self.level_track_definitions.len(),
            "derivedValueDefinitions": self.derived_value_definitions.len(),
            "leaderboardDefinitions": self.leaderboard_definitions.len(),
            "seasonDefinitions": self.season_definitions.len(),
            "seasonArchives": self.season_archives.values().map(|entries| entries.len()).sum::<usize>(),
            "prestigeDefinitions": self.prestige_definitions.len(),
            "collectionDefinitions": self.collection_definitions.len(),
            "populationTemplates": self.population_templates.len(),
            "populations": self.populations.len(),
            "challengeTemplateDefinitions": self.challenge_template_definitions.len(),
            "questDefinitions": self.quest_definitions.len(),
            "questCounterBindings": self.quest_counter_index.values().map(|bindings| bindings.len()).sum::<usize>(),
            "achievementDefinitions": self.achievement_definitions.len(),
            "events": self.events.len(),
            "changes": self.change_log.len(),
            "revision": self.revision,
            "time": self.time,
        })
    }

    /// Return a lightweight validation report for the current store state.
    pub fn validate(&self) -> JsonValue {
        let mut errors = Vec::new();
        if self.options.event_capacity == 0 {
            errors.push("event_capacity must be >= 1".to_string());
        }
        if self.options.change_capacity == 0 {
            errors.push("change_capacity must be >= 1".to_string());
        }
        if self.options.max_profiles == 0 {
            errors.push("max_profiles must be >= 1".to_string());
        }
        for profile_id in self.profiles.keys() {
            if let Err(err) = validate_id(profile_id) {
                errors.push(err.to_string());
            }
        }
        for (season_id, definition) in &self.season_definitions {
            if let Err(err) = self.validate_season_definition(season_id, definition) {
                errors.push(err.to_string());
            }
        }
        for (prestige_id, definition) in &self.prestige_definitions {
            if let Err(err) = self.validate_prestige_definition(prestige_id, definition) {
                errors.push(err.to_string());
            }
        }
        for (collection_id, definition) in &self.collection_definitions {
            if let Err(err) = self.validate_collection_definition(collection_id, definition) {
                errors.push(err.to_string());
            }
        }
        for (template_id, definition) in &self.population_templates {
            if let Err(err) = self.validate_population_template_definition(template_id, definition)
            {
                errors.push(err.to_string());
            }
        }
        for (template_id, definition) in &self.challenge_template_definitions {
            if let Err(err) = self.validate_challenge_template_definition(template_id, definition) {
                errors.push(err.to_string());
            }
        }
        json!({
            "ok": errors.is_empty(),
            "errors": errors,
            "definition_hash": self.definition_hash(),
            "revision": self.revision,
        })
    }

    /// Export the full store snapshot as structured JSON data.
    pub fn export_snapshot(&self) -> JsonValue {
        serde_json::to_value(self).unwrap_or_else(|_| json!({}))
    }

    /// Replace the current store state from a previously exported snapshot.
    pub fn load_snapshot(&mut self, snapshot: JsonValue) -> Result<(), ProgressionError> {
        let loaded: ProgressionStore = serde_json::from_value(snapshot)
            .map_err(|err| ProgressionError::InvalidValue(format!("snapshot: {err}")))?;
        *self = loaded;
        self.change_log.clear();
        self.last_recorded_change_revision = 0;
        Ok(())
    }

    /// Create a new store directly from a structured snapshot.
    pub fn from_snapshot(snapshot: JsonValue) -> Result<Self, ProgressionError> {
        serde_json::from_value(snapshot)
            .map_err(|err| ProgressionError::InvalidValue(format!("snapshot: {err}")))
    }

    /// Define one level track.
    pub fn define_level_track(
        &mut self,
        id: &str,
        definition: LevelTrackDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        self.level_track_definitions
            .insert(id.to_string(), definition);
        Ok(())
    }

    /// Define one named derived value.
    pub fn define_derived_value(
        &mut self,
        id: &str,
        definition: DerivedValueDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        self.validate_derived_value_definition(id, &definition)?;
        self.derived_value_definitions
            .insert(id.to_string(), definition);
        Ok(())
    }

    /// Remove one authored derived value.
    pub fn remove_derived_value(&mut self, id: &str) -> bool {
        self.derived_value_definitions.remove(id).is_some()
    }

    /// Start an empty transaction object.
    pub fn begin_transaction(&self, id: Option<String>) -> ProgressionTransaction {
        ProgressionTransaction::new(id)
    }

    /// Commit a transaction and assign one store revision.
    pub fn commit_transaction(
        &mut self,
        tx: &ProgressionTransaction,
    ) -> Result<ChangeSummary, ProgressionError> {
        if tx.operations.is_empty() {
            return Ok(ChangeSummary {
                revision: self.revision,
                changes: 0,
            });
        }
        for operation in &tx.operations {
            match operation.clone() {
                ProgressionOperation::AddCounter {
                    profile_id,
                    counter_id,
                    amount,
                } => {
                    self.add_counter(&profile_id, &counter_id, amount)?;
                }
                ProgressionOperation::SetCounter {
                    profile_id,
                    counter_id,
                    value,
                } => {
                    self.set_counter(&profile_id, &counter_id, value)?;
                }
                ProgressionOperation::SetAttributeBase {
                    profile_id,
                    attribute_id,
                    value,
                } => {
                    self.set_attribute_base(&profile_id, &attribute_id, value)?;
                }
                ProgressionOperation::SetResource {
                    profile_id,
                    resource_id,
                    value,
                } => {
                    self.set_resource(&profile_id, &resource_id, value)?;
                }
                ProgressionOperation::AddModifier {
                    profile_id,
                    target_id,
                    options,
                } => {
                    self.add_modifier(&profile_id, &target_id, options)?;
                }
                ProgressionOperation::SetQuestObjective {
                    profile_id,
                    quest_id,
                    objective_id,
                    value,
                } => {
                    self.set_quest_objective(&profile_id, &quest_id, &objective_id, value)?;
                }
                ProgressionOperation::AddExperience {
                    profile_id,
                    track_id,
                    amount,
                } => {
                    self.add_experience(&profile_id, &track_id, amount)?;
                }
                ProgressionOperation::SubmitScore {
                    profile_id,
                    leaderboard_id,
                    score,
                } => {
                    self.submit_score(&profile_id, &leaderboard_id, score)?;
                }
            }
        }
        Ok(ChangeSummary {
            revision: self.revision,
            changes: tx.operations.len(),
        })
    }

    /// Drain all retained events in sequence order.
    pub fn drain_events(&mut self) -> Vec<EventRecord> {
        self.events.drain(..).collect()
    }

    /// Advance logical time and run incremental maintenance work.
    pub fn update(&mut self, dt: f64) -> Result<JsonValue, ProgressionError> {
        let before = self.events.len();
        self.advance_time(dt)?;
        let mut population_updates = 0usize;
        if dt > 0.0 {
            let active_populations = self
                .populations
                .values()
                .filter(|population| !population.paused)
                .map(|population| population.id.clone())
                .collect::<Vec<_>>();
            for population_id in active_populations {
                self.update_population(&population_id, dt)?;
                population_updates += 1;
            }
        }
        Ok(json!({
            "time": self.time,
            "events_before": before,
            "events_after": self.events.len(),
            "population_updates": population_updates,
        }))
    }

    /// Return event snapshots without draining.
    pub fn list_events(&self) -> Vec<EventRecord> {
        self.events.iter().cloned().collect()
    }

    /// Clear all retained events.
    pub fn clear_events(&mut self) {
        self.events.clear();
    }

    /// Export retained change records after `revision`.
    pub fn export_changes_since(&self, revision: u64) -> Vec<ChangeRecord> {
        self.change_log
            .iter()
            .filter(|record| record.revision > revision)
            .cloned()
            .collect()
    }

    /// Apply an exported changeset onto this store by loading its latest retained snapshot.
    pub fn apply_changeset(
        &mut self,
        changes: Vec<ChangeRecord>,
    ) -> Result<JsonValue, ProgressionError> {
        if changes.is_empty() {
            return Ok(json!({
                "applied": false,
                "revision": self.revision,
                "changeCount": 0,
            }));
        }
        self.validate_change_records(&changes)?;
        let latest = changes
            .iter()
            .max_by_key(|record| record.revision)
            .cloned()
            .ok_or_else(|| {
                ProgressionError::InvalidValue("changeset missing latest record".to_string())
            })?;
        self.load_snapshot(latest.snapshot)?;
        self.last_recorded_change_revision = self.revision;
        Ok(json!({
            "applied": true,
            "revision": self.revision,
            "changeCount": changes.len(),
        }))
    }

    /// Return a debug snapshot for tests and migration helpers.
    pub fn debug_snapshot(&self) -> JsonValue {
        json!(self)
    }

    fn profile_mut(&mut self, id: &str) -> Result<&mut ProfileState, ProgressionError> {
        self.profiles
            .get_mut(id)
            .ok_or_else(|| ProgressionError::MissingProfile(id.to_string()))
    }

    fn bump_revision(&mut self) {
        self.revision += 1;
    }

    fn next_revision(&self) -> u64 {
        self.revision + 1
    }

    fn record_change_snapshot(&mut self) {
        if self.revision == 0 || self.last_recorded_change_revision == self.revision {
            return;
        }
        self.change_log.push_back(ChangeRecord {
            revision: self.revision,
            snapshot: self.export_snapshot(),
        });
        while self.change_log.len() > self.options.change_capacity {
            self.change_log.pop_front();
        }
        self.last_recorded_change_revision = self.revision;
    }

    fn push_event(
        &mut self,
        event_type: &str,
        profile_id: Option<String>,
        definition_id: Option<String>,
        payload: JsonValue,
    ) {
        let event = EventRecord {
            sequence: self.next_event_sequence,
            revision: self.revision,
            event_type: event_type.to_string(),
            profile_id,
            definition_id,
            payload,
        };
        self.next_event_sequence += 1;
        self.events.push_back(event);
        while self.events.len() > self.options.event_capacity {
            self.events.pop_front();
        }
        self.record_change_snapshot();
    }

    fn expire_modifiers(&mut self, seconds: f64) {
        if seconds <= 0.0 {
            return;
        }
        let mut expired: Vec<(String, String)> = Vec::new();
        for (profile_id, profile) in &mut self.profiles {
            for (handle, modifier) in &mut profile.modifiers {
                if let Some(remaining) = &mut modifier.remaining {
                    *remaining -= seconds;
                    if *remaining <= 0.0 {
                        expired.push((profile_id.clone(), handle.clone()));
                    }
                }
            }
        }
        for (profile_id, handle) in expired {
            if let Ok(true) = self.remove_modifier(&profile_id, &handle) {
                self.push_event(
                    "modifier_expired",
                    Some(profile_id),
                    None,
                    json!({ "handle": handle }),
                );
            }
        }
    }

    fn tick_skill_cooldowns(&mut self, seconds: f64) {
        if seconds <= 0.0 {
            return;
        }
        for profile in self.profiles.values_mut() {
            for skill in profile.skills.values_mut() {
                if skill.cooldown_remaining > 0.0 {
                    skill.cooldown_remaining = (skill.cooldown_remaining - seconds).max(0.0);
                }
            }
        }
    }

    fn validate_derived_value_definition(
        &self,
        id: &str,
        definition: &DerivedValueDefinition,
    ) -> Result<(), ProgressionError> {
        if definition.expression.trim().is_empty() {
            return Err(ProgressionError::InvalidValue(format!(
                "derived value '{}' expression must not be empty",
                id
            )));
        }
        if definition.expression.len() > 256 {
            return Err(ProgressionError::InvalidValue(format!(
                "derived value '{}' expression exceeds 256 characters",
                id
            )));
        }
        if definition.inputs.len() > 32 {
            return Err(ProgressionError::InvalidValue(format!(
                "derived value '{}' exceeds 32 inputs",
                id
            )));
        }
        let parsed = parse_formula_expression(&definition.expression)?;
        let mut names = BTreeSet::new();
        collect_formula_identifiers(&parsed, &mut names);
        for name in names {
            if !definition.inputs.contains_key(&name) && !is_formula_function_name(&name) {
                return Err(ProgressionError::InvalidValue(format!(
                    "derived value '{}' references unknown input '{}'",
                    id, name
                )));
            }
        }
        for (name, input) in &definition.inputs {
            validate_id(name)?;
            match input {
                DerivedValueInput::Counter { counter_id } => {
                    validate_id(counter_id)?;
                    if self.options.strict && !self.counter_definitions.contains_key(counter_id) {
                        return Err(ProgressionError::MissingDefinition {
                            kind: "counter",
                            id: counter_id.clone(),
                        });
                    }
                }
                DerivedValueInput::Attribute { attribute_id, .. } => {
                    validate_id(attribute_id)?;
                    if self.options.strict && !self.attribute_definitions.contains_key(attribute_id)
                    {
                        return Err(ProgressionError::MissingDefinition {
                            kind: "attribute",
                            id: attribute_id.clone(),
                        });
                    }
                }
                DerivedValueInput::Resource { resource_id } => {
                    validate_id(resource_id)?;
                    if self.options.strict && !self.resource_definitions.contains_key(resource_id) {
                        return Err(ProgressionError::MissingDefinition {
                            kind: "resource",
                            id: resource_id.clone(),
                        });
                    }
                }
                DerivedValueInput::Level { track_id }
                | DerivedValueInput::Experience { track_id } => {
                    validate_id(track_id)?;
                    if self.options.strict && !self.level_track_definitions.contains_key(track_id) {
                        return Err(ProgressionError::MissingDefinition {
                            kind: "level_track",
                            id: track_id.clone(),
                        });
                    }
                }
            }
        }
        if let Some(min) = definition.min {
            ensure_finite(min, "derived value min")?;
        }
        if let Some(max) = definition.max {
            ensure_finite(max, "derived value max")?;
        }
        if let (Some(min), Some(max)) = (definition.min, definition.max) {
            if max < min {
                return Err(ProgressionError::InvalidValue(format!(
                    "derived value '{}' max must be >= min",
                    id
                )));
            }
        }
        if let Some(round) = &definition.round {
            if !matches!(round.as_str(), "floor" | "ceil" | "round") {
                return Err(ProgressionError::InvalidValue(format!(
                    "derived value '{}' has unsupported round mode '{}'",
                    id, round
                )));
            }
        }
        Ok(())
    }

}

fn compare_f64(left: f64, op: ComparisonOp, right: f64) -> bool {
    match op {
        ComparisonOp::Greater => left > right,
        ComparisonOp::GreaterEqual => left >= right,
        ComparisonOp::Equal => (left - right).abs() <= f64::EPSILON,
        ComparisonOp::Less => left < right,
        ComparisonOp::LessEqual => left <= right,
    }
}

fn format_comparison_op(op: ComparisonOp) -> &'static str {
    match op {
        ComparisonOp::Greater => ">",
        ComparisonOp::GreaterEqual => ">=",
        ComparisonOp::Equal => "==",
        ComparisonOp::Less => "<",
        ComparisonOp::LessEqual => "<=",
    }
}

fn validate_id(id: &str) -> Result<(), ProgressionError> {
    if id.is_empty() || id.len() > 64 {
        return Err(ProgressionError::InvalidId(format!(
            "'{}' must be 1..64 characters",
            id
        )));
    }
    if !id
        .chars()
        .all(|ch| ch.is_ascii_alphanumeric() || ch == '_' || ch == '-' || ch == '.')
    {
        return Err(ProgressionError::InvalidId(format!(
            "'{}' contains unsupported characters",
            id
        )));
    }
    Ok(())
}

fn ensure_finite(value: f64, label: &str) -> Result<(), ProgressionError> {
    if !value.is_finite() {
        return Err(ProgressionError::InvalidValue(format!(
            "{} must be finite",
            label
        )));
    }
    Ok(())
}

fn stable_unit(seed: u64, parts: &[&str]) -> f64 {
    let mut hasher = Sha1::new();
    hasher.update(seed.to_le_bytes());
    for part in parts {
        hasher.update(part.as_bytes());
        hasher.update([0xff]);
    }
    let digest = hasher.finalize();
    let mut bytes = [0u8; 8];
    bytes.copy_from_slice(&digest[..8]);
    let value = u64::from_le_bytes(bytes);
    (value as f64) / (u64::MAX as f64)
}

fn stable_signed_unit(seed: u64, parts: &[&str]) -> f64 {
    stable_unit(seed, parts) * 2.0 - 1.0
}

fn stable_gaussianish(seed: u64, parts: &[&str]) -> f64 {
    let mut total = 0.0;
    for bucket in 0..3 {
        let bucket_string = bucket.to_string();
        let mut scoped = parts.to_vec();
        scoped.push(bucket_string.as_str());
        total += stable_signed_unit(seed, &scoped);
    }
    total / 3.0
}

fn select_optional_string(values: &[String], seed: u64, parts: &[&str]) -> Option<String> {
    if values.is_empty() {
        return None;
    }
    let index = ((stable_unit(seed, parts) * values.len() as f64).floor() as usize)
        .min(values.len().saturating_sub(1));
    values.get(index).cloned()
}

fn generate_population_name(
    id_prefix: &str,
    index: usize,
    identity: &crate::progression::PopulationIdentityDefinition,
    seed: u64,
    population_id: &str,
) -> String {
    if identity.name_generator.mode == "parts"
        && !identity.name_generator.prefixes.is_empty()
        && !identity.name_generator.suffixes.is_empty()
    {
        let prefix = select_optional_string(
            &identity.name_generator.prefixes,
            seed,
            &[population_id, "name_prefix", &index.to_string()],
        )
        .unwrap_or_else(|| id_prefix.to_string());
        let suffix = select_optional_string(
            &identity.name_generator.suffixes,
            seed,
            &[population_id, "name_suffix", &index.to_string()],
        )
        .unwrap_or_else(|| format!("{}", index + 1));
        return format!("{prefix} {suffix}");
    }
    format!("{id_prefix} {}", index + 1)
}

fn select_population_archetype<'a>(
    archetypes: &'a [PopulationArchetypeDefinition],
    seed: u64,
    population_id: &str,
    index: usize,
) -> Result<&'a PopulationArchetypeDefinition, ProgressionError> {
    let total_weight: u64 = archetypes
        .iter()
        .map(|archetype| archetype.weight as u64)
        .sum();
    if total_weight == 0 {
        return Err(ProgressionError::InvalidValue(
            "population archetype weights must sum to >= 1".to_string(),
        ));
    }
    let scaled = (stable_unit(seed, &[population_id, "archetype", &index.to_string()])
        * total_weight as f64)
        .floor() as u64;
    let mut cursor = 0u64;
    for archetype in archetypes {
        cursor += archetype.weight as u64;
        if scaled < cursor {
            return Ok(archetype);
        }
    }
    archetypes.last().ok_or_else(|| {
        ProgressionError::InvalidValue(
            "population template requires at least one archetype".to_string(),
        )
    })
}

fn bound_value(value: f64, min: Option<f64>, max: Option<f64>) -> f64 {
    let mut bounded = value;
    if let Some(min) = min {
        bounded = bounded.max(min);
    }
    if let Some(max) = max {
        bounded = bounded.min(max);
    }
    bounded
}

fn sanitize_counter_value(
    definition: &CounterDefinition,
    value: f64,
) -> Result<f64, ProgressionError> {
    ensure_finite(value, "counter value")?;
    let mut bounded = bound_value(value, definition.min, definition.max);
    match definition.kind {
        CounterKind::Integer | CounterKind::CumulativeInteger => {
            bounded = bounded.round();
        }
        CounterKind::Boolean => {
            bounded = if bounded > 0.0 { 1.0 } else { 0.0 };
        }
        CounterKind::Number | CounterKind::Gauge | CounterKind::CumulativeNumber => {}
    }
    Ok(bounded)
}

fn xp_threshold_for(definition: &LevelTrackDefinition, level: u32) -> f64 {
    definition.base_xp + definition.increment_xp * level.saturating_sub(1) as f64
}

fn compute_level_state(
    definition: &LevelTrackDefinition,
    total_experience: f64,
) -> Result<(u32, f64), ProgressionError> {
    ensure_finite(total_experience, "template experience")?;
    let mut experience = total_experience.max(0.0);
    let mut level = definition.initial_level;
    while level < definition.max_level && experience >= xp_threshold_for(definition, level) {
        if definition.carry_over {
            experience -= xp_threshold_for(definition, level);
        } else {
            break;
        }
        level += 1;
    }
    Ok((level, experience))
}

fn collect_formula_identifiers(expr: &FormulaExpr, out: &mut BTreeSet<String>) {
    match expr {
        FormulaExpr::Number(_) => {}
        FormulaExpr::Variable(name) => {
            out.insert(name.clone());
        }
        FormulaExpr::UnaryMinus(child) => collect_formula_identifiers(child, out),
        FormulaExpr::Binary { left, right, .. } => {
            collect_formula_identifiers(left, out);
            collect_formula_identifiers(right, out);
        }
        FormulaExpr::Function { args, .. } => {
            for arg in args {
                collect_formula_identifiers(arg, out);
            }
        }
    }
}

fn is_formula_function_name(name: &str) -> bool {
    matches!(
        name,
        "min" | "max" | "clamp" | "abs" | "floor" | "ceil" | "round"
    )
}
