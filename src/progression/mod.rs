//! Declares the headless progression domain that backs the public `lurek.progression` Lua module.
//! Exports the store, data contracts, and focused subsystem files that own deterministic progression behavior.
//! Separates profiles, leaderboards, populations, seasons, persistence, and event helpers into navigable owners.
//! Reexports the symbols that Rust tests and Lua bindings need without requiring callers to know file layout.
//! Marks the progression domain as CPU-only and independent from rendering, audio, networking, or live Lua state.
//! Open this index when routing a change to the correct progression owner or tracing reexports into sibling files.
pub mod store;
pub mod types;

pub use store::{
    AttributeExplanation, ChangeSummary, ProgressionError, ProgressionOperation, ProgressionStore,
    ProgressionTransaction, StatusTracker,
};
pub use types::{
    AchievementDefinition, AttributeDefinition, AttributeMode, ChallengeTemplateDefinition,
    ChangeRecord, ChangesetApplyOptions, ChangesetConflict, ChangesetEnvelope,
    ChangesetMergePolicy, CollectionDefinition, CollectionItemDefinition, ComparisonOp,
    CounterDefinition, CounterKind, CounterTriggerDefinition, DerivedValueDefinition,
    DerivedValueInput, EventRecord, LeaderboardDefinition, LeaderboardRankMode, LeaderboardSort,
    LevelTrackDefinition, ModifierAddOptions, PerkDefinition, PopulationActivityDefinition,
    PopulationArchetypeDefinition, PopulationIdentityDefinition, PopulationInitialScoreDefinition,
    PopulationLeaderboardDefinition, PopulationNameGeneratorDefinition,
    PopulationScoreProgressionDefinition, PopulationSkillDefinition, PopulationTemplateDefinition,
    PrestigeDefinition, PrestigePreserveDefinition, PrestigeResetDefinition, ProfileOptions,
    ProfileTemplateDefinition, ProgressionCondition, ProgressionStoreOptions, QuestDefinition,
    QuestJournalEntry, QuestObjectiveDefinition, QuestStageDefinition, ResourceDefinition,
    RewardRecord, RewardState, RivalDefinition, SeasonArchiveRecord, SeasonDefinition,
    SeasonResetDefinition, SeasonState, SkillDefinition, StatusDefinition, StatusEvent,
    StatusInstance, StatusSnapshot, TraitDefinition, TraitModifierDefinition,
};
