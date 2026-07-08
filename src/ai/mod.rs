//! Exports the AI subsystem surface that groups decision models, sensing, planning, pacing, and debug tools.
//! Acts as the navigation index for agent state, behavior trees, GOAP, HTN, MCTS, squads, and utility scoring.
//! Keeps module boundaries explicit so callers can find whether an AI concern belongs to storage, reasoning, or draw.
//! Open this file when adding or retiring AI owners or when public re-export policy for shared AI APIs changes.
//! The exported set here connects world awareness, strategic choice, internal drives, and supporting data models.
//! Agents should start here when tracing AI behavior because it reveals the authoritative file split by concern.
//! This index owns visibility and compatibility re-exports rather than world state, planners, or runtime solvers.
//! Neighboring work usually spans Agent, AIWorld, planning modules, and debug visualization helpers.
//! It is the right owner for composition-level AI API changes that should not alter any one behavior algorithm.
//! Read this file first when generated specs or Lua bindings need to map a feature to its concrete Rust owner.

/// Core agent type and decision model wiring.
pub mod agent;
/// Behavior tree nodes and execution runtime.
pub mod behavior_tree;
/// Command queue for deferred AI actions.
pub mod command_queue;
/// Shared AI diagnostics and decision traces.
pub mod diagnostics;
/// Shared AI validation and safety errors.
pub mod error;
/// Finite-state machine helpers.
pub mod fsm;
/// Goal-oriented action planning types.
pub mod goap;

/// AI-focused debug and visualization helpers.
pub mod render;
/// Squad membership and formation logic.
pub mod squad;
/// Utility-AI scoring and action selection.
pub mod utility_ai;
/// Abstract world view consumed by AI logic.
pub mod world;

/// Dialogue state, branches, and topic selection (re-exported from dialog module).
pub mod dialogue {
    pub use crate::dialog::{DialogueAI, DialogueBranch, DialogueTopic};
}
/// Encounter pacing and high-level director logic.
pub mod director;
/// Emotion state tracking and decay.
pub mod emotion;

/// Hierarchical task network planning.
pub mod htn;
/// AI level-of-detail switching.
pub mod lod;
/// Monte Carlo tree search support.
pub mod mcts;
/// Need evaluation and advertisement system.
pub mod needs;

/// Perception stimuli, sensors, and world state.
pub mod perception;
/// Higher-level strategy selection.
pub mod strategy;
/// Personality traits and archetype presets.
pub mod traits;
/// Shared AI validation limits and numeric helpers.
pub mod validation;

/// Grouped planning APIs for callers that want a narrower public surface.
pub mod planning {
    pub use super::goap::{GOAPAction, GOAPGoal, GOAPPlanner, PlanFailureReason};
    pub use super::htn::{HTNDomain, HTNMethod, HTNPlanner, HTNTask, WorldState};
    pub use super::mcts::{MCTSConfig, MCTSEngine};
}

/// Grouped decision APIs for callers that only need reasoning primitives.
pub mod decision {
    pub use super::behavior_tree::{BTNode, BTStatus, BehaviorTree, ParallelPolicy};
    pub use super::fsm::{StateCallbacks, StateMachine, Transition};
    pub use super::strategy::{StrategicGoal, StrategyAI};
    pub use super::utility_ai::{Consideration, ResponseCurve, UAAction, UtilityAI};
}

/// Grouped simulation-side AI state APIs for callers that manage world or actor state.
pub mod simulation {
    pub use super::agent::{Agent, AgentStance, DecisionModel, OrderRuntimeState, StanceProfile};
    pub use super::director::{AIDirector, DirectorConfig, DirectorPhase};
    pub use super::emotion::{Emotion, EmotionModel};
    pub use super::lod::{AILod, LodTier};
    pub use super::needs::{Need, NeedAdvertisement, NeedSystem};
    pub use super::perception::{DetectedStimulus, Sensor, Stimulus, StimulusType, StimulusWorld};
    pub use super::squad::{FormationType, Squad};
    pub use super::traits::{
        DecisionBiasMode, DecisionBiasRule, DecisionBiasSet, TraitArchetypes, TraitModifier,
        TraitProfile, BUILTIN_TRAITS,
    };
    pub use super::world::{AIOrderRuntimeStats, AISpatialQueryStats, AIWorld, SpatialQueryOptions};
}

/// Grouped debug and diagnostics APIs for AI inspection.
pub mod debug {
    pub use super::diagnostics::{
        CallbackErrorTrace, GoapPlanTrace, MctsDecisionTrace, UtilityActionTrace,
        UtilityConsiderationTrace, UtilityDecisionTrace,
    };
}

/// Blackboard storage shared by AI systems, re-exported from `crate::patterns`.
pub use crate::patterns::{Blackboard, BlackboardValue};
/// Base agent type and decision-model enum.
pub use agent::{Agent, AgentStance, DecisionModel, OrderRuntimeState, StanceProfile};
/// Behavior tree nodes, statuses, and policies.
pub use behavior_tree::{BTNode, BTStatus, BehaviorTree, ParallelPolicy};
/// Deferred command queue, immutable snapshots, and lifecycle events.
pub use command_queue::{Command, CommandEvent, CommandQueue, CommandSnapshot};
/// Finite-state machine building blocks.
pub use fsm::{StateCallbacks, StateMachine, Transition};
/// GOAP planner inputs and planner type.
pub use goap::{GOAPAction, GOAPGoal, GOAPPlanner, PlanFailureReason};
/// Squad container and formation mode.
pub use squad::{
    FormationFallbackMode, FormationLayout, FormationSlotAssignment, FormationSortMode,
    FormationType, Squad, SquadMemberProfile,
};
/// Utility-AI considerations, response curves, and actions.
pub use utility_ai::{Consideration, ResponseCurve, UAAction, UtilityAI};
/// AI-facing world abstraction.
pub use world::{AIOrderRuntimeStats, AISpatialQueryStats, AIWorld, SpatialQueryOptions};

/// Shared AI callback and decision traces.
pub use diagnostics::{
    CallbackErrorTrace, GoapPlanTrace, MctsDecisionTrace, UtilityActionTrace,
    UtilityConsiderationTrace, UtilityDecisionTrace,
};
/// Dialogue decision types.
pub use dialogue::{DialogueAI, DialogueBranch, DialogueTopic};
/// High-level encounter director types.
pub use director::{AIDirector, DirectorConfig, DirectorPhase};
/// Emotion model types.
pub use emotion::{Emotion, EmotionModel};
/// Shared AI validation errors and limits.
pub use error::AiError;
/// HTN planner domain and task types.
pub use htn::{HTNDomain, HTNMethod, HTNPlanner, HTNTask, WorldState};
/// AI level-of-detail types.
pub use lod::{AILod, LodTier};
/// Monte Carlo tree search configuration and engine.
pub use mcts::{MCTSConfig, MCTSEngine};
/// Need system state and advertisements.
pub use needs::{Need, NeedAdvertisement, NeedSystem};
/// Perception events, sensors, and stimulus world.
pub use perception::{DetectedStimulus, Sensor, Stimulus, StimulusType, StimulusWorld};
/// Strategy layer goals and controller.
pub use strategy::{StrategicGoal, StrategyAI};
/// Trait profiles, modifiers, archetypes, and decision bias rules.
pub use traits::{
    DecisionBiasMode, DecisionBiasRule, DecisionBiasSet, TraitArchetypes, TraitModifier,
    TraitProfile, BUILTIN_TRAITS,
};
/// Shared AI validation limit configuration.
pub use validation::AiValidationLimits;
