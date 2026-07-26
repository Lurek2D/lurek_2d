//! Owns the serializable data contracts, enums, and durable state shapes used by the progression store.
//! Stores authored definitions, retained runtime snapshots, and helper structs shared across progression subsystems.
//! Exposes the canonical types that Rust tests, persistence code, and Lua bindings serialize or inspect directly.
//! Keeps durable field layout separate from mutation logic so snapshots can evolve without hiding in store methods.
//! Defines profile, quest, leaderboard, population, challenge, season, and reward state in one reusable contract set.
//! Anchors deterministic serde behavior for snapshots, changesets, and debug payloads that cross module boundaries.
//! Integrates with `store.rs` as the state schema owner while sibling files focus on behavior and mutation rules.
//! Avoids renderer, filesystem, and Lua-specific adapters so these types stay transport-neutral and domain-focused.
//! Status snapshots retain copied tags and pause state while serde defaults accept snapshots authored before them.
//! Open this file when adding stored fields, authored definition shapes, or snapshot-visible progression contracts.
//! Reach here before changing persistence, docs generation, or Lua serialization that depends on stable type layout.
use serde::{Deserialize, Serialize};
use serde_json::Value as JsonValue;
use std::collections::BTreeMap;

/// Configuration used when creating a new progression store.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProgressionStoreOptions {
    /// Stable store identifier used in snapshots and diagnostics.
    pub id: String,
    /// Optional deterministic seed retained for future simulation features.
    pub seed: u64,
    /// Logical clock mode. `"manual"` never reads host time, `"runtime"` is reserved for future use.
    pub clock: String,
    /// Maximum retained events in the bounded ring buffer.
    pub event_capacity: usize,
    /// Maximum retained exported changes in the bounded change log.
    pub change_capacity: usize,
    /// Maximum retained profiles in the store.
    pub max_profiles: usize,
    /// Whether missing definitions should be rejected eagerly.
    pub strict: bool,
}

impl Default for ProgressionStoreOptions {
    fn default() -> Self {
        Self {
            id: "progression".to_string(),
            seed: 0,
            clock: "manual".to_string(),
            event_capacity: 1024,
            change_capacity: 256,
            max_profiles: 10_000,
            strict: true,
        }
    }
}

/// Creation and patch data for a progression profile.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ProfileOptions {
    /// Semantic profile kind such as `human`, `npc`, or `team`.
    pub kind: Option<String>,
    /// Human-readable display name.
    pub display_name: Option<String>,
    /// Optional avatar/path token retained as metadata.
    pub avatar: Option<String>,
    /// Profile tags used by simple conditions and filters.
    pub tags: Vec<String>,
    /// Bounded profile metadata payload.
    pub metadata: BTreeMap<String, JsonValue>,
    /// Optional template id to apply after creation.
    pub template: Option<String>,
}

/// Supported counter storage modes in the initial progression slice.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum CounterKind {
    /// Arbitrary signed integer-like value stored as a finite number.
    Integer,
    /// Arbitrary finite floating-point value.
    Number,
    /// Freely increasing and decreasing gauge.
    Gauge,
    /// Monotonic integer total.
    CumulativeInteger,
    /// Monotonic numeric total.
    CumulativeNumber,
    /// Boolean-like counter stored as `0.0` or `1.0`.
    Boolean,
}

/// Definition for one named counter.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CounterDefinition {
    /// Storage behavior of the counter.
    pub kind: CounterKind,
    /// Initial value used when a profile first touches the counter.
    pub initial: f64,
    /// Optional minimum accepted value.
    pub min: Option<f64>,
    /// Optional maximum accepted value.
    pub max: Option<f64>,
    /// Whether the value may only move upward.
    pub monotonic: bool,
    /// Sorted threshold list used for threshold-crossing events.
    pub thresholds: Vec<f64>,
}

impl Default for CounterDefinition {
    fn default() -> Self {
        Self {
            kind: CounterKind::Number,
            initial: 0.0,
            min: None,
            max: None,
            monotonic: false,
            thresholds: Vec::new(),
        }
    }
}

