//! Dialog and conversation system.
//!
//! Provides a flexible dialog tree engine with:
//! - Weighted topic/branch selection with gate conditions
//! - FSM and behavior tree state context for conditional branching
//! - Utility-score-based topic prioritization
//! - Speaker registry for character metadata
//! - Event emission for script integration
//!
//! The module powers both simple linear dialogs and complex branching
//! conversations with dynamic topic selection.

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

pub use condition::{DialogueCondition, GateContext};
pub use events::DialogueEvent;
pub use speaker::{Speaker, SpeakerRegistry};
pub use state::DialogueState;
pub use tree::{DialogueAI, DialogueBranch, DialogueNode, DialogueTopic};
