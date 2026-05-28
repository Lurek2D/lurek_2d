//! Lua-facing runtime helpers for `lurek.agent`.
//!
//! - Data types: `AgentBatchTask`, `LuaAgentRuntime`, `LuaAgentManagerRuntime`, `LuaAISystemRuntime`.
//! - Function: `lua_to_json`.
//! - Implementations: `BatchDispatcher`, `LuaAgentRuntime`, `LuaAgentManagerRuntime`, `LuaAISystemRuntime`.
//! - Public methods: `from_lua_config`, `add_skill`, `clear_skills`, `set_option`, and 27 more.

use crate::agent::{AISystemState, AgentClient, AgentError, AgentRequest, AgentState};
use mlua::prelude::*;
use mlua::{Function, Lua, RegistryKey, Table, Value};
use std::collections::HashMap;
use std::rc::Rc;

// ─── BatchDispatcher ─────────────────────────────────────────────────────────

/// Accumulates in-flight batch requests and fires a single Lua callback when all tasks finish.
#[derive(Default)]
struct BatchDispatcher {
    /// Active batch states keyed by batch callback ID.
    callback_registry: HashMap<usize, BatchCallbackState>,
    /// Next batch callback ID to assign.
    next_callback_id: usize,
}

/// Per-batch bookkeeping stored in [`BatchDispatcher`] until all tasks complete.
struct BatchCallbackState {
    /// Registry key of the Lua function to call when the batch finishes.
    callback_key: RegistryKey,
    /// Number of tasks in this batch; when `results.len() == expected_count` the batch is done.
    expected_count: usize,
    /// Response format per task index, used when converting the body to a Lua value.
    formats: HashMap<usize, String>,
    /// Accumulated task results keyed by task index.
    results: HashMap<usize, Result<String, AgentError>>,
}

/// One queued batch task derived from an agent configuration.
pub(crate) struct AgentBatchTask {
    /// Position index used to key the result in the batch output table.
    pub(crate) agent_idx: usize,
    /// Instruction sent to the LLM.
    pub(crate) instruction: String,
    /// Agent state snapshot for this task.
    pub(crate) state: AgentState,
    /// Optional pre-built system block that overrides the agent's own context assembly.
    pub(crate) system_override: Option<String>,
}

impl BatchDispatcher {
    /// Creates an empty [`BatchDispatcher`] with the ID counter starting at 1.
    fn new() -> Self {
        Self {
            callback_registry: HashMap::new(),
            next_callback_id: 1,
        }
    }

    /// Allocates and returns the next monotonically increasing batch ID.
    fn next_id(&mut self) -> usize {
        let id = self.next_callback_id;
        self.next_callback_id += 1;
        id
    }

    /// Registers `tasks` under a new batch ID, queues requests, and returns `(batch_id, requests)`.
    ///
    /// If `tasks` is empty the callback is invoked immediately and `None` is returned.
    fn start_batch(
        &mut self,
        lua: &Lua,
        tasks: Vec<AgentBatchTask>,
        callback: Function,
    ) -> LuaResult<Option<(usize, Vec<AgentRequest>)>> {
        if tasks.is_empty() {
            callback.call::<_, ()>(lua.create_table()?)?;
            return Ok(None);
        }

        let batch_id = self.next_id();
        let mut formats = HashMap::new();
        let mut requests = Vec::with_capacity(tasks.len());

        for task in tasks {
            let packed_id = pack_batch_callback_id(batch_id, task.agent_idx);
            formats.insert(task.agent_idx, task.state.format.clone());
            let req = if let Some(sys) = task.system_override {
                task.state.to_request_with_system(task.instruction, sys, packed_id)
            } else {
                task.state.to_request(task.instruction, packed_id)
            };
            requests.push(req);
        }

        let callback_key = lua.create_registry_value(callback)?;
        self.callback_registry.insert(
            batch_id,
            BatchCallbackState {
                callback_key,
                expected_count: requests.len(),
                formats,
                results: HashMap::new(),
            },
        );

        Ok(Some((batch_id, requests)))
    }

    /// Records one task result; returns `true` when all expected results have arrived.
    fn store_response(
        &mut self,
        batch_id: usize,
        task_idx: usize,
        body: Result<String, AgentError>,
    ) -> bool {
        if let Some(state) = self.callback_registry.get_mut(&batch_id) {
            state.results.insert(task_idx, body);
            return state.results.len() == state.expected_count;
        }
        false
    }

