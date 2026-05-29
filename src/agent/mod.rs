//! LLM agent runtime: state, request types, error variants, background HTTP client, and Ollama lifecycle management.

/// Chat session helpers and Ollama prompt integration routines.
pub mod chat;
/// Background LLM HTTP client and async request orchestration.
pub mod client;
/// Lua-facing runtime wrappers used by `src/lua_api/agent_api.rs`.
pub(crate) mod lua_runtime;
/// Working, episodic, and semantic memory primitives for agents.
pub mod memory;
/// Ollama server lifecycle and model-management helpers.
pub mod ollama;
/// Agent and AI-system configuration/state model structures.
pub mod state;
/// Shared request and response types for LLM transport.
pub mod types;

pub use chat::{GlobalLlmConfig, LlmChat, LlmTemplate, read_global_config, write_global_config};
pub use client::AgentClient;
pub(crate) use lua_runtime::{AgentBatchTask, LuaAgentManagerRuntime, LuaAgentRuntime, LuaAISystemRuntime};
pub(crate) use lua_runtime::lua_to_json;
pub use memory::{AgentMemory, EpisodicMemory, SemanticMemory, WorkingMemory};
pub use ollama::{ModelInfo, OllamaManager, OllamaPullResult};
pub use state::{AgentState, AISystemState, SystemSkill};
pub use types::{AgentError, AgentRequest, AgentResponse};
