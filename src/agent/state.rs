//! This file owns `AgentState`, `SystemSkill`, and `AISystemState`, the mutable config layer behind agent requests.
//! `AgentState` stores validated endpoint, model, prompt, format, options, skills, retries, and timeout for one caller.
//! Request builders turn that state into stable `AgentRequest` payloads and reject unsafe URLs, options, or oversized context.
//! `AISystemState` holds shared system prompts, named instruction blocks, and keyword-matched skills with provenance.
//! Context assembly merges explicit instructions and matched skills into structured prompt text for downstream agents.
//! Open it when request-shaping rules change; background delivery and memory behavior live in sibling modules.

use crate::agent::{AgentError, AgentRequest, AgentResponseFormat};
use std::collections::{HashMap, HashSet};

const DEFAULT_ALLOWED_AGENT_HOSTS: &[&str] = &["127.0.0.1", "localhost", "::1"];
const DEFAULT_MAX_CONTEXT_CHARS: usize = 16_384;

/// Safe network policy applied to outbound agent endpoints.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct AgentNetworkPolicy {
    /// Whether hosts outside the allowlist are accepted.
    pub allow_external_hosts: bool,
    /// Allowed URI schemes.
    pub allowed_schemes: Vec<String>,
    /// Allowed hosts in safe local-only mode.
    pub allowed_hosts: Vec<String>,
}

impl Default for AgentNetworkPolicy {
    fn default() -> Self {
        Self {
            allow_external_hosts: false,
            allowed_schemes: vec!["http".to_string(), "https".to_string()],
            allowed_hosts: DEFAULT_ALLOWED_AGENT_HOSTS
                .iter()
                .map(|host| (*host).to_string())
                .collect(),
        }
    }
}

/// Context sizing policy for structured prompt assembly.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct AgentPromptPolicy {
    /// Maximum number of characters allowed in the final system context.
    pub max_context_chars: usize,
}

impl Default for AgentPromptPolicy {
    fn default() -> Self {
        Self {
            max_context_chars: DEFAULT_MAX_CONTEXT_CHARS,
        }
    }
}

/// One provenance entry recorded while assembling a structured system block.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct PromptProvenanceEntry {
    /// Section type such as `instruction`, `system_skill`, or `agent_skill`.
    pub kind: String,
    /// Stable source identifier shown to callers.
    pub source: String,
    /// Why the source was added.
    pub reason: String,
}

/// Structured report returned by safe prompt assembly helpers.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct PromptBuildReport {
    /// Final system block delivered to the transport layer.
    pub text: String,
    /// Ordered provenance entries for every injected section.
    pub provenance: Vec<PromptProvenanceEntry>,
}

/// Per-agent runtime configuration owned by Lua agent runtimes.
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
    /// Response format.
    pub format: AgentResponseFormat,
    /// Extra model options forwarded to the backend.
    pub options: HashMap<String, serde_json::Value>,
    /// Named skill prompts appended to the system block.
    pub skills: Vec<(String, String)>,
    /// Maximum retry attempts on transient failure (0 = no retry).
    pub max_retries: u32,
    /// Per-request timeout in seconds (0 = use default 60 s).
    pub timeout_secs: u64,
    /// Network endpoint validation policy.
    pub network_policy: AgentNetworkPolicy,
    /// Prompt sizing and truncation policy.
    pub prompt_policy: AgentPromptPolicy,
    /// Whether unknown option keys may bypass validation.
    pub allow_unsafe_passthrough_options: bool,
}