    /// Finalises the batch: converts results to Lua, calls the callback, and removes the state.
    fn finish_batch(&mut self, lua: &Lua, batch_id: usize) -> LuaResult<()> {
        let Some(mut state) = self.callback_registry.remove(&batch_id) else {
            return Ok(());
        };

        let callback: Function = lua.registry_value(&state.callback_key)?;
        lua.remove_registry_value(state.callback_key)?;

        let out_table = lua.create_table()?;
        let mut keys = state.results.keys().copied().collect::<Vec<_>>();
        keys.sort_unstable();

        for idx in keys {
            let format = state
                .formats
                .get(&idx)
                .map(String::as_str)
                .unwrap_or("text");
            let result = state.results.remove(&idx).unwrap_or_else(|| {
                Err(AgentError::Model("missing batch result".to_string()))
            });
            let result_table = lua.create_table()?;
            let (success, data, err_info) = process_response(lua, format, result)?;
            result_table.set("success", success)?;
            result_table.set("data", data)?;
            result_table.set("error", err_info)?;
            out_table.set(idx as mlua::Integer, result_table)?;
        }

        callback.call::<_, ()>(out_table)?;
        Ok(())
    }
}

// ─── LuaAgentRuntime ─────────────────────────────────────────────────────────

/// Runtime state owned by a single Lua `LAgent` userdata.
pub(crate) struct LuaAgentRuntime {
    pub(crate) state: AgentState,
    /// Shared background HTTP client for this agent.
    client: Rc<AgentClient>,
    /// Single-prompt callbacks: callback_id -> (registry_key, format_string).
    callback_registry: HashMap<usize, (RegistryKey, String)>,
    /// Batch dispatcher for promptBatch calls.
    batch_dispatcher: BatchDispatcher,
    /// Next single-prompt callback ID to assign.
    next_callback_id: usize,
}

impl LuaAgentRuntime {
    /// Creates a Lua-facing runtime from a Lua configuration table.
    pub(crate) fn from_lua_config(config: Table) -> LuaResult<Self> {
        let url: String = config
            .get("url")
            .unwrap_or_else(|_| "http://127.0.0.1:11434/api/generate".to_string());
        let model: String = config
            .get("model")
            .unwrap_or_else(|_| "llama3".to_string());
        let system_prompt: String = config.get("system_prompt").unwrap_or_default();
        let format: String = config.get("format").unwrap_or_else(|_| "json".to_string());

        let mut options = HashMap::new();
        if let Ok(options_table) = config.get::<_, Table>("options") {
            for (key, value) in options_table.pairs::<String, Value>().flatten() {
                options.insert(key, lua_to_json(value)?);
            }
        }

        let mut state = AgentState::new(url, model, system_prompt, format, options);

        if let Ok(name) = config.get::<_, String>("name") {
            state.set_name(name);
        }
        if let Ok(description) = config.get::<_, String>("description") {
            state.set_description(description);
        }
        if let Ok(max_retries) = config.get::<_, u32>("max_retries") {
            state.set_max_retries(max_retries);
        }
        if let Ok(timeout) = config.get::<_, u64>("timeout") {
            state.set_timeout(timeout);
        }

        Ok(Self {
            state,
            client: Rc::new(AgentClient::new()),
            callback_registry: HashMap::new(),
            batch_dispatcher: BatchDispatcher::new(),
            next_callback_id: 1,
        })
    }

    /// Appends one named skill prompt to the runtime state.
    pub(crate) fn add_skill(&mut self, name: String, prompt: String) {
        self.state.add_skill(name, prompt);
    }

    /// Removes all registered skills from the runtime state.
    pub(crate) fn clear_skills(&mut self) {
        self.state.clear_skills();
    }

    /// Sets or updates a single model option (e.g. `temperature`, `seed`).
    pub(crate) fn set_option(&mut self, key: String, value: serde_json::Value) {
        self.state.set_option(key, value);
    }

    /// Changes the response format (`"json"`, `"csv"`, or `"text"`).
    pub(crate) fn set_format(&mut self, format: String) {
        self.state.format = format;
    }

    /// Sets the maximum retry count for transient errors.
    pub(crate) fn set_max_retries(&mut self, n: u32) {
        self.state.set_max_retries(n);
    }

