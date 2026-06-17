//! Defines the dialogue event vocabulary used to publish lifecycle milestones and selection outcomes. `dialog/events` delivers the event data and dispatch contracts for the dialog subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

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