impl AgentState {
    /// Creates a new `AgentState` with no skills and default retry, timeout, and policy settings.
    pub fn new(
        url: String,
        model: String,
        system_prompt: String,
        format: String,
        options: HashMap<String, serde_json::Value>,
    ) -> Result<Self, AgentError> {
        let format = AgentResponseFormat::parse(&format)?;
        validate_agent_url(&url, &AgentNetworkPolicy::default())?;
        validate_model_name(&model)?;
        validate_options(&options, false)?;
        Ok(Self {
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
            network_policy: AgentNetworkPolicy::default(),
            prompt_policy: AgentPromptPolicy::default(),
            allow_unsafe_passthrough_options: false,
        })
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

    /// Inserts or updates a single validated model option.
    pub fn set_option(&mut self, key: String, value: serde_json::Value) -> Result<(), AgentError> {
        validate_option_entry(&key, &value, self.allow_unsafe_passthrough_options)?;
        self.options.insert(key, value);
        Ok(())
    }

    /// Appends a named skill to the agent's context.
    pub fn add_skill(&mut self, name: String, prompt: String) {
        self.skills.push((name, prompt));
    }

    /// Removes all registered skills.
    pub fn clear_skills(&mut self) {
        self.skills.clear();
    }

    /// Returns `true` if a skill with `name` is registered.
    pub fn has_skill(&self, name: &str) -> bool {
        self.skills.iter().any(|(entry_name, _)| entry_name == name)
    }

    /// Returns the number of registered skills.
    pub fn skill_count(&self) -> usize {
        self.skills.len()
    }

    /// Returns the names of all registered skills in insertion order.
    pub fn list_skills(&self) -> Vec<String> {
        self.skills.iter().map(|(name, _)| name.clone()).collect()
    }

    /// Sets the response format (`"json"`, `"csv"`, or `"text"`).
    pub fn set_format(&mut self, format: String) -> Result<(), AgentError> {
        self.format = AgentResponseFormat::parse(&format)?;
        Ok(())
    }

    /// Sets the model identifier used for all future prompts.
    pub fn set_model(&mut self, model: String) -> Result<(), AgentError> {
        validate_model_name(&model)?;
        self.model = model;
        Ok(())
    }

    /// Sets the LLM endpoint URL used for outbound requests.
    pub fn set_url(&mut self, url: String) -> Result<(), AgentError> {
        validate_agent_url(&url, &self.network_policy)?;
        self.url = url;
        Ok(())
    }

    /// Builds a structured system block report with provenance for agent-local context.
    pub fn build_system_block_report(&self) -> Result<PromptBuildReport, AgentError> {
        let mut sections = Vec::new();
        let mut provenance = Vec::new();

        if !self.system_prompt.trim().is_empty() {
            sections.push(structured_section(
                "Base System Prompt",
                &self.system_prompt,
            ));
        }

        if !self.skills.is_empty() {
            let mut lines = Vec::new();
            for (name, prompt) in &self.skills {
                provenance.push(PromptProvenanceEntry {
                    kind: "agent_skill".to_string(),
                    source: name.clone(),
                    reason: "added through AgentState::add_skill".to_string(),
                });
                lines.push(format!("[skill:{}]\n{}", name, prompt));
            }
            sections.push(structured_section("Agent Skills", &lines.join("\n\n")));
        }

        let text = sections.join("\n\n");
        enforce_prompt_limit(&text, &self.prompt_policy)?;
        Ok(PromptBuildReport { text, provenance })
    }

    /// Build the effective system block without provenance metadata.
    pub fn build_system_block(&self) -> Result<String, AgentError> {
        self.build_system_block_report().map(|report| report.text)
    }

    /// Resolves the effective timeout: uses the configured value, defaulting to 60 s.
    fn effective_timeout(&self) -> u64 {
        if self.timeout_secs == 0 {
            60
        } else {
            self.timeout_secs
        }
    }

    /// Builds one outbound request using the current agent configuration.
    pub(crate) fn to_request(
        &self,
        prompt: String,
        callback_id: usize,
    ) -> Result<AgentRequest, AgentError> {
        validate_agent_url(&self.url, &self.network_policy)?;
        validate_model_name(&self.model)?;
        validate_options(&self.options, self.allow_unsafe_passthrough_options)?;
        Ok(AgentRequest {
            url: self.url.clone(),
            model: self.model.clone(),
            prompt,
            system: self.build_system_block()?,
            format: self.format,
            options: serde_json::Value::Object(self.options.clone().into_iter().collect()),
            callback_id,
            max_retries: self.max_retries,
            timeout_secs: self.effective_timeout(),
        })
    }

    /// Build a request with an external system block, bypassing the local block builder.
    pub(crate) fn to_request_with_system(
        &self,
        prompt: String,
        system_block: String,
        callback_id: usize,
    ) -> Result<AgentRequest, AgentError> {
        validate_agent_url(&self.url, &self.network_policy)?;
        validate_model_name(&self.model)?;
        validate_options(&self.options, self.allow_unsafe_passthrough_options)?;
        enforce_prompt_limit(&system_block, &self.prompt_policy)?;
        Ok(AgentRequest {
            url: self.url.clone(),
            model: self.model.clone(),
            prompt,
            system: system_block,
            format: self.format,
            options: serde_json::Value::Object(self.options.clone().into_iter().collect()),
            callback_id,
            max_retries: self.max_retries,
            timeout_secs: self.effective_timeout(),
        })
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

/// Shared orchestration state for Lua AI-system runtimes.
#[derive(Clone, Default)]
pub struct AISystemState {
    /// System-wide prompt prepended before every agent-routed prompt.
    pub system_prompt: String,
    /// Named instruction blocks the user may explicitly include per call.
    pub instructions: Vec<(String, String)>,
    /// Keyword-gated skill blocks auto-injected on prompt keyword overlap.
    pub system_skills: Vec<SystemSkill>,
    /// Prompt sizing and truncation policy for system-built context.
    pub prompt_policy: AgentPromptPolicy,
}

impl AISystemState {
    /// Creates a new `AISystemState` with the given system prompt.
    pub fn new(system_prompt: String) -> Self {
        Self {
            system_prompt,
            instructions: Vec::new(),
            system_skills: Vec::new(),
            prompt_policy: AgentPromptPolicy::default(),
        }
    }

    /// Adds or replaces a named instruction block.
    pub fn add_instruction(&mut self, key: String, text: String) {
        if let Some(entry) = self
            .instructions
            .iter_mut()
            .find(|(entry_key, _)| entry_key == &key)
        {
            entry.1 = text;
        } else {
            self.instructions.push((key, text));
        }
    }

    /// Removes an instruction by key. Returns `true` if it existed.
    pub fn remove_instruction(&mut self, key: &str) -> bool {
        let before = self.instructions.len();
        self.instructions.retain(|(entry_key, _)| entry_key != key);
        self.instructions.len() < before
    }

    /// Adds a keyword-gated skill. Replaces an existing skill with the same name.
    pub fn add_system_skill(&mut self, name: String, keywords: Vec<String>, prompt: String) {
        if let Some(entry) = self
            .system_skills
            .iter_mut()
            .find(|skill| skill.name == name)
        {
            entry.keywords = keywords;
            entry.prompt = prompt;
        } else {
            self.system_skills.push(SystemSkill {
                name,
                keywords,
                prompt,
            });
        }
    }

    /// Removes a system skill by name. Returns `true` if it existed.
    pub fn remove_system_skill(&mut self, name: &str) -> bool {
        let before = self.system_skills.len();
        self.system_skills.retain(|skill| skill.name != name);
        self.system_skills.len() < before
    }

    /// Returns `true` if an instruction with `key` exists.
    pub fn has_instruction(&self, key: &str) -> bool {
        self.instructions
            .iter()
            .any(|(entry_key, _)| entry_key == key)
    }

    /// Returns the number of registered instructions.
    pub fn instruction_count(&self) -> usize {
        self.instructions.len()
    }

    /// Returns the keys of all registered instructions in insertion order.
    pub fn list_instructions(&self) -> Vec<String> {
        self.instructions
            .iter()
            .map(|(entry_key, _)| entry_key.clone())
            .collect()
    }

    /// Returns `true` if a system skill with `name` is registered.
    pub fn has_system_skill(&self, name: &str) -> bool {
        self.system_skills.iter().any(|skill| skill.name == name)
    }

    /// Returns the number of registered system skills.
    pub fn system_skill_count(&self) -> usize {
        self.system_skills.len()
    }

    /// Builds the combined context report for a given prompt and explicit instruction list.
    pub fn build_context_report(
        &self,
        prompt: &str,
        include_instructions: &[String],
    ) -> Result<PromptBuildReport, AgentError> {
        let mut sections = Vec::new();
        let mut provenance = Vec::new();

        if !self.system_prompt.trim().is_empty() {
            sections.push(structured_section("System Context", &self.system_prompt));
        }

        for key in include_instructions {
            if let Some((_, text)) = self
                .instructions
                .iter()
                .find(|(entry_key, _)| entry_key == key)
            {
                provenance.push(PromptProvenanceEntry {
                    kind: "instruction".to_string(),
                    source: key.clone(),
                    reason: format!("explicit include '{}'", key),
                });
                sections.push(structured_section(&format!("Instruction {}", key), text));
            }
        }

        let prompt_tokens = tokenize_lowercase(prompt);
        let mut matched_sections = Vec::new();
        for skill in &self.system_skills {
            let Some(keyword) = matched_keyword(&prompt_tokens, &skill.keywords) else {
                continue;
            };
            provenance.push(PromptProvenanceEntry {
                kind: "system_skill".to_string(),
                source: skill.name.clone(),
                reason: format!("keyword match '{}'", keyword),
            });
            matched_sections.push(format!("[skill:{}]\n{}", skill.name, skill.prompt));
        }

        if !matched_sections.is_empty() {
            sections.push(structured_section(
                "Matched System Skills",
                &matched_sections.join("\n\n"),
            ));
        }

        let text = sections.join("\n\n");
        enforce_prompt_limit(&text, &self.prompt_policy)?;
        Ok(PromptBuildReport { text, provenance })
    }

    /// Builds the combined context block for a given prompt.
    pub fn build_context(
        &self,
        prompt: &str,
        include_instructions: &[String],
    ) -> Result<String, AgentError> {
        self.build_context_report(prompt, include_instructions)
            .map(|report| report.text)
    }
}

/// Validate the outbound agent URL under the given policy.
pub fn validate_agent_url(url: &str, policy: &AgentNetworkPolicy) -> Result<(), AgentError> {
    let uri: ureq::http::Uri = url.parse().map_err(|error| {
        AgentError::InvalidRequest(format!("invalid agent URL '{}': {}", url, error))
    })?;
    let scheme = uri.scheme_str().ok_or_else(|| {
        AgentError::InvalidRequest(format!("agent URL '{}' is missing a scheme", url))
    })?;
    if !policy
        .allowed_schemes
        .iter()
        .any(|allowed| allowed.eq_ignore_ascii_case(scheme))
    {
        return Err(AgentError::InvalidRequest(format!(
            "agent URL scheme '{}' is not allowed",
            scheme
        )));
    }

    let host = uri.host().ok_or_else(|| {
        AgentError::InvalidRequest(format!("agent URL '{}' is missing a host", url))
    })?;
    if !policy.allow_external_hosts
        && !policy
            .allowed_hosts
            .iter()
            .any(|allowed| allowed.eq_ignore_ascii_case(host))
    {
        return Err(AgentError::InvalidRequest(format!(
            "agent host '{}' is outside the safe-mode allowlist",
            host
        )));
    }
    Ok(())
}

fn validate_model_name(model: &str) -> Result<(), AgentError> {
    let trimmed = model.trim();
    if trimmed.is_empty() {
        return Err(AgentError::InvalidRequest(
            "model name must not be empty".to_string(),
        ));
    }
    if !trimmed
        .chars()
        .all(|ch| ch.is_ascii_alphanumeric() || matches!(ch, '_' | '-' | '.' | ':' | '/'))
    {
        return Err(AgentError::InvalidRequest(format!(
            "model '{}' contains unsupported characters",
            model
        )));
    }
    Ok(())
}

fn validate_options(
    options: &HashMap<String, serde_json::Value>,
    allow_unsafe_passthrough_options: bool,
) -> Result<(), AgentError> {
    for (key, value) in options {
        validate_option_entry(key, value, allow_unsafe_passthrough_options)?;
    }
    Ok(())
}

fn validate_option_entry(
    key: &str,
    value: &serde_json::Value,
    allow_unsafe_passthrough_options: bool,
) -> Result<(), AgentError> {
    match key {
        "temperature" => validate_f64_range(key, value, 0.0, 2.0),
        "top_p" => validate_f64_range(key, value, 0.0, 1.0),
        "seed" => validate_i64_range(key, value, i64::MIN, i64::MAX),
        "num_ctx" => validate_u64_range(key, value, 1, 262_144),
        "repeat_penalty" => validate_f64_range(key, value, 0.0, 4.0),
        "stop" => validate_stop_sequences(value),
        other if allow_unsafe_passthrough_options => {
            if other.trim().is_empty() {
                Err(AgentError::InvalidRequest(
                    "option names must not be empty".to_string(),
                ))
            } else {
                Ok(())
            }
        }
        other => Err(AgentError::InvalidRequest(format!(
            "option '{}' is not allowed without unsafe passthrough",
            other
        ))),
    }
}

fn validate_f64_range(
    key: &str,
    value: &serde_json::Value,
    min: f64,
    max: f64,
) -> Result<(), AgentError> {
    let number = value
        .as_f64()
        .ok_or_else(|| AgentError::InvalidRequest(format!("option '{}' must be numeric", key)))?;
    if !number.is_finite() || number < min || number > max {
        return Err(AgentError::InvalidRequest(format!(
            "option '{}' must be between {} and {}",
            key, min, max
        )));
    }
    Ok(())
}

fn validate_i64_range(
    key: &str,
    value: &serde_json::Value,
    min: i64,
    max: i64,
) -> Result<(), AgentError> {
    let number = value.as_i64().ok_or_else(|| {
        AgentError::InvalidRequest(format!("option '{}' must be an integer", key))
    })?;
    if number < min || number > max {
        return Err(AgentError::InvalidRequest(format!(
            "option '{}' must be between {} and {}",
            key, min, max
        )));
    }
    Ok(())
}

fn validate_u64_range(
    key: &str,
    value: &serde_json::Value,
    min: u64,
    max: u64,
) -> Result<(), AgentError> {
    let number = value.as_u64().ok_or_else(|| {
        AgentError::InvalidRequest(format!("option '{}' must be a positive integer", key))
    })?;
    if number < min || number > max {
        return Err(AgentError::InvalidRequest(format!(
            "option '{}' must be between {} and {}",
            key, min, max
        )));
    }
    Ok(())
}

fn validate_stop_sequences(value: &serde_json::Value) -> Result<(), AgentError> {
    match value {
        serde_json::Value::String(_) => Ok(()),
        serde_json::Value::Array(values) => {
            if values
                .iter()
                .all(|value| matches!(value, serde_json::Value::String(_)))
            {
                Ok(())
            } else {
                Err(AgentError::InvalidRequest(
                    "option 'stop' must contain only strings".to_string(),
                ))
            }
        }
        _ => Err(AgentError::InvalidRequest(
            "option 'stop' must be a string or string array".to_string(),
        )),
    }
}

fn enforce_prompt_limit(text: &str, policy: &AgentPromptPolicy) -> Result<(), AgentError> {
    if text.chars().count() > policy.max_context_chars {
        return Err(AgentError::InvalidRequest(format!(
            "system context length {} exceeds max_context_chars {}",
            text.chars().count(),
            policy.max_context_chars
        )));
    }
    Ok(())
}

fn structured_section(title: &str, body: &str) -> String {
    format!("## {}\n<<<BEGIN>>>\n{}\n<<<END>>>", title, body)
}

fn tokenize_lowercase(text: &str) -> HashSet<String> {
    text.split(|ch: char| !ch.is_ascii_alphanumeric())
        .filter(|token| !token.is_empty())
        .map(|token| token.to_ascii_lowercase())
        .collect()
}

fn matched_keyword(prompt_tokens: &HashSet<String>, keywords: &[String]) -> Option<String> {
    for keyword in keywords {
        let lowered = keyword.trim().to_ascii_lowercase();
        if lowered.is_empty() {
            continue;
        }
        if prompt_tokens.contains(&lowered) {
            return Some(lowered);
        }
    }
    None
}
