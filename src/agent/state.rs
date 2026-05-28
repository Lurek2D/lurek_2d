//! Holds per-agent configuration and assembles outbound `AgentRequest` values from endpoint, model, system prompt, skills, format, options, and retry settings.
//!
//! - `AgentState` builds the system block by appending named skills in insertion order behind the base system prompt.
//! - `AISystemState` stores the shared system prompt, named instruction blocks selectively included per prompt, and keyword-gated skills auto-injected when their keywords match the instruction.
//! - `SystemSkill` carries a keyword list and a prompt fragment; skills fire automatically when any keyword appears in the dispatched instruction.
//! - `to_request` and `to_request_with_system` build the final `AgentRequest` for single and system-routed prompts respectively.

use crate::agent::AgentRequest;
use std::collections::HashMap;

/// Per-agent runtime configuration owned by [`LuaAgentRuntime`] and [`LuaAISystemRuntime`].
#[derive(Clone)]
pub struct AgentState {
    /// Optional agent identifier.
    pub name: String,
    /// Agent role description injected after the system prompt when routed through an AISystem.
    pub description: String,
    /// LLM endpoint URL.
    pub url: String,
    /// Model identifier.
    pub model: String,
    /// Base system prompt.
    pub system_prompt: String,
    /// Response format (`"json"`, `"csv"`, or `"text"`).
    pub format: String,
    /// Extra model options forwarded to the backend.
    pub options: HashMap<String, serde_json::Value>,
    /// Named skill prompts appended to the system block.
    pub skills: Vec<(String, String)>,
    /// Maximum retry attempts on transient failure (0 = no retry).
    pub max_retries: u32,
    /// Per-request timeout in seconds (0 = use default 60 s).
    pub timeout_secs: u64,
}

impl AgentState {
    /// Creates a new `AgentState` with no skills and default retry/timeout settings.
    pub fn new(
        url: String,
        model: String,
        system_prompt: String,
        format: String,
        options: HashMap<String, serde_json::Value>,
    ) -> Self {
        Self {
            name: String::new(),
            description: String::new(),
            url,
            model,
            system_prompt,
            format,
            options,
            skills: Vec::new(),
            max_retries: 0,
            timeout_secs: 0,
        }
    }

    /// Sets the agent's name identifier.
    pub fn set_name(&mut self, name: String) {
        self.name = name;
    }

    /// Sets the agent's role description used when routed through an AISystem.
    pub fn set_description(&mut self, description: String) {
        self.description = description;
    }

    /// Sets the maximum retry count for transient errors.
    pub fn set_max_retries(&mut self, n: u32) {
        self.max_retries = n;
    }

    /// Sets the per-request timeout in seconds (0 = use default 60 s).
    pub fn set_timeout(&mut self, secs: u64) {
        self.timeout_secs = secs;
    }

    /// Inserts or updates a single model option.
    pub fn set_option(&mut self, key: String, value: serde_json::Value) {
        self.options.insert(key, value);
    }

    /// Appends a named skill to the agent's context.
    pub fn add_skill(&mut self, name: String, prompt: String) {
        self.skills.push((name, prompt));
    }

    /// Removes all registered skills.
    pub fn clear_skills(&mut self) {
        self.skills.clear();
    }

    /// Build the system block: base system prompt followed by a `Skills` section when skills are registered.
    pub fn build_system_block(&self) -> String {
        if self.skills.is_empty() {
            return self.system_prompt.clone();
        }

        let mut block = self.system_prompt.clone();
        block.push_str("\n\nSkills (Additional Instructions):\n");
        for (name, prompt) in &self.skills {
            block.push_str(&format!("- [{}]: {}\n", name, prompt));
        }
        block
    }

    /// Resolves the effective timeout: uses the configured value, defaulting to 60 s.
    fn effective_timeout(&self) -> u64 {
        if self.timeout_secs == 0 { 60 } else { self.timeout_secs }
    }

    /// Builds one outbound request using the current agent configuration.
    pub(crate) fn to_request(&self, prompt: String, callback_id: usize) -> AgentRequest {
        AgentRequest {
            url: self.url.clone(),
            model: self.model.clone(),
            prompt,
            system: self.build_system_block(),
            format: self.format.clone(),
            options: serde_json::Value::Object(self.options.clone().into_iter().collect()),
            callback_id,
            max_retries: self.max_retries,
            timeout_secs: self.effective_timeout(),
        }
    }

