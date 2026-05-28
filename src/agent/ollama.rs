//! Local Ollama server management: connectivity checks, process lifecycle, and model operations.
//!
//! - Data types: `ModelInfo`, `OllamaPullResult`, `OllamaManager`.
//! - Implementation: `OllamaManager`.
//! - Public methods: `new`, `is_running`, `version`, `list_models`, and 8 more.

use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, Mutex};

/// Info about a locally available Ollama model returned by [`OllamaManager::list_models`].
pub struct ModelInfo {
    /// Model name as returned by the Ollama API (e.g. `"llama3:latest"`).
    pub name: String,
    /// Approximate on-disk size in gigabytes.
    pub size_gb: f64,
}

/// Result of a completed async model pull dispatched by [`OllamaManager::pull_model`].
pub struct OllamaPullResult {
    /// Caller-assigned callback ID matching the value returned by [`OllamaManager::pull_model`].
    pub callback_id: usize,
    /// `Ok(())` on successful download; `Err(message)` on failure.
    pub result: Result<(), String>,
}

/// Manages connectivity, process lifecycle, and model operations for a local Ollama instance.
pub struct OllamaManager {
    /// Base URL for the Ollama HTTP API (e.g. `"http://127.0.0.1:11434"`).
    base_url: String,
    /// Child process handle if this manager started Ollama via [`OllamaManager::start`].
    child: Option<std::process::Child>,
    /// Completed async pull results pending delivery via [`OllamaManager::poll`].
    pending: Arc<Mutex<Vec<OllamaPullResult>>>,
    /// Active background pull threads not yet finished.
    in_flight: Arc<AtomicUsize>,
    /// Monotonically increasing callback ID counter for [`OllamaManager::pull_model`].
    next_id: usize,
}

impl OllamaManager {
    /// Creates an `OllamaManager` targeting `base_url` (e.g. `"http://127.0.0.1:11434"`).
    pub fn new(base_url: String) -> Self {
        Self {
            base_url,
            child: None,
            pending: Arc::new(Mutex::new(Vec::new())),
            in_flight: Arc::new(AtomicUsize::new(0)),
            next_id: 1,
        }
    }

    /// Returns `true` if the Ollama HTTP server responds on the base URL within 5 seconds.
    pub fn is_running(&self) -> bool {
        use crate::network::http::execute_request as http_exec;
        let headers: Vec<(String, String)> = Vec::new();
        let resp = http_exec("GET", &self.base_url, &headers, None, 5);
        resp.error.is_none()
    }

    /// Returns the Ollama version string from `/api/version`, or an empty string if not reachable.
    pub fn version(&self) -> String {
        use crate::network::http::execute_request as http_exec;
        let url = format!("{}/api/version", self.base_url);
        let headers: Vec<(String, String)> = Vec::new();
        let resp = http_exec("GET", &url, &headers, None, 5);
        if resp.error.is_some() {
            return String::new();
        }
        let Ok(text) = String::from_utf8(resp.body) else {
            return String::new();
        };
        let Ok(json) = serde_json::from_str::<serde_json::Value>(&text) else {
            return String::new();
        };
        json.get("version")
            .and_then(|v| v.as_str())
            .unwrap_or("")
            .to_string()
    }

    /// Returns all locally available models from `/api/tags`; empty vec if Ollama is not running.
    pub fn list_models(&self) -> Vec<ModelInfo> {
        use crate::network::http::execute_request as http_exec;
        let url = format!("{}/api/tags", self.base_url);
        let headers: Vec<(String, String)> = Vec::new();
        let resp = http_exec("GET", &url, &headers, None, 5);
        if resp.error.is_some() {
            return Vec::new();
        }
        let Ok(text) = String::from_utf8(resp.body) else {
            return Vec::new();
        };
        let Ok(json) = serde_json::from_str::<serde_json::Value>(&text) else {
            return Vec::new();
        };
        let Some(models) = json.get("models").and_then(|m| m.as_array()) else {
            return Vec::new();
        };
        models
            .iter()
            .filter_map(|m| {
                let name = m.get("name")?.as_str()?.to_string();
                let size_bytes = m.get("size").and_then(|s| s.as_u64()).unwrap_or(0);
                let size_gb = size_bytes as f64 / 1_073_741_824.0;
                Some(ModelInfo { name, size_gb })
            })
            .collect()
    }

