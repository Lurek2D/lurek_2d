//! Defines the dialogue event vocabulary used to publish lifecycle milestones and selection outcomes.
//! Carries typed payloads so UI, scripting, and telemetry can react without digging into internal state.
//! Delivers a clean event contract that keeps conversation flow observable across integration points.

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
