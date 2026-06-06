//! File: src/lua_api/agent_api.rs

use self::runtime::{
    lua_to_json, AgentBatchTask, LuaAISystemRuntime, LuaAgentManagerRuntime, LuaAgentRuntime,
};
use crate::agent::chat::{
    ollama_embed, ollama_generate, ollama_generate_json, ollama_is_available, ollama_list_models,
};
use crate::agent::{
    read_global_config, write_global_config, AgentMemory, EpisodicMemory, GlobalLlmConfig, LlmChat,
    LlmTemplate, OllamaManager, SemanticMemory, WorkingMemory,
};
use crate::runtime::SharedState;
use mlua::prelude::*;
use mlua::{AnyUserData, UserData, UserDataMethods};
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LuaAgent Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

/// Lua-side handle for a single LLM Agent.
pub struct LuaAgent {
    runtime: LuaAgentRuntime,
}

impl UserData for LuaAgent {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ addSkill Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Appends a named skill prompt to the agent's context block.
        /// @param | name | string | Unique skill identifier shown in the injected context.
        /// @param | prompt | string | Instruction text appended to the system block.
        /// @return | nil | No value is returned.
        methods.add_method_mut("addSkill", |_, this, (name, prompt): (String, String)| {
            this.runtime.add_skill(name, prompt);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ clearSkills Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Removes all registered skills from the agent's context.
        /// @return | nil | No value is returned.
        methods.add_method_mut("clearSkills", |_, this, ()| {
            this.runtime.clear_skills();
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ setOption Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Sets a single model option forwarded to the LLM backend.
        /// @param | key | string | Option name (e.g. `"temperature"`, `"seed"`, `"num_ctx"`).
        /// @param | value | any | Option value forwarded as JSON.
        /// @return | nil | No value is returned.
        methods.add_method_mut(
            "setOption",
            |_, this, (key, value): (String, mlua::Value)| {
                let json_val = lua_to_json(value)?;
                this.runtime.set_option(key, json_val);
                Ok(())
            },
        );

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ setFormat Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Changes the response format for future prompts.
        /// @param | format | string | One of `"json"`, `"csv"`, or `"text"`.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setFormat", |_, this, format: String| {
            this.runtime.set_format(format);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ setMaxRetries Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Sets the maximum retry count on transient network or timeout errors.
        /// @param | n | integer | Number of retries (0 disables retry).
        /// @return | nil | No value is returned.
        methods.add_method_mut("setMaxRetries", |_, this, n: u32| {
            this.runtime.set_max_retries(n);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ setContextSize Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Sets the token context window size forwarded to the LLM backend.
        /// @param | n | integer | Context size in tokens (e.g. 4096).
        /// @return | nil | No value is returned.
        methods.add_method_mut("setContextSize", |_, this, n: u32| {
            this.runtime
                .set_option("num_ctx".to_string(), serde_json::json!(n));
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ setTemperature Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Sets the sampling temperature forwarded to the LLM backend.
        /// @param | t | number | Temperature value (e.g. 0.7). Higher = more random.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setTemperature", |_, this, t: f64| {
            this.runtime
                .set_option("temperature".to_string(), serde_json::json!(t));
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ setName Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Sets the agent's name identifier used when added to an AISystem.
        /// @param | name | string | Agent name.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setName", |_, this, name: String| {
            this.runtime.set_name(name);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ setDescription Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Sets the agent's role description injected after the system prompt when routed through an AISystem.
        /// @param | description | string | Role description text.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setDescription", |_, this, description: String| {
            this.runtime.set_description(description);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ setModel Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Changes the model identifier for future prompts.
        /// @param | model | string | Model name (e.g. `"llama3"`, `"mistral"`).
        /// @return | nil | No value is returned.
        methods.add_method_mut("setModel", |_, this, model: String| {
            this.runtime.set_model(model);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ setUrl Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Changes the LLM endpoint URL for future prompts.
        /// @param | url | string | Full endpoint URL (e.g. `"http://127.0.0.1:11434/api/generate"`).
        /// @return | nil | No value is returned.
        methods.add_method_mut("setUrl", |_, this, url: String| {
            this.runtime.set_url(url);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ setTimeout Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Sets the per-request timeout in seconds (0 uses the default 60 s).
        /// @param | secs | integer | Timeout in seconds.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setTimeout", |_, this, secs: u64| {
            this.runtime.set_timeout(secs);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ getName Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the agent's name identifier.
        /// @return | string | Agent name, or `""` if not set.
        methods.add_method("getName", |_, this, ()| {
            Ok(this.runtime.get_name().to_string())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ getDescription Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the agent's role description.
        /// @return | string | Role description, or `""` if not set.
        methods.add_method("getDescription", |_, this, ()| {
            Ok(this.runtime.get_description().to_string())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ getModel Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the current model identifier.
        /// @return | string | Model name.
        methods.add_method("getModel", |_, this, ()| {
            Ok(this.runtime.get_model().to_string())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ getUrl Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the current LLM endpoint URL.
        /// @return | string | Endpoint URL.
        methods.add_method("getUrl", |_, this, ()| {
            Ok(this.runtime.get_url().to_string())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ getFormat Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the current response format string.
        /// @return | string | One of `"json"`, `"csv"`, or `"text"`.
        methods.add_method("getFormat", |_, this, ()| {
            Ok(this.runtime.get_format().to_string())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ hasSkill Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns `true` if a skill with `name` is registered.
        /// @param | name | string | Skill name to check.
        /// @return | boolean | `true` if the skill exists.
        methods.add_method("hasSkill", |_, this, name: String| {
            Ok(this.runtime.has_skill(&name))
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ skillCount Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the number of registered skills.
        /// @return | integer | Skill count.
        methods.add_method("skillCount", |_, this, ()| Ok(this.runtime.skill_count()));

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ listSkills Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ prompt Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ promptBatch Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ cancel Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Cancels an in-flight or pending request by callback ID.
        /// @param | callback_id | integer | ID returned by `prompt` or `promptBatch`.
        /// @return | nil | No value is returned.
        methods.add_method("cancel", |_, this, callback_id: usize| {
            this.runtime.cancel(callback_id);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ pendingCount Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the number of in-flight requests that have not yet completed.
        /// @return | integer | Number of pending requests.
        methods.add_method("pendingCount", |_, this, ()| {
            Ok(this.runtime.pending_count())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ update Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Polls the background client for completed LLM requests and dispatches callbacks.
        /// @return | nil | No value is returned.
        methods.add_method_mut("update", |lua, this, ()| this.runtime.update(lua));

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ evalCode Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Evaluates a Lua code string inside the active VM.
        /// @param | code | string | The Lua code to execute.
        /// @return | boolean | `true` on success, raises an error on failure.
        methods.add_method("evalCode", |lua, this, code: String| {
            this.runtime.eval_code(lua, code)
        });
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LuaAgentManager Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

/// Lua-side handle for managing multiple LLM Agents in parallel.
pub struct LuaAgentManager {
    runtime: LuaAgentManagerRuntime,
}

impl UserData for LuaAgentManager {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ runAll Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ update Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Polls the manager's background client for completed tasks and dispatches callbacks.
        /// @return | nil | No value is returned.
        methods.add_method_mut("update", |lua, this, ()| this.runtime.update(lua));
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LuaAISystem Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

/// Lua-side handle for an AISystem multi-agent orchestrator.
pub struct LuaAISystem {
    runtime: LuaAISystemRuntime,
}

impl UserData for LuaAISystem {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ addAgent Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Registers a named agent in the system.
        /// @param | name | string | Unique agent name used for routing.
        /// @param | agent | LAgent | The agent instance to register.
        /// @return | nil | No value is returned.
        methods.add_method_mut(
            "addAgent",
            |_, this, (name, agent_ud): (String, AnyUserData)| {
                let agent = agent_ud.borrow::<LuaAgent>()?;
                this.runtime.add_agent(name, agent.runtime.state.clone());
                Ok(())
            },
        );

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ removeAgent Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Removes a registered agent by name.
        /// @param | name | string | Agent name to remove.
        /// @return | boolean | `true` if the agent was found and removed.
        methods.add_method_mut("removeAgent", |_, this, name: String| {
            Ok(this.runtime.remove_agent(&name))
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ listAgents Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ hasAgent Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns `true` if an agent with `name` is registered.
        /// @param | name | string | Agent name to check.
        /// @return | boolean | `true` if the agent exists.
        methods.add_method("hasAgent", |_, this, name: String| {
            Ok(this.runtime.has_agent(&name))
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ agentCount Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the number of registered agents.
        /// @return | integer | Agent count.
        methods.add_method("agentCount", |_, this, ()| Ok(this.runtime.agent_count()));

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ addInstruction Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Adds a named instruction block the user can explicitly include per prompt.
        /// @param | key | string | Unique instruction identifier.
        /// @param | text | string | Instruction text injected into the system block.
        /// @return | nil | No value is returned.
        methods.add_method_mut(
            "addInstruction",
            |_, this, (key, text): (String, String)| {
                this.runtime.add_instruction(key, text);
                Ok(())
            },
        );

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ removeInstruction Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Removes an instruction block by key.
        /// @param | key | string | Instruction key to remove.
        /// @return | boolean | `true` if the instruction was found and removed.
        methods.add_method_mut("removeInstruction", |_, this, key: String| {
            Ok(this.runtime.remove_instruction(key))
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ hasInstruction Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns `true` if an instruction with `key` is registered.
        /// @param | key | string | Instruction key to check.
        /// @return | boolean | `true` if the instruction exists.
        methods.add_method("hasInstruction", |_, this, key: String| {
            Ok(this.runtime.has_instruction(&key))
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ instructionCount Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the number of registered instruction blocks.
        /// @return | integer | Instruction count.
        methods.add_method("instructionCount", |_, this, ()| {
            Ok(this.runtime.instruction_count())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ listInstructions Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ addSkill Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ removeSkill Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Removes a registered system skill by exact name.
        /// @param | name | string | Skill name to remove.
        /// @return | boolean | `true` if the skill was found and removed.
        methods.add_method_mut("removeSkill", |_, this, name: String| {
            Ok(this.runtime.remove_system_skill(name))
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ hasSkill Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns `true` if a system skill with `name` is registered.
        /// @param | name | string | Skill name to check.
        /// @return | boolean | `true` if the skill exists.
        methods.add_method("hasSkill", |_, this, name: String| {
            Ok(this.runtime.has_system_skill(&name))
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ skillCount Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the number of registered system skills.
        /// @return | integer | Skill count.
        methods.add_method("skillCount", |_, this, ()| {
            Ok(this.runtime.system_skill_count())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ buildContext Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Builds and returns the full context string that would be sent for a given prompt.
        /// @param | instruction | string | The prompt text used for keyword matching.
        /// @param | opts | table | Optional table with `agent` (string) and `instructions` (table) keys.
        /// @return | string | The assembled system context block.
        methods.add_method(
            "buildContext",
            |_, this, (instruction, opts): (String, Option<mlua::Table>)| {
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
                Ok(this
                    .runtime
                    .build_context(&instruction, &include, agent_name.as_deref()))
            },
        );

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ prompt Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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
                this.runtime
                    .prompt(lua, agent_name, instruction, callback, include)
            },
        );

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ runAll Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ update Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Polls the system's background client for completed requests and dispatches callbacks.
        /// @return | nil | No value is returned.
        methods.add_method_mut("update", |lua, this, ()| this.runtime.update(lua));
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LuaOllamaManager Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

/// Lua-side handle for managing a local Ollama server lifecycle and models.
pub struct LuaOllamaManager {
    /// Underlying Ollama infrastructure manager.
    manager: OllamaManager,
    /// Pull callbacks keyed by callback ID returned from `pullModel`.
    callback_registry: HashMap<usize, mlua::RegistryKey>,
}

impl UserData for LuaOllamaManager {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ isRunning Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns `true` if the Ollama HTTP server responds within 5 seconds.
        /// @return | boolean | `true` if Ollama is reachable.
        methods.add_method("isRunning", |_, this, ()| Ok(this.manager.is_running()));

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ version Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the Ollama version string, or an empty string if not running.
        /// @return | string | Ollama version or `""`.
        methods.add_method("version", |_, this, ()| Ok(this.manager.version()));

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ baseUrl Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the base URL this manager was created with.
        /// @return | string | Base URL (e.g. `"http://127.0.0.1:11434"`).
        methods.add_method("baseUrl", |_, this, ()| {
            Ok(this.manager.base_url().to_string())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ listModels Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ modelNames Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ hasModel Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns `true` if a model with the given name (or name prefix) is available locally.
        /// @param | name | string | Model name to check (e.g. `"llama3"` or `"llama3:latest"`).
        /// @return | boolean | `true` if found locally.
        methods.add_method("hasModel", |_, this, name: String| {
            Ok(this.manager.has_model(&name))
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ start Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Spawns `ollama serve` as a managed child process. Returns `true` on success.
        /// @return | boolean | `true` if the process started.
        methods.add_method_mut("start", |_, this, ()| Ok(this.manager.start()));

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ stop Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Kills the Ollama process started by this manager. Returns `true` if it was running.
        /// @return | boolean | `true` if the process was running under this manager.
        methods.add_method_mut("stop", |_, this, ()| Ok(this.manager.stop()));

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ restart Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Stops then restarts the managed Ollama process. Returns `true` on success.
        /// @return | boolean | `true` if the restart succeeded.
        methods.add_method_mut("restart", |_, this, ()| Ok(this.manager.restart()));

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ pullModel Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ deleteModel Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Sends `DELETE /api/delete` to remove a model from local Ollama storage.
        /// @param | name | string | Model name to delete (e.g. `"llama3:latest"`).
        /// @return | boolean | `true` if the request succeeded.
        methods.add_method("deleteModel", |_, this, name: String| {
            Ok(this.manager.delete_model(&name))
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ pendingCount Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the number of in-flight model pull operations.
        /// @return | integer | Number of pending pulls.
        methods.add_method("pendingCount", |_, this, ()| {
            Ok(this.manager.in_flight_count())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ update Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LuaAgentChat Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

/// Lua-side handle for a stateful LLM chat session.
pub struct LuaAgentChat {
    chat: LlmChat,
}

impl UserData for LuaAgentChat {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ setSystemPrompt Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Sets the system prompt used for all completions in this session.
        /// @param | prompt | string | System prompt text.
        /// @return | nil | No value is returned.
        methods.add_method_mut("setSystemPrompt", |_, this, prompt: String| {
            this.chat.set_system_prompt(prompt);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ addMessage Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Appends a message to the chat history without sending a completion.
        /// @param | role | string | Role identifier: `"user"`, `"assistant"`, or `"system"`.
        /// @param | content | string | Message content.
        /// @return | nil | No value is returned.
        methods.add_method_mut(
            "addMessage",
            |_, this, (role, content): (String, String)| {
                this.chat.add_message(role, content);
                Ok(())
            },
        );

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ complete Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ clear Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Clears all stored chat history messages.
        /// @return | nil | No value is returned.
        methods.add_method_mut("clear", |_, this, ()| {
            this.chat.clear();
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ getHistory Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LuaAgentTemplate Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

/// Lua-side handle for a `{key}` placeholder prompt template.
pub struct LuaAgentTemplate {
    template: LlmTemplate,
}

impl UserData for LuaAgentTemplate {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ render Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Renders the template by substituting `{key}` placeholders from `values`.
        /// @param | values | table | Map of key Ă˘â€ â€™ string substitutions.
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
            this.template
                .render(&map)
                .map_err(mlua::Error::RuntimeError)
        });
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LuaWorkingMemory Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

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
        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ push Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Inserts or updates a key-value entry; evicts the oldest entry if capacity is exceeded.
        /// @param | key | string | Entry key.
        /// @param | value | any | Entry value (any serialisable Lua value).
        /// @return | nil | No value is returned.
        methods.add_method_mut("push", |_, this, (key, value): (String, mlua::Value)| {
            let json = lua_to_json(value)?;
            this.mem.push(key, json);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ get Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the value for `key`, or `nil` if not found.
        /// @param | key | string | Entry key.
        /// @return | table | Stored value converted from JSON when present; returns nil when missing.
        methods.add_method("get", |lua, this, key: String| match this.mem.get(&key) {
            Some(v) => json_to_lua(lua, v.clone()),
            None => Ok(mlua::Value::Nil),
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ forget Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Removes the entry with `key`.  Returns `true` if it existed.
        /// @param | key | string | Entry key.
        /// @return | boolean | `true` if the entry was removed.
        methods.add_method_mut("forget", |_, this, key: String| Ok(this.mem.forget(&key)));

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ getRecent Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ len Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the current number of entries.
        /// @return | integer | Entry count.
        methods.add_method("len", |_, this, ()| Ok(this.mem.len()));

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ capacity Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the configured capacity (0 = unlimited).
        /// @return | integer | Capacity.
        methods.add_method("capacity", |_, this, ()| Ok(this.mem.capacity()));
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LuaEpisodicMemory Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

/// Lua-side handle for append-only episodic memory.
pub struct LuaEpisodicMemory {
    mem: EpisodicMemory,
}

impl UserData for LuaEpisodicMemory {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ record Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ query Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ forgetBefore Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Removes all episodes with tick < `cutoff`.
        /// @param | cutoff | integer | Tick threshold; episodes older than this are removed.
        /// @return | nil | No value is returned.
        methods.add_method_mut("forgetBefore", |_, this, cutoff: i64| {
            this.mem.forget_before(cutoff);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ len Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the number of stored episodes.
        /// @return | integer | Episode count.
        methods.add_method("len", |_, this, ()| Ok(this.mem.len()));
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LuaSemanticMemory Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

/// Lua-side handle for an unbounded key Ă˘â€ â€™ value fact store.
pub struct LuaSemanticMemory {
    mem: SemanticMemory,
}

impl UserData for LuaSemanticMemory {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ learn Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Inserts or replaces a fact at `key`.
        /// @param | key | string | Fact key.
        /// @param | value | any | Fact value.
        /// @return | nil | No value is returned.
        methods.add_method_mut("learn", |_, this, (key, value): (String, mlua::Value)| {
            this.mem.learn(key, lua_to_json(value)?);
            Ok(())
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ recall Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the fact for `key`, or `nil` if not found.
        /// @param | key | string | Fact key.
        /// @return | table | Stored fact converted from JSON when present; returns nil when missing.
        methods.add_method("recall", |lua, this, key: String| {
            match this.mem.recall(&key) {
                Some(v) => json_to_lua(lua, v.clone()),
                None => Ok(mlua::Value::Nil),
            }
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ forget Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Removes the fact at `key`.  Returns `true` if it existed.
        /// @param | key | string | Fact key.
        /// @return | boolean | `true` if the fact was removed.
        methods.add_method_mut("forget", |_, this, key: String| Ok(this.mem.forget(&key)));

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ query Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ len Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the number of stored facts.
        /// @return | integer | Fact count.
        methods.add_method("len", |_, this, ()| Ok(this.mem.len()));
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LuaAgentMemory Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

/// Lua-side handle for a bundled working+episodic+semantic memory with optional persistence.
pub struct LuaAgentMemory {
    mem: AgentMemory,
}

impl UserData for LuaAgentMemory {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ working Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the working memory component.
        /// @return | LWorkingMemory | Working memory handle.
        methods.add_method("working", |_, this, ()| {
            Ok(LuaWorkingMemory {
                mem: WorkingMemory::new(this.mem.working.capacity()),
            })
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ episodic Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the episodic memory component.
        /// @return | LEpisodicMemory | Episodic memory handle.
        methods.add_method("episodic", |_, _this, ()| {
            Ok(LuaEpisodicMemory {
                mem: EpisodicMemory::new(),
            })
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ semantic Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Returns the semantic memory component.
        /// @return | LSemanticMemory | Semantic memory handle.
        methods.add_method("semantic", |_, _this, ()| {
            Ok(LuaSemanticMemory {
                mem: SemanticMemory::new(),
            })
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ save Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Serialises all memory banks to the configured persist_path.
        /// @return | boolean | `true` on success, raises an error on failure.
        methods.add_method("save", |_, this, ()| {
            this.mem
                .save()
                .map(|_| true)
                .map_err(mlua::Error::RuntimeError)
        });

        // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ load Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
        /// Deserialises memory state from the configured persist_path.
        /// @return | boolean | `true` on success, raises an error on failure.
        methods.add_method_mut("load", |_, this, ()| {
            this.mem
                .load()
                .map(|_| true)
                .map_err(mlua::Error::RuntimeError)
        });
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ register Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

/// Registers the `lurek.agent` API in the global environment.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let agent_table = lua.create_table()?;

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ new Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
    /// Creates a new configurable LLM Agent runtime instance.
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

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ newManager Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ newSystem Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ newOllama Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ configure Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
    /// Configures the global LLM provider settings used by module-level functions.
    /// @param | config | table | Config with `provider`, `base_url`, `model`, `timeout_ms`, and `api_key` fields.
    /// @return | nil | No value is returned.
    agent_table.set(
        "configure",
        lua.create_function(move |_, config: mlua::Table| {
            let current = read_global_config();
            let cfg = GlobalLlmConfig {
                provider: config
                    .get::<_, String>("provider")
                    .unwrap_or(current.provider),
                base_url: config
                    .get::<_, String>("base_url")
                    .unwrap_or(current.base_url),
                model: config.get::<_, String>("model").unwrap_or(current.model),
                timeout_ms: config
                    .get::<_, u64>("timeout_ms")
                    .unwrap_or(current.timeout_ms),
                api_key: config
                    .get::<_, Option<String>>("api_key")
                    .unwrap_or(current.api_key),
            };
            write_global_config(cfg);
            Ok(())
        })?,
    )?;

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ complete Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ completeAsync Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ newChat Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
    /// Creates a new stateful chat session using the global LLM config.
    /// @return | LAgentChat | A new chat session object.
    agent_table.set(
        "newChat",
        lua.create_function(move |_, ()| {
            Ok(LuaAgentChat {
                chat: LlmChat::new(),
            })
        })?,
    )?;

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ newTemplate Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
    /// Creates a new `{key}` placeholder prompt template.
    /// @param | pattern | string | Template string with `{key}` placeholders.
    /// @return | LAgentTemplate | A new template object.
    agent_table.set(
        "newTemplate",
        lua.create_function(move |_, pattern: String| {
            Ok(LuaAgentTemplate {
                template: LlmTemplate::new(pattern),
            })
        })?,
    )?;

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ completeJson Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ embed Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ isAvailable Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
    /// Returns `true` if the configured LLM server responds within 5 seconds.
    /// @return | boolean | `true` if the server is reachable.
    agent_table.set(
        "isAvailable",
        lua.create_function(move |_, ()| {
            let cfg = read_global_config();
            Ok(ollama_is_available(&cfg.base_url, 5))
        })?,
    )?;

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ listModels Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ newWorkingMemory Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
    /// Creates a new bounded FIFO working memory with the given capacity.
    /// @param | capacity | integer | Maximum number of key-value slots (0 = unlimited).
    /// @return | LWorkingMemory | A new working memory object.
    agent_table.set(
        "newWorkingMemory",
        lua.create_function(move |_, capacity: usize| {
            Ok(LuaWorkingMemory {
                mem: WorkingMemory::new(capacity),
            })
        })?,
    )?;

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ newEpisodicMemory Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
    /// Creates a new episodic memory for recording time-stamped events.
    /// @return | LEpisodicMemory | A new episodic memory object.
    agent_table.set(
        "newEpisodicMemory",
        lua.create_function(move |_, ()| {
            Ok(LuaEpisodicMemory {
                mem: EpisodicMemory::new(),
            })
        })?,
    )?;

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ newSemanticMemory Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
    /// Creates a new semantic memory for storing named facts.
    /// @return | LSemanticMemory | A new semantic memory object.
    agent_table.set(
        "newSemanticMemory",
        lua.create_function(move |_, ()| {
            Ok(LuaSemanticMemory {
                mem: SemanticMemory::new(),
            })
        })?,
    )?;

    // Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ newAgentMemory Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬
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
            Ok(LuaAgentMemory {
                mem: AgentMemory::new(capacity, path),
            })
        })?,
    )?;

    lurek.set("agent", agent_table)?;
    Ok(())
}

mod runtime {

    //! Implements the Lua-facing runtime for `LAgent`, `LAgentManager`, and `LAISystem` userdata â€” all business logic for the agent API lives here.
    //!
    //! - `LuaAgentRuntime` owns an `AgentState`, `AgentClient`, callback registry, and `BatchDispatcher` to serve one `LAgent` userdata.
    //! - `LuaAgentManagerRuntime` dispatches explicit task batches across multiple agents and collects their responses under a single batch callback.
    //! - `LuaAISystemRuntime` routes prompts through `AISystemState` context injection before dispatch, supporting `addAgent`, `addInstruction`, `addSkill`, and `buildContext`.
    //! - `BatchDispatcher` packs multi-agent batch IDs into a single `usize` callback, collects partial results, and fires the Lua callback once all responses arrive.
    //! - `lua_to_json` converts arbitrary Lua values â€” primitives, arrays, and mixed tables â€” to `serde_json::Value` for model option serialization.

    use crate::agent::orchestration::{
        build_system_context, make_system_task as build_system_task, pack_batch_callback_id,
        unpack_batch_callback_id,
    };
    use crate::agent::{AISystemState, AgentClient, AgentError, AgentRequest, AgentState};
    use mlua::prelude::*;
    use mlua::{Function, Lua, RegistryKey, Table, Value};
    use std::collections::HashMap;
    use std::rc::Rc;

    // â”€â”€â”€ BatchDispatcher â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

    pub(crate) use crate::agent::AgentBatchTask;

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
                    task.state
                        .to_request_with_system(task.instruction, sys, packed_id)
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
                let result = state
                    .results
                    .remove(&idx)
                    .unwrap_or_else(|| Err(AgentError::Model("missing batch result".to_string())));
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

    // â”€â”€â”€ LuaAgentRuntime â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
            let model: String = config.get("model").unwrap_or_else(|_| "llama3".to_string());
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
            self.state.set_format(format);
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

        /// Sets the model identifier forwarded to the LLM backend.
        pub(crate) fn set_model(&mut self, model: String) {
            self.state.set_model(model);
        }

        /// Sets the LLM endpoint URL used for future requests.
        pub(crate) fn set_url(&mut self, url: String) {
            self.state.set_url(url);
        }

        /// Sets the per-request timeout in seconds.
        pub(crate) fn set_timeout(&mut self, secs: u64) {
            self.state.set_timeout(secs);
        }

        /// Returns `true` if a skill with `name` is registered.
        pub(crate) fn has_skill(&self, name: &str) -> bool {
            self.state.has_skill(name)
        }

        /// Returns the number of registered skills.
        pub(crate) fn skill_count(&self) -> usize {
            self.state.skill_count()
        }

        /// Returns the names of all registered skills in insertion order.
        pub(crate) fn list_skills(&self) -> Vec<String> {
            self.state.list_skills()
        }

        /// Returns the agent's name identifier.
        pub(crate) fn get_name(&self) -> &str {
            &self.state.name
        }

        /// Returns the agent's role description.
        pub(crate) fn get_description(&self) -> &str {
            &self.state.description
        }

        /// Returns the model identifier.
        pub(crate) fn get_model(&self) -> &str {
            &self.state.model
        }

        /// Returns the LLM endpoint URL.
        pub(crate) fn get_url(&self) -> &str {
            &self.state.url
        }

        /// Returns the response format string.
        pub(crate) fn get_format(&self) -> &str {
            &self.state.format
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
            self.callback_registry
                .insert(callback_id, (callback_key, format));

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
                self.client
                    .send_prompt(request)
                    .map_err(LuaError::runtime)?;
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
                    let (success, data, err_info) = process_response(lua, &format, response.body)?;
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

    // â”€â”€â”€ LuaAgentManagerRuntime â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
            let Some((batch_id, requests)) =
                self.batch_dispatcher.start_batch(lua, tasks, callback)?
            else {
                return Ok(0);
            };

            for request in requests {
                self.client
                    .send_prompt(request)
                    .map_err(LuaError::runtime)?;
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

    // â”€â”€â”€ LuaAISystemRuntime â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

        /// Returns `true` if an agent with `name` is registered.
        pub(crate) fn has_agent(&self, name: &str) -> bool {
            self.agents.contains_key(name)
        }

        /// Returns the number of registered agents.
        pub(crate) fn agent_count(&self) -> usize {
            self.agents.len()
        }

        /// Returns `true` if an instruction with `key` exists.
        pub(crate) fn has_instruction(&self, key: &str) -> bool {
            self.system_state.has_instruction(key)
        }

        /// Returns the number of registered instructions.
        pub(crate) fn instruction_count(&self) -> usize {
            self.system_state.instruction_count()
        }

        /// Returns the keys of all registered instructions in insertion order.
        pub(crate) fn list_instructions(&self) -> Vec<String> {
            self.system_state.list_instructions()
        }

        /// Returns `true` if a system skill with `name` is registered.
        pub(crate) fn has_system_skill(&self, name: &str) -> bool {
            self.system_state.has_system_skill(name)
        }

        /// Returns the number of registered system skills.
        pub(crate) fn system_skill_count(&self) -> usize {
            self.system_state.system_skill_count()
        }

        /// Builds the system context block that would be sent for `instruction`; used by `buildContext` and routing.
        pub(crate) fn build_context(
            &self,
            instruction: &str,
            include_instructions: &[String],
            agent_name: Option<&str>,
        ) -> String {
            build_system_context(
                &self.system_state,
                &self.agents,
                instruction,
                include_instructions,
                agent_name,
            )
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

            let system_block =
                self.build_context(&instruction, &include_instructions, Some(&agent_name));

            let callback_id = self.next_callback_id;
            self.next_callback_id += 1;

            let format = agent.format.clone();
            let callback_key = lua.create_registry_value(callback)?;
            self.callback_registry
                .insert(callback_id, (callback_key, format));

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
                self.client
                    .send_prompt(request)
                    .map_err(LuaError::runtime)?;
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
            build_system_task(
                &self.system_state,
                &self.agents,
                agent_name,
                task_idx,
                instruction,
                include_instructions,
            )
            .map_err(LuaError::runtime)
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
                    let (success, data, err_info) = process_response(lua, &format, response.body)?;
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

    // â”€â”€â”€ Private helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

    /// Recursively converts an `mlua::Value` into a `serde_json::Value`.
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
            let record = record
                .map_err(|error| LuaError::RuntimeError(format!("CSV record error: {}", error)))?;
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
            Ok(body) if format == "json" => {
                match serde_json::from_str::<serde_json::Value>(&body) {
                    Ok(value) => Ok((true, json_to_lua(lua, &value)?, Value::Nil)),
                    Err(error) => Ok((
                        false,
                        Value::Nil,
                        error_table(lua, "PARSE_ERROR", format!("Invalid JSON: {}", error))?,
                    )),
                }
            }
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
    fn error_table<'lua>(
        lua: &'lua Lua,
        code: &str,
        message: impl AsRef<str>,
    ) -> LuaResult<Value<'lua>> {
        let table = lua.create_table()?;
        table.set("code", code)?;
        table.set("message", message.as_ref())?;
        Ok(Value::Table(table))
    }
}
