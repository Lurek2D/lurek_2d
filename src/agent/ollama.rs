//! This file owns `OllamaManager`, plus model and pull result structs for local backend lifecycle control.
//! It checks server reachability, reports versions, lists local models, and tests whether specific models are present.
//! Process helpers start, stop, and restart `ollama serve` through an explicit process policy with health checks.
//! Pull operations run through a bounded worker pool and validate model names against the configured model policy.
//! Deletion supports protected models and explicit confirmation tokens for destructive actions.
//! Open this file when local backend control changes; synchronous chat calls and async prompt transport live nearby.

use std::collections::HashSet;
use std::path::PathBuf;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::mpsc::{self, Receiver, SyncSender, TrySendError};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

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

/// Successful process-start report returned by [`OllamaManager::start_with_status`].
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct OllamaStartStatus {
    /// Process ID of the managed `ollama serve` child.
    pub pid: u32,
    /// Base URL used for subsequent health checks and requests.
    pub base_url: String,
}

/// Process execution policy for managed Ollama lifecycle operations.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct OllamaProcessPolicy {
    /// Explicit binary path; when absent, PATH lookup is allowed only if `trusted_path` is true.
    pub binary_path: Option<PathBuf>,
    /// Whether PATH lookup is allowed when `binary_path` is not configured.
    pub trusted_path: bool,
    /// Total wait budget for the startup health-check loop.
    pub healthcheck_timeout_ms: u64,
    /// Poll interval used while waiting for the server to come up.
    pub healthcheck_poll_ms: u64,
}

impl Default for OllamaProcessPolicy {
    fn default() -> Self {
        Self {
            binary_path: None,
            trusted_path: true,
            healthcheck_timeout_ms: 5_000,
            healthcheck_poll_ms: 100,
        }
    }
}

/// Model management safety policy for pulls and deletes.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct OllamaModelPolicy {
    /// Allowed model prefixes. Empty means no prefix restriction.
    pub allowed_prefixes: Vec<String>,
    /// Protected model names that require a confirmation token to delete.
    pub protected_models: Vec<String>,
    /// Maximum concurrent pull workers.
    pub max_concurrent_pulls: usize,
    /// Maximum queued pull requests before rejecting new ones.
    pub max_queued_pulls: usize,
}

impl Default for OllamaModelPolicy {
    fn default() -> Self {
        Self {
            allowed_prefixes: Vec::new(),
            protected_models: Vec::new(),
            max_concurrent_pulls: 1,
            max_queued_pulls: 4,
        }
    }
}

/// Read-only operational diagnostics for managed Ollama operations.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct OllamaDiagnosticsSnapshot {
    /// Pull requests actively executing.
    pub in_flight_pulls: usize,
    /// Pull requests waiting in the queue.
    pub queued_pulls: usize,
    /// Completed successful pull requests.
    pub completed_pulls: u64,
    /// Failed pull requests.
    pub failed_pulls: u64,
    /// Pull requests rejected before enqueue.
    pub rejected_pulls: u64,
    /// Pull requests cancelled or ignored before delivery.
    pub cancelled_pulls: u64,
    /// Last model name involved in a pull or delete operation.
    pub last_model: Option<String>,
    /// Last operational error recorded by start, pull, or delete.
    pub last_error: Option<String>,
}

#[derive(Default)]
struct OllamaDiagnosticsState {
    completed_pulls: u64,
    failed_pulls: u64,
    rejected_pulls: u64,
    cancelled_pulls: u64,
    last_model: Option<String>,
    last_error: Option<String>,
}

struct QueuedPull {
    callback_id: usize,
    name: String,
}