    /// Sets the agent's display name (used when added to an AISystem).
    pub(crate) fn set_name(&mut self, name: String) {
        self.state.set_name(name);
    }

    /// Sets the agent's role description (injected by AISystem after the system prompt).
    pub(crate) fn set_description(&mut self, description: String) {
        self.state.set_description(description);
    }

    /// Cancels an in-flight or pending callback by ID, discarding its response.
    pub(crate) fn cancel(&self, callback_id: usize) {
        self.client.cancel(callback_id);
    }

    /// Returns the number of in-flight requests that have not yet completed.
    pub(crate) fn pending_count(&self) -> usize {
        self.client.in_flight_count()
    }

    /// Queues one asynchronous prompt and stores its Lua callback.
    pub(crate) fn prompt(
        &mut self,
        lua: &Lua,
        instruction: String,
        callback: Function,
    ) -> LuaResult<usize> {
        let callback_id = self.next_callback_id;
        self.next_callback_id += 1;

        let format = self.state.format.clone();
        let callback_key = lua.create_registry_value(callback)?;
        self.callback_registry.insert(callback_id, (callback_key, format));

        self.client
            .send_prompt(self.state.to_request(instruction, callback_id))
            .map_err(LuaError::runtime)?;

        Ok(callback_id)
    }

    /// Queues a batch of prompts that resolve through one Lua callback table.
    pub(crate) fn prompt_batch(
        &mut self,
        lua: &Lua,
        instructions: Table,
        callback: Function,
    ) -> LuaResult<usize> {
        let mut tasks = Vec::new();
        for pair in instructions.pairs::<mlua::Integer, String>() {
            let (idx, instruction) = pair?;
            tasks.push(self.make_batch_task(idx as usize, instruction));
        }

        let Some((batch_id, requests)) =
            self.batch_dispatcher.start_batch(lua, tasks, callback)?
        else {
            return Ok(0);
        };

        for request in requests {
            self.client.send_prompt(request).map_err(LuaError::runtime)?;
        }

        Ok(batch_id)
    }

    /// Polls completed prompt and batch responses and dispatches Lua callbacks.
    pub(crate) fn update(&mut self, lua: &Lua) -> LuaResult<()> {
        let responses = self.client.poll();

        for response in responses {
            if let Some((callback_key, format)) =
                self.callback_registry.remove(&response.callback_id)
            {
                let callback: Function = lua.registry_value(&callback_key)?;
                lua.remove_registry_value(callback_key)?;
                let (success, data, err_info) =
                    process_response(lua, &format, response.body)?;
                callback.call::<_, ()>((success, data, err_info))?;
                continue;
            }

            let (batch_id, task_idx) = unpack_batch_callback_id(response.callback_id);
            if batch_id == 0 {
                continue;
            }

            if self
                .batch_dispatcher
                .store_response(batch_id, task_idx, response.body)
            {
                self.batch_dispatcher.finish_batch(lua, batch_id)?;
            }
        }

        Ok(())
    }

    /// Executes Lua code inside the active VM and returns `true` on success.
    pub(crate) fn eval_code(&self, lua: &Lua, code: String) -> LuaResult<bool> {
        let chunk = lua.load(&code);
        match chunk.exec() {
            Ok(_) => Ok(true),
            Err(error) => Err(LuaError::RuntimeError(format!("Eval failed: {}", error))),
        }
    }

    /// Clones the current runtime state into one explicit batch task.
    pub(crate) fn make_batch_task(
        &self,
        agent_idx: usize,
        instruction: String,
    ) -> AgentBatchTask {
        AgentBatchTask {
            agent_idx,
            instruction,
            state: self.state.clone(),
            system_override: None,
        }
    }
}

// ─── LuaAgentManagerRuntime ──────────────────────────────────────────────────

/// Runtime state owned by a Lua `LAgentManager` userdata.
pub(crate) struct LuaAgentManagerRuntime {
    /// Shared background HTTP client for all managed agents.
    client: Rc<AgentClient>,
    /// Batch dispatcher for runAll calls.
    batch_dispatcher: BatchDispatcher,
}

impl LuaAgentManagerRuntime {
    /// Creates an empty batch manager runtime with its own background client.
    pub(crate) fn new() -> Self {
        Self {
            client: Rc::new(AgentClient::new()),
            batch_dispatcher: BatchDispatcher::new(),
        }
    }

