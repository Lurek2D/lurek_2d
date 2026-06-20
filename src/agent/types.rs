//! This file owns `AgentError`, `AgentRequest`, and `AgentResponse`, the shared payload contract for agent I/O.
//! It keeps callback ids, prompt envelopes, response bodies, and stable error codes aligned across runtime layers.
//! Error helpers classify retryable failures and expose Lua-safe codes without coupling callers to transport details.
//! Open this file when request or response structure changes; client execution and state assembly live in siblings.

use std::fmt;

/// Structured response format accepted by agent requests.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum AgentResponseFormat {
    /// Ask the backend for plain text.
    Text,
    /// Ask the backend for a JSON object or array encoded as text.
    Json,
    /// Ask the backend for CSV text.
    Csv,
}

impl AgentResponseFormat {
    /// Parse a Lua-facing format string into a validated enum value.
    pub fn parse(value: &str) -> Result<Self, AgentError> {
        match value.trim().to_ascii_lowercase().as_str() {
            "text" => Ok(Self::Text),
            "json" => Ok(Self::Json),
            "csv" => Ok(Self::Csv),
            other => Err(AgentError::InvalidRequest(format!(
                "unsupported response format '{}'; expected one of: text, json, csv",
                other
            ))),
        }
    }

    /// Return the wire-format string expected by the backend.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Text => "text",
            Self::Json => "json",
            Self::Csv => "csv",
        }
    }
}

impl fmt::Display for AgentResponseFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

/// Error variants for LLM agent requests; used by [`AgentClient`] and [`AgentState`].
#[derive(Debug, thiserror::Error)]
pub enum AgentError {
    /// Network or connection failure before receiving an HTTP response.
    #[error("network error: {0}")]
    Network(String),
    /// Request or response timeout.
    #[error("timeout: {0}")]
    Timeout(String),
    /// HTTP endpoint rejected the request with a non-auth, non-rate-limit status.
    #[error("http status {status}: {message}")]
    HttpStatus {
        /// HTTP status code returned by the backend.
        status: u16,
        /// Human-readable backend detail.
        message: String,
    },
    /// Backend rate-limited the request.
    #[error("rate limited: {message}")]
    RateLimited {
        /// Human-readable backend detail.
        message: String,
        /// Optional retry delay hint from the backend.
        retry_after_secs: Option<u64>,
    },
    /// Backend rejected the request for authentication or authorization reasons.
    #[error("unauthorized: {0}")]
    Unauthorized(String),
    /// Request failed local validation before dispatch.
    #[error("invalid request: {0}")]
    InvalidRequest(String),
    /// Backend was reachable but currently unavailable.
    #[error("backend unavailable: {0}")]
    BackendUnavailable(String),
    /// Request was explicitly cancelled or ignored after cancellation.
    #[error("cancelled: {0}")]
    Cancelled(String),
    /// Local bounded queue rejected the request.
    #[error("queue full: {0}")]
    QueueFull(String),
    /// Response payload could not be parsed.
    #[error("format error: {0}")]
    Format(String),
    /// Model-level rejection or error.
    #[error("model error: {0}")]
    Model(String),
}

impl AgentError {
    /// Returns the stable Lua-facing error code for this variant.
    pub fn code(&self) -> &'static str {
        match self {
            Self::Network(_) => "NETWORK_ERROR",
            Self::Timeout(_) => "TIMEOUT",
            Self::HttpStatus { .. } => "HTTP_STATUS",
            Self::RateLimited { .. } => "RATE_LIMITED",
            Self::Unauthorized(_) => "UNAUTHORIZED",
            Self::InvalidRequest(_) => "INVALID_REQUEST",
            Self::BackendUnavailable(_) => "BACKEND_UNAVAILABLE",
            Self::Cancelled(_) => "CANCELLED",
            Self::QueueFull(_) => "QUEUE_FULL",
            Self::Format(_) => "FORMAT_ERROR",
            Self::Model(_) => "MODEL_ERROR",
        }
    }

    /// Returns `true` if this error is likely transient and safe to retry.
    pub fn is_transient(&self) -> bool {
        match self {
            Self::Network(_)
            | Self::Timeout(_)
            | Self::BackendUnavailable(_)
            | Self::RateLimited { .. } => true,
            Self::HttpStatus { status, .. } => *status >= 500,
            _ => false,
        }
    }

    /// Returns the inner error message string.
    pub fn message(&self) -> &str {
        match self {
            Self::Network(m)
            | Self::Timeout(m)
            | Self::Unauthorized(m)
            | Self::InvalidRequest(m)
            | Self::BackendUnavailable(m)
            | Self::Cancelled(m)
            | Self::QueueFull(m)
            | Self::Format(m)
            | Self::Model(m) => m,
            Self::HttpStatus { message, .. } | Self::RateLimited { message, .. } => message,
        }
    }

    /// Returns a backend retry hint when one is available.
    pub fn retry_after_secs(&self) -> Option<u64> {
        match self {
            Self::RateLimited {
                retry_after_secs, ..
            } => *retry_after_secs,
            _ => None,
        }
    }
}

/// Single outbound LLM prompt request built by [`AgentState`] and dispatched by [`AgentClient`].
pub struct AgentRequest {
    /// Endpoint URL for the LLM backend.
    pub url: String,
    /// Model identifier.
    pub model: String,
    /// User-facing prompt/instruction.
    pub prompt: String,
    /// System block injected before the prompt.
    pub system: String,
    /// Response format validated before dispatch.
    pub format: AgentResponseFormat,
    /// Optional model parameters.
    pub options: serde_json::Value,
    /// Caller-assigned ID echoed back in the response.
    pub callback_id: usize,
    /// Maximum retry attempts on transient failure (0 = no retry).
    pub max_retries: u32,
    /// Per-request timeout in seconds.
    pub timeout_secs: u64,
}

/// Completed LLM response returned by [`AgentClient::poll`]; matched to a request by `callback_id`.
pub struct AgentResponse {
    /// Echoed callback ID from the originating request.
    pub callback_id: usize,
    /// Raw response body or an error.
    pub body: Result<String, AgentError>,
}

impl AgentResponse {
    /// Returns `true` if the response body is `Ok`.
    pub fn is_ok(&self) -> bool {
        self.body.is_ok()
    }

    /// Returns the response text if successful; `None` on error.
    pub fn text(&self) -> Option<&str> {
        self.body.as_deref().ok()
    }
}
