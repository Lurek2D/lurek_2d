//! `lurek.agent` -- Agent bindings for LLM and VM integration.
//!
//! - Registers `lurek.agent.*` functions and types via `register()`.
//! - Bridges 43 Lua-callable methods via `mlua`.
//! - See `docs/specs/agent.md` for the full API specification.

use crate::agent::{
    AgentBatchTask, AgentMemory, EpisodicMemory, GlobalLlmConfig, LlmChat, LlmTemplate,
    LuaAgentManagerRuntime, LuaAgentRuntime, LuaAISystemRuntime, OllamaManager, SemanticMemory,
    WorkingMemory, lua_to_json, read_global_config, write_global_config,
};
use crate::agent::chat::{ollama_embed, ollama_generate, ollama_generate_json, ollama_is_available, ollama_list_models};
use crate::runtime::SharedState;
use mlua::prelude::*;
use mlua::{AnyUserData, UserData, UserDataMethods};
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

// ─── LuaAgent ────────────────────────────────────────────────────────────────

/// Lua-side handle for a single LLM Agent.
pub struct LuaAgent {
    runtime: LuaAgentRuntime,
}

impl UserData for LuaAgent {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // ─── addSkill ───
        /// Appends a named skill prompt to the agent's context block.
        /// @param | name | string | Unique skill identifier shown in the injected context.
        /// @param | prompt | string | Instruction text appended to the system block.
        /// @return | nil | No value is returned.
        methods.add_method_mut("addSkill", |_, this, (name, prompt): (String, String)| {
            this.runtime.add_skill(name, prompt);
            Ok(())
        });

        // ─── clearSkills ───
        /// Removes all registered skills from the agent's context.
        /// @return | nil | No value is returned.
        methods.add_method_mut("clearSkills", |_, this, ()| {
            this.runtime.clear_skills();
            Ok(())
        });

        // ─── setOption ───
        /// Sets a single model option forwarded to the LLM backend.
        /// @param | key | string | Option name (e.g. `"temperature"`, `"seed"`, `"num_ctx"`).
        /// @param | value | any | Option value forwarded as JSON.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setOption", |_, this, (key, value): (String, mlua::Value)| {
            let json_val = lua_to_json(value)?;
            this.runtime.set_option(key, json_val);
            Ok(())
        });

        // ─── setFormat ───
        /// Changes the response format for future prompts.
        /// @param | format | string | One of `"json"`, `"csv"`, or `"text"`.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setFormat", |_, this, format: String| {
            this.runtime.set_format(format);
            Ok(())
        });

        // ─── setMaxRetries ───
        /// Sets the maximum retry count on transient network or timeout errors.
        /// @param | n | integer | Number of retries (0 disables retry).
        /// @return | nil | No value is returned.
        methods.add_method_mut("setMaxRetries", |_, this, n: u32| {
            this.runtime.set_max_retries(n);
            Ok(())
        });

        // ─── setContextSize ───
        /// Sets the token context window size forwarded to the LLM backend.
        /// @param | n | integer | Context size in tokens (e.g. 4096).
        /// @return | nil | No value is returned.
        methods.add_method_mut("setContextSize", |_, this, n: u32| {
            this.runtime.set_option("num_ctx".to_string(), serde_json::json!(n));
            Ok(())
        });

        // ─── setTemperature ───
        /// Sets the sampling temperature forwarded to the LLM backend.
        /// @param | t | number | Temperature value (e.g. 0.7). Higher = more random.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setTemperature", |_, this, t: f64| {
            this.runtime.set_option("temperature".to_string(), serde_json::json!(t));
            Ok(())
        });

        // ─── setName ───
        /// Sets the agent's name identifier used when added to an AISystem.
        /// @param | name | string | Agent name.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setName", |_, this, name: String| {
            this.runtime.set_name(name);
            Ok(())
        });

        // ─── setDescription ───
        /// Sets the agent's role description injected after the system prompt when routed through an AISystem.
        /// @param | description | string | Role description text.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setDescription", |_, this, description: String| {
            this.runtime.set_description(description);
            Ok(())
        });

        // ─── setModel ───
        /// Changes the model identifier for future prompts.
        /// @param | model | string | Model name (e.g. `"llama3"`, `"mistral"`).
        /// @return | nil | No value is returned.
        methods.add_method_mut("setModel", |_, this, model: String| {
            this.runtime.set_model(model);
            Ok(())
        });

        // ─── setUrl ───
        /// Changes the LLM endpoint URL for future prompts.
        /// @param | url | string | Full endpoint URL (e.g. `"http://127.0.0.1:11434/api/generate"`).
        /// @return | nil | No value is returned.
        methods.add_method_mut("setUrl", |_, this, url: String| {
            this.runtime.set_url(url);
            Ok(())
        });

        // ─── setTimeout ───
        /// Sets the per-request timeout in seconds (0 uses the default 60 s).
        /// @param | secs | integer | Timeout in seconds.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setTimeout", |_, this, secs: u64| {
            this.runtime.set_timeout(secs);
            Ok(())
        });

        // ─── getName ───
        /// Returns the agent's name identifier.
        /// @return | string | Agent name, or `""` if not set.
        methods.add_method("getName", |_, this, ()| {
            Ok(this.runtime.get_name().to_string())
        });

        // ─── getDescription ───
        /// Returns the agent's role description.
        /// @return | string | Role description, or `""` if not set.
        methods.add_method("getDescription", |_, this, ()| {
            Ok(this.runtime.get_description().to_string())
        });

        // ─── getModel ───
        /// Returns the current model identifier.
        /// @return | string | Model name.
        methods.add_method("getModel", |_, this, ()| {
            Ok(this.runtime.get_model().to_string())
        });

        // ─── getUrl ───
        /// Returns the current LLM endpoint URL.
        /// @return | string | Endpoint URL.
        methods.add_method("getUrl", |_, this, ()| {
            Ok(this.runtime.get_url().to_string())
        });

        // ─── getFormat ───
        /// Returns the current response format string.
        /// @return | string | One of `"json"`, `"csv"`, or `"text"`.
        methods.add_method("getFormat", |_, this, ()| {
            Ok(this.runtime.get_format().to_string())
        });

        // ─── hasSkill ───
        /// Returns `true` if a skill with `name` is registered.
        /// @param | name | string | Skill name to check.
        /// @return | boolean | `true` if the skill exists.
        methods.add_method("hasSkill", |_, this, name: String| {
            Ok(this.runtime.has_skill(&name))
        });

        // ─── skillCount ───
        /// Returns the number of registered skills.
        /// @return | integer | Skill count.
        methods.add_method("skillCount", |_, this, ()| {
            Ok(this.runtime.skill_count())
        });

        // ─── listSkills ───
        /// Returns a list of registered skill names in insertion order.
        /// @return | table | String array of skill names.
        methods.add_method("listSkills", |lua, this, ()| {
            let names = this.runtime.list_skills();
            let tbl = lua.create_table()?;
            for (i, name) in names.into_iter().enumerate() {
                tbl.set(i + 1, name)?;
            }
            Ok(tbl)
        });

        // ─── prompt ───
        /// Sends an instructional prompt to the LLM asynchronously.
        /// @param | instruction | string | The specific task instruction for the agent.
        /// @param | callback | function | Function called with `(success, data, err_info)` when complete.
        /// @return | integer | Callback ID used to cancel the request.
        methods.add_method_mut(
            "prompt",
            |lua, this, (instruction, callback): (String, mlua::Function)| {
                this.runtime.prompt(lua, instruction, callback)
            },
        );

        // ─── promptBatch ───
        /// Sends a batch of prompts to the LLM asynchronously.
        /// @param | instructions | table | Ordered list of instruction strings.
        /// @param | callback | function | Function called with a results table when all complete.
        /// @return | integer | Batch callback ID.
        methods.add_method_mut(
            "promptBatch",
            |lua, this, (instructions, callback): (mlua::Table, mlua::Function)| {
                this.runtime.prompt_batch(lua, instructions, callback)
            },
        );

        // ─── cancel ───
        /// Cancels an in-flight or pending request by callback ID.
        /// @param | callback_id | integer | ID returned by `prompt` or `promptBatch`.
        /// @return | nil | No value is returned.
        methods.add_method("cancel", |_, this, callback_id: usize| {
            this.runtime.cancel(callback_id);
            Ok(())
        });

        // ─── pendingCount ───
        /// Returns the number of in-flight requests that have not yet completed.
        /// @return | integer | Number of pending requests.
        methods.add_method("pendingCount", |_, this, ()| {
            Ok(this.runtime.pending_count())
        });

        // ─── update ───
        /// Polls the background client for completed LLM requests and dispatches callbacks.
        /// @return | nil | No value is returned.
        methods.add_method_mut("update", |lua, this, ()| this.runtime.update(lua));

        // ─── evalCode ───
        /// Evaluates a Lua code string inside the active VM.
        /// @param | code | string | The Lua code to execute.
        /// @return | boolean | `true` on success, raises an error on failure.
        methods.add_method("evalCode", |lua, this, code: String| {
            this.runtime.eval_code(lua, code)
        });
    }
}

