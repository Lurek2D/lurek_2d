//! Dedicated network I/O thread with mpsc bridge to the main engine thread.
//!
//! All async-style network operations (HTTP requests, WebSocket connections,
//! TCP streams) run on a single background OS thread managed by
//! [`NetworkRuntime`]. The main engine thread communicates via typed
//! `mpsc` channels, keeping the Lua VM single-threaded (constraint B-04).
//!
//! # Architecture
//!
//! ```text
//! Main Thread  ──[NetworkRequest]──►  Network Thread
//! Main Thread  ◄──[NetworkResponse]──  Network Thread
//! ```
//!
//! The main thread calls [`NetworkRuntime::poll`] once per frame to drain
//! completed responses. Lua callbacks are stored as `LuaRegistryKey` in the
//! Lua API layer and invoked after poll returns.
//!
//! # Lifecycle
//!
//! 1. [`NetworkRuntime::new`] spawns the background thread.
//! 2. Lua API sends requests via [`NetworkRuntime::send`].
//! 3. Each frame, engine calls [`NetworkRuntime::poll`] to get responses.
//! 4. On shutdown, [`NetworkRuntime::shutdown`] sends `Shutdown` and joins.

use std::sync::mpsc;
use std::thread;

use super::http;
use super::tcp::TcpConnectionManager;
use super::websocket::WebSocketManager;

/// Request sent from the main thread to the network thread.
///
/// # Variants
/// - `HttpRequest` — Perform an HTTP request (GET/POST/PUT/DELETE).
/// - `TcpConnect` — Open a new TCP connection.
/// - `TcpSend` — Send data on an existing TCP connection.
/// - `TcpClose` — Close a TCP connection.
/// - `WebSocketConnect` — Open a new WebSocket connection.
/// - `WebSocketSend` — Send data on an existing WebSocket.
/// - `WebSocketClose` — Close a WebSocket connection.
/// - `Shutdown` — Terminate the network thread.
#[derive(Debug)]
pub enum NetworkRequest {
    /// Perform an HTTP request.
    HttpRequest {
        /// Unique request identifier for callback routing.
        id: u64,
        /// HTTP method: GET, POST, PUT, DELETE, PATCH.
        method: String,
        /// Target URL (must include scheme).
        url: String,
        /// Request headers as key-value pairs.
        headers: Vec<(String, String)>,
        /// Optional request body.
        body: Option<Vec<u8>>,
        /// Request timeout in seconds.
        timeout_secs: u64,
    },
    /// Open a new TCP connection.
    TcpConnect {
        /// Unique connection identifier.
        id: u64,
        /// Remote address in `host:port` format.
        address: String,
        /// Connection timeout in milliseconds.
        timeout_ms: u64,
    },
    /// Send data on an existing TCP connection.
    TcpSend {
        /// Connection identifier from `TcpConnect`.
        id: u64,
        /// Data to send.
        data: Vec<u8>,
    },
    /// Close a TCP connection.
    TcpClose {
        /// Connection identifier.
        id: u64,
    },
    /// Open a new WebSocket connection.
    WebSocketConnect {
        /// Unique connection identifier.
        id: u64,
        /// WebSocket URL (`ws://` or `wss://`).
        url: String,
        /// Optional sub-protocol names.
        protocols: Vec<String>,
    },
    /// Send data on an existing WebSocket.
    WebSocketSend {
        /// Connection identifier from `WebSocketConnect`.
        id: u64,
        /// Data to send.
        data: Vec<u8>,
        /// `true` for text frame, `false` for binary frame.
        is_text: bool,
    },
    /// Close a WebSocket connection.
    WebSocketClose {
        /// Connection identifier.
        id: u64,
        /// WebSocket close code (e.g. 1000 for normal).
        code: u16,
        /// Close reason string.
        reason: String,
    },
    /// Terminate the network thread gracefully.
    Shutdown,
}