    /// Dispatches explicit batch tasks and stores the shared Lua completion callback.
    pub(crate) fn run_all(
        &mut self,
        lua: &Lua,
        tasks: Vec<AgentBatchTask>,
        callback: Function,
    ) -> LuaResult<usize> {
        let Some((batch_id, requests)) = self.batch_dispatcher.start_batch(lua, tasks, callback)? else {
            return Ok(0);
        };

        for request in requests {
            self.client.send_prompt(request).map_err(LuaError::runtime)?;
        }

        Ok(batch_id)
    }

    /// Polls completed manager batch responses and dispatches the batch callback.
    pub(crate) fn update(&mut self, lua: &Lua) -> LuaResult<()> {
        let responses = self.client.poll();
        for response in responses {
            let (batch_id, task_idx) = unpack_batch_callback_id(response.callback_id);
            if batch_id == 0 {
                continue;
            }

            if self
                .batch_dispatcher
                .store_response(batch_id, task_idx, response.body)
            {
                self.batch_dispatcher.finish_batch(lua, batch_id)?;
            }
        }

        Ok(())
    }
}

// ─── LuaAISystemRuntime ──────────────────────────────────────────────────────

/// Runtime state owned by a Lua `LAISystem` userdata.
pub(crate) struct LuaAISystemRuntime {
    /// Shared orchestration state (system prompt, instructions, system skills).
    pub(crate) system_state: AISystemState,
    /// Registered agents keyed by the name supplied to `addAgent`.
    agents: HashMap<String, AgentState>,
    /// Shared background HTTP client for all system-routed prompts.
    client: Rc<AgentClient>,
    /// Single-prompt callbacks: callback_id -> (registry_key, format_string).
    callback_registry: HashMap<usize, (RegistryKey, String)>,
    /// Batch dispatcher for runAll calls.
    batch_dispatcher: BatchDispatcher,
    /// Next single-prompt callback ID to assign.
    next_callback_id: usize,
}

impl LuaAISystemRuntime {
    /// Creates a new `LuaAISystemRuntime` from a Lua configuration table.
    pub(crate) fn from_lua_config(config: Table) -> LuaResult<Self> {
        let system_prompt: String = config.get("system_prompt").unwrap_or_default();
        Ok(Self {
            system_state: AISystemState::new(system_prompt),
            agents: HashMap::new(),
            client: Rc::new(AgentClient::new()),
            callback_registry: HashMap::new(),
            batch_dispatcher: BatchDispatcher::new(),
            next_callback_id: 1,
        })
    }

    /// Adds an agent to the system under the given name.
    pub(crate) fn add_agent(&mut self, name: String, state: AgentState) {
        self.agents.insert(name, state);
    }

    /// Removes an agent by name. Returns `true` if it existed.
    pub(crate) fn remove_agent(&mut self, name: &str) -> bool {
        self.agents.remove(name).is_some()
    }

    /// Returns a snapshot of registered agent names.
    pub(crate) fn list_agents(&self) -> Vec<String> {
        let mut names: Vec<String> = self.agents.keys().cloned().collect();
        names.sort();
        names
    }

    /// Adds or replaces a named instruction block.
    pub(crate) fn add_instruction(&mut self, key: String, text: String) {
        self.system_state.add_instruction(key, text);
    }

    /// Removes an instruction by key.
    pub(crate) fn remove_instruction(&mut self, key: String) -> bool {
        self.system_state.remove_instruction(&key)
    }

    /// Adds a keyword-gated skill. Replaces an existing skill with the same name.
    pub(crate) fn add_system_skill(
        &mut self,
        name: String,
        keywords: Vec<String>,
        prompt: String,
    ) {
        self.system_state.add_system_skill(name, keywords, prompt);
    }

    /// Removes a system skill by name.
    pub(crate) fn remove_system_skill(&mut self, name: String) -> bool {
        self.system_state.remove_system_skill(&name)
    }

    /// Builds the system context block that would be sent for `instruction`; used by `buildContext` and routing.
    pub(crate) fn build_context(
        &self,
        instruction: &str,
        include_instructions: &[String],
        agent_name: Option<&str>,
    ) -> String {
        let mut block = self
            .system_state
            .build_context(instruction, include_instructions);

        if let Some(name) = agent_name {
            if let Some(agent) = self.agents.get(name) {
                if !agent.description.is_empty() {
                    block.push_str(&format!(
                        "\n\n[Agent: {}]:\n{}",
                        name, agent.description
                    ));
                }
                let agent_system = agent.build_system_block();
                if !agent_system.is_empty() {
                    block.push_str(&format!("\n\n{}", agent_system));
                }
            }
        }

        block
    }