    /// Build a request with an external system block, bypassing this agent's own system prompt; used by AISystem routing.
    pub(crate) fn to_request_with_system(
        &self,
        prompt: String,
        system_block: String,
        callback_id: usize,
    ) -> AgentRequest {
        AgentRequest {
            url: self.url.clone(),
            model: self.model.clone(),
            prompt,
            system: system_block,
            format: self.format.clone(),
            options: serde_json::Value::Object(self.options.clone().into_iter().collect()),
            callback_id,
            max_retries: self.max_retries,
            timeout_secs: self.effective_timeout(),
        }
    }
}

/// Keyword-gated skill auto-injected into the system block when its keywords overlap with the prompt.
#[derive(Clone)]
pub struct SystemSkill {
    /// Skill identifier.
    pub name: String,
    /// Keywords that trigger auto-injection.
    pub keywords: Vec<String>,
    /// Instruction text injected when a keyword matches.
    pub prompt: String,
}

/// Shared orchestration state for [`LuaAISystemRuntime`]: system prompt, instruction blocks, and keyword-gated skills.
#[derive(Clone, Default)]
pub struct AISystemState {
    /// System-wide prompt prepended before every agent-routed prompt.
    pub system_prompt: String,
    /// Named instruction blocks the user may explicitly include per call.
    pub instructions: Vec<(String, String)>,
    /// Keyword-gated skill blocks auto-injected by Lurek on keyword overlap.
    pub system_skills: Vec<SystemSkill>,
}

impl AISystemState {
    /// Creates a new `AISystemState` with the given system prompt.
    pub fn new(system_prompt: String) -> Self {
        Self {
            system_prompt,
            instructions: Vec::new(),
            system_skills: Vec::new(),
        }
    }

    /// Adds or replaces a named instruction block.
    pub fn add_instruction(&mut self, key: String, text: String) {
        if let Some(entry) = self.instructions.iter_mut().find(|(k, _)| k == &key) {
            entry.1 = text;
        } else {
            self.instructions.push((key, text));
        }
    }

    /// Removes an instruction by key. Returns `true` if it existed.
    pub fn remove_instruction(&mut self, key: &str) -> bool {
        let before = self.instructions.len();
        self.instructions.retain(|(k, _)| k != key);
        self.instructions.len() < before
    }

    /// Adds a keyword-gated skill. Replaces an existing skill with the same name.
    pub fn add_system_skill(&mut self, name: String, keywords: Vec<String>, prompt: String) {
        if let Some(entry) = self.system_skills.iter_mut().find(|s| s.name == name) {
            entry.keywords = keywords;
            entry.prompt = prompt;
        } else {
            self.system_skills.push(SystemSkill { name, keywords, prompt });
        }
    }

    /// Removes a system skill by name. Returns `true` if it existed.
    pub fn remove_system_skill(&mut self, name: &str) -> bool {
        let before = self.system_skills.len();
        self.system_skills.retain(|s| s.name != name);
        self.system_skills.len() < before
    }

    /// Builds the combined context block for a given prompt.
    ///
    /// - `include_instructions`: keys of instructions the user explicitly wants included.
    /// - Skills whose keywords appear in `prompt` are auto-injected.
    pub fn build_context(&self, prompt: &str, include_instructions: &[String]) -> String {
        let mut block = self.system_prompt.clone();

        for key in include_instructions {
            if let Some((_, text)) = self.instructions.iter().find(|(k, _)| k == key) {
                block.push_str(&format!("\n\n[{}]:\n{}", key, text));
            }
        }

        let prompt_lower = prompt.to_lowercase();
        let matched: Vec<&SystemSkill> = self
            .system_skills
            .iter()
            .filter(|skill| {
                skill
                    .keywords
                    .iter()
                    .any(|kw| prompt_lower.contains(&kw.to_lowercase()))
            })
            .collect();

        if !matched.is_empty() {
            block.push_str("\n\nContext Skills:\n");
            for skill in matched {
                block.push_str(&format!("- [{}]: {}\n", skill.name, skill.prompt));
            }
        }

        block
    }
}
