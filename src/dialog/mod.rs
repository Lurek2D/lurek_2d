//! Provides the high-level dialog module surface that unifies authored conversation flow with runtime progression state.
//! Connects speaker identity, gating logic, selection models, and lifecycle events into one coherent interaction layer.
//! Delivers a stable module boundary that scripts and systems consume as the canonical dialogue orchestration entry point.

/// Gate conditions that guard dialog branch and topic selection.
pub mod condition;
/// Events emitted by the dialog tree engine during conversation playback.
pub mod events;
/// Speaker registry and character metadata used across dialog trees.
pub mod speaker;
/// Dialog FSM state tracking current node and conversation progress.
pub mod state;
/// Dialog tree engine: nodes, weighted branches, and topic selection.
pub mod tree;
/// Dialog sequencer: typewriter-reveal playback with choices and callbacks.
pub mod sequencer;

pub use condition::{DialogueCondition, GateContext};
pub use events::DialogueEvent;
pub use speaker::{Speaker, SpeakerRegistry};
pub use state::DialogueState;
pub use tree::{DialogueAI, DialogueBranch, DialogueNode, DialogueTopic};
pub use sequencer::{DialogSequencer, DialogNode as SequencerNode, SequencerState};