// ─── LuaAgentManager ─────────────────────────────────────────────────────────

/// Lua-side handle for managing multiple LLM Agents in parallel.
pub struct LuaAgentManager {
    runtime: LuaAgentManagerRuntime,
}

impl UserData for LuaAgentManager {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // ─── runAll ───
        /// Runs multiple agent tasks in parallel and calls a single callback when all finish.
        /// @param | tasks | table | List of `{ agent = LAgent, instruction = string }` tables.
        /// @param | callback | function | Function called with a results table when all tasks complete.
        /// @return | integer | Batch callback ID.
        methods.add_method_mut(
            "runAll",
            |lua, this, (tasks, callback): (mlua::Table, mlua::Function)| {
                let mut manager_tasks: Vec<AgentBatchTask> = Vec::new();
                for pair in tasks.pairs::<mlua::Integer, mlua::Table>() {
                    let (idx, task_tbl) = pair?;
                    let agent_ud: AnyUserData = task_tbl.get("agent")?;
                    let instruction: String = task_tbl.get("instruction")?;
                    let agent = agent_ud.borrow::<LuaAgent>()?;
                    manager_tasks.push(agent.runtime.make_batch_task(idx as usize, instruction));
                }
                this.runtime.run_all(lua, manager_tasks, callback)
            },
        );

        // ─── update ───
        /// Polls the manager's background client for completed tasks and dispatches callbacks.
        /// @return | nil | No value is returned.
        methods.add_method_mut("update", |lua, this, ()| this.runtime.update(lua));
    }
}

// ─── LuaAISystem ─────────────────────────────────────────────────────────────

/// Lua-side handle for an AISystem multi-agent orchestrator.
pub struct LuaAISystem {
    runtime: LuaAISystemRuntime,
}

impl UserData for LuaAISystem {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // ─── addAgent ───
        /// Registers a named agent in the system.
        /// @param | name | string | Unique agent name used for routing.
        /// @param | agent | LAgent | The agent instance to register.
        /// @return | nil | No value is returned.
        methods.add_method_mut("addAgent", |_, this, (name, agent_ud): (String, AnyUserData)| {
            let agent = agent_ud.borrow::<LuaAgent>()?;
            this.runtime.add_agent(name, agent.runtime.state.clone());
            Ok(())
        });

        // ─── removeAgent ───
        /// Removes a registered agent by name.
        /// @param | name | string | Agent name to remove.
        /// @return | boolean | `true` if the agent was found and removed.
        methods.add_method_mut("removeAgent", |_, this, name: String| {
            Ok(this.runtime.remove_agent(&name))
        });

        // ─── listAgents ───
        /// Returns a sorted list of all registered agent names.
        /// @return | table | String array of agent names.
        methods.add_method("listAgents", |lua, this, ()| {
            let names = this.runtime.list_agents();
            let tbl = lua.create_table()?;
            for (i, name) in names.into_iter().enumerate() {
                tbl.set(i + 1, name)?;
            }
            Ok(tbl)
        });

