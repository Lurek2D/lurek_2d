<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/agent.md or source docstrings instead. -->

# agent

## TL;DR

- Orchestrates multi-agent AI completions and stateful conversations.
- Supports tiered, persistent working, episodic, and semantic memory.
- Manages local Ollama lifecycles and background request polling over local plain HTTP.

## General Info

- Module group: `Feature Systems`
- Source path: `src/agent`
- Binding: `src/lua_api/agent_api.rs`
- Namespace: `lurek.agent`
- Lua API surface: `21` functions, `10` types, `91` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `agent` module is the engine's AI-assistant surface for users who want LLM-backed behavior inside the runtime without building transport, memory, and orchestration infrastructure from scratch.
- It turns raw model calls into an engine feature by combining direct chat, structured outputs, embeddings, background request transport, and named agent configuration in one subsystem.
- Working, episodic, and semantic memory are central because the module is designed for repeated interaction, not only for one-shot completions.
- That memory model matters because a useful assistant usually needs continuity: it should keep recent context, retain important facts, and support longer-lived agent identities instead of acting like a stateless prompt box.
- Polling, retries, and background lifecycle handling matter because real agent workflows are often slow, asynchronous, or multi-stage.
- Runtime HTTP transport is intentionally narrow: local `http://host:port/path` only, intended for Ollama endpoints such as `http://127.0.0.1:11434/api/generate`.
- HTTPS, TLS, redirects, gzip, and streaming/chunked responses are not part of the runtime agent transport. Attempts to use HTTPS are rejected with `Ollama agent runtime supports local plain HTTP only`.
- Structured responses broaden the feature beyond conversational prose into tool-friendly outputs that other systems can consume reliably.
- Embeddings support is equally important because retrieval, similarity search, and grounding workflows often matter as much as text generation itself.
- This makes the module useful not only for chat-like helpers, but also for assistants that classify, retrieve, summarize, or fill structured records as part of larger tool or content workflows.
- Orchestration support matters because several named agents may need different prompts, memory scopes, and response rules while still living under one runtime surface.
- The module is useful for tool copilots, content helpers, QA utilities, retrieval-backed assistants, and other workflows where model access should feel native to the engine.
- `agent` owns prompts, memory, agent identity, structured responses, and request orchestration semantics.
- Read `agent` as the place where assistants become first-class runtime capabilities rather than thin HTTP wrappers.

