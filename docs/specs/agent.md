# agent

## TL;DR

- Orchestrates multi-agent AI completions and stateful conversations.
- Supports tiered, persistent working, episodic, and semantic memory.
- Manages local Ollama lifecycles and background request polling.

## General Info

- Module group: `Feature Systems`
- Source path: `src/agent/`
- Binding: `src/lua_api/agent_api.rs`
- Namespace: `lurek.agent`
- Lua API surface: `20` functions, `10` types, `85` methods
- Rust test path(s): tests/rust/unit/agent_tests.rs
- Lua test path(s): tests/lua_reorg/unit/test_agent_core_unit.lua

## Summary

- Use `lurek.agent` when a game or tool script needs language-model features without building its own HTTP, polling, memory, or provider-management layer.
- The module gives the user one place to handle one-shot prompts, structured JSON replies, embeddings, persistent chat sessions, and long-running async requests.
- It is the path for turning LLM access from a raw network call into a reusable gameplay system.
- A script can start small with direct completion helpers.
- The same script can later grow into named agents with roles, system prompts, model options, and retry policy.
- That lets prototypes begin with simple prompt/response experiments and scale into stable production flows without moving to another module.
- Multi-turn conversations are a first-class use case here.
- Chat handles keep message history and system context together so follow-up prompts behave like part of one session instead of isolated requests.
- Memory support is also built around practical author needs rather than storage theory.
- Working memory keeps recent context available for immediate prompt quality.
- Episodic memory preserves timestamped events that can be recalled or forgotten over time.
- Semantic memory stores durable facts that should survive conversational churn and session boundaries.
- When a script needs several specialists instead of one assistant, the module provides orchestration rather than forcing the user to hand-roll routing logic.
- Users can register named agents, add instruction blocks, attach keyword-driven skills, dispatch parallel tasks, and collect results through one polling loop.
- Async execution is designed for frame-safe game runtime behavior.
- Requests can run in the background, be polled during update, and be cancelled when gameplay state has changed before the reply arrives.
- Local Ollama support makes the module useful even when the goal is offline or self-hosted workflows.
- Model discovery, service health checks, downloads, and lifecycle control all stay close to the same scripting surface that sends prompts.
- The module owns agent-facing state, memory, orchestration, and backend coordination.
- Network transport stays a dependency, but user-visible AI behavior and control policy live here.
- In practice, this is the module a developer reaches for when they want NPC dialogue helpers, runtime content generation, semantic recall, agent squads, or tooling assistants powered by LLMs.
- It is not just a chat wrapper.
- It is the engine's user-facing runtime for building persistent, configurable, multi-agent AI behavior on top of external or local language models.

This module primarily collaborates with `network`. Its responsibility should stay inside the `Feature Systems` group rather than absorb behavior owned by those neighbors.

## Files

### chat.rs

- Implements the direct synchronous conversation surface for immediate model-backed agent interactions.
- Builds deterministic request envelopes for plain text, structured JSON, and embedding-oriented calls.
- Preserves reusable global provider configuration so repeated invocations share one operational baseline.
- Maintains multi-turn message history for session continuity and contextual follow-up reasoning.
- Applies lightweight prompt templating to inject runtime variables without changing call contracts.
- Normalizes backend responses into stable Lua-facing shapes with predictable field semantics.

### client.rs

- Provides asynchronous prompt transport that moves network latency off the main update path.
- Tracks in-flight requests and pending completions so polling remains deterministic and frame-safe.
- Supports callback-scoped cancellation to discard stale results after gameplay state has changed.
- Retries transient transport failures with bounded backoff to improve completion reliability.
- Bridges worker-thread execution and runtime polling with consistent response delivery semantics.

### memory.rs

- Implements layered agent memory with short-term context, episodic recall, and durable semantic knowledge.
- Applies distinct retention strategies so each memory tier fits a different reasoning horizon.
- Supports bounded working slots for prompt context while preserving ordered recency behavior.
- Records timestamped episodes for searchable event history and narrative continuity.
- Stores semantic facts as named durable entries that survive immediate conversational churn.
- Provides aggregate save and load flows for cross-session continuity of memory state.

### mod.rs

- Defines the `agent` domain module boundary for LLM-backed behavior.
- Contains transport, state, memory, orchestration logic, and Ollama lifecycle components.
- Keeps Lua binding/runtime details out of this layer so `src/lua_api/` stays the integration boundary.

### ollama.rs

- Provides backend infrastructure control for local Ollama service lifecycle and operational health checks.
- Handles start, stop, restart, and version discovery to keep runtime integration state observable.
- Exposes model inventory queries and availability checks for capability-aware script decisions.
- Supports model deletion and asynchronous pull workflows with pollable completion tracking.
- Isolates backend process management from prompt orchestration to keep runtime layering clean.
- Normalizes infrastructure outcomes into stable results consumed by higher agent control surfaces.

