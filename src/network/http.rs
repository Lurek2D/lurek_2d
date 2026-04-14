//! HTTP client for async web requests on the network thread.
//!
//! Executes HTTP requests using the `ureq` crate. All requests run on the
//! dedicated network thread (see [`super::net_thread`]); the Lua API layer
//! only sees the request/response IDs and completion callbacks.
//!
//! # Supported methods
//!
//! GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS.
//!
//! # TLS
//!
//! Uses `rustls` (via ureq default features) for HTTPS — no OpenSSL dependency.

use std::io::Read;
use std::time::Duration;

use log::{debug, warn};

/// Result of an HTTP request execution.
///
/// # Fields
/// - `status` — HTTP status code (0 if connection failed before receiving a response).
/// - `body` — Response body bytes.
/// - `headers` — Response headers as key-value pairs.
/// - `error` — Error message if the request failed (`None` on success).
pub struct HttpResponse {
    /// HTTP status code (0 if the request never reached a server).
    pub status: u16,
    /// Response body as raw bytes.
    pub body: Vec<u8>,
    /// Response headers as `(name, value)` pairs.
    pub headers: Vec<(String, String)>,
    /// Error message if the request failed; `None` on success.
    pub error: Option<String>,
}

/// Execute an HTTP request synchronously (called from the network thread).
///
/// # Parameters
/// - `method` — HTTP method string (e.g. `"GET"`, `"POST"`).
/// - `url` — Target URL including scheme (e.g. `"https://api.example.com/data"`).
/// - `headers` — Request headers as `(name, value)` pairs.
/// - `body` — Optional request body bytes.
/// - `timeout_secs` — Request timeout in seconds (0 for no timeout).
///
/// # Returns
/// [`HttpResponse`] — always returns a response (errors encoded in the `error` field).
pub fn execute_request(
    method: &str,
    url: &str,
    headers: &[(String, String)],
    body: Option<&[u8]>,
    timeout_secs: u64,
) -> HttpResponse {
    debug!("HTTP {} {}", method, url);

    let agent = if timeout_secs > 0 {
        ureq::Agent::config_builder()
            .timeout_global(Some(Duration::from_secs(timeout_secs)))
            .build()
            .new_agent()
    } else {
        ureq::Agent::new_with_defaults()
    };

    let result = execute_with_agent(&agent, method, url, headers, body);

    match result {
        Ok(resp) => resp,
        Err(e) => {
            warn!("HTTP request failed: {} {} — {}", method, url, e);
            HttpResponse {
                status: 0,
                body: Vec::new(),
                headers: Vec::new(),
                error: Some(e),
            }
        }
    }
}

/// Internal: execute the request using a configured agent.
fn execute_with_agent(
    agent: &ureq::Agent,
    method: &str,
    url: &str,
    headers: &[(String, String)],
    body: Option<&[u8]>,
) -> Result<HttpResponse, String> {
    let mut request = match method.to_uppercase().as_str() {
        "GET" => agent.get(url),
        "POST" => agent.post(url),
        "PUT" => agent.put(url),
        "DELETE" => agent.delete(url),
        "PATCH" => agent.patch(url),
        "HEAD" => agent.head(url),
        "OPTIONS" => agent.request("OPTIONS", url),
        other => return Err(format!("unsupported HTTP method: {other}")),
    };

    for (name, value) in headers {
        request = request.header(name, value);
    }

    let response = if let Some(body_data) = body {
        request
            .send(body_data)
            .map_err(|e| format!("request error: {e}"))?
    } else {
        request
            .call()
            .map_err(|e| format!("request error: {e}"))?
    };

    let status = response.status();

    // Collect response headers
    let mut resp_headers = Vec::new();
    for name in response.headers().keys() {
        if let Some(value) = response.headers().get(name) {
            resp_headers.push((name.to_string(), value.to_string()));
        }
    }

    // Read response body
    let mut body_bytes = Vec::new();
    response
        .into_body()
        .read_to_end(&mut body_bytes)
        .map_err(|e| format!("failed to read response body: {e}"))?;

    Ok(HttpResponse {
        status,
        body: body_bytes,
        headers: resp_headers,
        error: None,
    })
}