        // ─── hasAgent ───
        /// Returns `true` if an agent with `name` is registered.
        /// @param | name | string | Agent name to check.
        /// @return | boolean | `true` if the agent exists.
        methods.add_method("hasAgent", |_, this, name: String| {
            Ok(this.runtime.has_agent(&name))
        });

        // ─── agentCount ───
        /// Returns the number of registered agents.
        /// @return | integer | Agent count.
        methods.add_method("agentCount", |_, this, ()| {
            Ok(this.runtime.agent_count())
        });

        // ─── addInstruction ───
        /// Adds a named instruction block the user can explicitly include per prompt.
        /// @param | key | string | Unique instruction identifier.
        /// @param | text | string | Instruction text injected into the system block.
        /// @return | nil | No value is returned.
        methods.add_method_mut("addInstruction", |_, this, (key, text): (String, String)| {
            this.runtime.add_instruction(key, text);
            Ok(())
        });

        // ─── removeInstruction ───
        /// Removes an instruction block by key.
        /// @param | key | string | Instruction key to remove.
        /// @return | boolean | `true` if the instruction was found and removed.
        methods.add_method_mut("removeInstruction", |_, this, key: String| {
            Ok(this.runtime.remove_instruction(key))
        });

        // ─── hasInstruction ───
        /// Returns `true` if an instruction with `key` is registered.
        /// @param | key | string | Instruction key to check.
        /// @return | boolean | `true` if the instruction exists.
        methods.add_method("hasInstruction", |_, this, key: String| {
            Ok(this.runtime.has_instruction(&key))
        });

        // ─── instructionCount ───
        /// Returns the number of registered instruction blocks.
        /// @return | integer | Instruction count.
        methods.add_method("instructionCount", |_, this, ()| {
            Ok(this.runtime.instruction_count())
        });

        // ─── listInstructions ───
        /// Returns a list of registered instruction keys in insertion order.
        /// @return | table | String array of instruction keys.
        methods.add_method("listInstructions", |lua, this, ()| {
            let keys = this.runtime.list_instructions();
            let tbl = lua.create_table()?;
            for (i, key) in keys.into_iter().enumerate() {
                tbl.set(i + 1, key)?;
            }
            Ok(tbl)
        });

        // ─── addSkill ───
        /// Adds a keyword-gated system skill that Lurek auto-injects when the prompt overlaps with its keywords.
        /// @param | name | string | Skill identifier shown in the injected context.
        /// @param | keywords | table | String array of trigger keywords (case-insensitive match).
        /// @param | prompt | string | Instruction text appended when a keyword matches.
        /// @return | nil | No value is returned.
        methods.add_method_mut(
            "addSkill",
            |_, this, (name, keywords_tbl, prompt): (String, mlua::Table, String)| {
                let mut keywords = Vec::new();
                for pair in keywords_tbl.pairs::<mlua::Integer, String>() {
                    let (_, kw) = pair?;
                    keywords.push(kw);
                }
                this.runtime.add_system_skill(name, keywords, prompt);
                Ok(())
            },
        );

        // ─── removeSkill ───
        /// Removes a system skill by name.
        /// @param | name | string | Skill name to remove.
        /// @return | boolean | `true` if the skill was found and removed.
        methods.add_method_mut("removeSkill", |_, this, name: String| {
            Ok(this.runtime.remove_system_skill(name))
        });

        // ─── hasSkill ───
        /// Returns `true` if a system skill with `name` is registered.
        /// @param | name | string | Skill name to check.
        /// @return | boolean | `true` if the skill exists.
        methods.add_method("hasSkill", |_, this, name: String| {
            Ok(this.runtime.has_system_skill(&name))
        });

        // ─── skillCount ───
        /// Returns the number of registered system skills.
        /// @return | integer | Skill count.
        methods.add_method("skillCount", |_, this, ()| {
            Ok(this.runtime.system_skill_count())
        });

        // ─── buildContext ───
        /// Builds and returns the full context string that would be sent for a given prompt.
        /// @param | instruction | string | The prompt text used for keyword matching.
        /// @param | opts | table | Optional table with `agent` (string) and `instructions` (table) keys.
        /// @return | string | The assembled system context block.
        methods.add_method("buildContext", |_, this, (instruction, opts): (String, Option<mlua::Table>)| {
            let mut include = Vec::new();
            let mut agent_name = None;
            if let Some(opts_tbl) = opts {
                if let Ok(inst_list) = opts_tbl.get::<_, mlua::Table>("instructions") {
                    for pair in inst_list.pairs::<mlua::Integer, String>() {
                        let (_, k) = pair?;
                        include.push(k);
                    }
                }
                if let Ok(name) = opts_tbl.get::<_, String>("agent") {
                    agent_name = Some(name);
                }
            }
            Ok(this.runtime.build_context(&instruction, &include, agent_name.as_deref()))
        });

        // ─── prompt ───
        /// Sends a prompt to a named agent through the system, auto-injecting matching context.
        /// @param | agent_name | string | Name of the agent to query.
        /// @param | instruction | string | The task instruction for the agent.
        /// @param | callback | function | Function called with `(success, data, err_info)` when complete.
        /// @param | opts | table | Optional: `{ instructions = {"key1", ...} }` to include manually.
        /// @return | integer | Callback ID.
        methods.add_method_mut(
            "prompt",
            |lua,
             this,
             (agent_name, instruction, callback, opts): (
                String,
                String,
                mlua::Function,
                Option<mlua::Table>,
            )| {
                let mut include = Vec::new();
                if let Some(opts_tbl) = opts {
                    if let Ok(inst_list) = opts_tbl.get::<_, mlua::Table>("instructions") {
                        for pair in inst_list.pairs::<mlua::Integer, String>() {
                            let (_, k) = pair?;
                            include.push(k);
                        }
                    }
                }
                this.runtime.prompt(lua, agent_name, instruction, callback, include)
            },
        );

