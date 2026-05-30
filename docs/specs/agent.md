# agent

## TL;DR

- The `agent` module gives one AI layer for games and tools: run prompts, coordinate agents, keep memory, and get results without blocking frame updates.

## General Info

- Module group: `Feature Systems`
- Source path: `src/agent/`
- Binding: `src/lua_api/agent_api.rs`
- Namespace: `lurek.agent`
- Lua API surface: `17` functions, `10` types, `85` methods
- Rust test path(s): tests/rust/unit/agent_tests.rs
- Lua test path(s): tests/lua/unit/test_agent_core_unit.lua

## Summary

The `agent` module turns model access into a stable service for gameplay and tools. Instead of many one-off scripts, it gives one consistent way to send prompts, receive answers, and handle callbacks. This makes AI features easier to build, easier to reason about, and safer to reuse across a project.

Its main functional value is non-blocking work. Requests run in the background while the frame loop keeps moving, then scripts poll and consume completed results. This protects runtime responsiveness and gives practical control over timeout, retry, cancellation, and response format.

The module also supports orchestration at different scales. You can run one agent, batch several tasks, or use a system that combines shared instructions with keyword-matched skills. This keeps prompt behavior more consistent between teams and features, because common context rules are managed in one place.

For direct use, the module includes synchronous completions, JSON output, embeddings, model listing, and availability checks. It also provides stateful chat sessions and simple template rendering, so both quick utility calls and longer multi-turn interactions can use the same module surface.

Memory is treated as a practical stack: short-term working context, episodic history, semantic facts, and a bundled memory that can persist across sessions. In real use, this helps agents keep continuity, retain useful facts, and restart with context, without every game script building custom memory plumbing.

## Imports

- `network`: `src/agent/client.rs` delegates HTTP transport to `crate::network::http::execute_request`.

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

## Lua API Ref

### Functions

- `lurek.agent.complete`: Sends a single prompt to the global LLM and returns the response text.
- `lurek.agent.completeAsync`: Sends a prompt asynchronously using a background thread; calls `callback(text, err)` on completion.
- `lurek.agent.completeJson`: Sends a prompt requesting a JSON-format response and returns a parsed Lua table.
- `lurek.agent.configure`: Configures the global LLM provider settings used by module-level functions.
- `lurek.agent.embed`: Returns an embedding vector for `text` from the global LLM.
- `lurek.agent.isAvailable`: Returns `true` if the configured LLM server responds within 5 seconds.
- `lurek.agent.listModels`: Returns a list of available model names from the configured LLM server.
- `lurek.agent.new`: Creates a new configurable LLM Agent runtime instance.
- `lurek.agent.newAgentMemory`: Creates a bundled working+episodic+semantic memory with optional disk persistence.
- `lurek.agent.newChat`: Creates a new stateful chat session using the global LLM config.
- `lurek.agent.newEpisodicMemory`: Creates a new episodic memory for recording time-stamped events.
- `lurek.agent.newManager`: Creates a new Agent Manager for batching multiple LLM agents over a shared client.
- `lurek.agent.newOllama`: Creates an Ollama infrastructure manager for server lifecycle and model management.
- `lurek.agent.newSemanticMemory`: Creates a new semantic memory for storing named facts.
- `lurek.agent.newSystem`: Creates a new AISystem orchestrator that holds agents, instructions, and keyword-gated skills.
- `lurek.agent.newTemplate`: Creates a new `{key}` placeholder prompt template.
- `lurek.agent.newWorkingMemory`: Creates a new bounded FIFO working memory with the given capacity.

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