/// Definition for one named attribute.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AttributeDefinition {
    /// Default base value.
    pub base: f64,
    /// Optional minimum effective value.
    pub min: Option<f64>,
    /// Optional maximum effective value.
    pub max: Option<f64>,
    /// Reserved regeneration rate in units per second.
    pub regen: f64,
    /// Reserved growth value for future progression rules.
    pub growth: f64,
}

impl Default for AttributeDefinition {
    fn default() -> Self {
        Self {
            base: 0.0,
            min: None,
            max: None,
            regen: 0.0,
            growth: 0.0,
        }
    }
}

/// View mode for attribute reads.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum AttributeMode {
    /// Base value before modifiers.
    Base,
    /// Current value. In this slice it matches effective value.
    Current,
    /// Effective value after modifiers and bounds.
    Effective,
    /// Minimum bound.
    Min,
    /// Maximum bound.
    Max,
}

/// Definition for one named spendable resource.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ResourceDefinition {
    /// Initial resource amount.
    pub initial: f64,
    /// Minimum retained amount.
    pub min: f64,
    /// Maximum retained amount.
    pub max: f64,
    /// Reserved regeneration rate in units per second.
    pub regeneration: f64,
    /// Refill policy label retained for snapshots.
    pub refill: String,
}

impl Default for ResourceDefinition {
    fn default() -> Self {
        Self {
            initial: 0.0,
            min: 0.0,
            max: 0.0,
            regeneration: 0.0,
            refill: "manual".to_string(),
        }
    }
}

/// Definition for a level/experience track.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LevelTrackDefinition {
    /// Initial level assigned to untouched profiles.
    pub initial_level: u32,
    /// Maximum reachable level.
    pub max_level: u32,
    /// Linear threshold base. Level 1 -> `base`.
    pub base_xp: f64,
    /// Linear threshold increment applied per level boundary.
    pub increment_xp: f64,
    /// Whether surplus XP carries into future levels.
    pub carry_over: bool,
    /// Whether direct experience loss may reduce level.
    pub allow_level_down: bool,
}

impl Default for LevelTrackDefinition {
    fn default() -> Self {
        Self {
            initial_level: 1,
            max_level: 100,
            base_xp: 100.0,
            increment_xp: 100.0,
            carry_over: true,
            allow_level_down: false,
        }
    }
}

/// Named input binding for one derived value definition.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "kind", rename_all = "snake_case")]
pub enum DerivedValueInput {
    /// Read a counter value.
    Counter {
        /// Counter id.
        counter_id: String,
    },
    /// Read an attribute value in one mode.
    Attribute {
        /// Attribute id.
        attribute_id: String,
        /// Requested attribute mode.
        mode: AttributeMode,
    },
    /// Read a resource value.
    Resource {
        /// Resource id.
        resource_id: String,
    },
    /// Read current level for one level track.
    Level {
        /// Track id.
        track_id: String,
    },
    /// Read current stored experience for one level track.
    Experience {
        /// Track id.
        track_id: String,
    },
}

/// Author-time definition for one named derived value.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DerivedValueDefinition {
    /// Expression string evaluated against the named input bindings.
    pub expression: String,
    /// Named input map available inside the expression.
    pub inputs: BTreeMap<String, DerivedValueInput>,
    /// Optional minimum result clamp.
    pub min: Option<f64>,
    /// Optional maximum result clamp.
    pub max: Option<f64>,
    /// Optional rounding mode such as `floor`, `ceil`, or `round`.
    pub round: Option<String>,
}

/// Author-time definition for one reusable profile template.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ProfileTemplateDefinition {
    /// Optional default profile kind.
    pub kind: Option<String>,
    /// Optional default display name.
    pub display_name: Option<String>,
    /// Optional default avatar token.
    pub avatar: Option<String>,
    /// Counter values seeded by the template.
    pub counters: BTreeMap<String, f64>,
    /// Attribute base values seeded by the template.
    pub attributes: BTreeMap<String, f64>,
    /// Resource values seeded by the template.
    pub resources: BTreeMap<String, f64>,
    /// Experience values seeded by the template.
    pub experience: BTreeMap<String, f64>,
    /// Tags applied to the profile.
    pub tags: Vec<String>,
    /// Metadata entries applied to the profile.
    pub metadata: BTreeMap<String, JsonValue>,
}