    /// Sends a single prompt to a named agent through the system, auto-injecting context.
    pub(crate) fn prompt(
        &mut self,
        lua: &Lua,
        agent_name: String,
        instruction: String,
        callback: Function,
        include_instructions: Vec<String>,
    ) -> LuaResult<usize> {
        let agent = self
            .agents
            .get(&agent_name)
            .ok_or_else(|| LuaError::runtime(format!("agent '{}' not found", agent_name)))?
            .clone();

        let system_block = self.build_context(&instruction, &include_instructions, Some(&agent_name));

        let callback_id = self.next_callback_id;
        self.next_callback_id += 1;

        let format = agent.format.clone();
        let callback_key = lua.create_registry_value(callback)?;
        self.callback_registry.insert(callback_id, (callback_key, format));

        let req = agent.to_request_with_system(instruction, system_block, callback_id);
        self.client.send_prompt(req).map_err(LuaError::runtime)?;

        Ok(callback_id)
    }

    /// Dispatches batch tasks built from named agents with auto-injected system context.
    pub(crate) fn run_all(
        &mut self,
        lua: &Lua,
        tasks: Vec<AgentBatchTask>,
        callback: Function,
    ) -> LuaResult<usize> {
        let Some((batch_id, requests)) =
            self.batch_dispatcher.start_batch(lua, tasks, callback)?
        else {
            return Ok(0);
        };

        for request in requests {
            self.client.send_prompt(request).map_err(LuaError::runtime)?;
        }

        Ok(batch_id)
    }

    /// Builds an `AgentBatchTask` for a named agent, injecting system context.
    pub(crate) fn make_system_task(
        &self,
        agent_name: &str,
        task_idx: usize,
        instruction: String,
        include_instructions: &[String],
    ) -> LuaResult<AgentBatchTask> {
        let agent = self
            .agents
            .get(agent_name)
            .ok_or_else(|| LuaError::runtime(format!("agent '{}' not found", agent_name)))?
            .clone();

        let system_block = self.build_context(&instruction, include_instructions, Some(agent_name));

        Ok(AgentBatchTask {
            agent_idx: task_idx,
            instruction,
            state: agent,
            system_override: Some(system_block),
        })
    }

    /// Polls all completed system responses and dispatches Lua callbacks.
    pub(crate) fn update(&mut self, lua: &Lua) -> LuaResult<()> {
        let responses = self.client.poll();

        for response in responses {
            if let Some((callback_key, format)) =
                self.callback_registry.remove(&response.callback_id)
            {
                let callback: Function = lua.registry_value(&callback_key)?;
                lua.remove_registry_value(callback_key)?;
                let (success, data, err_info) =
                    process_response(lua, &format, response.body)?;
                callback.call::<_, ()>((success, data, err_info))?;
                continue;
            }

            let (batch_id, task_idx) = unpack_batch_callback_id(response.callback_id);
            if batch_id == 0 {
                continue;
            }

            if self
                .batch_dispatcher
                .store_response(batch_id, task_idx, response.body)
            {
                self.batch_dispatcher.finish_batch(lua, batch_id)?;
            }
        }

        Ok(())
    }
}

// ─── Private helpers ─────────────────────────────────────────────────────────

/// Encodes `(batch_id, task_idx)` into a single callback ID by packing into the upper/lower halves.
fn pack_batch_callback_id(batch_id: usize, task_idx: usize) -> usize {
    (batch_id * 1000) + task_idx
}

/// Decodes a packed callback ID back into `(batch_id, task_idx)`.
fn unpack_batch_callback_id(callback_id: usize) -> (usize, usize) {
    (callback_id / 1000, callback_id % 1000)
}

