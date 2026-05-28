//! `lurek.agent` -- Agent bindings for LLM and VM integration.
//!
//! - Registers `lurek.agent.*` functions and types via `register()`.
//! - Bridges 43 Lua-callable methods via `mlua`.
//! - See `docs/specs/agent.md` for the full API specification.

use crate::agent::{AgentBatchTask, LuaAgentManagerRuntime, LuaAgentRuntime, LuaAISystemRuntime, OllamaManager, lua_to_json};
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
    /// @param | config | table | Optional config with `url` (default `"http://127.0.0.1:11434"`).
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

    lurek.set("agent", agent_table)?;
    Ok(())
}