/// One modifier entry authored inside a trait definition.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TraitModifierDefinition {
    /// Target attribute id.
    pub target_id: String,
    /// Optional modifier layer label.
    pub layer: Option<String>,
    /// Additive value applied by the trait.
    pub value: f64,
}

/// Author-time definition for one reusable trait.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct TraitDefinition {
    /// Modifier entries applied while the trait is active.
    pub modifiers: Vec<TraitModifierDefinition>,
}

/// Author-time definition for one perk unlock.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PerkDefinition {
    /// Minimum required level on the tracked level path.
    pub require_level: u32,
    /// Optional level track used for requirement checks.
    pub track_id: Option<String>,
    /// Traits granted once the perk is acquired.
    pub trait_ids: Vec<String>,
}

/// Author-time definition for one skill track.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SkillDefinition {
    /// Maximum reachable skill level.
    pub max_level: u32,
    /// Optional attribute id spent when using the skill.
    pub resource_id: Option<String>,
    /// Cost applied to the optional resource attribute.
    pub cost: f64,
    /// Cooldown duration in seconds after successful use.
    pub cooldown: f64,
}

/// One structured quest journal entry retained in canonical progression state.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QuestJournalEntry {
    /// Stable per-quest entry index.
    pub index: u64,
    /// Human-readable text body.
    pub text: String,
    /// Optional tag/category label.
    pub tag: String,
}

/// Sort direction for one leaderboard.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum LeaderboardSort {
    /// Higher scores rank above lower scores.
    Descending,
    /// Lower scores rank above higher scores.
    Ascending,
}

/// Rank numbering mode for one leaderboard.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum LeaderboardRankMode {
    /// 1, 2, 3 even across ties.
    Ordinal,
    /// 1, 1, 2 for ties.
    Dense,
    /// 1, 1, 3 for ties.
    Competition,
}

/// Author-time definition for one leaderboard.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LeaderboardDefinition {
    /// Stable leaderboard id.
    pub id: String,
    /// Optional display title.
    pub title: String,
    /// Score sort direction.
    pub sort: LeaderboardSort,
    /// Rank numbering mode.
    pub rank_mode: LeaderboardRankMode,
    /// Optional max returned rows for bounded queries.
    pub max_entries: Option<usize>,
    /// Optional counter id used as a canonical automatic score source.
    pub counter_id: Option<String>,
}

/// Reset targets applied when a season ends.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SeasonResetDefinition {
    /// Leaderboard ids cleared at season rollover.
    pub leaderboards: Vec<String>,
    /// Counter ids reset to their authored initial values at season rollover.
    pub counters: Vec<String>,
}

/// Author-time definition for one named season.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SeasonDefinition {
    /// Stable season id.
    pub id: String,
    /// Scheduled logical start time in seconds.
    pub starts_at: f64,
    /// Scheduled logical end time in seconds.
    pub ends_at: f64,
    /// Reset behavior applied after archive capture.
    pub reset: SeasonResetDefinition,
    /// Whether completed runs should retain archive snapshots.
    pub archive: bool,
}

/// Declarative condition tree used by progression definitions and queries.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "kind", rename_all = "snake_case")]
pub enum ProgressionCondition {
    /// Logical `all` over child conditions.
    All {
        /// Child conditions.
        conditions: Vec<ProgressionCondition>,
    },
    /// Logical `any` over child conditions.
    Any {
        /// Child conditions.
        conditions: Vec<ProgressionCondition>,
    },
    /// Logical negation.
    Not {
        /// Child condition.
        condition: Box<ProgressionCondition>,
    },
    /// Compare one counter value.
    Counter {
        /// Counter id.
        counter_id: String,
        /// Comparison operator.
        op: ComparisonOp,
        /// Compared value.
        value: f64,
    },
    /// Compare one level track's current level.
    Level {
        /// Level track id.
        track_id: String,
        /// Comparison operator.
        op: ComparisonOp,
        /// Compared level value.
        value: u32,
    },
    /// Check one achievement state.
    Achievement {
        /// Achievement id.
        achievement_id: String,
        /// Expected state such as `unlocked` or `locked`.
        state: String,
    },
    /// Check one quest lifecycle state.
    Quest {
        /// Quest id.
        quest_id: String,
        /// Expected state such as `active` or `completed`.
        state: String,
    },
    /// Check whether the profile has one tag.
    Tag {
        /// Required tag.
        tag: String,
    },
}

