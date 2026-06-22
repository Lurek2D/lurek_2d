//! Owns agent behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps agent data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how client data is validated, transformed, or stored before neighboring systems use it.
//! Owns agent behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on client behavior while Lua registration stays elsewhere.
//! Documents where agent callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
//! Use this file when changing client defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the agent state that can explain them while keeping call sites explicit.

use crate::agent::types::{AgentError, AgentRequest, AgentResponse};
use crate::network::http::HttpResponse;
use std::collections::HashSet;
use std::sync::atomic::{AtomicU64, AtomicUsize, Ordering};
use std::sync::mpsc::{self, Receiver, SyncSender, TrySendError};
use std::sync::{Arc, Mutex};
use std::time::Instant;

/// Transport abstraction used by [`AgentClient`] to execute one blocking request.
pub trait AgentTransport: Send + Sync {
    /// Execute the outbound prompt request and return the backend response text.
    fn execute(&self, req: &AgentRequest) -> Result<String, AgentError>;
}

/// Default HTTP-backed transport used by production agent clients.
#[derive(Default)]
pub struct HttpAgentTransport;

impl AgentTransport for HttpAgentTransport {
    fn execute(&self, req: &AgentRequest) -> Result<String, AgentError> {
        use crate::network::http::execute_request as http_execute;

        let body = serde_json::json!({
            "model": req.model,
            "prompt": req.prompt,
            "system": req.system,
            "stream": false,
            "format": req.format.as_str(),
            "options": req.options,
        });

        let body_bytes = body.to_string().into_bytes();
        let headers = vec![("Content-Type".to_string(), "application/json".to_string())];
        let resp = http_execute(
            "POST",
            &req.url,
            &headers,
            Some(&body_bytes),
            req.timeout_secs,
        );
        classify_transport_response(resp, req)
    }
}

/// Fixed transport limits and retry behavior for [`AgentClient`].
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AgentClientConfig {
    /// Number of worker threads allowed to execute requests concurrently.
    pub max_in_flight: usize,
    /// Number of queued requests accepted before returning `QueueFull`.
    pub max_queue_depth: usize,
    /// Base retry backoff in milliseconds.
    pub retry_backoff_ms: u64,
}

impl Default for AgentClientConfig {
    fn default() -> Self {
        Self {
            max_in_flight: 4,
            max_queue_depth: 64,
            retry_backoff_ms: 500,
        }
    }
}

/// Read-only transport diagnostics snapshot exposed to Rust tests and Lua bindings.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct AgentDiagnosticsSnapshot {
    /// Requests actively executing inside worker threads.
    pub in_flight: usize,
    /// Requests waiting in the bounded queue.
    pub queued: usize,
    /// Requests cancelled before completion.
    pub cancelled: u64,
    /// Successfully completed requests.
    pub completed: u64,
    /// Requests failed with any error.
    pub failed: u64,
    /// Requests rejected before enqueue because the queue was full.
    pub queue_rejected: u64,
    /// Requests that failed due to a network error.
    pub network_failures: u64,
    /// Requests that failed due to a timeout.
    pub timeout_failures: u64,
    /// Requests that failed due to invalid request validation.
    pub invalid_request_failures: u64,
    /// Requests that failed due to backend availability or status issues.
    pub backend_failures: u64,
    /// Requests that failed due to response format parsing.
    pub format_failures: u64,
    /// Requests that failed due to model-specific issues.
    pub model_failures: u64,
    /// Average completed-or-failed execution latency in milliseconds.
    pub avg_latency_ms: u64,
    /// Last backend host accepted for execution.
    pub last_endpoint_host: Option<String>,
    /// Last model name accepted for execution.
    pub last_model: Option<String>,
}

#[derive(Default)]
struct AgentDiagnosticsState {
    cancelled: u64,
    completed: u64,
    failed: u64,
    queue_rejected: u64,
    network_failures: u64,
    timeout_failures: u64,
    invalid_request_failures: u64,
    backend_failures: u64,
    format_failures: u64,
    model_failures: u64,
    last_endpoint_host: Option<String>,
    last_model: Option<String>,
}

struct QueuedRequest {
    req: AgentRequest,
}

