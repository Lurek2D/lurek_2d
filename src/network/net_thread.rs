//! Background network thread that owns all blocking I/O for HTTP, TCP, and WebSocket work.
//! Uses MPSC request and response channels to keep the game thread isolated from latency.
//! Drives transport activity through typed request and response enums.
//! Models connection state with explicit TCP and WebSocket event types.
//! Spawns, polls, and shuts down the runtime while preserving request ordering.
//! Routes completed results back with correlation ids for outstanding work.
//! Keeps the blocking transport surface off the main loop.

use super::http;
use super::tcp::TcpConnectionManager;
use super::websocket::WebSocketManager;
use std::sync::mpsc;
use std::thread;
/// Commands sent from the game thread to the background network thread.
#[derive(Debug)]
pub enum NetworkRequest {
    /// Perform a blocking HTTP request and post a `NetworkResponse::HttpResponse` when done.
    HttpRequest {
        /// Caller-assigned correlation ID echoed back in the response.
        id: u64,
        /// HTTP method string (e.g. `"GET"`, `"POST"`).
        method: String,
        /// Target URL.
        url: String,
        /// Additional request headers.
        headers: Vec<(String, String)>,
        /// Optional request body bytes.
        body: Option<Vec<u8>>,
        /// Request timeout in seconds; `0` means no timeout.
        timeout_secs: u64,
    },
    /// Start authenticating with a backend by calling a URL with a payload, and register a refresh URL.
    AuthBootstrap {
        /// Correlation ID.
        id: u64,
        /// Login URL.
        auth_url: String,
        /// Login POST payload (JSON string).
        payload: String,
        /// Refresh URL.
        refresh_url: String,
    },
    /// Cancel the auth session and clear tokens.
    AuthCancel,
    /// Internal request sent by the auth helper thread when login or refresh completes.
    AuthSuccess {
        /// Correlation ID.
        id: u64,
        /// Access token.
        token: String,
        /// Refresh token.
        refresh_token: String,
        /// Refresh URL.
        refresh_url: String,
        /// Expiry duration in seconds.
        expires_in: u64,
    },
    /// Internal request sent by the auth helper thread when login or refresh fails.
    AuthFailure {
        /// Correlation ID.
        id: u64,
        /// Error message.
        error: String,
    },
    /// Start matchmaking.
    MatchmakeStart {
        /// Correlation ID.
        id: u64,
        /// Matchmaker URL.
        url: String,
        /// JSON payload.
        payload: String,
    },
    /// Cancel matchmaking.
    MatchmakeCancel {
        /// Correlation ID.
        id: u64,
    },
    /// Internal request sent by a matchmaking helper thread when it gets a ticket ID.
    MatchmakeQueued {
        /// Correlation ID.
        id: u64,
        /// Matchmaker base URL.
        url: String,
        /// Ticket ID to poll.
        ticket_id: String,
    },
    /// Internal request to clear matchmaker state (success/error/cancel).
    MatchmakeComplete {
        /// Correlation ID.
        id: u64,
    },
    /// Open a TCP connection identified by `id`.
    TcpConnect {
        /// Caller-assigned connection ID used in all subsequent TCP requests.
        id: u64,
        /// Remote address in `host:port` format.
        address: String,
        /// Connection timeout in milliseconds.
        timeout_ms: u64,
    },
    /// Send raw bytes over the TCP connection with the given `id`.
    TcpSend {
        /// Connection ID returned from `TcpConnect`.
        id: u64,
        /// Payload bytes to send.
        data: Vec<u8>,
    },
    /// Close the TCP connection with the given `id`.
    TcpClose {
        /// Connection ID to close.
        id: u64,
    },
    /// Open a WebSocket connection identified by `id`.
    WebSocketConnect {
        /// Caller-assigned connection ID used in all subsequent WebSocket requests.
        id: u64,
        /// WebSocket URL (`ws://` or `wss://`).
        url: String,
        /// Sub-protocol negotiation list; empty to skip negotiation.
        protocols: Vec<String>,
    },
    /// Send a frame over the WebSocket connection.
    WebSocketSend {
        /// Connection ID.
        id: u64,
        /// Frame payload bytes.
        data: Vec<u8>,
        /// `true` for a text frame, `false` for a binary frame.
        is_text: bool,
    },
    /// Close the WebSocket connection with the given `id`.
    WebSocketClose {
        /// Connection ID.
        id: u64,
        /// WebSocket close status code (e.g. `1000` for normal closure).
        code: u16,
        /// Human-readable close reason sent in the close frame.
        reason: String,
    },
    /// Signal the network thread to exit its event loop.
    Shutdown,
}
/// Responses posted from the background network thread back to the game thread.
#[derive(Debug)]
pub enum NetworkResponse {
    /// Completed HTTP response for the given correlation `id`.
    HttpResponse {
        /// Correlation ID matching the originating `NetworkRequest::HttpRequest`.
        id: u64,
        /// HTTP status code; `0` when the request failed before a response arrived.
        status: u16,
        /// Response body bytes.
        body: Vec<u8>,
        /// Response headers.
        headers: Vec<(String, String)>,
        /// Error message when the request failed; `None` on success.
        error: Option<String>,
    },
    /// Auth event (status update).
    AuthEvent {
        /// Correlation ID.
        id: u64,
        /// Event type: "success", "refreshed", "failed", "cancelled".
        event: String,
        /// The active access token on success/refresh.
        token: Option<String>,
        /// Expiry in seconds.
        expires_in: Option<u64>,
        /// Error message on failure.
        error: Option<String>,
    },
    /// Matchmaking event.
    MatchmakeEvent {
        /// Correlation ID.
        id: u64,
        /// Event type: "queued", "matched", "cancelled", "error".
        event: String,
        /// Ticket ID if queued.
        ticket_id: Option<String>,
        /// Host endpoint if matched.
        host: Option<String>,
        /// Room ID if matched.
        room_id: Option<String>,
        /// Error message on failure.
        error: Option<String>,
    },
    /// Event from a TCP connection.
    TcpEvent {
        /// Connection ID.
        id: u64,
        /// The specific TCP lifecycle event.
        event: TcpEvent,
    },
    /// Event from a WebSocket connection.
    WebSocketEvent {
        /// Connection ID.
        id: u64,
        /// The specific WebSocket lifecycle event.
        event: WsEvent,
    },
}
/// Lifecycle events emitted by the TCP connection manager.
#[derive(Debug, Clone)]
pub enum TcpEvent {
    /// TCP handshake completed; the connection is ready to send.
    Connected,
    /// Data bytes arrived on the stream.
    Data(Vec<u8>),
    /// The remote end closed the connection; message gives the reason.
    Disconnected(String),
    /// A socket-level error occurred; message gives details.
    Error(String),
}
/// Lifecycle events emitted by the WebSocket manager.
#[derive(Debug, Clone)]
pub enum WsEvent {
    /// WebSocket handshake completed; the connection is open.
    Open,
    /// A UTF-8 text frame arrived.
    Text(String),
    /// A binary frame arrived.
    Binary(Vec<u8>),
    /// The connection was closed; `code` is the WebSocket status code.
    Close {
        /// WebSocket close status code (e.g. 1000 for normal closure).
        code: u16,
        /// Human-readable close reason from the peer.
        reason: String,
    },
    /// A WebSocket protocol or I/O error occurred.
    Error(String),
}
/// Handle that owns the background `lurek-network` thread and MPSC channels.
pub struct NetworkRuntime {
    /// Sender end of the request channel to the background thread.
    sender: mpsc::Sender<NetworkRequest>,
    /// Receiver end of the response channel from the background thread.
    receiver: mpsc::Receiver<NetworkResponse>,
    /// Join handle for the background thread; `None` after `shutdown` completes.
    handle: Option<thread::JoinHandle<()>>,
    /// Monotonically increasing counter used to generate unique request IDs.
    next_id: u64,
    /// Active access token.
    auth_token: Option<String>,
    /// Active authentication status.
    auth_status: String,
    /// Active/pending request queue size.
    active_requests: usize,
    /// Successful auth refreshes counter.
    reconnect_count: usize,
    /// Count of currently active HTTP requests.
    http_active_count: usize,
    /// Count of currently active TCP connections.
    tcp_active_count: usize,
    /// Count of currently active WebSocket connections.
    ws_active_count: usize,
}
impl NetworkRuntime {
    /// Spawn the background `lurek-network` thread and return the runtime handle; returns error on thread spawn failure.
    pub fn new() -> Result<Self, String> {
        let (req_tx, req_rx) = mpsc::channel::<NetworkRequest>();
        let (resp_tx, resp_rx) = mpsc::channel::<NetworkResponse>();
        let req_tx_clone = req_tx.clone();
        let handle = thread::Builder::new()
            .name("lurek-network".to_string())
            .spawn(move || {
                Self::thread_main(req_tx_clone, req_rx, resp_tx);
            })
            .map_err(|e| format!("failed to spawn network thread: {e}"))?;
        Ok(Self {
            sender: req_tx,
            receiver: resp_rx,
            handle: Some(handle),
            next_id: 0,
            auth_token: None,
            auth_status: "unauthenticated".to_string(),
            active_requests: 0,
            reconnect_count: 0,
            http_active_count: 0,
            tcp_active_count: 0,
            ws_active_count: 0,
        })
    }
    /// Allocate and return the next unique request ID.
    pub fn next_request_id(&mut self) -> u64 {
        self.next_id += 1;
        self.next_id
    }
    /// Send a request to the background thread and increment pending requests.
    fn send_request(&mut self, request: NetworkRequest) -> bool {
        let ok = self.sender.send(request).is_ok();
        if ok {
            self.active_requests += 1;
        }
        ok
    }
    /// Send a request to the background thread; returns `false` if the thread has exited.
    pub fn send(&self, request: NetworkRequest) -> bool {
        self.sender.send(request).is_ok()
    }
    /// Drain all pending responses from the background thread without blocking.
    pub fn poll(&mut self) -> Vec<NetworkResponse> {
        let mut responses = Vec::new();
        while let Ok(resp) = self.receiver.try_recv() {
            if self.active_requests > 0 {
                self.active_requests -= 1;
            }
            match &resp {
                NetworkResponse::HttpResponse { .. } => {
                    if self.http_active_count > 0 {
                        self.http_active_count -= 1;
                    }
                }
                NetworkResponse::AuthEvent { event, token, .. } => {
                    match event.as_str() {
                        "success" | "refreshed" => {
                            self.auth_status = "authenticated".to_string();
                            self.auth_token = token.clone();
                            if event.as_str() == "refreshed" {
                                self.reconnect_count += 1;
                            }
                        }
                        "failed" => {
                            self.auth_status = "failed".to_string();
                            self.auth_token = None;
                        }
                        "cancelled" => {
                            self.auth_status = "unauthenticated".to_string();
                            self.auth_token = None;
                        }
                        _ => {}
                    }
                    if self.http_active_count > 0 {
                        self.http_active_count -= 1;
                    }
                }
                NetworkResponse::MatchmakeEvent { event, .. } => {
                    if (event.as_str() == "matched"
                        || event.as_str() == "error"
                        || event.as_str() == "cancelled")
                        && self.http_active_count > 0
                    {
                        self.http_active_count -= 1;
                    }
                }
                NetworkResponse::TcpEvent { event, .. } => match event {
                    TcpEvent::Disconnected(_) | TcpEvent::Error(_) => {
                        if self.tcp_active_count > 0 {
                            self.tcp_active_count -= 1;
                        }
                    }
                    _ => {}
                },
                NetworkResponse::WebSocketEvent { event, .. } => match event {
                    WsEvent::Close { .. } | WsEvent::Error(_) => {
                        if self.ws_active_count > 0 {
                            self.ws_active_count -= 1;
                        }
                    }
                    _ => {}
                },
            }
            responses.push(resp);
        }
        responses
    }
    /// Send `Shutdown` to the background thread and block until it exits.
    pub fn shutdown(&mut self) {
        if self.handle.is_some() {
            let _ = self.sender.send(NetworkRequest::Shutdown);
            if let Some(handle) = self.handle.take() {
                let _ = handle.join();
            }
        }
    }
    /// Return `true` if the background thread is still running.
    pub fn is_running(&self) -> bool {
        self.handle.is_some()
    }
    /// Queue an HTTP request and return its correlation ID; returns error if the thread is not running.
    pub fn http_request(
        &mut self,
        method: &str,
        url: &str,
        headers: Option<&[(String, String)]>,
        body: Option<&str>,
        timeout_secs: Option<u64>,
    ) -> Result<u64, String> {
        let id = self.next_request_id();
        let ok = self.send_request(NetworkRequest::HttpRequest {
            id,
            method: method.to_string(),
            url: url.to_string(),
            headers: headers.map(|h| h.to_vec()).unwrap_or_default(),
            body: body.map(|b| b.as_bytes().to_vec()),
            timeout_secs: timeout_secs.unwrap_or(super::constants::HTTP_TIMEOUT_SECS),
        });
        if ok {
            self.http_active_count += 1;
            Ok(id)
        } else {
            Err("network thread not running".to_string())
        }
    }
    /// Start authenticating with a backend.
    pub fn auth_bootstrap(
        &mut self,
        auth_url: &str,
        payload: &str,
        refresh_url: &str,
    ) -> Result<u64, String> {
        let id = self.next_request_id();
        self.auth_status = "authenticating".to_string();
        let ok = self.send_request(NetworkRequest::AuthBootstrap {
            id,
            auth_url: auth_url.to_string(),
            payload: payload.to_string(),
            refresh_url: refresh_url.to_string(),
        });
        if ok {
            self.http_active_count += 1;
            Ok(id)
        } else {
            self.auth_status = "failed".to_string();
            Err("network thread not running".to_string())
        }
    }
    /// Cancel active auth session.
    pub fn auth_cancel(&mut self) -> Result<(), String> {
        self.auth_status = "unauthenticated".to_string();
        self.auth_token = None;
        let ok = self.send_request(NetworkRequest::AuthCancel);
        if ok {
            Ok(())
        } else {
            Err("network thread not running".to_string())
        }
    }
    /// Get current access token.
    pub fn get_auth_token(&self) -> Option<String> {
        self.auth_token.clone()
    }
    /// Get current auth status.
    pub fn get_auth_status(&self) -> String {
        self.auth_status.clone()
    }
    /// Get telemetry metrics for the network runtime.
    pub fn get_metrics(&self) -> (usize, usize, usize, usize, usize) {
        (
            self.active_requests,
            self.reconnect_count,
            self.http_active_count,
            self.tcp_active_count,
            self.ws_active_count,
        )
    }
    /// Start matchmaking.
    pub fn matchmake_start(&mut self, url: &str, payload: &str) -> Result<u64, String> {
        let id = self.next_request_id();
        let ok = self.send_request(NetworkRequest::MatchmakeStart {
            id,
            url: url.to_string(),
            payload: payload.to_string(),
        });
        if ok {
            self.http_active_count += 1;
            Ok(id)
        } else {
            Err("network thread not running".to_string())
        }
    }
    /// Cancel matchmaking.
    pub fn matchmake_cancel(&mut self, id: u64) -> Result<(), String> {
        let ok = self.send_request(NetworkRequest::MatchmakeCancel { id });
        if ok {
            Ok(())
        } else {
            Err("network thread not running".to_string())
        }
    }
    /// Open a TCP connection to `address` with a 5-second timeout; return its connection ID or error.
    pub fn tcp_connect(&mut self, address: &str) -> Result<u64, String> {
        let id = self.next_request_id();
        let ok = self.send_request(NetworkRequest::TcpConnect {
            id,
            address: address.to_string(),
            timeout_ms: 5000,
        });
        if ok {
            self.tcp_active_count += 1;
            Ok(id)
        } else {
            Err("network thread not running".to_string())
        }
    }
    /// Send raw bytes over an existing TCP connection; returns error if the thread is not running.
    pub fn tcp_send(&mut self, id: u64, data: &[u8]) -> Result<(), String> {
        let ok = self.send_request(NetworkRequest::TcpSend {
            id,
            data: data.to_vec(),
        });
        if ok {
            Ok(())
        } else {
            Err("network thread not running".to_string())
        }
    }
    /// Close an existing TCP connection; returns error if the thread is not running.
    pub fn tcp_close(&mut self, id: u64) -> Result<(), String> {
        let ok = self.send_request(NetworkRequest::TcpClose { id });
        if ok {
            Ok(())
        } else {
            Err("network thread not running".to_string())
        }
    }
    /// Open a WebSocket connection to `url`; return its connection ID or error.
    pub fn ws_connect(&mut self, url: &str) -> Result<u64, String> {
        let id = self.next_request_id();
        let ok = self.send_request(NetworkRequest::WebSocketConnect {
            id,
            url: url.to_string(),
            protocols: Vec::new(),
        });
        if ok {
            self.ws_active_count += 1;
            Ok(id)
        } else {
            Err("network thread not running".to_string())
        }
    }
    /// Send a UTF-8 text frame over an existing WebSocket connection.
    pub fn ws_send(&mut self, id: u64, data: &str) -> Result<(), String> {
        let ok = self.send_request(NetworkRequest::WebSocketSend {
            id,
            data: data.as_bytes().to_vec(),
            is_text: true,
        });
        if ok {
            Ok(())
        } else {
            Err("network thread not running".to_string())
        }
    }
    /// Send a normal close frame (1000) over an existing WebSocket connection.
    pub fn ws_close(&mut self, id: u64) -> Result<(), String> {
        let ok = self.send_request(NetworkRequest::WebSocketClose {
            id,
            code: 1000,
            reason: String::new(),
        });
        if ok {
            Ok(())
        } else {
            Err("network thread not running".to_string())
        }
    }

