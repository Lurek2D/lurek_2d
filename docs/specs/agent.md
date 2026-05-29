# agent

## TL;DR

- The `agent` module provides async LLM prompt dispatch, per-agent prompt state, AISystem multi-agent orchestration, keyword-gated skill injection, output format control, automatic retry, thin Lua-facing handles for polling results back into the Lua VM, a direct synchronous LLM API (`configure`, `complete`, `completeJson`, `embed`, etc.), and memory primitives for LLM agents (working, episodic, semantic, and bundled agent memory).

## General Info

- Module group: `Feature Systems`
- Source path: `src/agent/`
- Lua API path(s): `src/lua_api/agent_api.rs`
- Primary Lua namespace: `lurek.agent`
- Rust test path(s): tests/rust/unit/agent_tests.rs
- Lua test path(s): tests/lua/unit/test_agent_core_unit.lua

## Summary

The `agent` module owns the engine-side runtime for LLM-backed assistants. It keeps request state in `AgentState`, dispatches HTTP prompts in the background through `AgentClient`, and converts completed responses into callback payloads that Lua code can poll from the main loop. The module is intentionally split so the heavy request, batching, and response-processing logic lives in `src/agent/`, while `src/lua_api/agent_api.rs` stays a thin registration layer.

The module boundary is narrow. `src/agent/` owns request construction, async callback routing, response parsing for `json` / `csv` / `text`, automatic transient-error retry with back-off, and the secure `evalCode` runtime entry point. The `AISystemState` type provides multi-agent orchestration: a shared system prompt, manually included instruction blocks, and keyword-gated skill blocks that Lurek auto-injects based on prompt keyword overlap. `src/lua_api/agent_api.rs` exposes `lurek.agent.new`, `lurek.agent.newManager`, `lurek.agent.newSystem`, and userdata methods that delegate into the module runtime. Network transport stays delegated to `crate::network::http::execute_request`, and the API remains polling-based so prompt execution never blocks the frame loop.

`src/agent/chat.rs` provides a synchronous direct LLM path (`configure`, `complete`, `completeJson`, `embed`, `isAvailable`, `listModels`) backed by `GlobalLlmConfig`. `LlmChat` maintains a stateful message history for multi-turn conversations. `LlmTemplate` renders `{key}` placeholders. `src/agent/memory.rs` provides `WorkingMemory` (bounded FIFO), `EpisodicMemory` (tick-stamped event log), `SemanticMemory` (fact store), and `AgentMemory` (bundled, optionally persistent).

## Files

- `chat.rs`: Stateless and stateful LLM chat helpers: global provider config, single-shot completion, chat sessions, and prompt templates.
- `client.rs`: Background transport that dispatches LLM prompt requests on dedicated threads and collects responses for polling.
- `lua_runtime.rs`: Implements the Lua-facing runtime for `LAgent`, `LAgentManager`, and `LAISystem` userdata — all business logic for the agent API lives here.
- `memory.rs`: Per-session and persistent memory primitives for LLM agents.
- `mod.rs`: LLM agent runtime: state, request types, error variants, background HTTP client, and Ollama lifecycle management.
- `ollama.rs`: Manages connectivity, process lifecycle, and model inventory for a local Ollama HTTP server.
- `state.rs`: Holds per-agent configuration and assembles outbound `AgentRequest` values from endpoint, model, system prompt, skills, format, options, and retry settings.
- `types.rs`: Defines the public request, response, and error types exchanged between `AgentState`, `AgentClient`, and their Lua bindings.

## Source Documentation

### `chat.rs`
- Stateless and stateful LLM chat helpers: global provider config, single-shot completion, chat sessions, and prompt templates.
- `GlobalLlmConfig` is a process-wide default stored in a `Mutex`; set once via `configure()` and read by every direct completion call.
- `LlmChat` maintains a stateful message history and calls the Ollama `/api/chat` endpoint.
- `LlmTemplate` renders `{key}` placeholders from a Lua table.
- Sync HTTP calls reuse `crate::network::http::execute_request`.