/// Response sent from the network thread back to the main thread.
///
/// # Variants
/// - `HttpResponse` — Completed HTTP request result.
/// - `TcpEvent` — TCP connection event.
/// - `WebSocketEvent` — WebSocket connection event.
#[derive(Debug)]
pub enum NetworkResponse {
    /// Completed HTTP request.
    HttpResponse {
        /// Request identifier matching the original `HttpRequest`.
        id: u64,
        /// HTTP status code (0 if connection failed).
        status: u16,
        /// Response body bytes.
        body: Vec<u8>,
        /// Response headers.
        headers: Vec<(String, String)>,
        /// Error message if the request failed.
        error: Option<String>,
    },
    /// TCP connection event.
    TcpEvent {
        /// Connection identifier.
        id: u64,
        /// The event that occurred.
        event: TcpEvent,
    },
    /// WebSocket connection event.
    WebSocketEvent {
        /// Connection identifier.
        id: u64,
        /// The event that occurred.
        event: WsEvent,
    },
}

/// Events produced by TCP connections on the network thread.
///
/// # Variants
/// - `Connected` — TCP handshake completed.
/// - `Data` — Data received from the remote end.
/// - `Disconnected` — Connection closed.
/// - `Error` — An error occurred.
#[derive(Debug, Clone)]
pub enum TcpEvent {
    /// TCP handshake completed successfully.
    Connected,
    /// Data received from the remote end.
    Data(Vec<u8>),
    /// Connection closed (with optional reason).
    Disconnected(String),
    /// A socket error occurred.
    Error(String),
}

/// Events produced by WebSocket connections on the network thread.
///
/// # Variants
/// - `Open` — WebSocket handshake completed.
/// - `Text` — Text message received.
/// - `Binary` — Binary message received.
/// - `Close` — Connection closed with code and reason.
/// - `Error` — An error occurred.
#[derive(Debug, Clone)]
pub enum WsEvent {
    /// WebSocket handshake completed successfully.
    Open,
    /// Text message received.
    Text(String),
    /// Binary message received.
    Binary(Vec<u8>),
    /// Connection closed with a close code and reason.
    Close {
        /// WebSocket close code.
        code: u16,
        /// Close reason string.
        reason: String,
    },
    /// A WebSocket error occurred.
    Error(String),
}

/// Manages a dedicated OS thread for non-blocking network I/O.
///
/// All HTTP requests, WebSocket connections, and TCP sockets are handled
/// on this thread. The main engine thread communicates via typed `mpsc`
/// channels, keeping the Lua VM single-threaded (constraint B-04).
///
/// # Fields
/// - `sender` — Channel for sending requests to the network thread.
/// - `receiver` — Channel for receiving responses from the network thread.
/// - `handle` — Join handle for the background thread.
/// - `next_id` — Monotonically increasing request ID counter.
pub struct NetworkRuntime {
    /// Sends requests to the background network thread.
    sender: mpsc::Sender<NetworkRequest>,
    /// Receives responses from the background network thread.
    receiver: mpsc::Receiver<NetworkResponse>,
    /// Join handle for the background thread (`None` after shutdown).
    handle: Option<thread::JoinHandle<()>>,
    /// Next request ID to assign (monotonically increasing).
    next_id: u64,
}

impl NetworkRuntime {
    /// Create a new `NetworkRuntime`, spawning the background I/O thread.
    ///
    /// # Returns
    /// `Result<NetworkRuntime, String>` — ready to accept requests.
    pub fn new() -> Result<Self, String> {
        let (req_tx, req_rx) = mpsc::channel::<NetworkRequest>();
        let (resp_tx, resp_rx) = mpsc::channel::<NetworkResponse>();

        let handle = thread::Builder::new()
            .name("lurek-network".to_string())
            .spawn(move || {
                Self::thread_main(req_rx, resp_tx);
            })
            .map_err(|e| format!("failed to spawn network thread: {e}"))?;

        Ok(Self {
            sender: req_tx,
            receiver: resp_rx,
            handle: Some(handle),
            next_id: 0,
        })
    }