        // ─── runAll ───
        /// Dispatches multiple named-agent tasks in parallel through the system.
        /// @param | tasks | table | List of `{ agent = string, instruction = string, instructions = table? }`.
        /// @param | callback | function | Function called with a results table when all tasks complete.
        /// @return | integer | Batch callback ID.
        methods.add_method_mut(
            "runAll",
            |lua, this, (tasks, callback): (mlua::Table, mlua::Function)| {
                let mut system_tasks: Vec<AgentBatchTask> = Vec::new();
                for pair in tasks.pairs::<mlua::Integer, mlua::Table>() {
                    let (idx, task_tbl) = pair?;
                    let agent_name: String = task_tbl.get("agent")?;
                    let instruction: String = task_tbl.get("instruction")?;
                    let mut include = Vec::new();
                    if let Ok(inst_list) = task_tbl.get::<_, mlua::Table>("instructions") {
                        for pair in inst_list.pairs::<mlua::Integer, String>() {
                            let (_, k) = pair?;
                            include.push(k);
                        }
                    }
                    system_tasks.push(this.runtime.make_system_task(
                        &agent_name,
                        idx as usize,
                        instruction,
                        &include,
                    )?);
                }
                this.runtime.run_all(lua, system_tasks, callback)
            },
        );

        // ─── update ───
        /// Polls the system's background client for completed requests and dispatches callbacks.
        /// @return | nil | No value is returned.
        methods.add_method_mut("update", |lua, this, ()| this.runtime.update(lua));
    }
}

// ─── LuaOllamaManager ───────────────────────────────────────────────────────────

/// Lua-side handle for managing a local Ollama server lifecycle and models.
pub struct LuaOllamaManager {
    /// Underlying Ollama infrastructure manager.
    manager: OllamaManager,
    /// Pull callbacks keyed by callback ID returned from `pullModel`.
    callback_registry: HashMap<usize, mlua::RegistryKey>,
}

impl UserData for LuaOllamaManager {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // ─── isRunning ───
        /// Returns `true` if the Ollama HTTP server responds within 5 seconds.
        /// @return | boolean | `true` if Ollama is reachable.
        methods.add_method("isRunning", |_, this, ()| {
            Ok(this.manager.is_running())
        });

        // ─── version ───
        /// Returns the Ollama version string, or an empty string if not running.
        /// @return | string | Ollama version or `""`.
        methods.add_method("version", |_, this, ()| {
            Ok(this.manager.version())
        });

        // ─── baseUrl ───
        /// Returns the base URL this manager was created with.
        /// @return | string | Base URL (e.g. `"http://127.0.0.1:11434"`).
        methods.add_method("baseUrl", |_, this, ()| {
            Ok(this.manager.base_url().to_string())
        });

        // ─── listModels ───
        /// Returns a table of locally available models, each with `name` and `size_gb` fields.
        /// @return | table | Array of `{ name = string, size_gb = number }` tables.
        methods.add_method("listModels", |lua, this, ()| {
            let models = this.manager.list_models();
            let tbl = lua.create_table()?;
            for (i, m) in models.into_iter().enumerate() {
                let entry = lua.create_table()?;
                entry.set("name", m.name)?;
                entry.set("size_gb", m.size_gb)?;
                tbl.set(i + 1, entry)?;
            }
            Ok(tbl)
        });

        // ─── modelNames ───
        /// Returns a string array of locally available model names; empty if Ollama is not running.
        /// @return | table | String array of model names.
        methods.add_method("modelNames", |lua, this, ()| {
            let names = this.manager.model_names();
            let tbl = lua.create_table()?;
            for (i, name) in names.into_iter().enumerate() {
                tbl.set(i + 1, name)?;
            }
            Ok(tbl)
        });

        // ─── hasModel ───
        /// Returns `true` if a model with the given name (or name prefix) is available locally.
        /// @param | name | string | Model name to check (e.g. `"llama3"` or `"llama3:latest"`).
        /// @return | boolean | `true` if found locally.
        methods.add_method("hasModel", |_, this, name: String| {
            Ok(this.manager.has_model(&name))
        });

        // ─── start ───
        /// Spawns `ollama serve` as a managed child process. Returns `true` on success.
        /// @return | boolean | `true` if the process started.
        methods.add_method_mut("start", |_, this, ()| {
            Ok(this.manager.start())
        });

        // ─── stop ───
        /// Kills the Ollama process started by this manager. Returns `true` if it was running.
        /// @return | boolean | `true` if the process was running under this manager.
        methods.add_method_mut("stop", |_, this, ()| {
            Ok(this.manager.stop())
        });

        // ─── restart ───
        /// Stops then restarts the managed Ollama process. Returns `true` on success.
        /// @return | boolean | `true` if the restart succeeded.
        methods.add_method_mut("restart", |_, this, ()| {
            Ok(this.manager.restart())
        });

        // ─── pullModel ───
        /// Dispatches an async model download; calls `callback(success, err_msg)` on completion.
        /// @param | name | string | Model name to download (e.g. `"llama3"`).
        /// @param | callback | function | Called with `(success, err_msg)` on completion.
        /// @return | integer | Callback ID used with `update()`.
        methods.add_method_mut(
            "pullModel",
            |lua, this, (name, callback): (String, mlua::Function)| {
                let callback_id = this.manager.pull_model(name);
                let key = lua.create_registry_value(callback)?;
                this.callback_registry.insert(callback_id, key);
                Ok(callback_id)
            },
        );

        // ─── deleteModel ───
        /// Sends `DELETE /api/delete` to remove a model from local Ollama storage.
        /// @param | name | string | Model name to delete (e.g. `"llama3:latest"`).
        /// @return | boolean | `true` if the request succeeded.
        methods.add_method("deleteModel", |_, this, name: String| {
            Ok(this.manager.delete_model(&name))
        });

        // ─── pendingCount ───
        /// Returns the number of in-flight model pull operations.
        /// @return | integer | Number of pending pulls.
        methods.add_method("pendingCount", |_, this, ()| {
            Ok(this.manager.in_flight_count())
        });

        // ─── update ───
        /// Polls completed pull operations and dispatches registered callbacks.
        /// @return | nil | No value is returned.
        methods.add_method_mut("update", |lua, this, ()| {
            let results = this.manager.poll();
            for result in results {
                if let Some(key) = this.callback_registry.remove(&result.callback_id) {
                    let callback: mlua::Function = lua.registry_value(&key)?;
                    lua.remove_registry_value(key)?;
                    match result.result {
                        Ok(()) => callback.call::<_, ()>((true, mlua::Value::Nil))?,
                        Err(msg) => callback.call::<_, ()>((false, msg))?,
                    }
                }
            }
            Ok(())
        });
    }
}