    /// Returns `true` if a model with `name` (or the base name before `:`) is available locally.
    pub fn has_model(&self, name: &str) -> bool {
        self.list_models().iter().any(|m| {
            m.name == name
                || m.name
                    .split_once(':')
                    .map(|(base, _)| base == name)
                    .unwrap_or(false)
        })
    }

    /// Spawns `ollama serve` as a managed child process; returns `true` on success.
    pub fn start(&mut self) -> bool {
        if self.child.is_some() {
            return true;
        }
        match std::process::Command::new("ollama")
            .args(["serve"])
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .spawn()
        {
            Ok(child) => {
                self.child = Some(child);
                // Allow ~500 ms for the server to initialise before the caller's isRunning check.
                std::thread::sleep(std::time::Duration::from_millis(500));
                true
            }
            Err(_) => false,
        }
    }

    /// Kills the Ollama child process started by this manager; returns `true` if it was running.
    pub fn stop(&mut self) -> bool {
        if let Some(mut child) = self.child.take() {
            let _ = child.kill();
            let _ = child.wait();
            return true;
        }
        false
    }

    /// Stops then starts a fresh Ollama process; returns `true` if the restart succeeded.
    pub fn restart(&mut self) -> bool {
        self.stop();
        self.start()
    }

    /// Dispatches a background model pull for `name`; returns the callback ID for use with [`OllamaManager::poll`].
    pub fn pull_model(&mut self, name: String) -> usize {
        let callback_id = self.next_id;
        self.next_id += 1;
        let url = format!("{}/api/pull", self.base_url);
        let pending = Arc::clone(&self.pending);
        let in_flight = Arc::clone(&self.in_flight);
        in_flight.fetch_add(1, Ordering::Relaxed);
        std::thread::spawn(move || {
            use crate::network::http::execute_request as http_exec;
            let body_bytes = serde_json::json!({ "name": name, "stream": false })
                .to_string()
                .into_bytes();
            let headers = vec![("Content-Type".to_string(), "application/json".to_string())];
            let resp = http_exec("POST", &url, &headers, Some(&body_bytes), 3600);
            in_flight.fetch_sub(1, Ordering::Relaxed);
            let result = if let Some(err) = resp.error {
                Err(err)
            } else if let Ok(text) = String::from_utf8(resp.body) {
                if let Ok(json) = serde_json::from_str::<serde_json::Value>(&text) {
                    if json.get("status").and_then(|s| s.as_str()) == Some("success") {
                        Ok(())
                    } else {
                        let msg = json
                            .get("error")
                            .and_then(|e| e.as_str())
                            .unwrap_or("pull failed")
                            .to_string();
                        Err(msg)
                    }
                } else {
                    Ok(())
                }
            } else {
                Ok(())
            };
            if let Ok(mut guard) = pending.lock() {
                guard.push(OllamaPullResult { callback_id, result });
            }
        });
        callback_id
    }

    /// Sends `DELETE /api/delete` to remove `name` from local Ollama storage; returns `true` on success.
    pub fn delete_model(&self, name: &str) -> bool {
        use crate::network::http::execute_request as http_exec;
        let url = format!("{}/api/delete", self.base_url);
        let body_bytes = serde_json::json!({ "name": name }).to_string().into_bytes();
        let headers = vec![("Content-Type".to_string(), "application/json".to_string())];
        let resp = http_exec("DELETE", &url, &headers, Some(&body_bytes), 10);
        resp.error.is_none()
    }

    /// Returns the number of active background pull operations.
    pub fn in_flight_count(&self) -> usize {
        self.in_flight.load(Ordering::Relaxed)
    }

    /// Drains completed pull results since the last call; used by `LuaOllamaManager::update`.
    pub fn poll(&self) -> Vec<OllamaPullResult> {
        match self.pending.lock() {
            Ok(mut g) => std::mem::take(&mut *g),
            Err(_) => Vec::new(),
        }
    }
}