/// Background HTTP client used by Lua runtimes to dispatch prompts through a bounded worker pool.
pub struct AgentClient {
    /// Completed responses waiting to be drained by the next [`AgentClient::poll`] call.
    pending: Arc<Mutex<Vec<AgentResponse>>>,
    /// Callback IDs whose responses are silently discarded when work completes.
    cancelled: Arc<Mutex<HashSet<usize>>>,
    /// Background requests currently executing.
    in_flight: Arc<AtomicUsize>,
    /// Requests queued for workers but not yet executing.
    queued: Arc<AtomicUsize>,
    /// Bounded sender used by callers to enqueue requests.
    sender: SyncSender<QueuedRequest>,
    /// Shared diagnostics state.
    diagnostics: Arc<Mutex<AgentDiagnosticsState>>,
    /// Total execution latency accumulated across completed and failed requests.
    total_latency_ms: Arc<AtomicU64>,
    /// Total completed and failed requests used to compute average latency.
    total_finished: Arc<AtomicU64>,
}

impl AgentClient {
    /// Creates a new `AgentClient` with default concurrency and queue limits.
    pub fn new() -> Self {
        Self::with_config(AgentClientConfig::default())
    }

    /// Creates a new `AgentClient` with the provided config and the default HTTP transport.
    pub fn with_config(config: AgentClientConfig) -> Self {
        Self::with_transport(config, Arc::new(HttpAgentTransport))
    }

    /// Creates a new `AgentClient` using an injected transport, primarily for tests.
    pub fn with_transport(config: AgentClientConfig, transport: Arc<dyn AgentTransport>) -> Self {
        let max_in_flight = config.max_in_flight.max(1);
        let max_queue_depth = config.max_queue_depth.max(1);
        let (sender, receiver) = mpsc::sync_channel(max_queue_depth);
        let receiver = Arc::new(Mutex::new(receiver));
        let pending = Arc::new(Mutex::new(Vec::new()));
        let cancelled = Arc::new(Mutex::new(HashSet::new()));
        let in_flight = Arc::new(AtomicUsize::new(0));
        let queued = Arc::new(AtomicUsize::new(0));
        let diagnostics = Arc::new(Mutex::new(AgentDiagnosticsState::default()));
        let total_latency_ms = Arc::new(AtomicU64::new(0));
        let total_finished = Arc::new(AtomicU64::new(0));

        let worker_shared = AgentWorkerShared {
            receiver: Arc::clone(&receiver),
            pending: Arc::clone(&pending),
            cancelled: Arc::clone(&cancelled),
            in_flight: Arc::clone(&in_flight),
            queued: Arc::clone(&queued),
            diagnostics: Arc::clone(&diagnostics),
            total_latency_ms: Arc::clone(&total_latency_ms),
            total_finished: Arc::clone(&total_finished),
            transport: Arc::clone(&transport),
            retry_backoff_ms: config.retry_backoff_ms,
        };

        for _ in 0..max_in_flight {
            spawn_worker(worker_shared.clone());
        }

        Self {
            pending,
            cancelled,
            in_flight,
            queued,
            sender,
            diagnostics,
            total_latency_ms,
            total_finished,
        }
    }

    /// Dispatch `req` through the bounded queue; returns `QueueFull` when capacity is exhausted.
    pub fn send_prompt(&self, req: AgentRequest) -> Result<(), AgentError> {
        match self.sender.try_send(QueuedRequest { req }) {
            Ok(()) => {
                self.queued.fetch_add(1, Ordering::Relaxed);
                Ok(())
            }
            Err(TrySendError::Full(queued_req)) => {
                self.record_queue_rejected(&queued_req.req);
                Err(AgentError::QueueFull(format!(
                    "agent request queue is full (max queued {})",
                    self.queued.load(Ordering::Relaxed)
                )))
            }
            Err(TrySendError::Disconnected(_)) => Err(AgentError::BackendUnavailable(
                "agent worker queue is disconnected".to_string(),
            )),
        }
    }

    /// Mark `callback_id` as cancelled; queued requests are skipped and in-flight results are discarded.
    pub fn cancel(&self, callback_id: usize) {
        if let Ok(mut guard) = self.cancelled.lock() {
            guard.insert(callback_id);
        }
    }

    /// Returns the number of in-flight requests currently executing.
    pub fn in_flight_count(&self) -> usize {
        self.in_flight.load(Ordering::Relaxed)
    }

    /// Returns the number of requests waiting in the bounded queue.
    pub fn queued_count(&self) -> usize {
        self.queued.load(Ordering::Relaxed)
    }