/// Recursively converts a `serde_json::Value` into a Lua value.
fn json_to_lua<'lua>(lua: &'lua Lua, value: &serde_json::Value) -> LuaResult<Value<'lua>> {
    match value {
        serde_json::Value::Null => Ok(Value::Nil),
        serde_json::Value::Bool(value) => Ok(Value::Boolean(*value)),
        serde_json::Value::Number(value) => match value.as_f64() {
            Some(value) => Ok(Value::Number(value)),
            None => Ok(Value::Nil),
        },
        serde_json::Value::String(value) => Ok(Value::String(lua.create_string(value)?)),
        serde_json::Value::Array(values) => {
            let table = lua.create_table()?;
            for (idx, value) in values.iter().enumerate() {
                table.set(idx + 1, json_to_lua(lua, value)?)?;
            }
            Ok(Value::Table(table))
        }
        serde_json::Value::Object(values) => {
            let table = lua.create_table()?;
            for (key, value) in values {
                table.set(key.as_str(), json_to_lua(lua, value)?)?;
            }
            Ok(Value::Table(table))
        }
    }
}

pub(crate) fn lua_to_json(value: Value) -> LuaResult<serde_json::Value> {
    match value {
        Value::Nil => Ok(serde_json::Value::Null),
        Value::Boolean(value) => Ok(serde_json::Value::Bool(value)),
        Value::Integer(value) => Ok(serde_json::json!(value)),
        Value::Number(value) => Ok(serde_json::json!(value)),
        Value::String(value) => Ok(serde_json::Value::String(value.to_str()?.to_string())),
        Value::Table(value) => {
            if value.contains_key(1)? {
                let mut array = Vec::new();
                for pair in value.pairs::<Value, Value>() {
                    let (_, item) = pair?;
                    array.push(lua_to_json(item)?);
                }
                Ok(serde_json::Value::Array(array))
            } else {
                let mut object = serde_json::Map::new();
                for pair in value.pairs::<String, Value>() {
                    let (key, item) = pair?;
                    object.insert(key, lua_to_json(item)?);
                }
                Ok(serde_json::Value::Object(object))
            }
        }
        _ => Ok(serde_json::Value::Null),
    }
}

/// Converts a CSV-formatted string into a Lua table of row tables keyed by header name.
fn parse_csv_to_lua<'lua>(lua: &'lua Lua, csv_data: &str) -> LuaResult<Value<'lua>> {
    let mut reader = csv::ReaderBuilder::new()
        .has_headers(true)
        .from_reader(csv_data.as_bytes());

    let headers = reader
        .headers()
        .map_err(|error| LuaError::RuntimeError(format!("CSV headers error: {}", error)))?
        .clone();

    let rows = lua.create_table()?;
    let mut row_idx = 1;
    for record in reader.records() {
        let record =
            record.map_err(|error| LuaError::RuntimeError(format!("CSV record error: {}", error)))?;
        let row = lua.create_table()?;
        for (idx, value) in record.iter().enumerate() {
            if let Some(header) = headers.get(idx) {
                row.set(header, value)?;
            }
        }
        rows.set(row_idx, row)?;
        row_idx += 1;
    }

    Ok(Value::Table(rows))
}

/// Parses an agent response body according to `format` and returns `(success, data, error_info)`.
fn process_response<'lua>(
    lua: &'lua Lua,
    format: &str,
    body: Result<String, AgentError>,
) -> LuaResult<(bool, Value<'lua>, Value<'lua>)> {
    match body {
        Ok(body) if format == "json" => match serde_json::from_str::<serde_json::Value>(&body) {
            Ok(value) => Ok((true, json_to_lua(lua, &value)?, Value::Nil)),
            Err(error) => Ok((
                false,
                Value::Nil,
                error_table(lua, "PARSE_ERROR", format!("Invalid JSON: {}", error))?,
            )),
        },
        Ok(body) if format == "csv" => match parse_csv_to_lua(lua, &body) {
            Ok(value) => Ok((true, value, Value::Nil)),
            Err(error) => Ok((
                false,
                Value::Nil,
                error_table(lua, "PARSE_ERROR", error.to_string())?,
            )),
        },
        Ok(body) => Ok((true, Value::String(lua.create_string(&body)?), Value::Nil)),
        Err(error) => Ok((
            false,
            Value::Nil,
            error_table(lua, error.code(), error.to_string())?,
        )),
    }
}

/// Builds a Lua error-info table with `code` and `message` fields.
fn error_table<'lua>(lua: &'lua Lua, code: &str, message: impl AsRef<str>) -> LuaResult<Value<'lua>> {
    let table = lua.create_table()?;
    table.set("code", code)?;
    table.set("message", message.as_ref())?;
    Ok(Value::Table(table))
}