/// Author-time definition for one quest objective.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QuestObjectiveDefinition {
    /// Stable objective id unique within its stage.
    pub id: String,
    /// Human-readable objective text.
    pub description: String,
    /// Required progress to mark the objective complete.
    pub required: f64,
    /// Whether this objective blocks stage completion.
    pub mandatory: bool,
    /// Whether the objective starts visible in snapshots and UI-facing queries.
    pub visible: bool,
    /// Optional counter id that should drive this objective automatically.
    pub counter_id: Option<String>,
}

/// Author-time definition for one quest stage.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QuestStageDefinition {
    /// Stable stage id unique within the quest.
    pub id: String,
    /// Display label for the stage.
    pub name: String,
    /// Objectives in deterministic authored order.
    pub objectives: Vec<QuestObjectiveDefinition>,
}

/// Author-time definition for one quest.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QuestDefinition {
    /// Stable quest id.
    pub id: String,
    /// Display title.
    pub title: String,
    /// Optional description.
    pub description: String,
    /// Ordered stage list.
    pub stages: Vec<QuestStageDefinition>,
    /// Optional max retained journal entries for this quest.
    pub max_journal_entries: Option<usize>,
    /// Optional reveal condition checked before the quest becomes visible.
    pub reveal_condition: Option<ProgressionCondition>,
    /// Optional availability condition checked when accepting the quest.
    pub availability_condition: Option<ProgressionCondition>,
    /// Optional opaque reward payload granted on completion.
    pub reward_payload: Option<JsonValue>,
}

/// Author-time definition for one reusable challenge template.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChallengeTemplateDefinition {
    /// Stable challenge template id.
    pub id: String,
    /// Human-readable title.
    pub title: String,
    /// Optional display description.
    pub description: String,
    /// Required progress needed to complete the challenge.
    pub required: f64,
    /// Optional counter id that should drive challenge progress automatically.
    pub counter_id: Option<String>,
    /// Optional logical duration in seconds before the active run expires.
    pub duration: Option<f64>,
    /// Whether completed runs may be activated again.
    pub repeatable: bool,
    /// Optional ceiling for successful completions across activations.
    pub max_completions: Option<u32>,
    /// Optional tags retained as authored metadata.
    #[serde(default)]
    pub tags: Vec<String>,
    /// Optional opaque reward payload granted on completion.
    pub reward_payload: Option<JsonValue>,
}

/// Simple comparison operators supported by the initial achievement trigger slice.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ComparisonOp {
    /// Strictly greater than.
    Greater,
    /// Greater than or equal to.
    GreaterEqual,
    /// Equal to.
    Equal,
    /// Less than.
    Less,
    /// Less than or equal to.
    LessEqual,
}

/// Counter-based trigger definition for an authored achievement.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CounterTriggerDefinition {
    /// Counter id read by this trigger.
    pub counter_id: String,
    /// Comparison operator.
    pub op: ComparisonOp,
    /// Threshold value.
    pub value: f64,
}

/// Author-time definition for one achievement.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AchievementDefinition {
    /// Stable achievement id.
    pub id: String,
    /// Human-readable title.
    pub title: String,
    /// Optional description text.
    pub description: String,
    /// Whether the achievement starts hidden before unlock.
    pub hidden: bool,
    /// Whether the achievement may unlock more than once.
    pub repeatable: bool,
    /// Optional shared condition that must be satisfied before unlock.
    pub condition: Option<ProgressionCondition>,
    /// Optional counter trigger for automatic unlocks.
    pub counter_trigger: Option<CounterTriggerDefinition>,
    /// Optional opaque reward payload attached on unlock.
    pub reward_payload: Option<JsonValue>,
}