// ─── LuaAgentChat ────────────────────────────────────────────────────────────

/// Lua-side handle for a stateful LLM chat session.
pub struct LuaAgentChat {
    chat: LlmChat,
}

impl UserData for LuaAgentChat {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // ─── setSystemPrompt ───
        /// Sets the system prompt used for all completions in this session.
        /// @param | prompt | string | System prompt text.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setSystemPrompt", |_, this, prompt: String| {
            this.chat.set_system_prompt(prompt);
            Ok(())
        });

        // ─── addMessage ───
        /// Appends a message to the chat history without sending a completion.
        /// @param | role | string | Role identifier: `"user"`, `"assistant"`, or `"system"`.
        /// @param | content | string | Message content.
        /// @return | nil | No value is returned.
        methods.add_method_mut("addMessage", |_, this, (role, content): (String, String)| {
            this.chat.add_message(role, content);
            Ok(())
        });

        // ─── complete ───
        /// Sends the current history to the LLM and returns the assistant reply.
        ///
        /// The assistant reply is automatically appended to the history.
        /// @return | string | Assistant reply text, or raises an error on failure.
        methods.add_method_mut("complete", |_, this, ()| {
            let cfg = read_global_config();
            let timeout_secs = (cfg.timeout_ms / 1000).max(1);
            this.chat
                .complete(&cfg.base_url, &cfg.model, timeout_secs)
                .map_err(mlua::Error::RuntimeError)
        });

        // ─── clear ───
        /// Clears the chat history.
        /// @return | nil | No value is returned.
        methods.add_method_mut("clear", |_, this, ()| {
            this.chat.clear();
            Ok(())
        });

        // ─── getHistory ───
        /// Returns the chat history as an array of `{role, content}` tables.
        /// @return | table | Array of `{ role = string, content = string }` tables.
        methods.add_method("getHistory", |lua, this, ()| {
            let tbl = lua.create_table()?;
            for (i, msg) in this.chat.history().iter().enumerate() {
                let entry = lua.create_table()?;
                entry.set("role", msg.role.clone())?;
                entry.set("content", msg.content.clone())?;
                tbl.set(i + 1, entry)?;
            }
            Ok(tbl)
        });
    }
}

// ─── LuaAgentTemplate ────────────────────────────────────────────────────────

/// Lua-side handle for a `{key}` placeholder prompt template.
pub struct LuaAgentTemplate {
    template: LlmTemplate,
}

impl UserData for LuaAgentTemplate {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // ─── render ───
        /// Renders the template by substituting `{key}` placeholders from `values`.
        /// @param | values | table | Map of key → string substitutions.
        /// @return | string | Rendered string, or raises an error if a key is missing.
        methods.add_method("render", |_, this, values: mlua::Table| {
            let mut map = HashMap::new();
            for pair in values.pairs::<String, mlua::Value>() {
                let (k, v) = pair?;
                let s = match v {
                    mlua::Value::String(s) => s.to_str()?.to_string(),
                    mlua::Value::Integer(i) => i.to_string(),
                    mlua::Value::Number(n) => n.to_string(),
                    mlua::Value::Boolean(b) => b.to_string(),
                    _ => String::new(),
                };
                map.insert(k, s);
            }
            this.template.render(&map).map_err(mlua::Error::RuntimeError)
        });
    }
}

// ─── LuaWorkingMemory ─────────────────────────────────────────────────────────

/// Lua-side handle for a bounded FIFO working memory.
pub struct LuaWorkingMemory {
    mem: WorkingMemory,
}

/// Convert a `serde_json::Value` to a Lua `Value`.
fn json_to_lua<'lua>(lua: &'lua Lua, val: serde_json::Value) -> LuaResult<mlua::Value<'lua>> {
    match val {
        serde_json::Value::Null => Ok(mlua::Value::Nil),
        serde_json::Value::Bool(b) => Ok(mlua::Value::Boolean(b)),
        serde_json::Value::Number(n) => {
            if let Some(i) = n.as_i64() {
                Ok(mlua::Value::Integer(i))
            } else {
                Ok(mlua::Value::Number(n.as_f64().unwrap_or(0.0)))
            }
        }
        serde_json::Value::String(s) => Ok(mlua::Value::String(lua.create_string(&s)?)),
        serde_json::Value::Array(arr) => {
            let tbl = lua.create_table()?;
            for (i, v) in arr.into_iter().enumerate() {
                tbl.set(i + 1, json_to_lua(lua, v)?)?;
            }
            Ok(mlua::Value::Table(tbl))
        }
        serde_json::Value::Object(map) => {
            let tbl = lua.create_table()?;
            for (k, v) in map {
                tbl.set(k, json_to_lua(lua, v)?)?;
            }
            Ok(mlua::Value::Table(tbl))
        }
    }
}

impl UserData for LuaWorkingMemory {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // ─── push ───
        /// Inserts or updates a key-value entry; evicts the oldest entry if capacity is exceeded.
        /// @param | key | string | Entry key.
        /// @param | value | any | Entry value (any serialisable Lua value).
        /// @return | nil | No value is returned.
        methods.add_method_mut("push", |_, this, (key, value): (String, mlua::Value)| {
            let json = lua_to_json(value)?;
            this.mem.push(key, json);
            Ok(())
        });

        // ─── get ───
        /// Returns the value for `key`, or `nil` if not found.
        /// @param | key | string | Entry key.
        /// @return | any | Stored value, or `nil`.
        methods.add_method("get", |lua, this, key: String| {
            match this.mem.get(&key) {
                Some(v) => json_to_lua(lua, v.clone()),
                None => Ok(mlua::Value::Nil),
            }
        });

        // ─── forget ───
        /// Removes the entry with `key`.  Returns `true` if it existed.
        /// @param | key | string | Entry key.
        /// @return | boolean | `true` if the entry was removed.
        methods.add_method_mut("forget", |_, this, key: String| {
            Ok(this.mem.forget(&key))
        });