    /// Returns a diagnostics snapshot.
    pub fn diagnostics_snapshot(&self) -> AgentDiagnosticsSnapshot {
        let avg_latency_ms = match self.total_finished.load(Ordering::Relaxed) {
            0 => 0,
            finished => self.total_latency_ms.load(Ordering::Relaxed) / finished,
        };

        let state = self
            .diagnostics
            .lock()
            .map(|state| AgentDiagnosticsSnapshot {
                in_flight: self.in_flight_count(),
                queued: self.queued_count(),
                cancelled: state.cancelled,
                completed: state.completed,
                failed: state.failed,
                queue_rejected: state.queue_rejected,
                network_failures: state.network_failures,
                timeout_failures: state.timeout_failures,
                invalid_request_failures: state.invalid_request_failures,
                backend_failures: state.backend_failures,
                format_failures: state.format_failures,
                model_failures: state.model_failures,
                avg_latency_ms,
                last_endpoint_host: state.last_endpoint_host.clone(),
                last_model: state.last_model.clone(),
            })
            .unwrap_or_default();

        state
    }

    /// Drains all completed responses since the last poll.
    pub fn poll(&self) -> Vec<AgentResponse> {
        match self.pending.lock() {
            Ok(mut guard) => std::mem::take(&mut *guard),
            Err(_) => Vec::new(),
        }
    }

    fn record_queue_rejected(&self, req: &AgentRequest) {
        if let Ok(mut diagnostics) = self.diagnostics.lock() {
            diagnostics.queue_rejected += 1;
            diagnostics.last_endpoint_host = endpoint_host(&req.url);
            diagnostics.last_model = Some(req.model.clone());
        }
    }
}

/// Implement [`Default`] for [`AgentClient`] by delegating to [`AgentClient::new`].
impl Default for AgentClient {
    fn default() -> Self {
        Self::new()
    }
}

#[derive(Clone)]
struct AgentWorkerShared {
    receiver: Arc<Mutex<Receiver<QueuedRequest>>>,
    pending: Arc<Mutex<Vec<AgentResponse>>>,
    cancelled: Arc<Mutex<HashSet<usize>>>,
    in_flight: Arc<AtomicUsize>,
    queued: Arc<AtomicUsize>,
    diagnostics: Arc<Mutex<AgentDiagnosticsState>>,
    total_latency_ms: Arc<AtomicU64>,
    total_finished: Arc<AtomicU64>,
    transport: Arc<dyn AgentTransport>,
    retry_backoff_ms: u64,
}

fn spawn_worker(shared: AgentWorkerShared) {
    std::thread::spawn(move || loop {
        let queued_req = match shared.receiver.lock() {
            Ok(guard) => guard.recv(),
            Err(_) => return,
        };
        let queued_req = match queued_req {
            Ok(queued_req) => queued_req,
            Err(_) => return,
        };

        shared.queued.fetch_sub(1, Ordering::Relaxed);
        let callback_id = queued_req.req.callback_id;
        if take_cancelled(&shared.cancelled, callback_id) {
            record_cancelled(&shared.diagnostics, &queued_req.req);
            continue;
        }

        shared.in_flight.fetch_add(1, Ordering::Relaxed);
        record_last_target(&shared.diagnostics, &queued_req.req);
        let started_at = Instant::now();
        let result = execute_with_retry(
            shared.transport.as_ref(),
            &queued_req.req,
            shared.retry_backoff_ms,
        );
        let elapsed_ms = started_at.elapsed().as_millis() as u64;
        shared
            .total_latency_ms
            .fetch_add(elapsed_ms, Ordering::Relaxed);
        shared.total_finished.fetch_add(1, Ordering::Relaxed);
        shared.in_flight.fetch_sub(1, Ordering::Relaxed);

        if take_cancelled(&shared.cancelled, callback_id) {
            record_cancelled(&shared.diagnostics, &queued_req.req);
            continue;
        }

        record_finished(&shared.diagnostics, &result);
        let response = AgentResponse {
            callback_id,
            body: result,
        };
        if let Ok(mut guard) = shared.pending.lock() {
            guard.push(response);
        }
    });
}

/// Retry `req` up to `req.max_retries` times using linear back-off on transient errors.
fn execute_with_retry(
    transport: &dyn AgentTransport,
    req: &AgentRequest,
    retry_backoff_ms: u64,
) -> Result<String, AgentError> {
    let mut attempt = 0u32;
    loop {
        match transport.execute(req) {
            Ok(body) => return Ok(body),
            Err(error) if error.is_transient() && attempt < req.max_retries => {
                attempt += 1;
                let delay_ms = retry_backoff_ms.saturating_mul(u64::from(attempt.max(1)));
                std::thread::sleep(std::time::Duration::from_millis(delay_ms.max(1)));
            }
            Err(error) => return Err(error),
        }
    }
}

