//! Background transport for LLM agent prompts.
//!
//! - Data type: `AgentClient`.
//! - Implementation: `AgentClient`.

use std::collections::HashSet;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, Mutex};
use crate::agent::types::{AgentError, AgentRequest, AgentResponse};

/// Background HTTP client used by [`LuaAgentRuntime`] and [`LuaAISystemRuntime`] to dispatch prompts.
pub struct AgentClient {
    /// Completed responses waiting to be drained by the next [`AgentClient::poll`] call.
    pending: Arc<Mutex<Vec<AgentResponse>>>,
    /// Callback IDs whose responses are silently discarded when the background thread completes.
    cancelled: Arc<Mutex<HashSet<usize>>>,
    /// Background requests that have not yet completed.
    in_flight: Arc<AtomicUsize>,
}

impl AgentClient {
    /// Creates a new `AgentClient`.
    pub fn new() -> Self {
        Self {
            pending: Arc::new(Mutex::new(Vec::new())),
            cancelled: Arc::new(Mutex::new(HashSet::new())),
            in_flight: Arc::new(AtomicUsize::new(0)),
        }
    }

    /// Dispatch `req` on a background thread; retry on transient errors up to `req.max_retries` times.
    pub fn send_prompt(&self, req: AgentRequest) -> Result<(), String> {
        let pending = Arc::clone(&self.pending);
        let cancelled = Arc::clone(&self.cancelled);
        let in_flight = Arc::clone(&self.in_flight);

        in_flight.fetch_add(1, Ordering::Relaxed);

        std::thread::spawn(move || {
            let callback_id = req.callback_id;
            let result = execute_with_retry(&req);

            in_flight.fetch_sub(1, Ordering::Relaxed);

            let was_cancelled = cancelled
                .lock()
                .map(|mut g| g.remove(&callback_id))
                .unwrap_or(false);

            if was_cancelled {
                return;
            }

            let response = AgentResponse { callback_id, body: result };
            if let Ok(mut guard) = pending.lock() {
                guard.push(response);
            }
        });

        Ok(())
    }

    /// Mark `callback_id` as cancelled; its response is discarded when the background thread completes.
    pub fn cancel(&self, callback_id: usize) {
        if let Ok(mut guard) = self.cancelled.lock() {
            guard.insert(callback_id);
        }
    }

    /// Returns the number of in-flight requests that have not yet completed.
    pub fn in_flight_count(&self) -> usize {
        self.in_flight.load(Ordering::Relaxed)
    }

    /// Drains all completed responses since the last poll.
    pub fn poll(&self) -> Vec<AgentResponse> {
        match self.pending.lock() {
            Ok(mut guard) => std::mem::take(&mut *guard),
            Err(_) => Vec::new(),
        }
    }
}

/// Implement [`Default`] for [`AgentClient`] by delegating to [`AgentClient::new`].
impl Default for AgentClient {
    fn default() -> Self {
        Self::new()
    }
}

/// Retry `req` up to `req.max_retries` times using exponential back-off on transient errors.
fn execute_with_retry(req: &AgentRequest) -> Result<String, AgentError> {
    let mut attempt = 0u32;
    loop {
        match execute_request(req) {
            Ok(body) => return Ok(body),
            Err(e) if e.is_transient() && attempt < req.max_retries => {
                attempt += 1;
                let delay_ms = 500u64 * u64::from(attempt);
                std::thread::sleep(std::time::Duration::from_millis(delay_ms));
            }
            Err(e) => return Err(e),
        }
    }
}

/// Execute one blocking HTTP POST to the LLM backend and return the response body.
fn execute_request(req: &AgentRequest) -> Result<String, AgentError> {
    use crate::network::http::execute_request as http_execute;

    let body = serde_json::json!({
        "model": req.model,
        "prompt": req.prompt,
        "system": req.system,
        "stream": false,
        "format": req.format,
        "options": req.options,
    });

    let body_bytes = body.to_string().into_bytes();
    let headers = vec![
        ("Content-Type".to_string(), "application/json".to_string()),
    ];
    let resp = http_execute("POST", &req.url, &headers, Some(&body_bytes), req.timeout_secs);
    if let Some(err) = resp.error {
        return Err(AgentError::Network(err));
    }
    String::from_utf8(resp.body).map_err(|e| AgentError::Format(e.to_string()))
}
