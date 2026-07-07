//! `src/dialog/mod.rs` is the module index for dialogue gating, events, speakers, runtime state, sequencers, and trees.
//! It declares the files that own branch conditions, event vocabulary, speaker data, playback state, and selection logic.
//! This file reexports the dialog-facing types so callers can assemble conversations without importing deep internal paths.
//! No live conversation state or authored graph data lives here; it only defines visibility and subsystem boundaries.
//! Read this index first when tracing dialog behavior, because it shows where gating, playback, and authored data split.
//! Changes here affect module reachability and API shape, not sequencing rules, branch scoring, or runtime progression.

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
pub use sequencer::{
    DialogHistoryEntry, DialogLineMeta, DialogNode as SequencerNode, DialogSequencer,
    DialogSequencerSnapshot, DialogSignal, SequencerState,
};
pub use speaker::{Speaker, SpeakerRegistry};
pub use state::DialogueState;
pub use tree::{DialogueAI, DialogueBranch, DialogueNode, DialogueTopic};
