//! Background asset-loading worker that reads files off the main thread.
//!
//! The loader owns a single OS thread that processes read requests from a bounded
//! channel.  Results are polled from the main thread each frame — no `unsafe`, no
//! shared mutable state beyond an `Arc<Mutex<>>` result map.

use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{mpsc, Arc, Mutex};
use std::thread;

/// Opaque handle returned to callers (and to Lua) that identifies a pending load.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
/// # Fields
/// - `rx` — `Receiver<FileResult>`. Channel receiving completed file results.
pub struct LoadHandle(pub u64);

/// Outcome of a completed load request. Returns an error if the source data is malformed or missing.
///
/// # Variants
/// - `Ready` — Ready variant.
/// - `Error` — Error variant.
#[derive(Debug, Clone)]
pub enum LoadResult {
    /// File bytes loaded successfully.
    Ready(Vec<u8>),
    /// An error occurred during loading.
    Error(String),
}

/// Status returned by [`AsyncLoader::poll`].
///
/// # Variants
/// - `Pending` — Pending variant.
/// - `Done` — Done variant.
#[derive(Debug, Clone)]
pub enum LoadStatus {
    /// The request is still being processed.
    Pending,
    /// The load completed (success or failure).
    Done(LoadResult),
}

/// Internal request sent to the worker thread.
struct LoadRequest {
    handle: LoadHandle,
    /// Fully-resolved, sandbox-validated absolute path.
    resolved_path: PathBuf,
}

/// Maximum number of requests that can be queued before `request_load` blocks.
const QUEUE_CAPACITY: usize = 64;

/// A single-threaded background file reader.
///
/// Create one per engine session; drop it to join the worker thread.
///
/// # Fields
/// - `next_id` — `AtomicU64`.
/// - `tx` — `Option<mpsc::SyncSender<LoadRequest>>`.
/// - `results` — `Arc<Mutex<HashMap<u64`.
/// - `worker` — `Option<thread::JoinHandle<()>>`.
pub struct AsyncLoader {
    next_id: AtomicU64,
    tx: Option<mpsc::SyncSender<LoadRequest>>,
    results: Arc<Mutex<HashMap<u64, LoadResult>>>,
    worker: Option<thread::JoinHandle<()>>,
}

impl AsyncLoader {
    /// Spawns the background worker thread. Returns a fully initialised instance with all fields set to their initial values.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        let (tx, rx) = mpsc::sync_channel::<LoadRequest>(QUEUE_CAPACITY);
        let results: Arc<Mutex<HashMap<u64, LoadResult>>> = Arc::new(Mutex::new(HashMap::new()));
        let results_clone = Arc::clone(&results);

        let worker = thread::Builder::new()
            .name("luna-async-loader".into())
            .spawn(move || {
                Self::worker_loop(rx, results_clone);
            })
            .expect("failed to spawn async-loader thread");

        Self {
            next_id: AtomicU64::new(1),
            tx: Some(tx),
            results,
            worker: Some(worker),
        }
    }

    /// Submit a file-read request.
    ///
    /// # Parameters
    /// - `resolved_path` — `PathBuf`.
    ///
    /// # Returns
    /// `LoadHandle`.
    ///
    /// `resolved_path` must already be sandbox-validated (canonical, inside the
    /// game directory).  Path validation is the caller's responsibility and MUST
    /// happen on the main thread *before* this call to prevent TOCTOU races.
    ///
    /// Returns a [`LoadHandle`] that can be passed to [`poll`](Self::poll).
    pub fn request_load(&self, resolved_path: PathBuf) -> LoadHandle {
        let id = self.next_id.fetch_add(1, Ordering::Relaxed);
        let handle = LoadHandle(id);

        if let Some(ref tx) = self.tx {
            // try_send avoids blocking the main thread if the queue is full.
            if tx
                .try_send(LoadRequest {
                    handle,
                    resolved_path,
                })
                .is_err()
            {
                // Queue full — report as an error result immediately.
                if let Ok(mut map) = self.results.lock() {
                    map.insert(id, LoadResult::Error("Async load queue is full".into()));
                }
            }
        }
        handle
    }

    /// Check the status of a previously-requested load.
    ///
    /// # Parameters
    /// - `handle` — `LoadHandle`.
    ///
    /// # Returns
    /// `LoadStatus`.
    ///
    /// Returns [`LoadStatus::Done`] exactly once — subsequent polls for the same
    /// handle return [`LoadStatus::Pending`] (the entry is removed on first read).
    pub fn poll(&self, handle: LoadHandle) -> LoadStatus {
        if let Ok(mut map) = self.results.lock() {
            if let Some(result) = map.remove(&handle.0) {
                return LoadStatus::Done(result);
            }
        }
        LoadStatus::Pending
    }

    /// Returns the number of completed but un-polled results.
    ///
    /// # Returns
    /// `usize`.
    pub fn pending_results(&self) -> usize {
        self.results.lock().map(|m| m.len()).unwrap_or(0)
    }

    /// Worker thread main loop — reads files and stores results.
    fn worker_loop(rx: mpsc::Receiver<LoadRequest>, results: Arc<Mutex<HashMap<u64, LoadResult>>>) {
        for req in rx.iter() {
            let result = match std::fs::read(&req.resolved_path) {
                Ok(bytes) => LoadResult::Ready(bytes),
                Err(e) => LoadResult::Error(format!(
                    "Failed to read '{}': {}",
                    req.resolved_path.display(),
                    e
                )),
            };
            if let Ok(mut map) = results.lock() {
                map.insert(req.handle.0, result);
            }
        }
        // Channel closed — worker exits cleanly.
    }
}

impl Default for AsyncLoader {
    fn default() -> Self {
        Self::new()
    }
}

impl Drop for AsyncLoader {
    fn drop(&mut self) {
        // Drop the sender to signal the worker to exit.
        self.tx.take();
        if let Some(handle) = self.worker.take() {
            let _ = handle.join();
        }
    }
}
