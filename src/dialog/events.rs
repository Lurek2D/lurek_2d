//! - Provides the event payloads emitted by the dialog runtime while a conversation is advancing.
//! - Carries progression and selection signals so UI and script layers can react without inspecting engine internals.
//! - Keeps integration boundaries explicit by representing conversation lifecycle changes as typed records.

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