    /// Background thread entry point: poll transports and dispatch requests until `Shutdown`.
    fn thread_main(
        req_tx: mpsc::Sender<NetworkRequest>,
        req_rx: mpsc::Receiver<NetworkRequest>,
        resp_tx: mpsc::Sender<NetworkResponse>,
    ) {
        let mut tcp_manager = TcpConnectionManager::new();
        let mut ws_manager = WebSocketManager::new();
        let mut auth_session: Option<AuthSession> = None;
        let mut matchmake_session: Option<MatchmakeSession> = None;
        loop {
            tcp_manager.poll_all(&resp_tx);
            ws_manager.poll_all(&resp_tx);

            // Handle background auth token auto-refresh
            if let Some(ref mut auth) = auth_session {
                if !auth.refreshing
                    && std::time::Instant::now() + std::time::Duration::from_secs(30) >= auth.expiry
                {
                    auth.refreshing = true;
                    let req_tx = req_tx.clone();
                    let resp_tx = resp_tx.clone();
                    let url = auth.refresh_url.clone();
                    let token = auth.refresh_token.clone();
                    thread::spawn(move || {
                        let headers =
                            vec![("Content-Type".to_string(), "application/json".to_string())];
                        let payload = format!("{{\"refresh_token\":\"{}\"}}", token);
                        let resp = super::http::execute_request(
                            "POST",
                            &url,
                            &headers,
                            Some(payload.as_bytes()),
                            10,
                        );
                        if resp.status == 200 || resp.status == 201 {
                            if let Ok(json) =
                                serde_json::from_slice::<serde_json::Value>(&resp.body)
                            {
                                if let (Some(access), Some(refresh), Some(expires)) = (
                                    json.get("access_token").and_then(|v| v.as_str()),
                                    json.get("refresh_token").and_then(|v| v.as_str()),
                                    json.get("expires_in").and_then(|v| v.as_u64()),
                                ) {
                                    let _ = req_tx.send(NetworkRequest::AuthSuccess {
                                        id: 0,
                                        token: access.to_string(),
                                        refresh_token: refresh.to_string(),
                                        refresh_url: url.clone(),
                                        expires_in: expires,
                                    });
                                    let _ = resp_tx.send(NetworkResponse::AuthEvent {
                                        id: 0,
                                        event: "refreshed".to_string(),
                                        token: Some(access.to_string()),
                                        expires_in: Some(expires),
                                        error: None,
                                    });
                                    return;
                                }
                            }
                        }
                        let err = resp.error.unwrap_or_else(|| "refresh failed".to_string());
                        let _ = req_tx.send(NetworkRequest::AuthFailure {
                            id: 0,
                            error: err.clone(),
                        });
                        let _ = resp_tx.send(NetworkResponse::AuthEvent {
                            id: 0,
                            event: "failed".to_string(),
                            token: None,
                            expires_in: None,
                            error: Some(err),
                        });
                    });
                }
            }

            // Handle background matchmaking poll
            if let Some(ref mut m) = matchmake_session {
                if !m.polling && m.last_poll.elapsed() >= std::time::Duration::from_millis(1500) {
                    m.polling = true;
                    m.last_poll = std::time::Instant::now();
                    let req_tx = req_tx.clone();
                    let resp_tx = resp_tx.clone();
                    let id = m.id;
                    let poll_url = format!("{}/{}", m.url, m.ticket_id);
                    thread::spawn(move || {
                        let resp = super::http::execute_request("GET", &poll_url, &[], None, 5);
                        if resp.status == 200 {
                            if let Ok(json) =
                                serde_json::from_slice::<serde_json::Value>(&resp.body)
                            {
                                if let Some(status) = json.get("status").and_then(|v| v.as_str()) {
                                    if status == "matched" {
                                        let host =
                                            json.get("host").and_then(|v| v.as_str()).unwrap_or("");
                                        let room_id = json
                                            .get("room_id")
                                            .and_then(|v| v.as_str())
                                            .unwrap_or("");
                                        let _ = resp_tx.send(NetworkResponse::MatchmakeEvent {
                                            id,
                                            event: "matched".to_string(),
                                            ticket_id: None,
                                            host: Some(host.to_string()),
                                            room_id: Some(room_id.to_string()),
                                            error: None,
                                        });
                                        let _ =
                                            req_tx.send(NetworkRequest::MatchmakeComplete { id });
                                        return;
                                    } else if status == "queued" {
                                        let _ = req_tx.send(NetworkRequest::MatchmakeQueued {
                                            id,
                                            url: String::new(),
                                            ticket_id: String::new(),
                                        });
                                        return;
                                    }
                                }
                            }
                        }
                        let err = resp.error.unwrap_or_else(|| "polling error".to_string());
                        let _ = resp_tx.send(NetworkResponse::MatchmakeEvent {
                            id,
                            event: "error".to_string(),
                            ticket_id: None,
                            host: None,
                            room_id: None,
                            error: Some(err),
                        });
                        let _ = req_tx.send(NetworkRequest::MatchmakeComplete { id });
                    });
                }
            }

            match req_rx.recv_timeout(std::time::Duration::from_millis(10)) {
                Ok(NetworkRequest::Shutdown) => break,
                Ok(request) => {
                    Self::handle_request(
                        &req_tx,
                        request,
                        &resp_tx,
                        &mut tcp_manager,
                        &mut ws_manager,
                        &mut auth_session,
                        &mut matchmake_session,
                    );
                }
                Err(mpsc::RecvTimeoutError::Timeout) => {}
                Err(mpsc::RecvTimeoutError::Disconnected) => break,
            }
        }
        tcp_manager.close_all();
        ws_manager.close_all();
    }