- `LAISystem:addAgent`: Registers a named agent in the system.
- `LAISystem:addInstruction`: Adds a named instruction block the user can explicitly include per prompt.
- `LAISystem:addSkill`: Adds a keyword-gated system skill that Lurek auto-injects when the prompt overlaps with its keywords.
- `LAISystem:agentCount`: Returns the number of registered agents.
- `LAISystem:buildContext`: Builds and returns the full context string that would be sent for a given prompt.
- `LAISystem:hasAgent`: Returns `true` if an agent with `name` is registered.
- `LAISystem:hasInstruction`: Returns `true` if an instruction with `key` is registered.
- `LAISystem:hasSkill`: Returns `true` if a system skill with `name` is registered.
- `LAISystem:instructionCount`: Returns the number of registered instruction blocks.
- `LAISystem:listAgents`: Returns a sorted list of all registered agent names.
- `LAISystem:listInstructions`: Returns a list of registered instruction keys in insertion order.
- `LAISystem:prompt`: Sends a prompt to a named agent through the system, auto-injecting matching context.
- `LAISystem:removeAgent`: Removes a registered agent by name.
- `LAISystem:removeInstruction`: Removes an instruction block by key.
- `LAISystem:removeSkill`: Removes a registered system skill by exact name.
- `LAISystem:runAll`: Dispatches multiple named-agent tasks in parallel through the system.
- `LAISystem:skillCount`: Returns the number of registered system skills.
- `LAISystem:update`: Polls the system's background client for completed requests and dispatches callbacks.

#### LAgent Type

- Lua-side handle for a single LLM Agent.

##### Fields

- No documented fields.

##### Methods

- `LAgent:addSkill`: Appends a named skill prompt to the agent's context block.
- `LAgent:cancel`: Cancels an in-flight or pending request by callback ID.
- `LAgent:clearSkills`: Removes all registered skills from the agent's context.
- `LAgent:evalCode`: Evaluates a Lua code string inside the active VM.
- `LAgent:getDescription`: Returns the agent's role description.
- `LAgent:getFormat`: Returns the current response format string.
- `LAgent:getModel`: Returns the current model identifier.
- `LAgent:getName`: Returns the agent's name identifier.
- `LAgent:getUrl`: Returns the current LLM endpoint URL.
- `LAgent:hasSkill`: Returns `true` if a skill with `name` is registered.
- `LAgent:listSkills`: Returns a list of registered skill names in insertion order.
- `LAgent:pendingCount`: Returns the number of in-flight requests that have not yet completed.
- `LAgent:prompt`: Sends an instructional prompt to the LLM asynchronously.
- `LAgent:promptBatch`: Sends a batch of prompts to the LLM asynchronously.
- `LAgent:setContextSize`: Sets the token context window size forwarded to the LLM backend.
- `LAgent:setDescription`: Sets the agent's role description injected after the system prompt when routed through an AISystem.
- `LAgent:setFormat`: Changes the response format for future prompts.
- `LAgent:setMaxRetries`: Sets the maximum retry count on transient network or timeout errors.
- `LAgent:setModel`: Changes the model identifier for future prompts.
- `LAgent:setName`: Sets the agent's name identifier used when added to an AISystem.
- `LAgent:setOption`: Sets a single model option forwarded to the LLM backend.
- `LAgent:setTemperature`: Sets the sampling temperature forwarded to the LLM backend.
- `LAgent:setTimeout`: Sets the per-request timeout in seconds (0 uses the default 60 s).
- `LAgent:setUrl`: Changes the LLM endpoint URL for future prompts.
- `LAgent:skillCount`: Returns the number of registered skills.
- `LAgent:update`: Polls the background client for completed LLM requests and dispatches callbacks.

#### LAgentChat Type

- Lua-side handle for a stateful LLM chat session.

##### Fields

- No documented fields.

##### Methods

- `LAgentChat:addMessage`: Appends a message to the chat history without sending a completion.
- `LAgentChat:clear`: Clears all stored chat history messages.
- `LAgentChat:complete`: Sends the current history to the LLM and returns the assistant reply.
- `LAgentChat:getHistory`: Returns the chat history as an array of `{role, content}` tables.
- `LAgentChat:setSystemPrompt`: Sets the system prompt used for all completions in this session.

#### LAgentManager Type

- Lua-side handle for managing multiple LLM Agents in parallel.

##### Fields

- No documented fields.

##### Methods

- `LAgentManager:runAll`: Runs multiple agent tasks in parallel and calls a single callback when all finish.
- `LAgentManager:update`: Polls the manager's background client for completed tasks and dispatches callbacks.