fn classify_transport_response(
    resp: HttpResponse,
    req: &AgentRequest,
) -> Result<String, AgentError> {
    if let Some(error) = resp.error {
        let lowered = error.to_ascii_lowercase();
        if lowered.contains("timed out") || lowered.contains("timeout") {
            return Err(AgentError::Timeout(error));
        }
        return Err(AgentError::Network(error));
    }

    let raw =
        String::from_utf8(resp.body).map_err(|error| AgentError::Format(error.to_string()))?;
    if !(200..=299).contains(&resp.status) {
        return Err(classify_http_error(resp.status, &resp.headers, &raw, req));
    }

    Ok(extract_backend_text(raw))
}

fn classify_http_error(
    status: u16,
    headers: &[(String, String)],
    raw: &str,
    req: &AgentRequest,
) -> AgentError {
    let detail = extract_backend_error(raw);
    match status {
        400 | 404 | 409 | 422 => {
            if detail.to_ascii_lowercase().contains("model") {
                AgentError::Model(format!("{} ({})", detail, req.model))
            } else {
                AgentError::InvalidRequest(detail)
            }
        }
        401 | 403 => AgentError::Unauthorized(detail),
        429 => AgentError::RateLimited {
            message: detail,
            retry_after_secs: parse_retry_after(headers),
        },
        500..=599 => AgentError::BackendUnavailable(detail),
        _ => AgentError::HttpStatus {
            status,
            message: detail,
        },
    }
}

fn extract_backend_text(raw: String) -> String {
    let parsed = serde_json::from_str::<serde_json::Value>(&raw);
    if let Ok(json) = parsed {
        if let Some(response) = json.get("response").and_then(|value| value.as_str()) {
            return response.to_string();
        }
    }
    raw
}

fn extract_backend_error(raw: &str) -> String {
    if let Ok(json) = serde_json::from_str::<serde_json::Value>(raw) {
        if let Some(error) = json.get("error").and_then(|value| value.as_str()) {
            return error.to_string();
        }
    }
    raw.trim().to_string()
}

fn parse_retry_after(headers: &[(String, String)]) -> Option<u64> {
    headers.iter().find_map(|(name, value)| {
        if name.eq_ignore_ascii_case("retry-after") {
            value.trim().parse::<u64>().ok()
        } else {
            None
        }
    })
}

fn endpoint_host(url: &str) -> Option<String> {
    let uri: Result<ureq::http::Uri, _> = url.parse();
    uri.ok()
        .and_then(|uri| uri.host().map(|host| host.to_string()))
}

fn take_cancelled(cancelled: &Arc<Mutex<HashSet<usize>>>, callback_id: usize) -> bool {
    cancelled
        .lock()
        .map(|mut guard| guard.remove(&callback_id))
        .unwrap_or(false)
}

fn record_last_target(diagnostics: &Arc<Mutex<AgentDiagnosticsState>>, req: &AgentRequest) {
    if let Ok(mut diagnostics) = diagnostics.lock() {
        diagnostics.last_endpoint_host = endpoint_host(&req.url);
        diagnostics.last_model = Some(req.model.clone());
    }
}

fn record_cancelled(diagnostics: &Arc<Mutex<AgentDiagnosticsState>>, req: &AgentRequest) {
    if let Ok(mut diagnostics) = diagnostics.lock() {
        diagnostics.cancelled += 1;
        diagnostics.last_endpoint_host = endpoint_host(&req.url);
        diagnostics.last_model = Some(req.model.clone());
    }
}

fn record_finished(
    diagnostics: &Arc<Mutex<AgentDiagnosticsState>>,
    result: &Result<String, AgentError>,
) {
    let Ok(mut diagnostics) = diagnostics.lock() else {
        return;
    };

    match result {
        Ok(_) => diagnostics.completed += 1,
        Err(AgentError::Network(_)) => {
            diagnostics.failed += 1;
            diagnostics.network_failures += 1;
        }
        Err(AgentError::Timeout(_)) => {
            diagnostics.failed += 1;
            diagnostics.timeout_failures += 1;
        }
        Err(
            AgentError::InvalidRequest(_)
            | AgentError::Unauthorized(_)
            | AgentError::QueueFull(_)
            | AgentError::Cancelled(_),
        ) => {
            diagnostics.failed += 1;
            diagnostics.invalid_request_failures += 1;
        }
        Err(
            AgentError::HttpStatus { .. }
            | AgentError::RateLimited { .. }
            | AgentError::BackendUnavailable(_),
        ) => {
            diagnostics.failed += 1;
            diagnostics.backend_failures += 1;
        }
        Err(AgentError::Format(_)) => {
            diagnostics.failed += 1;
            diagnostics.format_failures += 1;
        }
        Err(AgentError::Model(_)) => {
            diagnostics.failed += 1;
            diagnostics.model_failures += 1;
        }
    }
}
