//! This module re-exports the agent subsystem surface for chat, transport, memory, Ollama control, and state.
//! It exists to keep callers on stable entry points while sibling files own request shaping, retries, and storage.
//! `chat.rs` handles synchronous prompt calls, templates, and session history for immediate model interactions.
//! `client.rs`, `types.rs`, and `state.rs` define async transport, payload contracts, and request-building state.
//! `memory.rs`, `ollama.rs`, and `orchestration.rs` cover recall stores, local backend control, and batch routing.
//! Change this file when the public agent symbol map moves; change siblings when behavior or data rules change.

/// Chat session helpers and Ollama prompt integration routines.
pub mod chat;
/// Background LLM HTTP client and async request orchestration.
pub mod client;
/// Working, episodic, and semantic memory primitives for agents.
pub mod memory;
/// Ollama server lifecycle and model-management helpers.
pub mod ollama;
/// Agent orchestration logic shared between runtime entrypoints.
pub mod orchestration;
/// Agent and AI-system configuration/state model structures.
pub mod state;
/// Shared request and response types for LLM transport.
pub mod types;

pub use chat::{
    read_global_config, validate_global_config, write_global_config, GlobalLlmConfig, LlmChat,
    LlmTemplate,
};
pub use client::{
    AgentClient, AgentClientConfig, AgentDiagnosticsSnapshot, AgentTransport, HttpAgentTransport,
};
pub use memory::{
    AgentMemory, AgentMemoryDiagnosticsSnapshot, AgentMemoryStoragePolicy, EpisodicMemory,
    SemanticMemory, WorkingMemory,
};
pub use ollama::{
    ModelInfo, OllamaDiagnosticsSnapshot, OllamaManager, OllamaModelPolicy, OllamaProcessPolicy,
    OllamaPullResult, OllamaStartStatus,
};
pub use orchestration::AgentBatchTask;
pub use state::{
    AISystemState, AgentNetworkPolicy, AgentPromptPolicy, AgentState, PromptBuildReport,
    PromptProvenanceEntry, SystemSkill,
};
pub use types::{AgentError, AgentRequest, AgentResponse, AgentResponseFormat};
