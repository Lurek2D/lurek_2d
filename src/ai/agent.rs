//! Defines the full runtime shape of one AI actor as a single cohesive control unit. `ai/agent` delivers the agent implementation for the ai subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Blends identity, movement, tactical priority, and decision style into one state heartbeat. The file owns or coordinates data contracts including `DecisionModel`, `Agent`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Keeps planner-facing memory, sensing, affect, motives, traits, and squad semantics aligned. Public callable behavior is centered on no named public items, while method-level behavior such as `parse_str`, `as_str`, `new` stays attached to the local data model and invariants.
//! Preserves stable cross-system handoff so world updates read one consistent behavioral snapshot. Runtime integration reaches sibling engine areas through crate modules `ai`, `patterns`, which explains the subsystem dependencies an agent should inspect before changing behavior.

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
            fsm_index: None,
            bt_index: None,
            steering_index: None,
            trait_profile: None,
            sensor: None,
            emotion_model: None,
            need_system: None,
            lod_tier: 0,
        }
    }
}
