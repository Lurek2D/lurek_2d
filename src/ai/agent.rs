//! Defines the runtime state shape for one AI actor, combining identity, movement state, decision mode, and support models.
//! Owns the DecisionModel enum plus agent-side blackboard, tags, optional sensor, emotions, needs, and traits.
//! Stores links into decision-runtime handles so one agent can bind to FSM, behavior-tree, and movement-guidance models.
//! Provides the per-actor boundary between shared AI systems and the concrete state they read and update.
//! Open this owner when agent schema, decision-mode tagging, or cross-system state handoff needs to change.

use crate::ai::command_queue::CommandQueue;
use crate::ai::emotion::EmotionModel;
use crate::ai::needs::NeedSystem;
use crate::ai::perception::Sensor;
use crate::ai::traits::TraitProfile;
use crate::patterns::Blackboard;
use std::collections::HashSet;
/// Active AI decision strategy assigned to an `Agent`.
#[derive(Debug, Clone, PartialEq)]
pub enum DecisionModel {
    /// Finite-state machine only.
    Fsm,
    /// Behavior tree only.
    Bt,
    /// Steering behaviors only.
    Steering,
    /// Finite-state machine combined with steering.
    FsmSteering,
    /// Behavior tree combined with steering.
    BtSteering,
    /// Custom strategy driven by a Lua callback.
    Custom {
        /// Registry index of the Lua decision callback.
        callback_id: u32,
    },
}
impl DecisionModel {
    /// Parse a string tag into a `DecisionModel`; returns `None` for unknown tags.
    pub fn parse_str(s: &str) -> Option<Self> {
        match s {
            "fsm" => Some(Self::Fsm),
            "bt" => Some(Self::Bt),
            "steering" => Some(Self::Steering),
            "fsm+steering" => Some(Self::FsmSteering),
            "bt+steering" => Some(Self::BtSteering),
            _ => None,
        }
    }
    /// Return the canonical string tag for this model.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Fsm => "fsm",
            Self::Bt => "bt",
            Self::Steering => "steering",
            Self::FsmSteering => "fsm+steering",
            Self::BtSteering => "bt+steering",
            Self::Custom { .. } => "custom",
        }
    }
}
/// Built-in stance presets used for RTS-style target acquisition and movement interruption policy.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AgentStance {
    /// Never auto-acquire targets from nearby hostiles.
    Passive,
    /// Acquire nearby targets for tracking but do not auto-fire.
    HoldFire,
    /// Acquire hostiles within a short guard radius and use a short chase leash.
    Defensive,
    /// Acquire nearby hostiles and allow brief movement interruption for engagement.
    Aggressive,
    /// Acquire any nearby hostile with the loosest leash and weakest formation discipline.
    Berserk,
}
impl AgentStance {
    /// Parse a lowercase stance name; unknown strings map to `None`.
    pub fn parse_str(s: &str) -> Option<Self> {
        match s {
            "passive" => Some(Self::Passive),
            "hold_fire" => Some(Self::HoldFire),
            "defensive" => Some(Self::Defensive),
            "aggressive" => Some(Self::Aggressive),
            "berserk" => Some(Self::Berserk),
            _ => None,
        }
    }
    /// Return the canonical lowercase stance name.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Passive => "passive",
            Self::HoldFire => "hold_fire",
            Self::Defensive => "defensive",
            Self::Aggressive => "aggressive",
            Self::Berserk => "berserk",
        }
    }
    /// Build the default runtime profile for this stance.
    pub fn default_profile(&self) -> StanceProfile {
        match self {
            Self::Passive => StanceProfile {
                stance: *self,
                acquire_enabled: false,
                hold_fire: false,
                acquire_radius: 0.0,
                guard_radius: 64.0,
                chase_radius: 0.0,
                interrupts_move: false,
                abandon_formation: false,
            },
            Self::HoldFire => StanceProfile {
                stance: *self,
                acquire_enabled: true,
                hold_fire: true,
                acquire_radius: 144.0,
                guard_radius: 96.0,
                chase_radius: 0.0,
                interrupts_move: false,
                abandon_formation: false,
            },
            Self::Defensive => StanceProfile {
                stance: *self,
                acquire_enabled: true,
                hold_fire: false,
                acquire_radius: 160.0,
                guard_radius: 128.0,
                chase_radius: 96.0,
                interrupts_move: false,
                abandon_formation: false,
            },
            Self::Aggressive => StanceProfile {
                stance: *self,
                acquire_enabled: true,
                hold_fire: false,
                acquire_radius: 224.0,
                guard_radius: 160.0,
                chase_radius: 192.0,
                interrupts_move: true,
                abandon_formation: false,
            },
            Self::Berserk => StanceProfile {
                stance: *self,
                acquire_enabled: true,
                hold_fire: false,
                acquire_radius: 320.0,
                guard_radius: 224.0,
                chase_radius: 320.0,
                interrupts_move: true,
                abandon_formation: true,
            },
        }
    }
}
/// Runtime stance settings copied onto one agent and optionally overridden by gameplay code.
#[derive(Debug, Clone, PartialEq)]
pub struct StanceProfile {
    /// Base built-in stance name from which this profile was derived.
    pub stance: AgentStance,
    /// Whether the agent may auto-acquire nearby targets.
    pub acquire_enabled: bool,
    /// Whether the agent should track targets without firing automatically.
    pub hold_fire: bool,
    /// Radius in world units used for general hostile acquisition.
    pub acquire_radius: f32,
    /// Radius in world units used for defensive guard reactions.
    pub guard_radius: f32,
    /// Maximum chase leash in world units once a target is acquired.
    pub chase_radius: f32,
    /// Whether a move order may be interrupted for a newly acquired target.
    pub interrupts_move: bool,
    /// Whether the agent may abandon formation discipline while engaging.
    pub abandon_formation: bool,
}
/// Per-agent runtime state that tracks soft order interruption and auto-engagement.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct OrderRuntimeState {
    /// Current hostile target name when the agent is temporarily overriding its queued order.
    pub engage_target: Option<String>,
    /// World-space position from which the current engagement leash is measured.
    pub engage_origin: Option<(f32, f32)>,
    /// Front-queue order id currently suspended by the engagement override, when any.
    pub suspended_order_id: Option<u64>,
    /// Whether the engagement override is currently allowed to break formation discipline.
    pub formation_abandoned: bool,
}
/// Runtime state for one AI-controlled entity in the world.
pub struct Agent {
    /// Unique agent name.
    pub name: String,
    /// Scheduling priority; higher values are processed first.
    pub priority: i32,
    /// World-space position in pixels.
    pub position: (f32, f32),
    /// World-space velocity in pixels per second.
    pub velocity: (f32, f32),
    /// Maximum movement speed.
    pub max_speed: f32,
    /// Maximum steering force magnitude.
    pub max_force: f32,
    /// Active decision strategy.
    pub decision_model: DecisionModel,
    /// Per-agent key/value store.
    pub blackboard: Blackboard,
    /// String tags attached to this agent.
    pub tags: HashSet<String>,
    /// Integer team identifier used by spatial hostile-acquisition queries.
    pub team: i32,
    /// RTS-style stance profile that controls acquisition and interruption defaults.
    pub stance: StanceProfile,
    /// Index into the FSM arena when the model uses FSM.
    pub fsm_index: Option<usize>,
    /// Index into the behavior-tree arena when the model uses BT.
    pub bt_index: Option<usize>,
    /// Index into the steering arena when the model uses steering.
    pub steering_index: Option<usize>,
    /// Optional trait profile.
    pub trait_profile: Option<TraitProfile>,
    /// Optional sensory perception filter.
    pub sensor: Option<Sensor>,
    /// Optional emotional state model.
    pub emotion_model: Option<EmotionModel>,
    /// Optional needs system.
    pub need_system: Option<NeedSystem>,
    /// Current LOD tier index.
    pub lod_tier: usize,
    /// Ordered command queue owned by this agent for movement, action, and interruption orchestration.
    pub command_queue: CommandQueue,
    /// Soft order-interruption state used by world update to suspend or resume queued intent.
    pub order_runtime: OrderRuntimeState,
}
impl Agent {
    /// Create a new agent with default movement, AI, and support systems.
    pub fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            priority: 0,
            position: (0.0, 0.0),
            velocity: (0.0, 0.0),
            max_speed: 100.0,
            max_force: 200.0,
            decision_model: DecisionModel::Fsm,
            blackboard: Blackboard::default(),
            tags: HashSet::new(),
            team: 0,
            stance: AgentStance::Aggressive.default_profile(),
            fsm_index: None,
            bt_index: None,
            steering_index: None,
            trait_profile: None,
            sensor: None,
            emotion_model: None,
            need_system: None,
            lod_tier: 0,
            command_queue: CommandQueue::new(),
            order_runtime: OrderRuntimeState::default(),
        }
    }
}