        // ─── getRecent ───
        /// Returns the `n` most recently inserted entries as an array of `{key, value}` tables.
        /// @param | n | integer | Maximum number of entries to return.
        /// @return | table | Array of `{ key = string, value = any }` tables.
        methods.add_method("getRecent", |lua, this, n: usize| {
            let tbl = lua.create_table()?;
            for (i, (k, v)) in this.mem.get_recent(n).into_iter().enumerate() {
                let entry = lua.create_table()?;
                entry.set("key", k)?;
                entry.set("value", json_to_lua(lua, v.clone())?)?;
                tbl.set(i + 1, entry)?;
            }
            Ok(tbl)
        });

        // ─── len ───
        /// Returns the current number of entries.
        /// @return | integer | Entry count.
        methods.add_method("len", |_, this, ()| Ok(this.mem.len()));

        // ─── capacity ───
        /// Returns the configured capacity (0 = unlimited).
        /// @return | integer | Capacity.
        methods.add_method("capacity", |_, this, ()| Ok(this.mem.capacity()));
    }
}

// ─── LuaEpisodicMemory ────────────────────────────────────────────────────────

/// Lua-side handle for append-only episodic memory.
pub struct LuaEpisodicMemory {
    mem: EpisodicMemory,
}

impl UserData for LuaEpisodicMemory {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // ─── record ───
        /// Records a new episode at `tick` with `data`.
        /// @param | tick | integer | Logical tick or frame counter for this episode.
        /// @param | data | table | Key-value payload stored with the episode.
        /// @return | nil | No value is returned.
        methods.add_method_mut("record", |_, this, (tick, data): (i64, mlua::Table)| {
            let mut map = std::collections::HashMap::new();
            for pair in data.pairs::<String, mlua::Value>() {
                let (k, v) = pair?;
                map.insert(k, lua_to_json(v)?);
            }
            this.mem.record(tick, map);
            Ok(())
        });

        // ─── query ───
        /// Returns all episodes whose data matches every key-value pair in `filter`.
        /// @param | filter | table | Key-value filter table (empty = return all).
        /// @return | table | Array of `{ tick = integer, data = table }` episode tables.
        methods.add_method("query", |lua, this, filter: mlua::Table| {
            let mut fmap = std::collections::HashMap::new();
            for pair in filter.pairs::<String, mlua::Value>() {
                let (k, v) = pair?;
                fmap.insert(k, lua_to_json(v)?);
            }
            let results = this.mem.query(&fmap);
            let tbl = lua.create_table()?;
            for (i, ep) in results.into_iter().enumerate() {
                let entry = lua.create_table()?;
                entry.set("tick", ep.tick)?;
                let data_tbl = lua.create_table()?;
                for (k, v) in &ep.data {
                    data_tbl.set(k.clone(), json_to_lua(lua, v.clone())?)?;
                }
                entry.set("data", data_tbl)?;
                tbl.set(i + 1, entry)?;
            }
            Ok(tbl)
        });

        // ─── forgetBefore ───
        /// Removes all episodes with tick < `cutoff`.
        /// @param | cutoff | integer | Tick threshold; episodes older than this are removed.
        /// @return | nil | No value is returned.
        methods.add_method_mut("forgetBefore", |_, this, cutoff: i64| {
            this.mem.forget_before(cutoff);
            Ok(())
        });

        // ─── len ───
        /// Returns the number of stored episodes.
        /// @return | integer | Episode count.
        methods.add_method("len", |_, this, ()| Ok(this.mem.len()));
    }
}

// ─── LuaSemanticMemory ────────────────────────────────────────────────────────

/// Lua-side handle for an unbounded key → value fact store.
pub struct LuaSemanticMemory {
    mem: SemanticMemory,
}

impl UserData for LuaSemanticMemory {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // ─── learn ───
        /// Inserts or replaces a fact at `key`.
        /// @param | key | string | Fact key.
        /// @param | value | any | Fact value.
        /// @return | nil | No value is returned.
        methods.add_method_mut("learn", |_, this, (key, value): (String, mlua::Value)| {
            this.mem.learn(key, lua_to_json(value)?);
            Ok(())
        });

        // ─── recall ───
        /// Returns the fact for `key`, or `nil` if not found.
        /// @param | key | string | Fact key.
        /// @return | any | Stored fact, or `nil`.
        methods.add_method("recall", |lua, this, key: String| {
            match this.mem.recall(&key) {
                Some(v) => json_to_lua(lua, v.clone()),
                None => Ok(mlua::Value::Nil),
            }
        });

        // ─── forget ───
        /// Removes the fact at `key`.  Returns `true` if it existed.
        /// @param | key | string | Fact key.
        /// @return | boolean | `true` if the fact was removed.
        methods.add_method_mut("forget", |_, this, key: String| {
            Ok(this.mem.forget(&key))
        });

        // ─── query ───
        /// Returns all facts whose value matches every key-value pair in `filter`.
        /// @param | filter | table | Key-value filter applied to each fact's value object (empty = return all).
        /// @return | table | Array of `{ key = string, value = any }` tables.
        methods.add_method("query", |lua, this, filter: mlua::Table| {
            let mut fmap = std::collections::HashMap::new();
            for pair in filter.pairs::<String, mlua::Value>() {
                let (k, v) = pair?;
                fmap.insert(k, lua_to_json(v)?);
            }
            let results = this.mem.query(&fmap);
            let tbl = lua.create_table()?;
            for (i, (k, v)) in results.into_iter().enumerate() {
                let entry = lua.create_table()?;
                entry.set("key", k)?;
                entry.set("value", json_to_lua(lua, v.clone())?)?;
                tbl.set(i + 1, entry)?;
            }
            Ok(tbl)
        });

        // ─── len ───
        /// Returns the number of stored facts.
        /// @return | integer | Fact count.
        methods.add_method("len", |_, this, ()| Ok(this.mem.len()));
    }
}

// ─── LuaAgentMemory ──────────────────────────────────────────────────────────