### `client.rs`
- Background transport that dispatches LLM prompt requests on dedicated threads and collects responses for polling.
- Tracks in-flight requests with an atomic counter and silently drops responses for callbacks marked as cancelled.
- Retries transient network and timeout failures up to `AgentRequest::max_retries` times using exponential back-off.
- Exposes `send_prompt`, `cancel`, `in_flight_count`, and `poll` as the complete public surface.

### `lua_runtime.rs`
- Implements the Lua-facing runtime for `LAgent`, `LAgentManager`, and `LAISystem` userdata — all business logic for the agent API lives here.
- `LuaAgentRuntime` owns an `AgentState`, `AgentClient`, callback registry, and `BatchDispatcher` to serve one `LAgent` userdata.
- `LuaAgentManagerRuntime` dispatches explicit task batches across multiple agents and collects their responses under a single batch callback.
- `LuaAISystemRuntime` routes prompts through `AISystemState` context injection before dispatch, supporting `addAgent`, `addInstruction`, `addSkill`, and `buildContext`.
- `BatchDispatcher` packs multi-agent batch IDs into a single `usize` callback, collects partial results, and fires the Lua callback once all responses arrive.
- `lua_to_json` converts arbitrary Lua values — primitives, arrays, and mixed tables — to `serde_json::Value` for model option serialization.

### `memory.rs`
- Per-session and persistent memory primitives for LLM agents.
- `WorkingMemory` is a bounded FIFO key-value store with configurable capacity (FIFO eviction when full).
- `EpisodicMemory` records time-stamped events and supports simple key-match queries and age-based pruning.
- `SemanticMemory` is an unbounded key-value fact store.
- `AgentMemory` bundles all three types and optionally serialises to disk via `save()` / `load()`.

### `mod.rs`
- LLM agent runtime: state, request types, error variants, background HTTP client, and Ollama lifecycle management.

### `ollama.rs`
- Manages connectivity, process lifecycle, and model inventory for a local Ollama HTTP server.
- `is_running` and `version` probe the REST API; `start` and `stop` spawn or kill the `ollama serve` child process.
- `list_models` and `has_model` query `/api/tags`; `pull_model` dispatches an async background download that delivers results via `poll`.
- `delete_model` removes a local model; `restart` combines stop and start with a settle pause.
- All HTTP calls reuse `crate::network::http::execute_request`; async pulls use `Arc<Mutex>` + `Arc<AtomicUsize>` for thread-safe result collection.

### `state.rs`
- Holds per-agent configuration and assembles outbound `AgentRequest` values from endpoint, model, system prompt, skills, format, options, and retry settings.
- `AgentState` builds the system block by appending named skills in insertion order behind the base system prompt.
- `AISystemState` stores the shared system prompt, named instruction blocks selectively included per prompt, and keyword-gated skills auto-injected when their keywords match the instruction.
- `SystemSkill` carries a keyword list and a prompt fragment; skills fire automatically when any keyword appears in the dispatched instruction.
- `to_request` and `to_request_with_system` build the final `AgentRequest` for single and system-routed prompts respectively.

### `types.rs`
- Defines the public request, response, and error types exchanged between `AgentState`, `AgentClient`, and their Lua bindings.
- `AgentError` classifies failures as network, timeout, format, or model errors and carries a stable Lua-facing error code and a transient-retry flag.
- `AgentRequest` and `AgentResponse` carry the callback ID that threads agent dispatch back to the originating Lua callback.

## Types