/// Manages connectivity, process lifecycle, and model operations for a local Ollama instance.
pub struct OllamaManager {
    /// Base URL for the Ollama HTTP API (e.g. `"http://127.0.0.1:11434"`).
    base_url: String,
    /// Child process handle if this manager started Ollama via [`OllamaManager::start`].
    child: Option<std::process::Child>,
    /// Completed async pull results pending delivery via [`OllamaManager::poll`].
    pending: Arc<Mutex<Vec<OllamaPullResult>>>,
    /// Active background pull workers not yet finished.
    in_flight: Arc<AtomicUsize>,
    /// Queued pull requests waiting for a worker.
    queued: Arc<AtomicUsize>,
    /// Monotonically increasing callback ID counter for [`OllamaManager::pull_model`].
    next_id: usize,
    /// Pull callback IDs that should be ignored when work completes.
    cancelled: Arc<Mutex<HashSet<usize>>>,
    /// Safe lifecycle policy for managed process startup.
    process_policy: OllamaProcessPolicy,
    /// Safe model policy for pulls and deletes.
    model_policy: OllamaModelPolicy,
    /// Bounded pull queue sender.
    pull_sender: SyncSender<QueuedPull>,
    /// Shared operational diagnostics.
    diagnostics: Arc<Mutex<OllamaDiagnosticsState>>,
}

impl OllamaManager {
    /// Creates an `OllamaManager` targeting `base_url` with default safe policies.
    pub fn new(base_url: String) -> Self {
        Self::with_policies(
            base_url,
            OllamaProcessPolicy::default(),
            OllamaModelPolicy::default(),
        )
    }

    /// Creates an `OllamaManager` with explicit process and model policies.
    pub fn with_policies(
        base_url: String,
        process_policy: OllamaProcessPolicy,
        model_policy: OllamaModelPolicy,
    ) -> Self {
        let (pull_sender, pull_receiver) = mpsc::sync_channel(model_policy.max_queued_pulls.max(1));
        let pull_receiver = Arc::new(Mutex::new(pull_receiver));
        let pending = Arc::new(Mutex::new(Vec::new()));
        let in_flight = Arc::new(AtomicUsize::new(0));
        let queued = Arc::new(AtomicUsize::new(0));
        let cancelled = Arc::new(Mutex::new(HashSet::new()));
        let diagnostics = Arc::new(Mutex::new(OllamaDiagnosticsState::default()));

        for _ in 0..model_policy.max_concurrent_pulls.max(1) {
            spawn_pull_worker(
                base_url.clone(),
                Arc::clone(&pull_receiver),
                Arc::clone(&pending),
                Arc::clone(&in_flight),
                Arc::clone(&queued),
                Arc::clone(&cancelled),
                Arc::clone(&diagnostics),
            );
        }

        Self {
            base_url,
            child: None,
            pending,
            in_flight,
            queued,
            next_id: 1,
            cancelled,
            process_policy,
            model_policy,
            pull_sender,
            diagnostics,
        }
    }

    /// Returns the base URL this manager was created with.
    pub fn base_url(&self) -> &str {
        &self.base_url
    }

    /// Returns a diagnostics snapshot for managed operations.
    pub fn diagnostics_snapshot(&self) -> OllamaDiagnosticsSnapshot {
        self.diagnostics
            .lock()
            .map(|state| OllamaDiagnosticsSnapshot {
                in_flight_pulls: self.in_flight_count(),
                queued_pulls: self.queued_count(),
                completed_pulls: state.completed_pulls,
                failed_pulls: state.failed_pulls,
                rejected_pulls: state.rejected_pulls,
                cancelled_pulls: state.cancelled_pulls,
                last_model: state.last_model.clone(),
                last_error: state.last_error.clone(),
            })
            .unwrap_or_default()
    }

    /// Returns the names of all locally available models; empty vec if Ollama is not running.
    pub fn model_names(&self) -> Vec<String> {
        self.list_models()
            .into_iter()
            .map(|model| model.name)
            .collect()
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
            .and_then(|value| value.as_str())
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
        let Some(models) = json.get("models").and_then(|value| value.as_array()) else {
            return Vec::new();
        };
        models
            .iter()
            .filter_map(|model| {
                let name = model.get("name")?.as_str()?.to_string();
                let size_bytes = model
                    .get("size")
                    .and_then(|value| value.as_u64())
                    .unwrap_or(0);
                Some(ModelInfo {
                    name,
                    size_gb: size_bytes as f64 / 1_073_741_824.0,
                })
            })
            .collect()
    }

