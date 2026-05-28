# agent

## TL;DR

- The `agent` module provides async LLM prompt dispatch, per-agent prompt state, AISystem multi-agent orchestration, keyword-gated skill injection, output format control, automatic retry, and thin Lua-facing handles for polling results back into the Lua VM.

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

## Files

- `mod.rs`: Module manifest and re-export surface.
- `client.rs`: Background request transport and completed-response queue.
- `state.rs`: Per-agent configuration, skill storage, and prompt assembly.
- `types.rs`: Shared request, response, and error types.
- `lua_runtime.rs`: Lua-facing runtime helpers used by the thin wrapper in `src/lua_api/agent_api.rs`.

## Source Documentation

### `client.rs`
- Background transport for LLM agent prompts.

### `lua_runtime.rs`
- Lua-facing runtime helpers for `lurek.agent`.

### `mod.rs`
- LLM agent runtime: state, request types, error variants, and background HTTP client.

### `state.rs`
- Per-agent configuration and prompt assembly helpers.

### `types.rs`
- Public request, response, and error types for the LLM agent runtime.

## Types

- `AgentClient` (`struct`, `client.rs`): Background prompt transport with cancel tracking, in-flight counter, and retry-aware dispatch.
- `AgentBatchTask` (`struct`, `lua_runtime.rs`): One queued batch task; carries an optional `system_override` for AISystem routing.
- `LuaAgentRuntime` (`struct`, `lua_runtime.rs`): Runtime state owned by a single Lua `LAgent` userdata.
- `LuaAgentManagerRuntime` (`struct`, `lua_runtime.rs`): Runtime state owned by a Lua `LAgentManager` userdata.
- `LuaAISystemRuntime` (`struct`, `lua_runtime.rs`): Multi-agent orchestrator runtime owned by a Lua `LAISystem` userdata.
- `AgentState` (`struct`, `state.rs`): Per-agent configuration: identity, skills, retry, timeout, options, and request-building helpers.
- `AISystemState` (`struct`, `state.rs`): Shared orchestration state: system prompt, instruction blocks, and keyword-gated skill blocks.
- `SystemSkill` (`struct`, `state.rs`): A keyword-gated skill block registered at the AISystem level.
- `AgentError` (`enum`, `types.rs`): Error classification for network, timeout, format, and model failures.
- `AgentRequest` (`struct`, `types.rs`): One outbound prompt request including retry and timeout settings.
- `AgentResponse` (`struct`, `types.rs`): One completed async response paired back to a callback ID.

## Functions