/// Reset targets applied when a prestige action is accepted.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PrestigeResetDefinition {
    /// Level track ids reset to their authored initial state.
    pub level_tracks: Vec<String>,
    /// Counter ids reset to their authored initial value.
    pub counters: Vec<String>,
}

/// Preserve flags applied during prestige.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PrestigePreserveDefinition {
    /// Whether achievement unlock state should survive the reset.
    pub achievements: bool,
    /// Whether reset counter values should accumulate into lifetime history.
    pub lifetime_counters: bool,
}

/// Author-time definition for one prestige/rebirth path.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PrestigeDefinition {
    /// Stable prestige id.
    pub id: String,
    /// Shared condition that must be satisfied before prestige can be applied.
    pub condition: ProgressionCondition,
    /// Reset behavior applied after the prestige succeeds.
    pub reset: PrestigeResetDefinition,
    /// History that should survive across resets.
    pub preserve: PrestigePreserveDefinition,
}

/// One item authored inside a collection.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CollectionItemDefinition {
    /// Stable item id unique within the collection.
    pub id: String,
    /// Human-readable title.
    pub title: String,
    /// Whether the item stays hidden until discovered.
    pub hidden: bool,
    /// Optional achievement id that should mark this item collected automatically.
    pub achievement_id: Option<String>,
}

/// Author-time definition for one collection or achievement set.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CollectionDefinition {
    /// Stable collection id.
    pub id: String,
    /// Human-readable title.
    pub title: String,
    /// Optional display description.
    pub description: String,
    /// Ordered item list.
    pub items: Vec<CollectionItemDefinition>,
    /// Optional achievement unlocked after all items are collected.
    pub meta_achievement_id: Option<String>,
}

/// One pinned rival relationship retained in progression state.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RivalDefinition {
    /// Owning profile id.
    pub profile_id: String,
    /// Rival profile id.
    pub rival_profile_id: String,
    /// Optional leaderboard used for delta and overtaking checks.
    pub leaderboard_id: Option<String>,
}

/// Deterministic name generator configuration for a virtual population.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PopulationNameGeneratorDefinition {
    /// Generator mode such as `parts`.
    #[serde(default)]
    pub mode: String,
    /// Prefix pool for `parts` mode.
    #[serde(default)]
    pub prefixes: Vec<String>,
    /// Suffix pool for `parts` mode.
    #[serde(default)]
    pub suffixes: Vec<String>,
}

/// Identity configuration applied to generated virtual profiles.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PopulationIdentityDefinition {
    /// Deterministic name generation config.
    #[serde(default)]
    pub name_generator: PopulationNameGeneratorDefinition,
    /// Optional avatar pool.
    #[serde(default)]
    pub avatars: Vec<String>,
    /// Tags applied to generated profiles.
    #[serde(default)]
    pub tags: Vec<String>,
}

/// Min/max activity band for one archetype.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PopulationActivityDefinition {
    /// Minimum simulated matches per logical day.
    #[serde(default)]
    pub min: u32,
    /// Maximum simulated matches per logical day.
    #[serde(default)]
    pub max: u32,
}

/// Score/skill distribution config for one archetype.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PopulationSkillDefinition {
    /// Mean score/skill anchor.
    #[serde(default)]
    pub mean: f64,
    /// Standard deviation-like spread.
    #[serde(default)]
    pub deviation: f64,
}

/// One weighted archetype used when generating a population.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PopulationArchetypeDefinition {
    /// Stable archetype id.
    pub id: String,
    /// Relative selection weight.
    pub weight: u32,
    /// Activity range for the archetype.
    pub activity: PopulationActivityDefinition,
    /// Skill distribution config.
    pub skill: PopulationSkillDefinition,
}

/// Initial score distribution config for one simulated leaderboard.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PopulationInitialScoreDefinition {
    /// Distribution label such as `normal`.
    pub distribution: String,
}

/// Progression rule for one simulated leaderboard.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PopulationScoreProgressionDefinition {
    /// Progression mode such as `bounded_random_walk`.
    pub mode: String,
    /// Per-update volatility scale.
    pub volatility: f64,
    /// Mean-reversion factor toward the archetype mean.
    pub mean_reversion: f64,
}