- `GlobalLlmConfig` (`struct`, `chat.rs`): Process-wide LLM provider config; stored in a `Mutex`; set via `configure()`.
- `LlmTemplate` (`struct`, `chat.rs`): `{key}` placeholder prompt template; `render()` substitutes values from a map.
- `ChatMessage` (`struct`, `chat.rs`): A single message in a chat session history.
- `LlmChat` (`struct`, `chat.rs`): Stateful chat session; maintains history, calls `/api/chat` on `complete()`.
- `AgentClient` (`struct`, `client.rs`): Background prompt transport with cancel tracking, in-flight counter, and retry-aware dispatch.
- `AgentBatchTask` (`struct`, `lua_runtime.rs`): One queued batch task; carries an optional `system_override` for AISystem routing.
- `LuaAgentRuntime` (`struct`, `lua_runtime.rs`): Runtime state owned by a single Lua `LAgent` userdata.
- `LuaAgentManagerRuntime` (`struct`, `lua_runtime.rs`): Runtime state owned by a Lua `LAgentManager` userdata.
- `LuaAISystemRuntime` (`struct`, `lua_runtime.rs`): Multi-agent orchestrator runtime owned by a Lua `LAISystem` userdata.
- `WorkingMemory` (`struct`, `memory.rs`): Bounded FIFO key-value store.
- `Episode` (`struct`, `memory.rs`): A single recorded episodic-memory event snapshot.
- `EpisodicMemory` (`struct`, `memory.rs`): Append-only tick-stamped event log.
- `SemanticMemory` (`struct`, `memory.rs`): Unbounded key→JSON fact store.
- `AgentMemory` (`struct`, `memory.rs`): Bundled working+episodic+semantic memory with optional JSON persistence.
- `ModelInfo` (`struct`, `ollama.rs`): Info about a locally available Ollama model returned by [`OllamaManager::list_models`].
- `OllamaPullResult` (`struct`, `ollama.rs`): Result of a completed async model pull dispatched by [`OllamaManager::pull_model`].
- `OllamaManager` (`struct`, `ollama.rs`): Manages connectivity, process lifecycle, and model operations for a local Ollama instance.
- `AgentState` (`struct`, `state.rs`): Per-agent configuration: identity, skills, retry, timeout, options, and request-building helpers.
- `SystemSkill` (`struct`, `state.rs`): A keyword-gated skill block registered at the AISystem level.
- `AISystemState` (`struct`, `state.rs`): Shared orchestration state: system prompt, instruction blocks, and keyword-gated skill blocks.
- `AgentError` (`enum`, `types.rs`): Error classification for network, timeout, format, and model failures.
- `AgentRequest` (`struct`, `types.rs`): One outbound prompt request including retry and timeout settings.
- `AgentResponse` (`struct`, `types.rs`): One completed async response paired back to a callback ID.

## Functions

