//! Events emitted by the dialog tree engine during conversation playback.
//!
//! - `DialogEvent` variants: `NodeEntered`, `ChoiceMade`, `Finished`, `Interrupted`.
//! - Pushed into the engine's event queue; consumed by game scripts each tick.
//! - `NodeEntered` carries the node ID and speaker ID for UI presentation.
//! - Cleared at the start of each tick after the Lua callback has processed them.

/// Events emitted by the dialog system for script integration.
#[derive(Debug, Clone)]
pub enum DialogueEvent {
    /// Conversation started at given node.
    Started { node_id: String },
    /// Advanced to a new node.
    Advanced { from: String, to: String },
    /// A branch/choice was selected.
    BranchSelected { topic_id: String, branch_id: String },
    /// A topic was selected.
    TopicSelected { topic_id: String },
    /// Conversation ended.
    Ended,
    /// A variable was set during conversation.
    VariableSet { key: String, value: String },
}