/// Per-leaderboard simulation config inside a population template.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct PopulationLeaderboardDefinition {
    /// Optional category token retained as metadata.
    #[serde(default)]
    pub category: Option<String>,
    /// Initial score distribution config.
    #[serde(default)]
    pub initial_score: PopulationInitialScoreDefinition,
    /// Score evolution rule.
    #[serde(default)]
    pub progression: PopulationScoreProgressionDefinition,
}

/// Author-time definition for one virtual population template.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PopulationTemplateDefinition {
    /// Stable template id.
    pub id: String,
    /// Prefix used for generated profile ids.
    pub id_prefix: String,
    /// Number of virtual profiles to generate.
    pub count: usize,
    /// Identity generation config.
    pub identity: PopulationIdentityDefinition,
    /// Weighted archetypes.
    pub archetypes: Vec<PopulationArchetypeDefinition>,
    /// Simulated leaderboard map by leaderboard id.
    pub leaderboards: BTreeMap<String, PopulationLeaderboardDefinition>,
}

/// Reward state tracked by the store.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum RewardState {
    /// Reward is waiting for game code to claim it.
    Pending,
    /// Reward was claimed by game code for application.
    Claimed,
    /// Reward was marked applied successfully.
    Applied,
    /// Reward was rejected.
    Rejected,
}

/// One reward record emitted by progression systems.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RewardRecord {
    /// Stable reward id.
    pub id: String,
    /// Origin kind such as `achievement`.
    pub source_kind: String,
    /// Origin id such as the achievement id.
    pub source_id: String,
    /// Opaque reward payload.
    pub payload: JsonValue,
    /// Current reward state.
    pub state: RewardState,
    /// Optional external receipt id.
    pub external_receipt: Option<String>,
}

/// Options accepted when creating a modifier.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ModifierAddOptions {
    /// Modifier layer label such as `final_add`.
    pub layer: Option<String>,
    /// Additive modifier value.
    pub value: f64,
    /// Optional duration in logical seconds.
    pub duration: Option<f64>,
    /// Optional source label.
    pub source: Option<String>,
    /// Optional tag list.
    pub tags: Vec<String>,
}

/// One structured event emitted by the store.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventRecord {
    /// Monotonic event sequence within the store.
    pub sequence: u64,
    /// Store revision associated with the committed change.
    pub revision: u64,
    /// Event type identifier.
    pub event_type: String,
    /// Optional owning profile id.
    pub profile_id: Option<String>,
    /// Optional definition id related to the event.
    pub definition_id: Option<String>,
    /// Structured event payload.
    pub payload: JsonValue,
}

/// One retained transport-neutral change record.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChangeRecord {
    /// Store revision represented by this record.
    pub revision: u64,
    /// Full snapshot for this revision in the initial changeset slice.
    pub snapshot: JsonValue,
}

/// Bounded transport-neutral changeset envelope for incremental sync.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChangesetEnvelope {
    /// Schema version expected by the exported records.
    pub schema_version: u32,
    /// Deterministic hash of authored definitions on the exporting store.
    pub definition_hash: String,
    /// Caller-supplied lower revision bound used for the export request.
    pub from_revision: u64,
    /// Highest revision retained inside `records`.
    pub to_revision: u64,
    /// Whether older matching records were omitted due to an export cap.
    pub truncated: bool,
    /// Retained change records in strictly increasing revision order.
    pub records: Vec<ChangeRecord>,
}

/// Merge policy used when applying a transport-neutral changeset envelope.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ChangesetMergePolicy {
    /// Replace the current local store with the incoming latest snapshot.
    Replace,
    /// Keep the current local store when conflicts are detected.
    KeepLocal,
    /// Reject the incoming changeset when conflicts are detected.
    RejectConflicts,
}

/// Options controlling validated changeset-envelope application.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChangesetApplyOptions {
    /// Whether the incoming schema version must match the local store schema version.
    pub require_schema_match: bool,
    /// Whether the incoming definition hash must match the local store definition hash.
    pub require_definition_hash_match: bool,
    /// Merge policy to apply after validation and conflict analysis.
    pub merge_policy: ChangesetMergePolicy,
}