    /// Route one `NetworkRequest` to the appropriate transport manager.
    fn handle_request(
        req_tx: &mpsc::Sender<NetworkRequest>,
        request: NetworkRequest,
        resp_tx: &mpsc::Sender<NetworkResponse>,
        tcp_manager: &mut TcpConnectionManager,
        ws_manager: &mut WebSocketManager,
        auth_session: &mut Option<AuthSession>,
        matchmake_session: &mut Option<MatchmakeSession>,
    ) {
        match request {
            NetworkRequest::HttpRequest {
                id,
                method,
                url,
                headers,
                body,
                timeout_secs,
            } => {
                let response =
                    http::execute_request(&method, &url, &headers, body.as_deref(), timeout_secs);
                let _ = resp_tx.send(NetworkResponse::HttpResponse {
                    id,
                    status: response.status,
                    body: response.body,
                    headers: response.headers,
                    error: response.error,
                });
            }
            NetworkRequest::AuthBootstrap {
                id,
                auth_url,
                payload,
                refresh_url,
            } => {
                let req_tx = req_tx.clone();
                let resp_tx = resp_tx.clone();
                thread::spawn(move || {
                    let headers =
                        vec![("Content-Type".to_string(), "application/json".to_string())];
                    let resp = super::http::execute_request(
                        "POST",
                        &auth_url,
                        &headers,
                        Some(payload.as_bytes()),
                        15,
                    );
                    if resp.status == 200 || resp.status == 201 {
                        if let Ok(json) = serde_json::from_slice::<serde_json::Value>(&resp.body) {
                            if let (Some(access), Some(refresh), Some(expires)) = (
                                json.get("access_token").and_then(|v| v.as_str()),
                                json.get("refresh_token").and_then(|v| v.as_str()),
                                json.get("expires_in").and_then(|v| v.as_u64()),
                            ) {
                                let _ = req_tx.send(NetworkRequest::AuthSuccess {
                                    id,
                                    token: access.to_string(),
                                    refresh_token: refresh.to_string(),
                                    refresh_url,
                                    expires_in: expires,
                                });
                                let _ = resp_tx.send(NetworkResponse::AuthEvent {
                                    id,
                                    event: "success".to_string(),
                                    token: Some(access.to_string()),
                                    expires_in: Some(expires),
                                    error: None,
                                });
                                return;
                            }
                        }
                    }
                    let err = resp
                        .error
                        .unwrap_or_else(|| "authentication failed".to_string());
                    let _ = req_tx.send(NetworkRequest::AuthFailure {
                        id,
                        error: err.clone(),
                    });
                    let _ = resp_tx.send(NetworkResponse::AuthEvent {
                        id,
                        event: "failed".to_string(),
                        token: None,
                        expires_in: None,
                        error: Some(err),
                    });
                });
            }
            NetworkRequest::AuthCancel => {
                *auth_session = None;
                let _ = resp_tx.send(NetworkResponse::AuthEvent {
                    id: 0,
                    event: "cancelled".to_string(),
                    token: None,
                    expires_in: None,
                    error: None,
                });
            }
            NetworkRequest::AuthSuccess {
                id: _,
                token,
                refresh_token,
                refresh_url,
                expires_in,
            } => {
                *auth_session = Some(AuthSession {
                    token,
                    refresh_token,
                    refresh_url,
                    expiry: std::time::Instant::now() + std::time::Duration::from_secs(expires_in),
                    refreshing: false,
                });
            }
            NetworkRequest::AuthFailure { id: _, error: _ } => {
                *auth_session = None;
            }
            NetworkRequest::MatchmakeStart { id, url, payload } => {
                let req_tx = req_tx.clone();
                let resp_tx = resp_tx.clone();
                thread::spawn(move || {
                    let headers =
                        vec![("Content-Type".to_string(), "application/json".to_string())];
                    let resp = super::http::execute_request(
                        "POST",
                        &url,
                        &headers,
                        Some(payload.as_bytes()),
                        15,
                    );
                    if resp.status == 200 || resp.status == 201 {
                        if let Ok(json) = serde_json::from_slice::<serde_json::Value>(&resp.body) {
                            if let Some(status) = json.get("status").and_then(|v| v.as_str()) {
                                if status == "matched" {
                                    let host =
                                        json.get("host").and_then(|v| v.as_str()).unwrap_or("");
                                    let room_id =
                                        json.get("room_id").and_then(|v| v.as_str()).unwrap_or("");
                                    let _ = resp_tx.send(NetworkResponse::MatchmakeEvent {
                                        id,
                                        event: "matched".to_string(),
                                        ticket_id: None,
                                        host: Some(host.to_string()),
                                        room_id: Some(room_id.to_string()),
                                        error: None,
                                    });
                                    let _ = req_tx.send(NetworkRequest::MatchmakeComplete { id });
                                    return;
                                } else if status == "queued" {
                                    let ticket_id = json
                                        .get("ticket_id")
                                        .and_then(|v| v.as_str())
                                        .unwrap_or("");
                                    let _ = resp_tx.send(NetworkResponse::MatchmakeEvent {
                                        id,
                                        event: "queued".to_string(),
                                        ticket_id: Some(ticket_id.to_string()),
                                        host: None,
                                        room_id: None,
                                        error: None,
                                    });
                                    let _ = req_tx.send(NetworkRequest::MatchmakeQueued {
                                        id,
                                        url,
                                        ticket_id: ticket_id.to_string(),
                                    });
                                    return;
                                }
                            }
                        }
                    }
                    let err = resp
                        .error
                        .unwrap_or_else(|| "matchmaking failed".to_string());
                    let _ = resp_tx.send(NetworkResponse::MatchmakeEvent {
                        id,
                        event: "error".to_string(),
                        ticket_id: None,
                        host: None,
                        room_id: None,
                        error: Some(err),
                    });
                    let _ = req_tx.send(NetworkRequest::MatchmakeComplete { id });
                });
            }
            NetworkRequest::MatchmakeCancel { id } => {
                if let Some(ref m) = matchmake_session {
                    if m.id == id {
                        let cancel_url = format!("{}/{}", m.url, m.ticket_id);
                        thread::spawn(move || {
                            let _ =
                                super::http::execute_request("DELETE", &cancel_url, &[], None, 5);
                        });
                    }
                }
                *matchmake_session = None;
                let _ = resp_tx.send(NetworkResponse::MatchmakeEvent {
                    id,
                    event: "cancelled".to_string(),
                    ticket_id: None,
                    host: None,
                    room_id: None,
                    error: None,
                });
            }
            NetworkRequest::MatchmakeQueued { id, url, ticket_id } => {
                if let Some(ref mut m) = matchmake_session {
                    if m.id == id {
                        m.polling = false;
                        if !url.is_empty() {
                            m.url = url;
                        }
                        if !ticket_id.is_empty() {
                            m.ticket_id = ticket_id;
                        }
                    }
                } else if !url.is_empty() && !ticket_id.is_empty() {
                    *matchmake_session = Some(MatchmakeSession {
                        id,
                        url,
                        ticket_id,
                        last_poll: std::time::Instant::now(),
                        polling: false,
                    });
                }
            }
            NetworkRequest::MatchmakeComplete { id } => {
                if let Some(ref m) = matchmake_session {
                    if m.id == id {
                        *matchmake_session = None;
                    }
                }
            }
            NetworkRequest::TcpConnect {
                id,
                address,
                timeout_ms,
            } => {
                tcp_manager.connect(id, &address, timeout_ms, resp_tx);
            }
            NetworkRequest::TcpSend { id, data } => {
                tcp_manager.send(id, &data, resp_tx);
            }
            NetworkRequest::TcpClose { id } => {
                tcp_manager.close(id, resp_tx);
            }
            NetworkRequest::WebSocketConnect { id, url, protocols } => {
                ws_manager.connect(id, &url, &protocols, resp_tx);
            }
            NetworkRequest::WebSocketSend { id, data, is_text } => {
                ws_manager.send(id, &data, is_text, resp_tx);
            }
            NetworkRequest::WebSocketClose { id, code, reason } => {
                ws_manager.close(id, code, &reason, resp_tx);
            }
            NetworkRequest::Shutdown => {}
        }
    }
}
#[allow(dead_code)]
struct AuthSession {
    token: String,
    refresh_token: String,
    refresh_url: String,
    expiry: std::time::Instant,
    refreshing: bool,
}
struct MatchmakeSession {
    id: u64,
    url: String,
    ticket_id: String,
    last_poll: std::time::Instant,
    polling: bool,
}
/// Create a `NetworkRuntime`, panicking on thread spawn failure.
impl Default for NetworkRuntime {
    fn default() -> Self {
        Self::new().expect("failed to spawn network thread")
    }
}
/// Shut down the network thread when the runtime is dropped.
impl Drop for NetworkRuntime {
    fn drop(&mut self) {
        self.shutdown();
    }
}
