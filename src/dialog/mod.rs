//! Provides the high-level dialog module surface that unifies authored conversation flow with runtime progression state. `dialog/mod` is the dialog module index, declaring `condition`, `events`, `sequencer`, `speaker`, `state`, and 1 more so agents can identify which files own each feature slice before opening implementation code.
//! Connects speaker identity, gating logic, selection models, and lifecycle events into one coherent interaction layer. `src/dialog/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `condition::{DialogueCondition, GateContext}`, `events::DialogueEvent`, `sequencer::{DialogNode as SequencerNode, DialogSequencer, SequencerState}`, `speaker::{Speaker, SpeakerRegistry}`, and 2 more centralized for the dialog subsystem.

/// Gate conditions that guard dialog branch and topic selection.
pub mod condition;
/// Events emitted by the dialog tree engine during conversation playback.
pub mod events;
/// Dialog sequencer: typewriter-reveal playback with choices and callbacks.
pub mod sequencer;
/// Speaker registry and character metadata used across dialog trees.
pub mod speaker;
/// Dialog FSM state tracking current node and conversation progress.
pub mod state;
/// Dialog tree engine: nodes, weighted branches, and topic selection.
pub mod tree;

pub use condition::{DialogueCondition, GateContext};
pub use events::DialogueEvent;
pub use sequencer::{DialogNode as SequencerNode, DialogSequencer, SequencerState};
pub use speaker::{Speaker, SpeakerRegistry};
pub use state::DialogueState;
pub use tree::{DialogueAI, DialogueBranch, DialogueNode, DialogueTopic};