    /// Generate the next unique request ID.
    ///
    /// # Returns
    /// `u64` — a monotonically increasing identifier.
    pub fn next_request_id(&mut self) -> u64 {
        self.next_id += 1;
        self.next_id
    }

    /// Send a request to the network thread.
    ///
    /// # Parameters
    /// - `request` — `NetworkRequest`: the operation to perform.
    ///
    /// # Returns
    /// `bool` — `true` if the request was enqueued, `false` if the thread has shut down.
    pub fn send(&self, request: NetworkRequest) -> bool {
        self.sender.send(request).is_ok()
    }

    /// Drain all completed responses from the network thread.
    ///
    /// Call this once per frame in the engine loop, before `lurek.process(dt)`.
    /// Non-blocking — returns immediately if no responses are pending.
    ///
    /// # Returns
    /// `Vec<NetworkResponse>` — all responses received since the last poll.
    pub fn poll(&self) -> Vec<NetworkResponse> {
        let mut responses = Vec::new();
        while let Ok(resp) = self.receiver.try_recv() {
            responses.push(resp);
        }
        responses
    }

    /// Shut down the network thread gracefully.
    ///
    /// Sends a `Shutdown` request and waits for the thread to finish.
    /// Safe to call multiple times (no-op after first call).
    pub fn shutdown(&mut self) {
        if self.handle.is_some() {
            let _ = self.sender.send(NetworkRequest::Shutdown);
            if let Some(handle) = self.handle.take() {
                let _ = handle.join();
            }
        }
    }