#### LAgentMemory Type

- Lua-side handle for a bundled working+episodic+semantic memory with optional persistence.

##### Fields

- No documented fields.

##### Methods

- `LAgentMemory:episodic`: Returns the episodic memory component.
- `LAgentMemory:load`: Deserialises memory state from the configured persist_path.
- `LAgentMemory:save`: Serialises all memory banks to the configured persist_path.
- `LAgentMemory:semantic`: Returns the semantic memory component.
- `LAgentMemory:working`: Returns the working memory component.

#### LAgentTemplate Type

- Lua-side handle for a `{key}` placeholder prompt template.

##### Fields

- No documented fields.

##### Methods

- `LAgentTemplate:render`: Renders the template by substituting `{key}` placeholders from `values`.

#### LEpisodicMemory Type

- Lua-side handle for append-only episodic memory.

##### Fields

- No documented fields.

##### Methods

- `LEpisodicMemory:forgetBefore`: Removes all episodes with tick < `cutoff`.
- `LEpisodicMemory:len`: Returns the number of stored episodes.
- `LEpisodicMemory:query`: Returns all episodes whose data matches every key-value pair in `filter`.
- `LEpisodicMemory:record`: Records a new episode at `tick` with `data`.

#### LOllamaManager Type

- Lua-side handle for managing a local Ollama server lifecycle and models.

##### Fields

- No documented fields.

##### Methods

- `LOllamaManager:baseUrl`: Returns the base URL this manager was created with.
- `LOllamaManager:deleteModel`: Sends `DELETE /api/delete` to remove a model from local Ollama storage.
- `LOllamaManager:hasModel`: Returns `true` if a model with the given name (or name prefix) is available locally.
- `LOllamaManager:isRunning`: Returns `true` if the Ollama HTTP server responds within 5 seconds.
- `LOllamaManager:listModels`: Returns a table of locally available models, each with `name` and `size_gb` fields.
- `LOllamaManager:modelNames`: Returns a string array of locally available model names; empty if Ollama is not running.
- `LOllamaManager:pendingCount`: Returns the number of in-flight model pull operations.
- `LOllamaManager:pullModel`: Dispatches an async model download; calls `callback(success, err_msg)` on completion.
- `LOllamaManager:restart`: Stops then restarts the managed Ollama process. Returns `true` on success.
- `LOllamaManager:start`: Spawns `ollama serve` as a managed child process. Returns `true` on success.
- `LOllamaManager:stop`: Kills the Ollama process started by this manager. Returns `true` if it was running.
- `LOllamaManager:update`: Polls completed pull operations and dispatches registered callbacks.
- `LOllamaManager:version`: Returns the Ollama version string, or an empty string if not running.

#### LSemanticMemory Type

- Lua-side handle for an unbounded key Ă˘â€ â€™ value fact store.

##### Fields

- No documented fields.

##### Methods

- `LSemanticMemory:forget`: Removes the fact at `key`.  Returns `true` if it existed.
- `LSemanticMemory:learn`: Inserts or replaces a fact at `key`.
- `LSemanticMemory:len`: Returns the number of stored facts.
- `LSemanticMemory:query`: Returns all facts whose value matches every key-value pair in `filter`.
- `LSemanticMemory:recall`: Returns the fact for `key`, or `nil` if not found.

#### LWorkingMemory Type

- Lua-side handle for a bounded FIFO working memory.

##### Fields

- No documented fields.

##### Methods

- `LWorkingMemory:capacity`: Returns the configured capacity (0 = unlimited).
- `LWorkingMemory:forget`: Removes the entry with `key`.  Returns `true` if it existed.
- `LWorkingMemory:get`: Returns the value for `key`, or `nil` if not found.
- `LWorkingMemory:getRecent`: Returns the `n` most recently inserted entries as an array of `{key, value}` tables.
- `LWorkingMemory:len`: Returns the current number of entries.
- `LWorkingMemory:push`: Inserts or updates a key-value entry; evicts the oldest entry if capacity is exceeded.
