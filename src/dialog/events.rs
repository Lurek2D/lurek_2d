//! `src/dialog/events.rs` defines the event vocabulary emitted by the dialog system during conversation progress.
//! It owns lifecycle and selection payloads for start, advance, topic choice, branch choice, ending, and variable writes.
//! Read it when dialog event names, payload shapes, or script-facing milestone contracts need to change.

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