- `AgentClient::new` (`client.rs`): Creates a new `AgentClient`.
- `AgentClient::send_prompt` (`client.rs`): Dispatches a prompt on a background thread with retry on transient errors.
- `AgentClient::cancel` (`client.rs`): Marks a callback ID as cancelled so its response is silently discarded.
- `AgentClient::in_flight_count` (`client.rs`): Returns the number of in-flight requests that have not completed.
- `AgentClient::poll` (`client.rs`): Drains all completed responses since the last poll.
- `LuaAgentRuntime::from_lua_config` (`lua_runtime.rs`): Creates a runtime from a Lua config table, including new fields: name, description, max_retries, timeout.
- `LuaAgentRuntime::add_skill` (`lua_runtime.rs`): Appends a named skill to the runtime state.
- `LuaAgentRuntime::clear_skills` (`lua_runtime.rs`): Removes all skills from the runtime state.
- `LuaAgentRuntime::set_option` (`lua_runtime.rs`): Inserts or updates a single model option.
- `LuaAgentRuntime::set_format` (`lua_runtime.rs`): Changes the response format for future prompts.
- `LuaAgentRuntime::set_max_retries` (`lua_runtime.rs`): Sets the retry count.
- `LuaAgentRuntime::set_name` (`lua_runtime.rs`): Sets the agent identifier.
- `LuaAgentRuntime::set_description` (`lua_runtime.rs`): Sets the agent role description.
- `LuaAgentRuntime::cancel` (`lua_runtime.rs`): Cancels an in-flight callback by ID.
- `LuaAgentRuntime::pending_count` (`lua_runtime.rs`): Returns the in-flight request count.
- `LuaAgentRuntime::prompt` (`lua_runtime.rs`): Queues one async prompt and stores its callback.
- `LuaAgentRuntime::prompt_batch` (`lua_runtime.rs`): Queues a batch of prompts under one callback.
- `LuaAgentRuntime::update` (`lua_runtime.rs`): Polls and dispatches completed responses.
- `LuaAgentRuntime::eval_code` (`lua_runtime.rs`): Evaluates a Lua string in the active VM.
- `LuaAgentRuntime::make_batch_task` (`lua_runtime.rs`): Clones state into an `AgentBatchTask`.
- `LuaAgentManagerRuntime::new` (`lua_runtime.rs`): Creates an empty batch manager runtime.
- `LuaAgentManagerRuntime::run_all` (`lua_runtime.rs`): Dispatches explicit batch tasks.
- `LuaAgentManagerRuntime::update` (`lua_runtime.rs`): Polls completed manager batch responses.
- `LuaAISystemRuntime::from_lua_config` (`lua_runtime.rs`): Creates a system runtime from a Lua config table.
- `LuaAISystemRuntime::add_agent` (`lua_runtime.rs`): Registers an agent by name.
- `LuaAISystemRuntime::remove_agent` (`lua_runtime.rs`): Removes an agent by name.
- `LuaAISystemRuntime::list_agents` (`lua_runtime.rs`): Returns sorted agent names.
- `LuaAISystemRuntime::add_instruction` (`lua_runtime.rs`): Adds a named instruction block.
- `LuaAISystemRuntime::remove_instruction` (`lua_runtime.rs`): Removes an instruction block.
- `LuaAISystemRuntime::add_system_skill` (`lua_runtime.rs`): Adds a keyword-gated skill.
- `LuaAISystemRuntime::remove_system_skill` (`lua_runtime.rs`): Removes a system skill.
- `LuaAISystemRuntime::build_context` (`lua_runtime.rs`): Assembles the full context block for a given prompt.
- `LuaAISystemRuntime::prompt` (`lua_runtime.rs`): Sends a single system-routed prompt to a named agent.
- `LuaAISystemRuntime::run_all` (`lua_runtime.rs`): Dispatches system-context batch tasks.
- `LuaAISystemRuntime::make_system_task` (`lua_runtime.rs`): Builds a task for a named agent with system context injected.
- `LuaAISystemRuntime::update` (`lua_runtime.rs`): Polls and dispatches completed system responses.
- `AgentState::new` (`state.rs`): Creates a new `AgentState` with default retry and timeout.
- `AgentState::set_name` / `set_description` / `set_max_retries` / `set_timeout` / `set_option` (`state.rs`): Mutation helpers.
- `AgentState::add_skill` / `clear_skills` (`state.rs`): Skill management.
- `AgentState::build_system_block` (`state.rs`): Builds the agent system block including skills.
- `AgentState::to_request` / `to_request_with_system` (`state.rs`): Request-building helpers.
- `AISystemState::new` (`state.rs`): Creates a new orchestration state.
- `AISystemState::add_instruction` / `remove_instruction` (`state.rs`): Instruction management.
- `AISystemState::add_system_skill` / `remove_system_skill` (`state.rs`): Skill management.
- `AISystemState::build_context` (`state.rs`): Assembles the system context block with auto-matched skills.
- `AgentError::code` (`types.rs`): Returns the stable Lua-facing error code.
- `AgentError::is_transient` (`types.rs`): Returns `true` for errors safe to retry.

## Lua API Reference

- Binding path(s): `src/lua_api/agent_api.rs`
- Namespace: `lurek.agent`

### Module Functions
- `lurek.agent.new(config)`: Creates a new LLM Agent. Config keys: `url`, `model`, `system_prompt`, `format`, `name`, `description`, `max_retries`, `timeout`, `options`.
- `lurek.agent.newManager()`: Creates a batch manager for running multiple agents over a shared client.
- `lurek.agent.newSystem(config)`: Creates an AISystem orchestrator. Config keys: `system_prompt`.