/// Lua-side handle for a bundled working+episodic+semantic memory with optional persistence.
pub struct LuaAgentMemory {
    mem: AgentMemory,
}

impl UserData for LuaAgentMemory {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // ─── working ───
        /// Returns the working memory component.
        /// @return | LWorkingMemory | Working memory handle.
        methods.add_method("working", |_, this, ()| {
            Ok(LuaWorkingMemory { mem: WorkingMemory::new(this.mem.working.capacity()) })
        });

        // ─── episodic ───
        /// Returns the episodic memory component.
        /// @return | LEpisodicMemory | Episodic memory handle.
        methods.add_method("episodic", |_, _this, ()| {
            Ok(LuaEpisodicMemory { mem: EpisodicMemory::new() })
        });

        // ─── semantic ───
        /// Returns the semantic memory component.
        /// @return | LSemanticMemory | Semantic memory handle.
        methods.add_method("semantic", |_, _this, ()| {
            Ok(LuaSemanticMemory { mem: SemanticMemory::new() })
        });

        // ─── save ───
        /// Serialises all memory banks to the configured persist_path.
        /// @return | boolean | `true` on success, raises an error on failure.
        methods.add_method("save", |_, this, ()| {
            this.mem.save().map(|_| true).map_err(mlua::Error::RuntimeError)
        });

        // ─── load ───
        /// Deserialises memory state from the configured persist_path.
        /// @return | boolean | `true` on success, raises an error on failure.
        methods.add_method_mut("load", |_, this, ()| {
            this.mem.load().map(|_| true).map_err(mlua::Error::RuntimeError)
        });
    }
}

// ─── register ────────────────────────────────────────────────────────────────

