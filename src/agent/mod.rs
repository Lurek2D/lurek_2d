//! Defines the `agent` domain module boundary for LLM-backed behavior.
//! Contains transport, state, memory, orchestration logic, and Ollama lifecycle components.
//! Keeps Lua binding/runtime details out of this layer so `src/lua_api/` stays the integration boundary.

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

pub use chat::{read_global_config, write_global_config, GlobalLlmConfig, LlmChat, LlmTemplate};
pub use client::AgentClient;
pub use memory::{AgentMemory, EpisodicMemory, SemanticMemory, WorkingMemory};
pub use ollama::{ModelInfo, OllamaManager, OllamaPullResult};
pub use orchestration::AgentBatchTask;
pub use state::{AISystemState, AgentState, SystemSkill};
pub use types::{AgentError, AgentRequest, AgentResponse};
