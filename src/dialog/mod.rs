//! - Provides the runtime conversation stack for branching dialogue, speaker metadata, and progression state.
//! - Combines gate-aware topic and branch selection with lightweight context signals for adaptive narrative flow.
//! - Exposes a clean integration surface where scripts consume events while core logic remains in typed dialog data.

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