/// Registers the `lurek.agent` API in the global environment.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let agent_table = lua.create_table()?;

    // ─── new ───
    /// Creates a new LLM Agent instance.
    /// @param | config | table | Config with `url`, `model`, `system_prompt`, `format`, `name`, `description`, `max_retries`, `timeout`, and `options` sub-table.
    /// @return | LAgent | A new agent object.
    agent_table.set(
        "new",
        lua.create_function(move |_lua, config: mlua::Table| {
            Ok(LuaAgent {
                runtime: LuaAgentRuntime::from_lua_config(config)?,
            })
        })?,
    )?;

    // ─── newManager ───
    /// Creates a new Agent Manager for batching multiple LLM agents over a shared client.
    /// @return | LAgentManager | A new agent manager object.
    agent_table.set(
        "newManager",
        lua.create_function(move |_lua, ()| {
            Ok(LuaAgentManager {
                runtime: LuaAgentManagerRuntime::new(),
            })
        })?,
    )?;

    // ─── newSystem ───
    /// Creates a new AISystem orchestrator that holds agents, instructions, and keyword-gated skills.
    /// @param | config | table | Config with `system_prompt` for the shared system context.
    /// @return | LAISystem | A new AI system object.
    agent_table.set(
        "newSystem",
        lua.create_function(move |_lua, config: mlua::Table| {
            Ok(LuaAISystem {
                runtime: LuaAISystemRuntime::from_lua_config(config)?,
            })
        })?,
    )?;

    // ─── newOllama ───
    /// Creates an Ollama infrastructure manager for server lifecycle and model management.
    /// @param | config | table? | Optional config with `url` (default `"http://127.0.0.1:11434"`).
    /// @return | LOllamaManager | A new Ollama manager object.
    agent_table.set(
        "newOllama",
        lua.create_function(move |_lua, config: Option<mlua::Table>| {
            let url = config
                .as_ref()
                .and_then(|t| t.get::<_, String>("url").ok())
                .unwrap_or_else(|| "http://127.0.0.1:11434".to_string());
            Ok(LuaOllamaManager {
                manager: OllamaManager::new(url),
                callback_registry: HashMap::new(),
            })
        })?,
    )?;

    // ─── configure ───
    /// Configures the global LLM provider settings used by module-level functions.
    /// @param | config | table | Config with `provider`, `base_url`, `model`, `timeout_ms`, and `api_key` fields.
    /// @return | nil | No value is returned.
    agent_table.set(
        "configure",
        lua.create_function(move |_, config: mlua::Table| {
            let current = read_global_config();
            let cfg = GlobalLlmConfig {
                provider: config.get::<_, String>("provider").unwrap_or(current.provider),
                base_url: config.get::<_, String>("base_url").unwrap_or(current.base_url),
                model: config.get::<_, String>("model").unwrap_or(current.model),
                timeout_ms: config.get::<_, u64>("timeout_ms").unwrap_or(current.timeout_ms),
                api_key: config.get::<_, Option<String>>("api_key").unwrap_or(current.api_key),
            };
            write_global_config(cfg);
            Ok(())
        })?,
    )?;

    // ─── complete ───
    /// Sends a single prompt to the global LLM and returns the response text.
    /// @param | prompt | string | Prompt text.
    /// @return | string | Response text, or raises an error on failure.
    agent_table.set(
        "complete",
        lua.create_function(move |_, prompt: String| {
            let cfg = read_global_config();
            let timeout_secs = (cfg.timeout_ms / 1000).max(1);
            ollama_generate(&cfg.base_url, &cfg.model, &prompt, "", timeout_secs)
                .map_err(mlua::Error::RuntimeError)
        })?,
    )?;

    // ─── completeAsync ───
    /// Sends a prompt asynchronously using a background thread; calls `callback(text, err)` on completion.
    /// @param | prompt | string | Prompt text.
    /// @param | callback | function | Called with `(text, err)` on completion (`err` is `nil` on success).
    /// @return | nil | No value is returned.
    agent_table.set(
        "completeAsync",
        lua.create_function(move |lua, (prompt, callback): (String, mlua::Function)| {
            let cfg = read_global_config();
            let timeout_secs = (cfg.timeout_ms / 1000).max(1);
            let base_url = cfg.base_url.clone();
            let model = cfg.model.clone();

            // Capture callback in registry so it can cross the thread boundary safely.
            let key = lua.create_registry_value(callback)?;
            // We cannot move a RegistryKey into std::thread::spawn directly because Lua is not Send.
            // Use a shared result channel instead.
            let (tx, rx) = std::sync::mpsc::channel::<Result<String, String>>();
            std::thread::spawn(move || {
                let result = ollama_generate(&base_url, &model, &prompt, "", timeout_secs);
                let _ = tx.send(result);
            });

            // Poll results in current Lua state context.
            match rx.recv() {
                Ok(Ok(text)) => {
                    let cb: mlua::Function = lua.registry_value(&key)?;
                    lua.remove_registry_value(key)?;
                    cb.call::<_, ()>((text, mlua::Value::Nil))?;
                }
                Ok(Err(err)) => {
                    let cb: mlua::Function = lua.registry_value(&key)?;
                    lua.remove_registry_value(key)?;
                    cb.call::<_, ()>((mlua::Value::Nil, err))?;
                }
                Err(_) => {
                    lua.remove_registry_value(key)?;
                }
            }
            Ok(())
        })?,
    )?;

    // ─── newChat ───
    /// Creates a new stateful chat session using the global LLM config.
    /// @return | LAgentChat | A new chat session object.
    agent_table.set(
        "newChat",
        lua.create_function(move |_, ()| {
            Ok(LuaAgentChat { chat: LlmChat::new() })
        })?,
    )?;

    // ─── newTemplate ───
    /// Creates a new `{key}` placeholder prompt template.
    /// @param | pattern | string | Template string with `{key}` placeholders.
    /// @return | LAgentTemplate | A new template object.
    agent_table.set(
        "newTemplate",
        lua.create_function(move |_, pattern: String| {
            Ok(LuaAgentTemplate { template: LlmTemplate::new(pattern) })
        })?,
    )?;

    // ─── completeJson ───
    /// Sends a prompt requesting a JSON-format response and returns a parsed Lua table.
    /// @param | prompt | string | Prompt text.
    /// @return | table | Parsed JSON response as a Lua table, or raises an error on failure.
    agent_table.set(
        "completeJson",
        lua.create_function(move |lua, prompt: String| {
            let cfg = read_global_config();
            let timeout_secs = (cfg.timeout_ms / 1000).max(1);
            let val = ollama_generate_json(&cfg.base_url, &cfg.model, &prompt, "", timeout_secs)
                .map_err(mlua::Error::RuntimeError)?;
            json_to_lua(lua, val)
        })?,
    )?;

    // ─── embed ───
    /// Returns an embedding vector for `text` from the global LLM.
    /// @param | text | string | Text to embed.
    /// @return | table | Number array of float embedding values, or raises an error on failure.
    agent_table.set(
        "embed",
        lua.create_function(move |lua, text: String| {
            let cfg = read_global_config();
            let timeout_secs = (cfg.timeout_ms / 1000).max(1);
            let floats = ollama_embed(&cfg.base_url, &cfg.model, &text, timeout_secs)
                .map_err(mlua::Error::RuntimeError)?;
            let tbl = lua.create_table()?;
            for (i, v) in floats.into_iter().enumerate() {
                tbl.set(i + 1, v)?;
            }
            Ok(tbl)
        })?,
    )?;

    // ─── isAvailable ───
    /// Returns `true` if the configured LLM server responds within 5 seconds.
    /// @return | boolean | `true` if the server is reachable.
    agent_table.set(
        "isAvailable",
        lua.create_function(move |_, ()| {
            let cfg = read_global_config();
            Ok(ollama_is_available(&cfg.base_url, 5))
        })?,
    )?;

    // ─── listModels ───
    /// Returns a list of available model names from the configured LLM server.
    /// @return | table | String array of model names; empty if the server is unreachable.
    agent_table.set(
        "listModels",
        lua.create_function(move |lua, ()| {
            let cfg = read_global_config();
            let timeout_secs = (cfg.timeout_ms / 1000).max(1);
            let names = ollama_list_models(&cfg.base_url, timeout_secs);
            let tbl = lua.create_table()?;
            for (i, name) in names.into_iter().enumerate() {
                tbl.set(i + 1, name)?;
            }
            Ok(tbl)
        })?,
    )?;

    // ─── newWorkingMemory ───
    /// Creates a new bounded FIFO working memory with the given capacity.
    /// @param | capacity | integer | Maximum number of key-value slots (0 = unlimited).
    /// @return | LWorkingMemory | A new working memory object.
    agent_table.set(
        "newWorkingMemory",
        lua.create_function(move |_, capacity: usize| {
            Ok(LuaWorkingMemory { mem: WorkingMemory::new(capacity) })
        })?,
    )?;

    // ─── newEpisodicMemory ───
    /// Creates a new episodic memory for recording time-stamped events.
    /// @return | LEpisodicMemory | A new episodic memory object.
    agent_table.set(
        "newEpisodicMemory",
        lua.create_function(move |_, ()| {
            Ok(LuaEpisodicMemory { mem: EpisodicMemory::new() })
        })?,
    )?;

    // ─── newSemanticMemory ───
    /// Creates a new semantic memory for storing named facts.
    /// @return | LSemanticMemory | A new semantic memory object.
    agent_table.set(
        "newSemanticMemory",
        lua.create_function(move |_, ()| {
            Ok(LuaSemanticMemory { mem: SemanticMemory::new() })
        })?,
    )?;

    // ─── newAgentMemory ───
    /// Creates a bundled working+episodic+semantic memory with optional disk persistence.
    /// @param | config | table? | Config with `working_capacity` (integer) and `persist_path` (string?) fields.
    /// @return | LAgentMemory | A new agent memory object.
    agent_table.set(
        "newAgentMemory",
        lua.create_function(move |_, config: Option<mlua::Table>| {
            let (capacity, path) = if let Some(cfg) = config {
                let cap = cfg.get::<_, usize>("working_capacity").unwrap_or(64);
                let p = cfg.get::<_, Option<String>>("persist_path").unwrap_or(None);
                (cap, p)
            } else {
                (64, None)
            };
            Ok(LuaAgentMemory { mem: AgentMemory::new(capacity, path) })
        })?,
    )?;

    lurek.set("agent", agent_table)?;
    Ok(())
}