    /// Returns `true` if a model with `name` (or the base name before `:`) is available locally.
    pub fn has_model(&self, name: &str) -> bool {
        self.list_models().iter().any(|model| {
            model.name == name
                || model
                    .name
                    .split_once(':')
                    .map(|(base, _)| base == name)
                    .unwrap_or(false)
        })
    }

    /// Spawns `ollama serve` as a managed child process and returns startup diagnostics on success.
    pub fn start_with_status(&mut self) -> Result<OllamaStartStatus, String> {
        if let Some(child) = &self.child {
            return Ok(OllamaStartStatus {
                pid: child.id(),
                base_url: self.base_url.clone(),
            });
        }

        let executable = if let Some(path) = &self.process_policy.binary_path {
            path.clone()
        } else if self.process_policy.trusted_path {
            PathBuf::from("ollama")
        } else {
            let error = "ollama binary path is not configured and trusted PATH mode is disabled"
                .to_string();
            self.record_error(None, error.clone());
            return Err(error);
        };

        let mut command = std::process::Command::new(&executable);
        command.arg("serve");
        if cfg!(debug_assertions) {
            command.stderr(std::process::Stdio::piped());
        } else {
            command.stderr(std::process::Stdio::null());
        }
        command.stdout(std::process::Stdio::null());

        let mut child = command.spawn().map_err(|error| {
            let message = format!(
                "failed to start ollama binary '{}': {}",
                executable.display(),
                error
            );
            self.record_error(None, message.clone());
            message
        })?;

        let deadline = Instant::now()
            + Duration::from_millis(self.process_policy.healthcheck_timeout_ms.max(100));
        while Instant::now() < deadline {
            if self.is_running() {
                let status = OllamaStartStatus {
                    pid: child.id(),
                    base_url: self.base_url.clone(),
                };
                self.child = Some(child);
                return Ok(status);
            }
            if let Ok(Some(exit_status)) = child.try_wait() {
                let message = format!(
                    "ollama exited before health check completed with status {}",
                    exit_status
                );
                self.record_error(None, message.clone());
                return Err(message);
            }
            std::thread::sleep(Duration::from_millis(
                self.process_policy.healthcheck_poll_ms.max(25),
            ));
        }

        let _ = child.kill();
        let _ = child.wait();
        let message = format!(
            "ollama health check timed out after {} ms",
            self.process_policy.healthcheck_timeout_ms.max(100)
        );
        self.record_error(None, message.clone());
        Err(message)
    }

