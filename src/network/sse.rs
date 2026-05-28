//! Server-Sent Events (SSE) stream reader.
//! Uses a background thread to read events from an HTTP SSE endpoint.
//!
//! - `SseStream::connect` spawns a reader thread that parses SSE frames and sends them over a channel.
//! - `SseStream::next` polls for the next event without blocking.
//! - `SseStream::collect` is a blocking helper for gathering a fixed number of events.
//! - See `docs/specs/network.md` for the full SSE API specification.

use log::warn;
use std::io::{BufRead, BufReader};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{mpsc, Arc};
use std::time::{Duration, Instant};

/// A single SSE event dispatched from a stream.
pub struct SseEvent {
    /// Optional event `id:` field.
    pub id: Option<String>,
    /// Optional `event:` type field.
    pub event: Option<String>,
    /// The `data:` payload (may be multi-line, joined with `\n`).
    pub data: String,
}

/// A live SSE connection managed by a background reader thread.
///
/// Drop this value (or call `close`) to signal the reader thread to stop.
pub struct SseStream {
    receiver: mpsc::Receiver<Option<SseEvent>>,
    close_flag: Arc<AtomicBool>,
    is_open: Arc<AtomicBool>,
}

impl SseStream {
    /// Opens an SSE connection to `url` and returns a `SseStream` backed by a background reader thread.
    ///
    /// The background thread makes an HTTP GET with `Accept: text/event-stream` and reads lines
    /// until the connection closes or `close_flag` is set.  Returns an error string when the
    /// initial channel setup fails (thread spawn errors only; connection errors are reported via
    /// `is_open` becoming `false`).
    pub fn connect(url: &str) -> Result<Self, String> {
        let (tx, rx) = mpsc::channel();
        let close_flag = Arc::new(AtomicBool::new(false));
        let is_open = Arc::new(AtomicBool::new(true));

        let close_flag_bg = Arc::clone(&close_flag);
        let is_open_bg = Arc::clone(&is_open);
        let url_owned = url.to_string();

        std::thread::spawn(move || {
            let config = ureq::config::Config::builder()
                .tls_config(
                    ureq::tls::TlsConfig::builder()
                        .provider(ureq::tls::TlsProvider::NativeTls)
                        .build(),
                )
                .build();
            let agent: ureq::Agent = config.into();

            let resp = agent
                .get(&url_owned)
                .header("Accept", "text/event-stream")
                .header("Cache-Control", "no-cache")
                .call();

            let resp = match resp {
                Ok(r) => r,
                Err(e) => {
                    warn!("SSE connect failed for {url_owned}: {e}");
                    is_open_bg.store(false, Ordering::Relaxed);
                    let _ = tx.send(None);
                    return;
                }
            };

            let reader = BufReader::new(resp.into_body().into_reader());
            let mut id: Option<String> = None;
            let mut event_type: Option<String> = None;
            let mut data = String::new();

            for line in reader.lines() {
                if close_flag_bg.load(Ordering::Relaxed) {
                    break;
                }
                let line = match line {
                    Ok(l) => l,
                    Err(e) => {
                        warn!("SSE read error on {url_owned}: {e}");
                        break;
                    }
                };

                if line.is_empty() {
                    // Blank line: dispatch buffered event.
                    if !data.is_empty() {
                        // Strip trailing newline added by multi-line data.
                        if data.ends_with('\n') {
                            data.pop();
                        }
                        let ev = SseEvent {
                            id: id.take(),
                            event: event_type.take(),
                            data: std::mem::take(&mut data),
                        };
                        if tx.send(Some(ev)).is_err() {
                            // Receiver dropped; stop reading.
                            break;
                        }
                    } else {
                        // Empty event (no data); reset accumulated fields.
                        id = None;
                        event_type = None;
                    }
                } else if let Some(value) = line.strip_prefix("data:") {
                    if !data.is_empty() {
                        data.push('\n');
                    }
                    data.push_str(value.strip_prefix(' ').unwrap_or(value));
                } else if let Some(value) = line.strip_prefix("event:") {
                    event_type =
                        Some(value.strip_prefix(' ').unwrap_or(value).to_string());
                } else if let Some(value) = line.strip_prefix("id:") {
                    id = Some(value.strip_prefix(' ').unwrap_or(value).to_string());
                }
                // Lines starting with ':' are comments; unknown fields are ignored per spec.
            }

            is_open_bg.store(false, Ordering::Relaxed);
            let _ = tx.send(None); // Closed sentinel.
        });

        Ok(SseStream {
            receiver: rx,
            close_flag,
            is_open,
        })
    }

    /// Non-blocking poll; returns the next queued event or `None` when the queue is empty or the
    /// stream has closed.
    pub fn next(&self) -> Option<SseEvent> {
        match self.receiver.try_recv() {
            Ok(Some(ev)) => Some(ev),
            Ok(None) => {
                self.is_open.store(false, Ordering::Relaxed);
                None
            }
            Err(mpsc::TryRecvError::Empty) => None,
            Err(mpsc::TryRecvError::Disconnected) => {
                self.is_open.store(false, Ordering::Relaxed);
                None
            }
        }
    }

    /// Signals the background reader thread to stop.  The thread will exit after the next line
    /// read completes (or the connection drops).
    pub fn close(&self) {
        self.close_flag.store(true, Ordering::Relaxed);
    }

    /// Returns `true` while the background reader thread is still connected and reading.
    pub fn is_open(&self) -> bool {
        self.is_open.load(Ordering::Relaxed)
    }

    /// Blocking helper: opens a fresh SSE connection to `url`, collects up to `n` events, and
    /// returns them once `n` is reached or `timeout_secs` elapses (whichever comes first).
    ///
    /// Returns an empty `Vec` when the connection fails immediately.
    pub fn collect(url: &str, n: usize, timeout_secs: f64) -> Vec<SseEvent> {
        let stream = match Self::connect(url) {
            Ok(s) => s,
            Err(e) => {
                warn!("SSE collect: connect failed: {e}");
                return Vec::new();
            }
        };

        let timeout = Duration::from_secs_f64(timeout_secs.max(0.0));
        let deadline = Instant::now() + timeout;
        let mut events = Vec::with_capacity(n.min(64));

        while events.len() < n {
            let remaining = deadline.saturating_duration_since(Instant::now());
            if remaining.is_zero() {
                break;
            }
            match stream.receiver.recv_timeout(remaining) {
                Ok(Some(ev)) => events.push(ev),
                // Closed sentinel or timeout/disconnect: stop collecting.
                Ok(None) | Err(_) => break,
            }
        }

        stream.close();
        events
    }
}

impl Drop for SseStream {
    fn drop(&mut self) {
        self.close_flag.store(true, Ordering::Relaxed);
    }
}