- `read_global_config` (`chat.rs`): Returns a snapshot of the current `GlobalLlmConfig`.
- `write_global_config` (`chat.rs`): Replaces the global config.
- `ollama_generate` (`chat.rs`): Calls `/api/generate` synchronously and returns the response text.
- `ollama_generate_json` (`chat.rs`): Calls `/api/generate` with `format: "json"` and parses the inner JSON.
- `ollama_embed` (`chat.rs`): Calls `/api/embeddings` and returns the embedding vector.
- `ollama_list_models` (`chat.rs`): Queries `/api/tags` and returns available model names.
- `ollama_is_available` (`chat.rs`): Probes the base URL; returns `true` if it responds.
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
- `LuaAgentRuntime::from_lua_config` (`lua_runtime.rs`): Creates a Lua-facing runtime from a Lua configuration table.
- `LuaAgentRuntime::add_skill` (`lua_runtime.rs`): Appends one named skill prompt to the runtime state.
- `LuaAgentRuntime::clear_skills` (`lua_runtime.rs`): Removes all registered skills from the runtime state.
- `LuaAgentRuntime::set_option` (`lua_runtime.rs`): Sets or updates a single model option (e.g.
- `LuaAgentRuntime::set_format` (`lua_runtime.rs`): Changes the response format (`"json"`, `"csv"`, or `"text"`).
- `LuaAgentRuntime::set_max_retries` (`lua_runtime.rs`): Sets the maximum retry count for transient errors.
- `LuaAgentRuntime::set_name` (`lua_runtime.rs`): Sets the agent's display name (used when added to an AISystem).
- `LuaAgentRuntime::set_description` (`lua_runtime.rs`): Sets the agent's role description (injected by AISystem after the system prompt).
- `LuaAgentRuntime::set_model` (`lua_runtime.rs`): Sets the model identifier forwarded to the LLM backend.
- `LuaAgentRuntime::set_url` (`lua_runtime.rs`): Sets the LLM endpoint URL used for future requests.
- `LuaAgentRuntime::set_timeout` (`lua_runtime.rs`): Sets the per-request timeout in seconds.
- `LuaAgentRuntime::has_skill` (`lua_runtime.rs`): Returns `true` if a skill with `name` is registered.
- `LuaAgentRuntime::skill_count` (`lua_runtime.rs`): Returns the number of registered skills.
- `LuaAgentRuntime::list_skills` (`lua_runtime.rs`): Returns the names of all registered skills in insertion order.
- `LuaAgentRuntime::get_name` (`lua_runtime.rs`): Returns the agent's name identifier.
- `LuaAgentRuntime::get_description` (`lua_runtime.rs`): Returns the agent's role description.
- `LuaAgentRuntime::get_model` (`lua_runtime.rs`): Returns the model identifier.
- `LuaAgentRuntime::get_url` (`lua_runtime.rs`): Returns the LLM endpoint URL.
- `LuaAgentRuntime::get_format` (`lua_runtime.rs`): Returns the response format string.
- `LuaAgentRuntime::cancel` (`lua_runtime.rs`): Cancels an in-flight or pending callback by ID, discarding its response.
- `LuaAgentRuntime::pending_count` (`lua_runtime.rs`): Returns the number of in-flight requests that have not yet completed.
- `LuaAgentRuntime::prompt` (`lua_runtime.rs`): Queues one asynchronous prompt and stores its Lua callback.
- `LuaAgentRuntime::prompt_batch` (`lua_runtime.rs`): Queues a batch of prompts that resolve through one Lua callback table.
- `LuaAgentRuntime::update` (`lua_runtime.rs`): Polls completed prompt and batch responses and dispatches Lua callbacks.
- `LuaAgentRuntime::eval_code` (`lua_runtime.rs`): Executes Lua code inside the active VM and returns `true` on success.
- `LuaAgentRuntime::make_batch_task` (`lua_runtime.rs`): Clones the current runtime state into one explicit batch task.
- `LuaAgentManagerRuntime::new` (`lua_runtime.rs`): Creates an empty batch manager runtime with its own background client.
- `LuaAgentManagerRuntime::run_all` (`lua_runtime.rs`): Dispatches explicit batch tasks and stores the shared Lua completion callback.
- `LuaAgentManagerRuntime::update` (`lua_runtime.rs`): Polls completed manager batch responses and dispatches the batch callback.
- `LuaAISystemRuntime::from_lua_config` (`lua_runtime.rs`): Creates a new `LuaAISystemRuntime` from a Lua configuration table.
- `LuaAISystemRuntime::add_agent` (`lua_runtime.rs`): Adds an agent to the system under the given name.
- `LuaAISystemRuntime::remove_agent` (`lua_runtime.rs`): Removes an agent by name.
- `LuaAISystemRuntime::list_agents` (`lua_runtime.rs`): Returns a snapshot of registered agent names.
- `LuaAISystemRuntime::add_instruction` (`lua_runtime.rs`): Adds or replaces a named instruction block.
- `LuaAISystemRuntime::remove_instruction` (`lua_runtime.rs`): Removes an instruction by key.
- `LuaAISystemRuntime::add_system_skill` (`lua_runtime.rs`): Adds a keyword-gated skill.
- `LuaAISystemRuntime::remove_system_skill` (`lua_runtime.rs`): Removes a system skill by name.
- `LuaAISystemRuntime::has_agent` (`lua_runtime.rs`): Returns `true` if an agent with `name` is registered.
- `LuaAISystemRuntime::agent_count` (`lua_runtime.rs`): Returns the number of registered agents.
- `LuaAISystemRuntime::has_instruction` (`lua_runtime.rs`): Returns `true` if an instruction with `key` exists.
- `LuaAISystemRuntime::instruction_count` (`lua_runtime.rs`): Returns the number of registered instructions.
- `LuaAISystemRuntime::list_instructions` (`lua_runtime.rs`): Returns the keys of all registered instructions in insertion order.
- `LuaAISystemRuntime::has_system_skill` (`lua_runtime.rs`): Returns `true` if a system skill with `name` is registered.
- `LuaAISystemRuntime::system_skill_count` (`lua_runtime.rs`): Returns the number of registered system skills.
- `LuaAISystemRuntime::build_context` (`lua_runtime.rs`): Builds the system context block that would be sent for `instruction`; used by `buildContext` and routing.
- `LuaAISystemRuntime::prompt` (`lua_runtime.rs`): Sends a single prompt to a named agent through the system, auto-injecting context.
- `LuaAISystemRuntime::run_all` (`lua_runtime.rs`): Dispatches batch tasks built from named agents with auto-injected system context.
- `LuaAISystemRuntime::make_system_task` (`lua_runtime.rs`): Builds an `AgentBatchTask` for a named agent, injecting system context.
- `LuaAISystemRuntime::update` (`lua_runtime.rs`): Polls all completed system responses and dispatches Lua callbacks.
- `lua_to_json` (`lua_runtime.rs`): Recursively converts an `mlua::Value` into a `serde_json::Value`.
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

- Binding path(s): `src/lua_api/agent_api.rs`
- Namespace: `lurek.agent`

### Module Functions
- `lurek.agent.new`: Creates a new configurable LLM Agent runtime instance.
- `lurek.agent.newManager`: Creates a new Agent Manager for batching multiple LLM agents over a shared client.
- `lurek.agent.newSystem`: Creates a new AISystem orchestrator that holds agents, instructions, and keyword-gated skills.
- `lurek.agent.newOllama`: Creates an Ollama infrastructure manager for server lifecycle and model management.
- `lurek.agent.configure`: Configures the global LLM provider settings used by module-level functions.
- `lurek.agent.complete`: Sends a single prompt to the global LLM and returns the response text.
- `lurek.agent.completeAsync`: Sends a prompt asynchronously using a background thread; calls `callback(text, err)` on completion.
- `lurek.agent.newChat`: Creates a new stateful chat session using the global LLM config.
- `lurek.agent.newTemplate`: Creates a new `{key}` placeholder prompt template.
- `lurek.agent.completeJson`: Sends a prompt requesting a JSON-format response and returns a parsed Lua table.
- `lurek.agent.embed`: Returns an embedding vector for `text` from the global LLM.
- `lurek.agent.isAvailable`: Returns `true` if the configured LLM server responds within 5 seconds.
- `lurek.agent.listModels`: Returns a list of available model names from the configured LLM server.
- `lurek.agent.newWorkingMemory`: Creates a new bounded FIFO working memory with the given capacity.
- `lurek.agent.newEpisodicMemory`: Creates a new episodic memory for recording time-stamped events.
- `lurek.agent.newSemanticMemory`: Creates a new semantic memory for storing named facts.
- `lurek.agent.newAgentMemory`: Creates a bundled working+episodic+semantic memory with optional disk persistence.

### `LAISystem` Methods
- `LAISystem:addAgent`: Registers a named agent in the system.
- `LAISystem:removeAgent`: Removes a registered agent by name.
- `LAISystem:listAgents`: Returns a sorted list of all registered agent names.
- `LAISystem:hasAgent`: Returns `true` if an agent with `name` is registered.
- `LAISystem:agentCount`: Returns the number of registered agents.
- `LAISystem:addInstruction`: Adds a named instruction block the user can explicitly include per prompt.
- `LAISystem:removeInstruction`: Removes an instruction block by key.
- `LAISystem:hasInstruction`: Returns `true` if an instruction with `key` is registered.
- `LAISystem:instructionCount`: Returns the number of registered instruction blocks.
- `LAISystem:listInstructions`: Returns a list of registered instruction keys in insertion order.
- `LAISystem:addSkill`: Adds a keyword-gated system skill that Lurek auto-injects when the prompt overlaps with its keywords.
- `LAISystem:removeSkill`: Removes a registered system skill by exact name.
- `LAISystem:hasSkill`: Returns `true` if a system skill with `name` is registered.
- `LAISystem:skillCount`: Returns the number of registered system skills.
- `LAISystem:buildContext`: Builds and returns the full context string that would be sent for a given prompt.
- `LAISystem:prompt`: Sends a prompt to a named agent through the system, auto-injecting matching context.
- `LAISystem:runAll`: Dispatches multiple named-agent tasks in parallel through the system.
- `LAISystem:update`: Polls the system's background client for completed requests and dispatches callbacks.

### `LAgent` Methods
- `LAgent:addSkill`: Appends a named skill prompt to the agent's context block.
- `LAgent:clearSkills`: Removes all registered skills from the agent's context.
- `LAgent:setOption`: Sets a single model option forwarded to the LLM backend.
- `LAgent:setFormat`: Changes the response format for future prompts.
- `LAgent:setMaxRetries`: Sets the maximum retry count on transient network or timeout errors.
- `LAgent:setContextSize`: Sets the token context window size forwarded to the LLM backend.
- `LAgent:setTemperature`: Sets the sampling temperature forwarded to the LLM backend.
- `LAgent:setName`: Sets the agent's name identifier used when added to an AISystem.
- `LAgent:setDescription`: Sets the agent's role description injected after the system prompt when routed through an AISystem.
- `LAgent:setModel`: Changes the model identifier for future prompts.
- `LAgent:setUrl`: Changes the LLM endpoint URL for future prompts.
- `LAgent:setTimeout`: Sets the per-request timeout in seconds (0 uses the default 60 s).
- `LAgent:getName`: Returns the agent's name identifier.
- `LAgent:getDescription`: Returns the agent's role description.
- `LAgent:getModel`: Returns the current model identifier.
- `LAgent:getUrl`: Returns the current LLM endpoint URL.
- `LAgent:getFormat`: Returns the current response format string.
- `LAgent:hasSkill`: Returns `true` if a skill with `name` is registered.
- `LAgent:skillCount`: Returns the number of registered skills.
- `LAgent:listSkills`: Returns a list of registered skill names in insertion order.
- `LAgent:prompt`: Sends an instructional prompt to the LLM asynchronously.
- `LAgent:promptBatch`: Sends a batch of prompts to the LLM asynchronously.
- `LAgent:cancel`: Cancels an in-flight or pending request by callback ID.
- `LAgent:pendingCount`: Returns the number of in-flight requests that have not yet completed.
- `LAgent:update`: Polls the background client for completed LLM requests and dispatches callbacks.
- `LAgent:evalCode`: Evaluates a Lua code string inside the active VM.

### `LAgentChat` Methods
- `LAgentChat:setSystemPrompt`: Sets the system prompt used for all completions in this session.
- `LAgentChat:addMessage`: Appends a message to the chat history without sending a completion.
- `LAgentChat:complete`: Sends the current history to the LLM and returns the assistant reply.
- `LAgentChat:clear`: Clears all stored chat history messages.
- `LAgentChat:getHistory`: Returns the chat history as an array of `{role, content}` tables.

### `LAgentManager` Methods
- `LAgentManager:runAll`: Runs multiple agent tasks in parallel and calls a single callback when all finish.
- `LAgentManager:update`: Polls the manager's background client for completed tasks and dispatches callbacks.

### `LAgentMemory` Methods
- `LAgentMemory:working`: Returns the working memory component.
- `LAgentMemory:episodic`: Returns the episodic memory component.
- `LAgentMemory:semantic`: Returns the semantic memory component.
- `LAgentMemory:save`: Serialises all memory banks to the configured persist_path.
- `LAgentMemory:load`: Deserialises memory state from the configured persist_path.

### `LAgentTemplate` Methods
- `LAgentTemplate:render`: Renders the template by substituting `{key}` placeholders from `values`.

### `LEpisodicMemory` Methods
- `LEpisodicMemory:record`: Records a new episode at `tick` with `data`.
- `LEpisodicMemory:query`: Returns all episodes whose data matches every key-value pair in `filter`.
- `LEpisodicMemory:forgetBefore`: Removes all episodes with tick < `cutoff`.
- `LEpisodicMemory:len`: Returns the number of stored episodes.

### `LOllamaManager` Methods
- `LOllamaManager:isRunning`: Returns `true` if the Ollama HTTP server responds within 5 seconds.
- `LOllamaManager:version`: Returns the Ollama version string, or an empty string if not running.
- `LOllamaManager:baseUrl`: Returns the base URL this manager was created with.
- `LOllamaManager:listModels`: Returns a table of locally available models, each with `name` and `size_gb` fields.
- `LOllamaManager:modelNames`: Returns a string array of locally available model names; empty if Ollama is not running.
- `LOllamaManager:hasModel`: Returns `true` if a model with the given name (or name prefix) is available locally.
- `LOllamaManager:start`: Spawns `ollama serve` as a managed child process. Returns `true` on success.
- `LOllamaManager:stop`: Kills the Ollama process started by this manager. Returns `true` if it was running.
- `LOllamaManager:restart`: Stops then restarts the managed Ollama process. Returns `true` on success.
- `LOllamaManager:pullModel`: Dispatches an async model download; calls `callback(success, err_msg)` on completion.
- `LOllamaManager:deleteModel`: Sends `DELETE /api/delete` to remove a model from local Ollama storage.
- `LOllamaManager:pendingCount`: Returns the number of in-flight model pull operations.
- `LOllamaManager:update`: Polls completed pull operations and dispatches registered callbacks.

### `LSemanticMemory` Methods
- `LSemanticMemory:learn`: Inserts or replaces a fact at `key`.
- `LSemanticMemory:recall`: Returns the fact for `key`, or `nil` if not found.
- `LSemanticMemory:forget`: Removes the fact at `key`.  Returns `true` if it existed.
- `LSemanticMemory:query`: Returns all facts whose value matches every key-value pair in `filter`.
- `LSemanticMemory:len`: Returns the number of stored facts.

### `LWorkingMemory` Methods
- `LWorkingMemory:push`: Inserts or updates a key-value entry; evicts the oldest entry if capacity is exceeded.
- `LWorkingMemory:get`: Returns the value for `key`, or `nil` if not found.
- `LWorkingMemory:forget`: Removes the entry with `key`.  Returns `true` if it existed.
- `LWorkingMemory:getRecent`: Returns the `n` most recently inserted entries as an array of `{key, value}` tables.
- `LWorkingMemory:len`: Returns the current number of entries.
- `LWorkingMemory:capacity`: Returns the configured capacity (0 = unlimited).

## References

- `network`: `src/agent/client.rs` delegates HTTP transport to `crate::network::http::execute_request`.

## Notes

- All prompt APIs are async-by-poll; callers must drive completion from `update()` each frame.
- `complete()`, `completeJson()`, and `embed()` are synchronous blocking calls — they block the Lua VM until the request completes. Use in init, background tasks, or scripted agents only.
- Response parsing supports `json` (returns Lua table), `csv` (returns dataframe-like rows table), and `text`; parse failures are returned through the Lua callback `err_info` table.
- `evalCode` executes dynamic Lua and must stay constrained to trusted or sandboxed code paths.
- `setContextSize(n)` and `setTemperature(t)` are convenience shortcuts for `setOption("num_ctx", n)` and `setOption("temperature", t)`. All backend parameters are forwarded through the `options` JSON object.
- `cancel(callback_id)` silently discards the response if the background thread has already completed. It does not interrupt an in-flight HTTP request.
- AISystem context assembly order: `system_prompt` → auto-matched skills → explicit instructions → agent description → agent system block (agent prompt + agent skills).
- `buildContext` returns the assembled string without dispatching a request; use it to inspect or log context before sending.
- `LAgentMemory:working()`, `:episodic()`, and `:semantic()` return new independent handles (snapshots), not live references to the bundle's internal stores. Mutate the bundle via the returned handles and call `save()` to persist.