### orchestration.rs

- Agent orchestration logic extracted from Lua runtime glue.
- Owns batch-task data contracts, callback ID packing, and system-context assembly.
- This module is runtime-agnostic and intentionally free of `mlua` types.

### state.rs

- Defines runtime state contracts that shape outbound agent requests from script-facing configuration.
- Aggregates endpoint, model, prompt policy, timeout, and retry controls into deterministic payload inputs.
- Builds direct and system-routed request variants with consistent field and option mapping.
- Composes AI-system context from instructions and skill fragments matched to prompt intent signals.
- Keeps mutable control state separate from transport execution to preserve predictable behavior boundaries.
- Bridges Lua runtime controls to transport-ready request structures without duplicating orchestration logic.

### types.rs

- Defines shared data contracts for agent requests, responses, and cross-layer failure representation.
- Aligns state construction, async transport, and callback dispatch on one stable payload vocabulary.
- Encodes retry semantics and error categories so runtime behavior is consistent across entry points.
- Serves as the canonical contract layer that keeps agent submodules interoperable and predictable.

## Types

- `GlobalLlmConfig` (`struct`, `chat.rs`): Process-wide LLM configuration used by module-level functions (`configure`, `complete`, etc.). Details: fields: provider: String, base_url: String, model: String, timeout_ms: u64, api_key: Option<String>
- `LlmTemplate` (`struct`, `chat.rs`): Simple `{key}` placeholder template. Details: methods: new (Creates a new template from `pattern`.); render (Renders the template by substituting each `{key}` with `values[key]`.)
- `ChatMessage` (`struct`, `chat.rs`): A single message in a chat session history. Details: fields: role: String, content: String
- `LlmChat` (`struct`, `chat.rs`): Stateful chat session backed by the Ollama `/api/chat` endpoint. Details: methods: add_message (Appends a message with the given role and content to the history.); clear (Clears all accumulated chat history entries.); complete (Sends the current history plus `user_message` to the LLM and returns the assistant reply.); history (Returns a snapshot of the current history.); new (Creates a new empty chat session with no system prompt.); set_system_prompt (Sets the system prompt used on all completions.); system_prompt (Returns the current system prompt.)
- `AgentClient` (`struct`, `client.rs`): Background HTTP client used by [`LuaAgentRuntime`] and [`LuaAISystemRuntime`] to dispatch prompts. Details: methods: cancel (Mark `callback_id` as cancelled; its response is discarded when the background thread completes.); in_flight_count (Returns the number of in-flight requests that have not yet completed.); new (Creates a new `AgentClient`.); poll (Drains all completed responses since the last poll.); send_prompt (Dispatch `req` on a background thread; retry on transient errors up to `req.max_retries` times.)
- `WorkingMemory` (`struct`, `memory.rs`): Bounded FIFO key-value working memory. Details: methods: capacity (Returns the configured capacity (0 = unlimited).); forget (Removes the entry with `key`.); get (Returns the value for `key`, or `None` if not present.); get_recent (Returns the `n` most recently inserted entries as `(key, value)` pairs, newest last.); is_empty (Returns `true` if there are no entries.); len (Returns the current number of entries.); new (Creates a new `WorkingMemory` with the given `capacity`.); push (Inserts or updates an entry; evicts the oldest entry if capacity is exceeded.)
- `Episode` (`struct`, `memory.rs`): A single recorded episodic-memory event snapshot. Details: fields: tick: i64, data: HashMap<String
- `EpisodicMemory` (`struct`, `memory.rs`): Append-only episodic memory with tick-based pruning and field-equality queries. Details: methods: forget_before (Removes all episodes with `tick < cutoff`.); is_empty (Returns `true` if there are no episodes.); len (Returns the number of stored episodes.); new (Creates an empty `EpisodicMemory`.); query (Returns all episodes whose data contains every key-value pair in `filter`.); record (Records a new episode at `tick` with the given data map.)
- `SemanticMemory` (`struct`, `memory.rs`): Unbounded key → JSON fact store. Details: methods: forget (Removes the fact at `key`.); is_empty (Returns `true` if there are no facts.); learn (Inserts or replaces the fact at `key`.); len (Returns the number of stored facts.); new (Creates an empty `SemanticMemory`.); query (Returns all facts whose value contains every key-value pair in `filter`.); recall (Returns the fact for `key`, or `None`.)
- `AgentMemory` (`struct`, `memory.rs`): Bundled working, episodic, and semantic memory with optional disk persistence. Details: fields: working: WorkingMemory, episodic: EpisodicMemory, semantic: SemanticMemory, persist_path: Option<String> | methods: load (Deserialises memory state from `persist_path`, replacing the current contents.); new (Creates an `AgentMemory` with the given working-memory capacity.); save (Serialises all three memory banks to the configured `persist_path`.)
- `ModelInfo` (`struct`, `ollama.rs`): Info about a locally available Ollama model returned by [`OllamaManager::list_models`]. Details: fields: name: String, size_gb: f64
- `OllamaPullResult` (`struct`, `ollama.rs`): Result of a completed async model pull dispatched by [`OllamaManager::pull_model`]. Details: fields: callback_id: usize, result: Result<()
- `OllamaManager` (`struct`, `ollama.rs`): Manages connectivity, process lifecycle, and model operations for a local Ollama instance. Details: methods: base_url (Returns the base URL this manager was created with.); delete_model (Sends `DELETE /api/delete` to remove `name` from local Ollama storage; returns `true` on success.); has_model (Returns `true` if a model with `name` (or the base name before `:`) is available locally.); in_flight_count (Returns the number of active background pull operations.); is_running (Returns `true` if the Ollama HTTP server responds on the base URL within 5 seconds.); list_models (Returns all locally available models from `/api/tags`; empty vec if Ollama is not running.); model_names (Returns the names of all locally available models; empty vec if Ollama is not running.); new (Creates an `OllamaManager` targeting `base_url` (e.g.); poll (Drains completed pull results since the last call; used by `LuaOllamaManager::update`.); pull_model (Dispatches a background model pull for `name`; returns the callback ID for use with [`OllamaManager::poll`].); restart (Stops then starts a fresh Ollama process; returns `true` if the restart succeeded.); start (Spawns `ollama serve` as a managed child process; returns `true` on success.); stop (Kills the Ollama child process started by this manager; returns `true` if it was running.); version (Returns the Ollama version string from `/api/version`, or an empty string if not reachable.)
- `AgentBatchTask` (`struct`, `orchestration.rs`): One queued batch task derived from an agent configuration. Details: fields: agent_idx: usize, instruction: String, state: AgentState, system_override: Option<String>
- `AgentState` (`struct`, `state.rs`): Per-agent runtime configuration owned by [`LuaAgentRuntime`] and [`LuaAISystemRuntime`]. Details: fields: name: String, description: String, url: String, model: String, system_prompt: String, format: String, options: HashMap<String, skills: Vec<(String, max_retries: u32, timeout_secs: u64 | methods: add_skill (Appends a named skill to the agent's context.); build_system_block (Build the system block: base system prompt followed by a `Skills` section when skills are registered.); clear_skills (Removes all registered skills.); has_skill (Returns `true` if a skill with `name` is registered.); list_skills (Returns the names of all registered skills in insertion order.); new (Creates a new `AgentState` with no skills and default retry/timeout settings.); set_description (Sets the agent's role description used when routed through an AISystem.); set_format (Sets the response format (`"json"`, `"csv"`, or `"text"`).); set_max_retries (Sets the maximum retry count for transient errors.); set_model (Sets the model identifier used for all future prompts.); set_name (Sets the agent's name identifier.); set_option (Inserts or updates a single model option.); set_timeout (Sets the per-request timeout in seconds (0 = use default 60 s).); set_url (Sets the LLM endpoint URL used for outbound requests.); skill_count (Returns the number of registered skills.); to_request (Builds one outbound request using the current agent configuration.); to_request_with_system (Build a request with an external system block, bypassing this agent's own system prompt; used by AISystem routing.)
- `SystemSkill` (`struct`, `state.rs`): Keyword-gated skill auto-injected into the system block when its keywords overlap with the prompt. Details: fields: name: String, keywords: Vec<String>, prompt: String
- `AISystemState` (`struct`, `state.rs`): Shared orchestration state for [`LuaAISystemRuntime`]: system prompt, instruction blocks, and keyword-gated skills. Details: fields: system_prompt: String, instructions: Vec<(String, system_skills: Vec<SystemSkill> | methods: add_instruction (Adds or replaces a named instruction block.); add_system_skill (Adds a keyword-gated skill.); build_context (Builds the combined context block for a given prompt.); has_instruction (Returns `true` if an instruction with `key` exists.); has_system_skill (Returns `true` if a system skill with `name` is registered.); instruction_count (Returns the number of registered instructions.); list_instructions (Returns the keys of all registered instructions in insertion order.); new (Creates a new `AISystemState` with the given system prompt.); remove_instruction (Removes an instruction by key.); remove_system_skill (Removes a system skill by name.); system_skill_count (Returns the number of registered system skills.)
- `AgentError` (`enum`, `types.rs`): Error variants for LLM agent requests; used by [`AgentClient`] and [`AgentState`]. Details: variants: Network, Timeout, Format, Model | methods: code (Returns the stable Lua-facing error code for this variant.); is_transient (Returns `true` if this error is likely transient and safe to retry.); message (Returns the inner error message string.)
- `AgentRequest` (`struct`, `types.rs`): Single outbound LLM prompt request built by [`AgentState`] and dispatched by [`AgentClient`]. Details: fields: url: String, model: String, prompt: String, system: String, format: String, options: serde_json::Value, callback_id: usize, max_retries: u32, timeout_secs: u64
- `AgentResponse` (`struct`, `types.rs`): Completed LLM response returned by [`AgentClient::poll`]; matched to a request by `callback_id`. Details: fields: callback_id: usize, body: Result<String | methods: is_ok (Returns `true` if the response body is `Ok`.); text (Returns the response text if successful; `None` on error.)

## Functions

- `read_global_config` (`chat.rs`): Reads a snapshot of the current global LLM config.
- `write_global_config` (`chat.rs`): Replaces the global LLM config.
- `ollama_generate` (`chat.rs`): Calls the Ollama `/api/generate` endpoint synchronously and returns the response text.
- `ollama_generate_json` (`chat.rs`): Calls the Ollama `/api/generate` endpoint and requests a JSON format response.
- `ollama_embed` (`chat.rs`): Calls the Ollama `/api/embeddings` endpoint and returns the embedding vector.
- `ollama_list_models` (`chat.rs`): Calls the Ollama `/api/tags` endpoint and returns available model names.
- `ollama_is_available` (`chat.rs`): Probes the Ollama base URL and returns `true` if it responds.
- `LlmTemplate::new` (`chat.rs`): Creates a new template from `pattern`.
- `LlmTemplate::render` (`chat.rs`): Renders the template by substituting each `{key}` with `values[key]`.
- `LlmChat::new` (`chat.rs`): Creates a new empty chat session with no system prompt.
- `LlmChat::set_system_prompt` (`chat.rs`): Sets the system prompt used on all completions.
- `LlmChat::system_prompt` (`chat.rs`): Returns the current system prompt.
- `LlmChat::add_message` (`chat.rs`): Appends a message with the given role and content to the history.
- `LlmChat::clear` (`chat.rs`): Clears all accumulated chat history entries.
- `LlmChat::history` (`chat.rs`): Returns a snapshot of the current history.
- `LlmChat::complete` (`chat.rs`): Sends the current history plus `user_message` to the LLM and returns the assistant reply.
- `AgentClient::new` (`client.rs`): Creates a new `AgentClient`.
- `AgentClient::send_prompt` (`client.rs`): Dispatch `req` on a background thread; retry on transient errors up to `req.max_retries` times.
- `AgentClient::cancel` (`client.rs`): Mark `callback_id` as cancelled; its response is discarded when the background thread completes.
- `AgentClient::in_flight_count` (`client.rs`): Returns the number of in-flight requests that have not yet completed.
- `AgentClient::poll` (`client.rs`): Drains all completed responses since the last poll.
- `WorkingMemory::new` (`memory.rs`): Creates a new `WorkingMemory` with the given `capacity`.
- `WorkingMemory::capacity` (`memory.rs`): Returns the configured capacity (0 = unlimited).
- `WorkingMemory::len` (`memory.rs`): Returns the current number of entries.
- `WorkingMemory::is_empty` (`memory.rs`): Returns `true` if there are no entries.
- `WorkingMemory::push` (`memory.rs`): Inserts or updates an entry; evicts the oldest entry if capacity is exceeded.
- `WorkingMemory::get` (`memory.rs`): Returns the value for `key`, or `None` if not present.
- `WorkingMemory::forget` (`memory.rs`): Removes the entry with `key`.
- `WorkingMemory::get_recent` (`memory.rs`): Returns the `n` most recently inserted entries as `(key, value)` pairs, newest last.
- `EpisodicMemory::new` (`memory.rs`): Creates an empty `EpisodicMemory`.
- `EpisodicMemory::len` (`memory.rs`): Returns the number of stored episodes.
- `EpisodicMemory::is_empty` (`memory.rs`): Returns `true` if there are no episodes.
- `EpisodicMemory::record` (`memory.rs`): Records a new episode at `tick` with the given data map.
- `EpisodicMemory::query` (`memory.rs`): Returns all episodes whose data contains every key-value pair in `filter`.
- `EpisodicMemory::forget_before` (`memory.rs`): Removes all episodes with `tick < cutoff`.
- `SemanticMemory::new` (`memory.rs`): Creates an empty `SemanticMemory`.
- `SemanticMemory::len` (`memory.rs`): Returns the number of stored facts.
- `SemanticMemory::is_empty` (`memory.rs`): Returns `true` if there are no facts.
- `SemanticMemory::learn` (`memory.rs`): Inserts or replaces the fact at `key`.
- `SemanticMemory::recall` (`memory.rs`): Returns the fact for `key`, or `None`.
- `SemanticMemory::forget` (`memory.rs`): Removes the fact at `key`.
- `SemanticMemory::query` (`memory.rs`): Returns all facts whose value contains every key-value pair in `filter`.
- `AgentMemory::new` (`memory.rs`): Creates an `AgentMemory` with the given working-memory capacity.
- `AgentMemory::save` (`memory.rs`): Serialises all three memory banks to the configured `persist_path`.
- `AgentMemory::load` (`memory.rs`): Deserialises memory state from `persist_path`, replacing the current contents.
- `OllamaManager::new` (`ollama.rs`): Creates an `OllamaManager` targeting `base_url` (e.g.
- `OllamaManager::base_url` (`ollama.rs`): Returns the base URL this manager was created with.
- `OllamaManager::model_names` (`ollama.rs`): Returns the names of all locally available models; empty vec if Ollama is not running.
- `OllamaManager::is_running` (`ollama.rs`): Returns `true` if the Ollama HTTP server responds on the base URL within 5 seconds.
- `OllamaManager::version` (`ollama.rs`): Returns the Ollama version string from `/api/version`, or an empty string if not reachable.
- `OllamaManager::list_models` (`ollama.rs`): Returns all locally available models from `/api/tags`; empty vec if Ollama is not running.
- `OllamaManager::has_model` (`ollama.rs`): Returns `true` if a model with `name` (or the base name before `:`) is available locally.
- `OllamaManager::start` (`ollama.rs`): Spawns `ollama serve` as a managed child process; returns `true` on success.
- `OllamaManager::stop` (`ollama.rs`): Kills the Ollama child process started by this manager; returns `true` if it was running.
- `OllamaManager::restart` (`ollama.rs`): Stops then starts a fresh Ollama process; returns `true` if the restart succeeded.
- `OllamaManager::pull_model` (`ollama.rs`): Dispatches a background model pull for `name`; returns the callback ID for use with [`OllamaManager::poll`].
- `OllamaManager::delete_model` (`ollama.rs`): Sends `DELETE /api/delete` to remove `name` from local Ollama storage; returns `true` on success.
- `OllamaManager::in_flight_count` (`ollama.rs`): Returns the number of active background pull operations.
- `OllamaManager::poll` (`ollama.rs`): Drains completed pull results since the last call; used by `LuaOllamaManager::update`.
- `pack_batch_callback_id` (`orchestration.rs`): Encodes `(batch_id, task_idx)` into a single callback ID.
- `unpack_batch_callback_id` (`orchestration.rs`): Decodes a packed callback ID back into `(batch_id, task_idx)`.
- `build_system_context` (`orchestration.rs`): Builds the system context block for the given prompt and optional target agent.
- `make_system_task` (`orchestration.rs`): Builds a batch task for a named agent, injecting system context.
- `AgentState::new` (`state.rs`): Creates a new `AgentState` with no skills and default retry/timeout settings.
- `AgentState::set_name` (`state.rs`): Sets the agent's name identifier.
- `AgentState::set_description` (`state.rs`): Sets the agent's role description used when routed through an AISystem.
- `AgentState::set_max_retries` (`state.rs`): Sets the maximum retry count for transient errors.
- `AgentState::set_timeout` (`state.rs`): Sets the per-request timeout in seconds (0 = use default 60 s).
- `AgentState::set_option` (`state.rs`): Inserts or updates a single model option.
- `AgentState::add_skill` (`state.rs`): Appends a named skill to the agent's context.
- `AgentState::clear_skills` (`state.rs`): Removes all registered skills.
- `AgentState::has_skill` (`state.rs`): Returns `true` if a skill with `name` is registered.
- `AgentState::skill_count` (`state.rs`): Returns the number of registered skills.
- `AgentState::list_skills` (`state.rs`): Returns the names of all registered skills in insertion order.
- `AgentState::set_format` (`state.rs`): Sets the response format (`"json"`, `"csv"`, or `"text"`).
- `AgentState::set_model` (`state.rs`): Sets the model identifier used for all future prompts.
- `AgentState::set_url` (`state.rs`): Sets the LLM endpoint URL used for outbound requests.
- `AgentState::build_system_block` (`state.rs`): Build the system block: base system prompt followed by a `Skills` section when skills are registered.
- `AgentState::to_request` (`state.rs`): Builds one outbound request using the current agent configuration.
- `AgentState::to_request_with_system` (`state.rs`): Build a request with an external system block, bypassing this agent's own system prompt; used by AISystem routing.
- `AISystemState::new` (`state.rs`): Creates a new `AISystemState` with the given system prompt.
- `AISystemState::add_instruction` (`state.rs`): Adds or replaces a named instruction block.
- `AISystemState::remove_instruction` (`state.rs`): Removes an instruction by key.
- `AISystemState::add_system_skill` (`state.rs`): Adds a keyword-gated skill.
- `AISystemState::remove_system_skill` (`state.rs`): Removes a system skill by name.
- `AISystemState::has_instruction` (`state.rs`): Returns `true` if an instruction with `key` exists.
- `AISystemState::instruction_count` (`state.rs`): Returns the number of registered instructions.
- `AISystemState::list_instructions` (`state.rs`): Returns the keys of all registered instructions in insertion order.
- `AISystemState::has_system_skill` (`state.rs`): Returns `true` if a system skill with `name` is registered.
- `AISystemState::system_skill_count` (`state.rs`): Returns the number of registered system skills.
- `AISystemState::build_context` (`state.rs`): Builds the combined context block for a given prompt.
- `AgentError::code` (`types.rs`): Returns the stable Lua-facing error code for this variant.
- `AgentError::is_transient` (`types.rs`): Returns `true` if this error is likely transient and safe to retry.
- `AgentError::message` (`types.rs`): Returns the inner error message string.
- `AgentResponse::is_ok` (`types.rs`): Returns `true` if the response body is `Ok`.
- `AgentResponse::text` (`types.rs`): Returns the response text if successful; `None` on error.

## Lua API Reference

### Functions

- `lurek.agent.cancel(callback_id) -> nil`: Cancels a module-level asynchronous completion by callback ID.
- `lurek.agent.complete(prompt) -> string`: Sends a single prompt to the global LLM and returns the response text.
- `lurek.agent.completeAsync(prompt, callback) -> integer`: Sends a prompt asynchronously using a background thread; calls `callback(text, err)` on completion.
- `lurek.agent.completeJson(prompt) -> table`: Sends a prompt requesting a JSON-format response and returns a parsed Lua table.
- `lurek.agent.configure(config) -> nil`: Configures the global LLM provider settings used by module-level functions.
- `lurek.agent.embed(text) -> table`: Returns an embedding vector for `text` from the global LLM.
- `lurek.agent.isAvailable() -> boolean`: Returns `true` if the configured LLM server responds within 5 seconds.
- `lurek.agent.listModels() -> table`: Returns a list of available model names from the configured LLM server.
- `lurek.agent.new(config) -> LAgent`: Creates a new configurable LLM Agent runtime instance.
- `lurek.agent.newAgentMemory(config?) -> LAgentMemory`: Creates a bundled working+episodic+semantic memory with optional disk persistence.
- `lurek.agent.newChat() -> LAgentChat`: Creates a new stateful chat session using the global LLM config.
- `lurek.agent.newEpisodicMemory() -> LEpisodicMemory`: Creates a new episodic memory for recording time-stamped events.
- `lurek.agent.newManager() -> LAgentManager`: Creates a new Agent Manager for batching multiple LLM agents over a shared client.
- `lurek.agent.newOllama(config?) -> LOllamaManager`: Creates an Ollama infrastructure manager for server lifecycle and model management.
- `lurek.agent.newSemanticMemory() -> LSemanticMemory`: Creates a new semantic memory for storing named facts.
- `lurek.agent.newSystem(config) -> LAISystem`: Creates a new AISystem orchestrator that holds agents, instructions, and keyword-gated skills.
- `lurek.agent.newTemplate(pattern) -> LAgentTemplate`: Creates a new `{key}` placeholder prompt template.
- `lurek.agent.newWorkingMemory(capacity) -> LWorkingMemory`: Creates a new bounded FIFO working memory with the given capacity.
- `lurek.agent.pendingCount() -> integer`: Returns the number of module-level asynchronous completions still in flight.
- `lurek.agent.update() -> nil`: Polls module-level asynchronous completions and dispatches callbacks.

### Callbacks

- `LAISystem:prompt` param `callback` (`function`): Function called with `(success, data, err_info)` when complete.
- `LAISystem:runAll` param `callback` (`function`): Function called with a results table when all tasks complete.
- `LAgent:prompt` param `callback` (`function`): Function called with `(success, data, err_info)` when complete.
- `LAgent:promptBatch` param `callback` (`function`): Function called with a results table when all complete.
- `LAgentManager:runAll` param `callback` (`function`): Function called with a results table when all tasks complete.
- `LOllamaManager:pullModel` param `callback` (`function`): Called with `(success, err_msg)` on completion.
- `lurek.agent.completeAsync` param `callback` (`function`): Called with `(text, err)` on completion (`err` is `nil` on success).

### Enums

- No documented module-level enums/constants.

### Types

#### LAISystem Type

- Lua-side handle for an AISystem multi-agent orchestrator.

##### Fields

- No documented fields.

##### Methods

- `LAISystem:addAgent(name, agent) -> nil`: Registers a named agent in the system.
- `LAISystem:addInstruction(key, text) -> nil`: Adds a named instruction block the user can explicitly include per prompt.
- `LAISystem:addSkill(name, keywords, prompt) -> nil`: Adds a keyword-gated system skill that Lurek auto-injects when the prompt overlaps with its keywords.
- `LAISystem:agentCount() -> integer`: Returns the number of registered agents.
- `LAISystem:buildContext(instruction, opts?) -> string`: Builds and returns the full context string that would be sent for a given prompt.
- `LAISystem:hasAgent(name) -> boolean`: Returns `true` if an agent with `name` is registered.
- `LAISystem:hasInstruction(key) -> boolean`: Returns `true` if an instruction with `key` is registered.
- `LAISystem:hasSkill(name) -> boolean`: Returns `true` if a system skill with `name` is registered.
- `LAISystem:instructionCount() -> integer`: Returns the number of registered instruction blocks.
- `LAISystem:listAgents() -> table`: Returns a sorted list of all registered agent names.
- `LAISystem:listInstructions() -> table`: Returns a list of registered instruction keys in insertion order.
- `LAISystem:prompt(agent_name, instruction, callback, opts) -> integer`: Sends a prompt to a named agent through the system, auto-injecting matching context.
- `LAISystem:removeAgent(name) -> boolean`: Removes a registered agent by name.
- `LAISystem:removeInstruction(key) -> boolean`: Removes an instruction block by key.
- `LAISystem:removeSkill(name) -> boolean`: Removes a registered system skill by exact name.
- `LAISystem:runAll(tasks, callback) -> integer`: Dispatches multiple named-agent tasks in parallel through the system.
- `LAISystem:skillCount() -> integer`: Returns the number of registered system skills.
- `LAISystem:update() -> nil`: Polls the system's background client for completed requests and dispatches callbacks.

#### LAgent Type

- Lua-side handle for a single LLM Agent.

##### Fields

- No documented fields.

##### Methods

- `LAgent:addSkill(name, prompt) -> nil`: Appends a named skill prompt to the agent's context block.
- `LAgent:cancel(callback_id) -> nil`: Cancels an in-flight or pending request by callback ID.
- `LAgent:clearSkills() -> nil`: Removes all registered skills from the agent's context.
- `LAgent:evalCode(code) -> boolean`: Evaluates a Lua code string inside the active VM.
- `LAgent:getDescription() -> string`: Returns the agent's role description.
- `LAgent:getFormat() -> string`: Returns the current response format string.
- `LAgent:getModel() -> string`: Returns the current model identifier.
- `LAgent:getName() -> string`: Returns the agent's name identifier.
- `LAgent:getUrl() -> string`: Returns the current LLM endpoint URL.
- `LAgent:hasSkill(name) -> boolean`: Returns `true` if a skill with `name` is registered.
- `LAgent:listSkills() -> table`: Returns a list of registered skill names in insertion order.
- `LAgent:pendingCount() -> integer`: Returns the number of in-flight requests that have not yet completed.
- `LAgent:prompt(instruction, callback) -> integer`: Sends an instructional prompt to the LLM asynchronously.
- `LAgent:promptBatch(instructions, callback) -> integer`: Sends a batch of prompts to the LLM asynchronously.
- `LAgent:setContextSize(n) -> nil`: Sets the token context window size forwarded to the LLM backend.
- `LAgent:setDescription(description) -> nil`: Sets the agent's role description injected after the system prompt when routed through an AISystem.
- `LAgent:setFormat(format) -> nil`: Changes the response format for future prompts.
- `LAgent:setMaxRetries(n) -> nil`: Sets the maximum retry count on transient network or timeout errors.
- `LAgent:setModel(model) -> nil`: Changes the model identifier for future prompts.
- `LAgent:setName(name) -> nil`: Sets the agent's name identifier used when added to an AISystem.
- `LAgent:setOption(key, value) -> nil`: Sets a single model option forwarded to the LLM backend.
- `LAgent:setTemperature(t) -> nil`: Sets the sampling temperature forwarded to the LLM backend.
- `LAgent:setTimeout(secs) -> nil`: Sets the per-request timeout in seconds (0 uses the default 60 s).
- `LAgent:setUrl(url) -> nil`: Changes the LLM endpoint URL for future prompts.
- `LAgent:skillCount() -> integer`: Returns the number of registered skills.
- `LAgent:update() -> nil`: Polls the background client for completed LLM requests and dispatches callbacks.

#### LAgentChat Type

- Lua-side handle for a stateful LLM chat session.

##### Fields

- No documented fields.

##### Methods

- `LAgentChat:addMessage(role, content) -> nil`: Appends a message to the chat history without sending a completion.
- `LAgentChat:clear() -> nil`: Clears all stored chat history messages.
- `LAgentChat:complete() -> string`: Sends the current history to the LLM and returns the assistant reply.
- `LAgentChat:getHistory() -> table`: Returns the chat history as an array of `{role, content}` tables.
- `LAgentChat:setSystemPrompt(prompt) -> nil`: Sets the system prompt used for all completions in this session.

#### LAgentManager Type

- Lua-side handle for managing multiple LLM Agents in parallel.

##### Fields

- No documented fields.

##### Methods

- `LAgentManager:runAll(tasks, callback) -> integer`: Runs multiple agent tasks in parallel and calls a single callback when all finish.
- `LAgentManager:update() -> nil`: Polls the manager's background client for completed tasks and dispatches callbacks.

#### LAgentMemory Type

- Lua-side handle for a bundled working+episodic+semantic memory with optional persistence.

##### Fields

- No documented fields.

##### Methods

- `LAgentMemory:episodic() -> LEpisodicMemory`: Returns the episodic memory component.
- `LAgentMemory:load() -> boolean`: Deserialises memory state from the configured persist_path.
- `LAgentMemory:save() -> boolean`: Serialises all memory banks to the configured persist_path.
- `LAgentMemory:semantic() -> LSemanticMemory`: Returns the semantic memory component.
- `LAgentMemory:working() -> LWorkingMemory`: Returns the working memory component.

#### LAgentTemplate Type

- Lua-side handle for a `{key}` placeholder prompt template.

##### Fields

- No documented fields.

##### Methods

- `LAgentTemplate:render(values) -> string`: Renders the template by substituting `{key}` placeholders from `values`.

#### LEpisodicMemory Type

- Lua-side handle for append-only episodic memory.

##### Fields

- No documented fields.

##### Methods

- `LEpisodicMemory:forgetBefore(cutoff) -> nil`: Removes all episodes with tick < `cutoff`.
- `LEpisodicMemory:len() -> integer`: Returns the number of stored episodes.
- `LEpisodicMemory:query(filter) -> table`: Returns all episodes whose data matches every key-value pair in `filter`.
- `LEpisodicMemory:record(tick, data) -> nil`: Records a new episode at `tick` with `data`.

#### LOllamaManager Type

- Lua-side handle for managing a local Ollama server lifecycle and models.

##### Fields

- No documented fields.

##### Methods

- `LOllamaManager:baseUrl() -> string`: Returns the base URL this manager was created with.
- `LOllamaManager:deleteModel(name) -> boolean`: Sends `DELETE /api/delete` to remove a model from local Ollama storage.
- `LOllamaManager:hasModel(name) -> boolean`: Returns `true` if a model with the given name (or name prefix) is available locally.
- `LOllamaManager:isRunning() -> boolean`: Returns `true` if the Ollama HTTP server responds within 5 seconds.
- `LOllamaManager:listModels() -> table`: Returns a table of locally available models, each with `name` and `size_gb` fields.
- `LOllamaManager:modelNames() -> table`: Returns a string array of locally available model names; empty if Ollama is not running.
- `LOllamaManager:pendingCount() -> integer`: Returns the number of in-flight model pull operations.
- `LOllamaManager:pullModel(name, callback) -> integer`: Dispatches an async model download; calls `callback(success, err_msg)` on completion.
- `LOllamaManager:restart() -> boolean`: Stops then restarts the managed Ollama process. Returns `true` on success.
- `LOllamaManager:start() -> boolean`: Spawns `ollama serve` as a managed child process. Returns `true` on success.
- `LOllamaManager:stop() -> boolean`: Kills the Ollama process started by this manager. Returns `true` if it was running.
- `LOllamaManager:update() -> nil`: Polls completed pull operations and dispatches registered callbacks.
- `LOllamaManager:version() -> string`: Returns the Ollama version string, or an empty string if not running.

#### LSemanticMemory Type

- Lua-side handle for an unbounded key Ă˘â€ â€™ value fact store.

##### Fields

- No documented fields.

##### Methods

- `LSemanticMemory:forget(key) -> boolean`: Removes the fact at `key`.  Returns `true` if it existed.
- `LSemanticMemory:learn(key, value) -> nil`: Inserts or replaces a fact at `key`.
- `LSemanticMemory:len() -> integer`: Returns the number of stored facts.
- `LSemanticMemory:query(filter) -> table`: Returns all facts whose value matches every key-value pair in `filter`.
- `LSemanticMemory:recall(key) -> table`: Returns the fact for `key`, or `nil` if not found.

#### LWorkingMemory Type

- Lua-side handle for a bounded FIFO working memory.

##### Fields

- No documented fields.

##### Methods

- `LWorkingMemory:capacity() -> integer`: Returns the configured capacity (0 = unlimited).
- `LWorkingMemory:forget(key) -> boolean`: Removes the entry with `key`.  Returns `true` if it existed.
- `LWorkingMemory:get(key) -> table`: Returns the value for `key`, or `nil` if not found.
- `LWorkingMemory:getRecent(n) -> table`: Returns the `n` most recently inserted entries as an array of `{key, value}` tables.
- `LWorkingMemory:len() -> integer`: Returns the current number of entries.
- `LWorkingMemory:push(key, value) -> nil`: Inserts or updates a key-value entry; evicts the oldest entry if capacity is exceeded.

## References

- `network`: `src/agent/client.rs` delegates HTTP transport to `crate::network::http::execute_request`.

## Notes

- No additional module-specific notes.