    /// Returns `true` if the background thread is still alive.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_running(&self) -> bool {
        self.handle.is_some()
    }

    // -- Convenience methods for Lua API layer --

    /// Send an HTTP request to the network thread.
    ///
    /// # Parameters
    /// - `method` — HTTP method (`"GET"`, `"POST"`, etc.).
    /// - `url` — Target URL.
    /// - `headers` — Optional request headers.
    /// - `body` — Optional request body.
    /// - `timeout_secs` — Optional timeout override.
    ///
    /// # Returns
    /// `Result<u64, String>` — the request ID for matching the response.
    pub fn http_request(
        &mut self,
        method: &str,
        url: &str,
        headers: Option<&[(String, String)]>,
        body: Option<&str>,
        timeout_secs: Option<u64>,
    ) -> Result<u64, String> {
        let id = self.next_request_id();
        let ok = self.send(NetworkRequest::HttpRequest {
            id,
            method: method.to_string(),
            url: url.to_string(),
            headers: headers.map(|h| h.to_vec()).unwrap_or_default(),
            body: body.map(|b| b.as_bytes().to_vec()),
            timeout_secs: timeout_secs.unwrap_or(super::constants::HTTP_TIMEOUT_SECS),
        });
        if ok {
            Ok(id)
        } else {
            Err("network thread not running".to_string())
        }
    }

    /// Open a TCP connection on the network thread.
    ///
    /// # Parameters
    /// - `address` — Remote address in `"host:port"` format.
    ///
    /// # Returns
    /// `Result<u64, String>` — the connection ID.
    pub fn tcp_connect(&mut self, address: &str) -> Result<u64, String> {
        let id = self.next_request_id();
        let ok = self.send(NetworkRequest::TcpConnect {
            id,
            address: address.to_string(),
            timeout_ms: 5000,
        });
        if ok {
            Ok(id)
        } else {
            Err("network thread not running".to_string())
        }
    }

    /// Send data on a TCP connection.
    ///
    /// # Parameters
    /// - `id` — Connection ID from `tcp_connect`.
    /// - `data` — Bytes to send.
    ///
    /// # Returns
    /// `Result<(), String>`.
    pub fn tcp_send(&mut self, id: u64, data: &[u8]) -> Result<(), String> {
        let ok = self.send(NetworkRequest::TcpSend {
            id,
            data: data.to_vec(),
        });
        if ok {
            Ok(())
        } else {
            Err("network thread not running".to_string())
        }
    }

    /// Close a TCP connection.
    ///
    /// # Parameters
    /// - `id` — Connection ID.
    ///
    /// # Returns
    /// `Result<(), String>`.
    pub fn tcp_close(&mut self, id: u64) -> Result<(), String> {
        let ok = self.send(NetworkRequest::TcpClose { id });
        if ok {
            Ok(())
        } else {
            Err("network thread not running".to_string())
        }
    }

    /// Open a WebSocket connection on the network thread.
    ///
    /// # Parameters
    /// - `url` — WebSocket URL (`ws://` or `wss://`).
    ///
    /// # Returns
    /// `Result<u64, String>` — the connection ID.
    pub fn ws_connect(&mut self, url: &str) -> Result<u64, String> {
        let id = self.next_request_id();
        let ok = self.send(NetworkRequest::WebSocketConnect {
            id,
            url: url.to_string(),
            protocols: Vec::new(),
        });
        if ok {
            Ok(id)
        } else {
            Err("network thread not running".to_string())
        }
    }

    /// Send a text message on a WebSocket connection.
    ///
    /// # Parameters
    /// - `id` — Connection ID from `ws_connect`.
    /// - `data` — Text to send.
    ///
    /// # Returns
    /// `Result<(), String>`.
    pub fn ws_send(&mut self, id: u64, data: &str) -> Result<(), String> {
        let ok = self.send(NetworkRequest::WebSocketSend {
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

    /// Close a WebSocket connection.
    ///
    /// # Parameters
    /// - `id` — Connection ID.
    ///
    /// # Returns
    /// `Result<(), String>`.
    pub fn ws_close(&mut self, id: u64) -> Result<(), String> {
        let ok = self.send(NetworkRequest::WebSocketClose {
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

    /// The main loop of the background network thread.
    ///
    /// Blocks on the request channel, processes each request, and sends
    /// responses back. Exits on `Shutdown` or when the channel closes.
    fn thread_main(req_rx: mpsc::Receiver<NetworkRequest>, resp_tx: mpsc::Sender<NetworkResponse>) {
        let mut tcp_manager = TcpConnectionManager::new();
        let mut ws_manager = WebSocketManager::new();

        // Main loop: poll existing connections for events, then check for new
        // requests with a short timeout to keep polling responsive.
        loop {
            // First, poll existing TCP and WebSocket connections for events
            tcp_manager.poll_all(&resp_tx);
            ws_manager.poll_all(&resp_tx);

            // Then check for new requests (10ms timeout keeps polling active
            // even when no new requests arrive).
            match req_rx.recv_timeout(std::time::Duration::from_millis(10)) {
                Ok(NetworkRequest::Shutdown) => break,
                Ok(request) => {
                    Self::handle_request(request, &resp_tx, &mut tcp_manager, &mut ws_manager);
                }
                Err(mpsc::RecvTimeoutError::Timeout) => {
                    // No new requests, continue polling existing connections
                }
                Err(mpsc::RecvTimeoutError::Disconnected) => break,
            }
        }

        // Clean up: close all active connections
        tcp_manager.close_all();
        ws_manager.close_all();
    }

    /// Process a single request from the main thread.
    fn handle_request(
        request: NetworkRequest,
        resp_tx: &mpsc::Sender<NetworkResponse>,
        tcp_manager: &mut TcpConnectionManager,
        ws_manager: &mut WebSocketManager,
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
            NetworkRequest::Shutdown => {
                // Handled in the main loop
            }
        }
    }
}

impl Default for NetworkRuntime {
    fn default() -> Self {
        Self::new().expect("failed to spawn network thread")
    }
}

impl Drop for NetworkRuntime {
    fn drop(&mut self) {
        self.shutdown();
    }
}