    /// Backwards-compatible boolean start helper.
    pub fn start(&mut self) -> bool {
        self.start_with_status().is_ok()
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

    /// Dispatches a background model pull for `name`; returns a callback ID or a validation error.
    pub fn pull_model(&mut self, name: String) -> Result<usize, String> {
        validate_ollama_model_name(&name, &self.model_policy)?;
        let callback_id = self.next_id;
        self.next_id = self
            .next_id
            .checked_add(1)
            .ok_or_else(|| "ollama callback ID counter overflowed".to_string())?;
        match self.pull_sender.try_send(QueuedPull {
            callback_id,
            name: name.clone(),
        }) {
            Ok(()) => {
                self.queued.fetch_add(1, Ordering::Relaxed);
                self.record_last_model(Some(name));
                Ok(callback_id)
            }
            Err(TrySendError::Full(_)) => {
                let message = format!(
                    "ollama pull queue is full (max queued {})",
                    self.model_policy.max_queued_pulls.max(1)
                );
                self.record_rejected(Some(name), message.clone());
                Err(message)
            }
            Err(TrySendError::Disconnected(_)) => {
                let message = "ollama pull queue is disconnected".to_string();
                self.record_rejected(Some(name), message.clone());
                Err(message)
            }
        }
    }

    /// Marks a queued or in-flight pull as cancelled so its result is ignored when work completes.
    pub fn cancel_pull(&self, callback_id: usize) -> bool {
        self.cancelled
            .lock()
            .map(|mut cancelled| cancelled.insert(callback_id))
            .unwrap_or(false)
    }

    /// Sends `DELETE /api/delete` to remove `name` from local Ollama storage.
    pub fn delete_model(&self, name: &str, confirm_token: Option<&str>) -> Result<(), String> {
        validate_ollama_model_name(name, &self.model_policy)?;
        if self
            .model_policy
            .protected_models
            .iter()
            .any(|protected| protected.eq_ignore_ascii_case(name))
        {
            let expected = delete_confirmation_token(name);
            if confirm_token != Some(expected.as_str()) {
                let error = format!(
                    "protected model '{}' requires confirm token '{}'",
                    name, expected
                );
                self.record_error(Some(name.to_string()), error.clone());
                return Err(error);
            }
        }

        use crate::network::http::execute_request as http_exec;
        let url = format!("{}/api/delete", self.base_url);
        let body_bytes = serde_json::json!({ "name": name }).to_string().into_bytes();
        let headers = vec![("Content-Type".to_string(), "application/json".to_string())];
        let resp = http_exec("DELETE", &url, &headers, Some(&body_bytes), 10);
        if let Some(error) = resp.error {
            self.record_error(Some(name.to_string()), error.clone());
            return Err(error);
        }
        if !(200..=299).contains(&resp.status) {
            let text = String::from_utf8(resp.body).unwrap_or_default();
            let error = if text.trim().is_empty() {
                format!("ollama delete failed with status {}", resp.status)
            } else {
                format!("ollama delete failed with status {}: {}", resp.status, text)
            };
            self.record_error(Some(name.to_string()), error.clone());
            return Err(error);
        }
        self.record_last_model(Some(name.to_string()));
        Ok(())
    }

    /// Returns the number of active background pull operations.
    pub fn in_flight_count(&self) -> usize {
        self.in_flight.load(Ordering::Relaxed)
    }

    /// Returns the number of queued pull operations.
    pub fn queued_count(&self) -> usize {
        self.queued.load(Ordering::Relaxed)
    }

    /// Drains completed pull results since the last call; used by Lua update helpers.
    pub fn poll(&self) -> Vec<OllamaPullResult> {
        match self.pending.lock() {
            Ok(mut guard) => std::mem::take(&mut *guard),
            Err(_) => Vec::new(),
        }
    }

    fn record_last_model(&self, model: Option<String>) {
        if let Ok(mut diagnostics) = self.diagnostics.lock() {
            diagnostics.last_model = model;
        }
    }

    fn record_rejected(&self, model: Option<String>, error: String) {
        if let Ok(mut diagnostics) = self.diagnostics.lock() {
            diagnostics.rejected_pulls += 1;
            diagnostics.last_model = model;
            diagnostics.last_error = Some(error);
        }
    }

    fn record_error(&self, model: Option<String>, error: String) {
        if let Ok(mut diagnostics) = self.diagnostics.lock() {
            diagnostics.last_model = model;
            diagnostics.last_error = Some(error);
        }
    }
}

fn spawn_pull_worker(
    base_url: String,
    receiver: Arc<Mutex<Receiver<QueuedPull>>>,
    pending: Arc<Mutex<Vec<OllamaPullResult>>>,
    in_flight: Arc<AtomicUsize>,
    queued: Arc<AtomicUsize>,
    cancelled: Arc<Mutex<HashSet<usize>>>,
    diagnostics: Arc<Mutex<OllamaDiagnosticsState>>,
) {
    std::thread::spawn(move || loop {
        let queued_pull = match receiver.lock() {
            Ok(guard) => guard.recv(),
            Err(_) => return,
        };
        let queued_pull = match queued_pull {
            Ok(queued_pull) => queued_pull,
            Err(_) => return,
        };

        queued.fetch_sub(1, Ordering::Relaxed);
        if take_cancelled_pull(&cancelled, queued_pull.callback_id) {
            record_cancelled_pull(&diagnostics, &queued_pull.name);
            continue;
        }
        in_flight.fetch_add(1, Ordering::Relaxed);
        let result = execute_pull(&base_url, &queued_pull.name);
        in_flight.fetch_sub(1, Ordering::Relaxed);

        if take_cancelled_pull(&cancelled, queued_pull.callback_id) {
            record_cancelled_pull(&diagnostics, &queued_pull.name);
            continue;
        }

        if let Ok(mut state) = diagnostics.lock() {
            state.last_model = Some(queued_pull.name.clone());
            match &result {
                Ok(()) => state.completed_pulls += 1,
                Err(error) => {
                    state.failed_pulls += 1;
                    state.last_error = Some(error.clone());
                }
            }
        }

        if let Ok(mut guard) = pending.lock() {
            guard.push(OllamaPullResult {
                callback_id: queued_pull.callback_id,
                result,
            });
        }
    });
}

fn take_cancelled_pull(cancelled: &Arc<Mutex<HashSet<usize>>>, callback_id: usize) -> bool {
    cancelled
        .lock()
        .map(|mut cancelled| cancelled.remove(&callback_id))
        .unwrap_or(false)
}

fn record_cancelled_pull(diagnostics: &Arc<Mutex<OllamaDiagnosticsState>>, model: &str) {
    if let Ok(mut state) = diagnostics.lock() {
        state.cancelled_pulls += 1;
        state.last_model = Some(model.to_string());
        state.last_error = Some("pull cancelled before result delivery".to_string());
    }
}

fn execute_pull(base_url: &str, name: &str) -> Result<(), String> {
    use crate::network::http::execute_request as http_exec;
    let url = format!("{}/api/pull", base_url);
    let body_bytes = serde_json::json!({ "name": name, "stream": false })
        .to_string()
        .into_bytes();
    let headers = vec![("Content-Type".to_string(), "application/json".to_string())];
    let resp = http_exec("POST", &url, &headers, Some(&body_bytes), 3600);
    if let Some(error) = resp.error {
        return Err(error);
    }
    let text = String::from_utf8(resp.body).unwrap_or_default();
    if !(200..=299).contains(&resp.status) {
        return Err(if text.trim().is_empty() {
            format!("ollama pull failed with status {}", resp.status)
        } else {
            format!("ollama pull failed with status {}: {}", resp.status, text)
        });
    }
    if let Ok(json) = serde_json::from_str::<serde_json::Value>(&text) {
        if json.get("status").and_then(|value| value.as_str()) == Some("success") {
            return Ok(());
        }
        if let Some(error) = json.get("error").and_then(|value| value.as_str()) {
            return Err(error.to_string());
        }
    }
    Ok(())
}

fn validate_ollama_model_name(name: &str, policy: &OllamaModelPolicy) -> Result<(), String> {
    let trimmed = name.trim();
    if trimmed.is_empty() {
        return Err("ollama model name must not be empty".to_string());
    }
    if !trimmed
        .chars()
        .all(|ch| ch.is_ascii_alphanumeric() || matches!(ch, '_' | '-' | '.' | ':' | '/'))
    {
        return Err(format!(
            "ollama model '{}' contains unsupported characters",
            name
        ));
    }
    if !policy.allowed_prefixes.is_empty()
        && !policy
            .allowed_prefixes
            .iter()
            .any(|prefix| trimmed.starts_with(prefix))
    {
        return Err(format!(
            "ollama model '{}' is outside the allowed prefix policy",
            name
        ));
    }
    Ok(())
}

fn delete_confirmation_token(name: &str) -> String {
    format!("delete:{}", name)
}
