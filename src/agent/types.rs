//! Defines the public request, response, and error types exchanged between `AgentState`, `AgentClient`, and their Lua bindings.
//!
//! - `AgentError` classifies failures as network, timeout, format, or model errors and carries a stable Lua-facing error code and a transient-retry flag.
//! - `AgentRequest` and `AgentResponse` carry the callback ID that threads agent dispatch back to the originating Lua callback.


/// Error variants for LLM agent requests; used by [`AgentClient`] and [`AgentState`].
#[derive(Debug, thiserror::Error)]
pub enum AgentError {
    /// Network or connection failure.
    #[error("network error: {0}")]
    Network(String),
    /// Request or response timeout.
    #[error("timeout: {0}")]
    Timeout(String),
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
            Self::Format(_) => "FORMAT_ERROR",
            Self::Model(_) => "MODEL_ERROR",
        }
    }

    /// Returns `true` if this error is likely transient and safe to retry.
    pub fn is_transient(&self) -> bool {
        matches!(self, Self::Network(_) | Self::Timeout(_))
    }

    /// Returns the inner error message string.
    pub fn message(&self) -> &str {
        match self {
            Self::Network(m) | Self::Timeout(m) | Self::Format(m) | Self::Model(m) => m,
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
    /// Response format: `"json"`, `"csv"`, or `"text"`.
    pub format: String,
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