This module owns its small local Ollama HTTP client rather than depending on `network`. Its responsibility should stay inside the `Feature Systems` group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/agent`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/agent_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### chat.rs

- This file owns the synchronous chat surface, global LLM config, prompt templates, and session message history.
- It wraps direct Ollama generate, JSON, embedding, model-list, and availability calls for immediate agent workflows.
- Global config helpers store the default provider, base URL, model, timeout, and API key for module-level calls.
- `LlmTemplate` performs keyed placeholder rendering so runtime code can assemble prompts without ad hoc string glue.
- `LlmChat` preserves multi-turn history and system prompts, then sends `/api/chat` requests and appends replies.
- These APIs are intentionally synchronous and local, making them suitable for tools or simple flows outside polling.
- Open this file when direct request formats change; async transport and backend process control live in siblings.

### client.rs

- Owns agent behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps agent data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how client data is validated, transformed, or stored before neighboring systems use it.
- Owns agent behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on client behavior while Lua registration stays elsewhere.
- Documents where agent callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
- Use this file when changing client defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the agent state that can explain them while keeping call sites explicit.

### local_http.rs

- Minimal plain-HTTP client used only by the local Ollama agent runtime.
- It intentionally supports a narrow HTTP/1.1 request/response path so the
- game networking module does not need a general web client dependency.

### memory.rs

- Owns the memory store for the agent subsystem and keeps its rules local to this file while keeping call sites explicit.
- Keeps agent data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how memory data is validated, transformed, or stored before neighboring systems use it.
- Owns agent behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on memory behavior while Lua registration stays elsewhere.
- Documents where agent callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
- Use this file when changing memory defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the agent state that can explain them while keeping call sites explicit.

### mod.rs

- This module re-exports the agent subsystem surface for chat, transport, memory, Ollama control, and state.
- It exists to keep callers on stable entry points while sibling files own request shaping, retries, and storage.
- `chat.rs` handles synchronous prompt calls, templates, and session history for immediate model interactions.
- `client.rs`, `types.rs`, and `state.rs` define async transport, payload contracts, and request-building state.
- `memory.rs`, `ollama.rs`, and `orchestration.rs` cover recall stores, local backend control, and batch routing.
- Change this file when the public agent symbol map moves; change siblings when behavior or data rules change.

### ollama.rs

- Owns the ollama owner for the agent subsystem and keeps its rules local to this file while keeping call sites explicit.
- Keeps agent data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how ollama data is validated, transformed, or stored before neighboring systems use it.
- Owns agent behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on ollama behavior while Lua registration stays elsewhere.
- Documents where agent callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
- Use this file when changing ollama defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the agent state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping ollama calculations explicit at their owner boundary.

### orchestration.rs

- This file owns agent batch-task assembly, callback-id packing, and system-context composition for routed prompts.
- It stays free of `mlua` types so Lua runtimes and tests can share one orchestration layer without glue churn.
- Helpers merge AI-system prompts, named instruction blocks, and optional agent descriptions into one system block.
- Open this file when batch routing changes; transport threads and mutable agent state live in sibling files.

### state.rs

- Owns agent behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps agent data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how state data is validated, transformed, or stored before neighboring systems use it.
- Owns agent behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on state behavior while Lua registration stays elsewhere.
- Documents where agent callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
- Use this file when changing state defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the agent state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping state calculations explicit at their owner boundary.

### types.rs

- Owns the shared type model for the agent subsystem and keeps its rules local to this file.
- Centers the implementation around AgentResponseFormat, parse, as_str, with helpers kept close to their invariants.
- Defines how types data is validated, transformed, or stored before neighboring systems use it.
- Owns agent behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on types behavior while Lua registration stays elsewhere.



## Lua API Ref

### Functions

- `lurek.agent.cancel(callback_id) -> nil`: Cancels a module-level asynchronous completion by callback ID.
- `lurek.agent.complete(prompt) -> string`: Sends a single prompt to the global LLM and returns the response text.
- `lurek.agent.completeAsync(prompt, callback) -> integer`: Queues a prompt on the module-level bounded worker pool; calls `callback(text, err)` on completion.
- `lurek.agent.completeJson(prompt) -> table`: Sends a prompt requesting a JSON-format response and returns a parsed Lua table.
- `lurek.agent.configure(config) -> nil`: Configures the global LLM provider settings used by module-level functions.
- `lurek.agent.embed(text) -> table`: Returns an embedding vector for `text` from the global LLM.
- `lurek.agent.getDiagnostics() -> table`: Returns module-level async transport diagnostics for `completeAsync`.
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
- `LAISystem:buildContextReport(instruction, opts?) -> table`: Builds context and returns both the rendered text and provenance list.
- `LAISystem:getDiagnostics() -> table`: Returns transport diagnostics for the AI system runtime.
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
- `LAgent:getDiagnostics() -> table`: Returns transport diagnostics for the agent runtime.
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
- `LAgent:setUrl(url) -> nil`: Changes the LLM endpoint URL for future prompts after safe-mode validation.
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
- `LAgentMemory:getDiagnostics() -> table`: Returns diagnostics for the bundled memory state and persistence policy.
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
- `LOllamaManager:cancelPull(callback_id) -> boolean`: Marks a queued or in-flight pull as cancelled so its result is ignored on completion.
- `LOllamaManager:deleteModel(name, confirm_token?) -> boolean`: Sends `DELETE /api/delete` to remove a model from local Ollama storage.
- `LOllamaManager:getDiagnostics() -> table`: Returns operational diagnostics for the Ollama manager.
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

## Examples

- `content/examples/agent.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
