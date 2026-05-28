//! Stateless and stateful LLM chat helpers: global provider config, single-shot completion, chat sessions, and prompt templates.
//!
//! - `GlobalLlmConfig` is a process-wide default stored in a `Mutex`; set once via `configure()` and read by every direct completion call.
//! - `LlmChat` maintains a stateful message history and calls the Ollama `/api/chat` endpoint.
//! - `LlmTemplate` renders `{key}` placeholders from a Lua table.
//! - Sync HTTP calls reuse `crate::network::http::execute_request`.

use std::sync::{Mutex, OnceLock};
use std::collections::HashMap;

// ─── GlobalLlmConfig ─────────────────────────────────────────────────────────

/// Process-wide LLM configuration used by module-level functions (`configure`, `complete`, etc.).
#[derive(Clone)]
pub struct GlobalLlmConfig {
    /// Backend provider identifier (currently only `"ollama"` is supported).
    pub provider: String,
    /// Base URL of the LLM server (e.g. `"http://127.0.0.1:11434"`).
    pub base_url: String,
    /// Default model identifier (e.g. `"llama3"`).
    pub model: String,
    /// Request timeout in milliseconds (default 30 000).
    pub timeout_ms: u64,
    /// Optional API key forwarded in the `Authorization` header.
    pub api_key: Option<String>,
}

impl Default for GlobalLlmConfig {
    fn default() -> Self {
        Self {
            provider: "ollama".to_string(),
            base_url: "http://127.0.0.1:11434".to_string(),
            model: "llama3".to_string(),
            timeout_ms: 30_000,
            api_key: None,
        }
    }
}

static GLOBAL_CFG: OnceLock<Mutex<GlobalLlmConfig>> = OnceLock::new();

fn global_cfg_mutex() -> &'static Mutex<GlobalLlmConfig> {
    GLOBAL_CFG.get_or_init(|| Mutex::new(GlobalLlmConfig::default()))
}

/// Reads a snapshot of the current global LLM config.
pub fn read_global_config() -> GlobalLlmConfig {
    global_cfg_mutex()
        .lock()
        .map(|g| g.clone())
        .unwrap_or_default()
}

