//! Exports the AI subsystem surface that groups decision models, sensing, planning, steering, pacing, and debug tools.
//! Acts as the navigation index for agent state, behavior trees, GOAP, HTN, MCTS, squads, and utility scoring.
//! Keeps module boundaries explicit so callers can find whether an AI concern belongs to storage, reasoning, or draw.
//! Open this file when adding or retiring AI owners or when public re-export policy for shared AI APIs changes.
//! The exported set here connects tactical motion, world awareness, strategic choice, and supporting data models.
//! Agents should start here when tracing AI behavior because it reveals the authoritative file split by concern.
//! This index owns visibility and compatibility re-exports rather than world state, planners, or runtime solvers.
//! Neighboring work usually spans Agent, AIWorld, steering, planning modules, and debug visualization helpers.
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
/// Steering behaviors and movement guidance.
pub mod steering;
/// Utility-AI scoring and action selection.
pub mod utility_ai;
/// Abstract world view consumed by AI logic.
pub mod world;

/// Context-steering behavior composition.
pub mod context_steering;
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

/// ORCA-based local avoidance.
pub mod orca;
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

/// Grouped movement and avoidance APIs for callers that only need locomotion-side AI.
pub mod movement {
    pub use super::context_steering::{ContextBehavior, ContextBehaviorKind, ContextSteering};
    pub use super::orca::{ORCAAgent, ORCASolver};
    pub use super::steering::*;
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
    pub use super::agent::{Agent, DecisionModel};
    pub use super::director::{AIDirector, DirectorConfig, DirectorPhase};
    pub use super::emotion::{Emotion, EmotionModel};
    pub use super::lod::{AILod, LodTier};
    pub use super::needs::{Need, NeedAdvertisement, NeedSystem};
    pub use super::perception::{DetectedStimulus, Sensor, Stimulus, StimulusType, StimulusWorld};
    pub use super::squad::{FormationType, Squad};
    pub use super::traits::{TraitArchetypes, TraitModifier, TraitProfile};
    pub use super::world::AIWorld;
}

/// Grouped debug and diagnostics APIs for AI inspection.
pub mod debug {
    pub use super::diagnostics::{
        CallbackErrorTrace, GoapPlanTrace, MctsDecisionTrace, UtilityActionTrace,
        UtilityConsiderationTrace, UtilityDecisionTrace,
    };
}

/// Tabular reinforcement learner (re-exported from learning module).
pub use crate::learning::QLearner;
/// Blackboard storage shared by AI systems, re-exported from `crate::patterns`.
pub use crate::patterns::{Blackboard, BlackboardValue};
/// Base agent type and decision-model enum.
pub use agent::{Agent, DecisionModel};
/// Behavior tree nodes, statuses, and policies.
pub use behavior_tree::{BTNode, BTStatus, BehaviorTree, ParallelPolicy};
/// Deferred command queue and command variants.
pub use command_queue::{Command, CommandQueue};
/// Finite-state machine building blocks.
pub use fsm::{StateCallbacks, StateMachine, Transition};
/// GOAP planner inputs and planner type.
pub use goap::{GOAPAction, GOAPGoal, GOAPPlanner, PlanFailureReason};
/// Squad container and formation mode.
pub use squad::{FormationType, Squad};
/// Steering behavior primitives and helpers.
pub use steering::*;
/// Utility-AI considerations, response curves, and actions.
pub use utility_ai::{Consideration, ResponseCurve, UAAction, UtilityAI};
/// AI-facing world abstraction.
pub use world::AIWorld;

/// Neuroevolution entry point (re-exported from learning module).
pub use crate::learning::Neuroevolution;
/// Neural-network layer and activation types (re-exported from learning module).
pub use crate::learning::{Activation, NeuralLayer, NeuralNet};
/// Multi-armed bandit policies and arm stats (re-exported from learning module).
pub use crate::learning::{Bandit, BanditArm, BanditStrategy};
/// Shared AI callback and decision traces.
pub use diagnostics::{
    CallbackErrorTrace, GoapPlanTrace, MctsDecisionTrace, UtilityActionTrace,
    UtilityConsiderationTrace, UtilityDecisionTrace,
};
/// Shared AI validation errors and limits.
pub use error::AiError;
/// Genetic algorithm public types (re-exported from learning module).
pub use crate::learning::{Chromosome, GeneticAlgorithm};
/// Context-steering behaviors and runtime type.
pub use context_steering::{ContextBehavior, ContextBehaviorKind, ContextSteering};
/// Dialogue decision types.
pub use dialogue::{DialogueAI, DialogueBranch, DialogueTopic};
/// High-level encounter director types.
pub use director::{AIDirector, DirectorConfig, DirectorPhase};
/// Emotion model types.
pub use emotion::{Emotion, EmotionModel};
/// HTN planner domain and task types.
pub use htn::{HTNDomain, HTNMethod, HTNPlanner, HTNTask, WorldState};
/// AI level-of-detail types.
pub use lod::{AILod, LodTier};
/// Monte Carlo tree search configuration and engine.
pub use mcts::{MCTSConfig, MCTSEngine};
/// Need system state and advertisements.
pub use needs::{Need, NeedAdvertisement, NeedSystem};
/// ORCA avoidance solver types.
pub use orca::{ORCAAgent, ORCASolver};
/// Perception events, sensors, and stimulus world.
pub use perception::{DetectedStimulus, Sensor, Stimulus, StimulusType, StimulusWorld};
/// Strategy layer goals and controller.
pub use strategy::{StrategicGoal, StrategyAI};
/// Trait profiles, modifiers, and archetypes.
pub use traits::{TraitArchetypes, TraitModifier, TraitProfile};
/// Shared AI validation limit configuration.
pub use validation::AiValidationLimits;