impl Default for ChangesetApplyOptions {
    fn default() -> Self {
        Self {
            require_schema_match: true,
            require_definition_hash_match: true,
            merge_policy: ChangesetMergePolicy::Replace,
        }
    }
}

/// One detected conflict while comparing a local store against an incoming changeset snapshot.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChangesetConflict {
    /// Stable conflict kind identifier.
    pub kind: String,
    /// Optional profile id involved in the conflict.
    pub profile_id: Option<String>,
    /// Optional definition or entity id involved in the conflict.
    pub definition_id: Option<String>,
    /// Local revision at the time the conflict was evaluated.
    pub local_revision: u64,
    /// Incoming source revision represented by the applied envelope.
    pub source_revision: u64,
    /// Structured conflict details.
    pub details: JsonValue,
}

/// Runtime lifecycle state for one season definition.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SeasonState {
    /// Stable season id.
    pub id: String,
    /// Whether the season is currently active.
    pub active: bool,
    /// Actual logical start time when manually started.
    pub started_at: Option<f64>,
    /// Actual logical end time when manually ended.
    pub ended_at: Option<f64>,
    /// Number of archived completed runs retained for this season.
    pub archive_count: u32,
}

/// Retained archive entry for one completed season run.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SeasonArchiveRecord {
    /// Stable season id.
    pub id: String,
    /// One-based archive sequence for the season.
    pub archive_index: u32,
    /// Actual logical start time for the archived run.
    pub started_at: Option<f64>,
    /// Actual logical end time for the archived run.
    pub ended_at: f64,
    /// Store revision that captured the archived snapshot.
    pub revision: u64,
    /// Full progression snapshot captured before resets were applied.
    pub snapshot: JsonValue,
}

/// Authored lifecycle rules for one gameplay status effect.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StatusDefinition {
    /// Stable definition identifier.
    pub id: String,
    /// Duration in seconds. `None` means the status does not expire automatically.
    pub duration: Option<f64>,
    /// Optional periodic tick interval in seconds.
    pub tick_interval: Option<f64>,
    /// Maximum number of stacks accepted for one subject.
    pub max_stacks: u32,
    /// Replace, refresh, or add stacking policy.
    pub stacking: String,
    /// Caller-defined tags used by Lua-side immunity and dispel rules.
    pub tags: Vec<String>,
}

/// Runtime state for one status instance attached to a stable subject ID.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StatusInstance {
    /// Runtime instance identifier.
    pub id: u64,
    /// Stable status definition identifier.
    pub definition_id: String,
    /// Stable subject/entity identifier.
    pub subject_id: u64,
    /// Optional source/owner identifier.
    pub source_id: Option<u64>,
    /// Current stack count.
    pub stacks: u32,
    /// Remaining duration in seconds, or `None` for infinite duration.
    pub remaining: Option<f64>,
    /// Time remaining before the next periodic tick.
    pub next_tick: Option<f64>,
    /// Tags copied from the definition when the instance was applied.
    #[serde(default)]
    pub tags: Vec<String>,
    /// Whether lifecycle timers are currently paused.
    #[serde(default)]
    pub paused: bool,
}

/// Neutral status lifecycle event for Lua-side integrations.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StatusEvent {
    /// Event kind: applied, refreshed, stacked, tick, or expired.
    pub kind: String,
    /// Runtime status instance identifier.
    pub instance_id: u64,
    /// Stable subject/entity identifier.
    pub subject_id: u64,
    /// Stable status definition identifier.
    pub definition_id: String,
    /// Current stack count at the event boundary.
    pub stacks: u32,
    /// Remaining duration, when finite.
    pub remaining: Option<f64>,
    /// Number of periodic ticks represented by this event.
    pub tick_count: u32,
}

/// Serializable status tracker snapshot.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StatusSnapshot {
    /// Authored definitions keyed by ID.
    pub definitions: BTreeMap<String, StatusDefinition>,
    /// Active instances keyed by runtime ID.
    pub instances: BTreeMap<u64, StatusInstance>,
    /// Next runtime ID reserved by the tracker.
    pub next_id: u64,
}