/// Replaces the global LLM config.
pub fn write_global_config(cfg: GlobalLlmConfig) {
    if let Ok(mut guard) = global_cfg_mutex().lock() {
        *guard = cfg;
    }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Calls the Ollama `/api/generate` endpoint synchronously and returns the response text.
///
/// Returns `Err(message)` on HTTP or JSON failure.
pub fn ollama_generate(base_url: &str, model: &str, prompt: &str, system: &str, timeout_secs: u64) -> Result<String, String> {
    use crate::network::http::execute_request as http_execute;

    let body = serde_json::json!({
        "model": model,
        "prompt": prompt,
        "system": system,
        "stream": false,
        "format": "text",
    });
    let body_bytes = body.to_string().into_bytes();
    let headers = vec![("Content-Type".to_string(), "application/json".to_string())];
    let url = format!("{}/api/generate", base_url);
    let resp = http_execute("POST", &url, &headers, Some(&body_bytes), timeout_secs);
    if let Some(err) = resp.error {
        return Err(err);
    }
    let raw = String::from_utf8(resp.body).map_err(|e| e.to_string())?;
    let val: serde_json::Value = serde_json::from_str(&raw).map_err(|e| e.to_string())?;
    val["response"]
        .as_str()
        .map(|s| s.to_string())
        .ok_or_else(|| format!("missing 'response' field: {}", raw))
}

/// Calls the Ollama `/api/generate` endpoint and requests a JSON format response.
pub fn ollama_generate_json(base_url: &str, model: &str, prompt: &str, system: &str, timeout_secs: u64) -> Result<serde_json::Value, String> {
    use crate::network::http::execute_request as http_execute;

    let body = serde_json::json!({
        "model": model,
        "prompt": prompt,
        "system": system,
        "stream": false,
        "format": "json",
    });
    let body_bytes = body.to_string().into_bytes();
    let headers = vec![("Content-Type".to_string(), "application/json".to_string())];
    let url = format!("{}/api/generate", base_url);
    let resp = http_execute("POST", &url, &headers, Some(&body_bytes), timeout_secs);
    if let Some(err) = resp.error {
        return Err(err);
    }
    let raw = String::from_utf8(resp.body).map_err(|e| e.to_string())?;
    let outer: serde_json::Value = serde_json::from_str(&raw).map_err(|e| e.to_string())?;
    let inner_str = outer["response"].as_str().unwrap_or("{}");
    serde_json::from_str(inner_str).map_err(|e| e.to_string())
}

/// Calls the Ollama `/api/embeddings` endpoint and returns the embedding vector.
pub fn ollama_embed(base_url: &str, model: &str, text: &str, timeout_secs: u64) -> Result<Vec<f64>, String> {
    use crate::network::http::execute_request as http_execute;

    let body = serde_json::json!({ "model": model, "prompt": text });
    let body_bytes = body.to_string().into_bytes();
    let headers = vec![("Content-Type".to_string(), "application/json".to_string())];
    let url = format!("{}/api/embeddings", base_url);
    let resp = http_execute("POST", &url, &headers, Some(&body_bytes), timeout_secs);
    if let Some(err) = resp.error {
        return Err(err);
    }
    let raw = String::from_utf8(resp.body).map_err(|e| e.to_string())?;
    let val: serde_json::Value = serde_json::from_str(&raw).map_err(|e| e.to_string())?;
    val["embedding"]
        .as_array()
        .map(|arr| arr.iter().map(|v| v.as_f64().unwrap_or(0.0)).collect())
        .ok_or_else(|| format!("missing 'embedding' field: {}", raw))
}

/// Calls the Ollama `/api/tags` endpoint and returns available model names.
pub fn ollama_list_models(base_url: &str, timeout_secs: u64) -> Vec<String> {
    use crate::network::http::execute_request as http_execute;

    let headers: Vec<(String, String)> = vec![];
    let url = format!("{}/api/tags", base_url);
    let resp = http_execute("GET", &url, &headers, None, timeout_secs);
    if resp.error.is_some() {
        return Vec::new();
    }
    let raw = match String::from_utf8(resp.body) {
        Ok(s) => s,
        Err(_) => return Vec::new(),
    };
    let val: serde_json::Value = match serde_json::from_str(&raw) {
        Ok(v) => v,
        Err(_) => return Vec::new(),
    };
    val["models"]
        .as_array()
        .map(|arr| {
            arr.iter()
                .filter_map(|m| m["name"].as_str().map(|s| s.to_string()))
                .collect()
        })
        .unwrap_or_default()
}

/// Probes the Ollama base URL and returns `true` if it responds.
pub fn ollama_is_available(base_url: &str, timeout_secs: u64) -> bool {
    use crate::network::http::execute_request as http_execute;
    let headers: Vec<(String, String)> = vec![];
    let resp = http_execute("GET", base_url, &headers, None, timeout_secs);
    resp.error.is_none()
}

// ─── LlmTemplate ─────────────────────────────────────────────────────────────

/// Simple `{key}` placeholder template.
///
/// Keys are replaced by values supplied at render time; a missing key leaves the placeholder intact.
pub struct LlmTemplate {
    /// The raw pattern string containing `{key}` placeholders.
    pattern: String,
}

impl LlmTemplate {
    /// Creates a new template from `pattern`.
    pub fn new(pattern: String) -> Self {
        Self { pattern }
    }

    /// Renders the template by substituting each `{key}` with `values[key]`.
    ///
    /// Returns `Err` if a placeholder key not found in `values` is encountered.
    pub fn render(&self, values: &HashMap<String, String>) -> Result<String, String> {
        let chars: Vec<char> = self.pattern.chars().collect();
        let mut out = String::with_capacity(self.pattern.len());
        let mut i = 0;
        while i < chars.len() {
            if chars[i] == '{' {
                if let Some(close) = chars[i..].iter().position(|&c| c == '}') {
                    let key: String = chars[i + 1..i + close].iter().collect();
                    match values.get(&key) {
                        Some(val) => {
                            out.push_str(val);
                            i += close + 1;
                            continue;
                        }
                        None => {
                            return Err(format!("template key '{}' not found in values", key));
                        }
                    }
                }
            }
            out.push(chars[i]);
            i += 1;
        }
        Ok(out)
    }
}

// ─── ChatMessage ─────────────────────────────────────────────────────────────

/// A single message in a chat session history.
#[derive(Clone)]
pub struct ChatMessage {
    /// Role identifier: `"user"`, `"assistant"`, or `"system"`.
    pub role: String,
    /// Message text content.
    pub content: String,
}

// ─── LlmChat ─────────────────────────────────────────────────────────────────

/// Stateful chat session backed by the Ollama `/api/chat` endpoint.
///
/// Maintains a message history that grows with each `complete()` call.
pub struct LlmChat {
    /// Optional system prompt prepended on the first turn (not stored in history).
    system_prompt: String,
    /// Accumulated conversation history.
    history: Vec<ChatMessage>,
}

impl LlmChat {
    /// Creates a new empty chat session with no system prompt.
    pub fn new() -> Self {
        Self {
            system_prompt: String::new(),
            history: Vec::new(),
        }
    }

    /// Sets the system prompt used on all completions.
    pub fn set_system_prompt(&mut self, prompt: String) {
        self.system_prompt = prompt;
    }

    /// Returns the current system prompt.
    pub fn system_prompt(&self) -> &str {
        &self.system_prompt
    }

    /// Appends a message with the given role and content to the history.
    pub fn add_message(&mut self, role: String, content: String) {
        self.history.push(ChatMessage { role, content });
    }

    /// Clears all history entries.
    pub fn clear(&mut self) {
        self.history.clear();
    }

    /// Returns a snapshot of the current history.
    pub fn history(&self) -> &[ChatMessage] {
        &self.history
    }

    /// Sends the current history plus `user_message` to the LLM and returns the assistant reply.
    ///
    /// On success the user message and assistant reply are appended to history.
    pub fn complete(&mut self, base_url: &str, model: &str, timeout_secs: u64) -> Result<String, String> {
        use crate::network::http::execute_request as http_execute;

        let mut messages: Vec<serde_json::Value> = Vec::new();
        if !self.system_prompt.is_empty() {
            messages.push(serde_json::json!({ "role": "system", "content": self.system_prompt }));
        }
        for msg in &self.history {
            messages.push(serde_json::json!({ "role": msg.role, "content": msg.content }));
        }

        let body = serde_json::json!({
            "model": model,
            "messages": messages,
            "stream": false,
        });
        let body_bytes = body.to_string().into_bytes();
        let headers = vec![("Content-Type".to_string(), "application/json".to_string())];
        let url = format!("{}/api/chat", base_url);
        let resp = http_execute("POST", &url, &headers, Some(&body_bytes), timeout_secs);
        if let Some(err) = resp.error {
            return Err(err);
        }
        let raw = String::from_utf8(resp.body).map_err(|e| e.to_string())?;
        let val: serde_json::Value = serde_json::from_str(&raw).map_err(|e| e.to_string())?;
        let reply = val["message"]["content"]
            .as_str()
            .map(|s| s.to_string())
            .ok_or_else(|| format!("missing 'message.content' field: {}", raw))?;

        self.history.push(ChatMessage { role: "assistant".to_string(), content: reply.clone() });
        Ok(reply)
    }
}

impl Default for LlmChat {
    fn default() -> Self {
        Self::new()
    }
}
