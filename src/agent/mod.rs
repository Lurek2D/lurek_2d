//! LLM agent runtime: state, request types, error variants, background HTTP client, and Ollama lifecycle management.

pub mod chat;
pub mod client;
pub(crate) mod lua_runtime;
pub mod memory;
pub mod ollama;
pub mod state;
pub mod types;

pub use chat::{GlobalLlmConfig, LlmChat, LlmTemplate, read_global_config, write_global_config};
pub use client::AgentClient;
pub(crate) use lua_runtime::{AgentBatchTask, LuaAgentManagerRuntime, LuaAgentRuntime, LuaAISystemRuntime};
pub(crate) use lua_runtime::lua_to_json;
pub use memory::{AgentMemory, EpisodicMemory, SemanticMemory, WorkingMemory};
pub use ollama::{ModelInfo, OllamaManager, OllamaPullResult};
pub use state::{AgentState, AISystemState, SystemSkill};
pub use types::{AgentError, AgentRequest, AgentResponse};