### `LAgent` Methods
- `LAgent:addSkill(name, prompt)`: Appends a named skill prompt to the agent's context block.
- `LAgent:clearSkills()`: Removes all registered skills.
- `LAgent:setOption(key, value)`: Sets a single model option (e.g. `temperature`, `seed`, `num_ctx`).
- `LAgent:setFormat(format)`: Changes the response format (`json`, `csv`, `text`).
- `LAgent:setMaxRetries(n)`: Sets the retry count for transient errors.
- `LAgent:setContextSize(n)`: Sets `options.num_ctx`.
- `LAgent:setTemperature(t)`: Sets `options.temperature`.
- `LAgent:setName(name)`: Sets the agent's name identifier.
- `LAgent:setDescription(description)`: Sets the agent's role description.
- `LAgent:prompt(instruction, callback)`: Sends an async prompt; callback receives `(success, data, err_info)`. Returns callback ID.
- `LAgent:promptBatch(instructions, callback)`: Sends a batch; callback receives a results table. Returns batch ID.
- `LAgent:cancel(callback_id)`: Cancels a pending or in-flight request.
- `LAgent:pendingCount()`: Returns the in-flight request count.
- `LAgent:update()`: Polls for completed responses and dispatches callbacks.
- `LAgent:evalCode(code)`: Executes a Lua string in the VM; returns `true` or raises.

### `LAgentManager` Methods
- `LAgentManager:runAll(tasks, callback)`: Runs multiple `{ agent, instruction }` tasks in parallel.
- `LAgentManager:update()`: Polls the manager's background client for completed tasks.

### `LAISystem` Methods
- `LAISystem:addAgent(name, agent)`: Registers a named agent in the system.
- `LAISystem:removeAgent(name)`: Removes an agent by name; returns `true` if found.
- `LAISystem:listAgents()`: Returns a sorted table of registered agent names.
- `LAISystem:addInstruction(key, text)`: Adds a named instruction block the user may explicitly include per call.
- `LAISystem:removeInstruction(key)`: Removes an instruction block; returns `true` if found.
- `LAISystem:addSkill(name, keywords, prompt)`: Adds a keyword-gated skill auto-injected by Lurek on prompt overlap.
- `LAISystem:removeSkill(name)`: Removes a system skill; returns `true` if found.
- `LAISystem:buildContext(instruction, opts?)`: Returns the assembled context string for debug/preview. Opts: `{ agent = string, instructions = table }`.
- `LAISystem:prompt(agent_name, instruction, callback, opts?)`: Sends a system-routed prompt to a named agent. Opts: `{ instructions = { "key", ... } }`. Returns callback ID.
- `LAISystem:runAll(tasks, callback)`: Dispatches named-agent batch tasks. Each task: `{ agent = string, instruction = string, instructions = table? }`. Returns batch ID.
- `LAISystem:update()`: Polls for completed system responses and dispatches callbacks.

## References

- `network`: `src/agent/client.rs` delegates HTTP transport to `crate::network::http::execute_request`.

## Notes

- All prompt APIs are async-by-poll; callers must drive completion from `update()` each frame.
- Response parsing supports `json` (returns Lua table), `csv` (returns dataframe-like rows table), and `text`; parse failures are returned through the Lua callback `err_info` table.
- `evalCode` executes dynamic Lua and must stay constrained to trusted or sandboxed code paths.
- `setContextSize(n)` and `setTemperature(t)` are convenience shortcuts for `setOption("num_ctx", n)` and `setOption("temperature", t)`. All backend parameters are forwarded through the `options` JSON object.
- `cancel(callback_id)` silently discards the response if the background thread has already completed. It does not interrupt an in-flight HTTP request.
- AISystem context assembly order: `system_prompt` → auto-matched skills → explicit instructions → agent description → agent system block (agent prompt + agent skills).
- `buildContext` returns the assembled string without dispatching a request; use it to inspect or log context before sending.
