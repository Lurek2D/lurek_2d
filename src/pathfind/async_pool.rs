//! Runs prioritized off-thread path queries so expensive A* work can happen without blocking the main game loop.
//! Owns async request and event payloads, worker queue state, cancellation tables, and owner-version supersession.
//! Streams partial or final path results back to callers, including cancelled, failed, complete, and superseded states.
//! Provides the execution boundary between synchronous path solvers and systems that need queued background navigation.
//! Tracks per-owner live requests so newer versions can invalidate stale work before outdated routes reach gameplay.
//! This file is the right owner for queue ordering, thread-count policy, pending counts, and worker shutdown rules.
//! Neighboring changes usually involve NavGrid snapshots, A* budget behavior, and Lua or gameplay request adapters.
//! Open this file when path jobs need new lifecycle semantics or when streamed progress events stop matching callers.

use crate::pathfind::{astar, FlowField, FootprintSpec, NavGrid, UnitPathfinder};
use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap};
use std::sync::atomic::{AtomicU64, Ordering as AtomicOrdering};
use std::sync::{mpsc, Arc, Condvar, Mutex};
use std::thread;

type OwnerRequestMap = HashMap<u64, Vec<(u64, u64)>>;
type SharedOwnerRequests = Arc<Mutex<OwnerRequestMap>>;

/// Legacy completed result returned from the compatibility `poll()` API.
pub type PathResult = (u64, Option<Vec<(u32, u32)>>);
/// Grouped route payload returned by shared-goal async batch requests.
pub type GroupedPathResult = Vec<Option<Vec<(u32, u32)>>>;
/// One explicit start-goal pair for a batched path request.
pub type PathPair = ((u32, u32), (u32, u32));

/// Streaming/final state emitted for an async path request.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PathEventStatus {
    /// Intermediate best-effort path produced before the search budget is exhausted.
    Partial,
    /// The goal was reached and the final full path is available.
    Complete,
    /// The request ended without reaching the goal. The payload may still contain a partial path.
    Failed,
    /// The request was explicitly cancelled before completion.
    Cancelled,
    /// The request was superseded by a newer version for the same owner.
    Superseded,
}

/// One event emitted by the async path-query service.
#[derive(Debug, Clone)]
pub struct AsyncPathEvent {
    /// Caller-assigned request identifier.
    pub id: u64,
    /// Stable owner identifier used for version supersession.
    pub owner_id: u64,
    /// Caller-assigned version for stale-result suppression.
    pub version: u64,
    /// Event step index starting at 1 for each request.
    pub step: u32,
    /// Current request status.
    pub status: PathEventStatus,
    /// Best path known at this step, if any.
    pub path: Option<Vec<(u32, u32)>>,
    /// Best grouped paths known at this step, if any.
    pub paths: Option<GroupedPathResult>,
    /// True only when the goal was actually reached.
    pub complete: bool,
    /// True when this is the terminal event for the request.
    pub final_event: bool,
}

impl AsyncPathEvent {
    fn terminal(
        request: &AsyncPathRequest,
        step: u32,
        status: PathEventStatus,
        path: Option<Vec<(u32, u32)>>,
    ) -> Self {
        Self {
            id: request.id,
            owner_id: request.owner_id,
            version: request.version,
            step,
            status,
            paths: None,
            complete: matches!(status, PathEventStatus::Complete),
            final_event: true,
            path,
        }
    }

    fn terminal_paths(
        request: &AsyncPathRequest,
        step: u32,
        status: PathEventStatus,
        paths: GroupedPathResult,
    ) -> Self {
        Self {
            id: request.id,
            owner_id: request.owner_id,
            version: request.version,
            step,
            status,
            path: None,
            paths: Some(paths),
            complete: matches!(status, PathEventStatus::Complete),
            final_event: true,
        }
    }

    fn partial(request: &AsyncPathRequest, step: u32, path: Option<Vec<(u32, u32)>>) -> Self {
        Self {
            id: request.id,
            owner_id: request.owner_id,
            version: request.version,
            step,
            status: PathEventStatus::Partial,
            complete: false,
            final_event: false,
            path,
            paths: None,
        }
    }
}

/// Caller-specified request metadata and search parameters.
#[derive(Debug, Clone)]
pub struct AsyncPathRequest {
    /// Caller-assigned request identifier.
    pub id: u64,
    /// Stable owner/group identifier used for version supersession.
    pub owner_id: u64,
    /// Monotonic request version for the owner.
    pub version: u64,
    /// Higher values run before lower values once they reach the queue.
    pub priority: i32,
    /// Grid snapshot fully owned by the worker.
    pub grid: NavGrid,
    /// Start cell.
    pub start: (u32, u32),
    /// Goal cell.
    pub goal: (u32, u32),
    /// Clearance footprint forwarded to A*.
    pub unit_size: u32,
    /// Partial-stream budget per step. Zero disables streaming and runs one final search.
    pub stream_budget: u32,
    /// Optional grouped start cells for one shared-goal batch request.
    pub batch_starts: Option<Vec<(u32, u32)>>,
    /// Optional grouped target cells for one shared-goal batch request.
    pub batch_targets: Option<Vec<(u32, u32)>>,
    /// Optional explicit start-goal pairs for one paired async batch request.
    pub batch_pairs: Option<Vec<PathPair>>,
    /// Optional footprint forwarded to shared-goal batch flow construction.
    pub batch_footprint: Option<FootprintSpec>,
    /// Optional maximum downhill reconstruction steps for shared-goal batch routes.
    pub batch_max_steps: u32,
}

impl AsyncPathRequest {
    /// Build a legacy one-shot request with no streaming or version tracking.
    pub fn legacy(
        id: u64,
        grid: NavGrid,
        start: (u32, u32),
        goal: (u32, u32),
        unit_size: u32,
    ) -> Self {
        Self {
            id,
            owner_id: id,
            version: 0,
            priority: 0,
            grid,
            start,
            goal,
            unit_size,
            stream_budget: 0,
            batch_starts: None,
            batch_targets: None,
            batch_pairs: None,
            batch_footprint: None,
            batch_max_steps: 0,
        }
    }

    fn tracks_version(&self) -> bool {
        self.version > 0 || self.owner_id != self.id
    }

    fn is_batch(&self) -> bool {
        self.batch_starts.is_some() || self.batch_pairs.is_some()
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum CancelReason {
    Cancelled,
    Superseded,
}

#[derive(Debug)]
struct QueuedRequest {
    priority: i32,
    sequence: u64,
    request: AsyncPathRequest,
}

impl PartialEq for QueuedRequest {
    fn eq(&self, other: &Self) -> bool {
        self.priority == other.priority && self.sequence == other.sequence
    }
}

impl Eq for QueuedRequest {}

impl Ord for QueuedRequest {
    fn cmp(&self, other: &Self) -> Ordering {
        self.priority
            .cmp(&other.priority)
            .then_with(|| other.sequence.cmp(&self.sequence))
    }
}

impl PartialOrd for QueuedRequest {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

#[derive(Debug, Default)]
struct QueueState {
    queue: BinaryHeap<QueuedRequest>,
    shutdown_tokens: usize,
    closed: bool,
}

#[derive(Debug, Default)]
struct WorkQueue {
    state: Mutex<QueueState>,
    ready: Condvar,
}

impl WorkQueue {
    fn push(&self, request: QueuedRequest) {
        let mut state = self.state.lock().unwrap_or_else(|e| e.into_inner());
        if state.closed {
            return;
        }
        state.queue.push(request);
        self.ready.notify_one();
    }

    fn next(&self) -> Option<AsyncPathRequest> {
        let mut state = self.state.lock().unwrap_or_else(|e| e.into_inner());
        loop {
            if state.closed {
                return None;
            }
            if state.shutdown_tokens > 0 {
                state.shutdown_tokens -= 1;
                return None;
            }
            if let Some(request) = state.queue.pop() {
                return Some(request.request);
            }
            state = self.ready.wait(state).unwrap_or_else(|e| e.into_inner());
        }
    }

    fn request_shutdown(&self, count: usize) {
        let mut state = self.state.lock().unwrap_or_else(|e| e.into_inner());
        state.shutdown_tokens = state.shutdown_tokens.saturating_add(count);
        self.ready.notify_all();
    }

    fn close(&self) {
        let mut state = self.state.lock().unwrap_or_else(|e| e.into_inner());
        state.closed = true;
        self.ready.notify_all();
    }
}

/// Fixed-size worker pool that runs prioritized path queries off the game thread.
pub struct PathThreadPool {
    /// Shared prioritized work queue.
    queue: Arc<WorkQueue>,
    /// Receiver for streamed and final events.
    rx: mpsc::Receiver<AsyncPathEvent>,
    /// Sender cloned into workers and reused for immediate terminal events.
    result_tx: mpsc::Sender<AsyncPathEvent>,
    /// Explicitly cancelled request ids.
    cancelled: Arc<Mutex<HashMap<u64, CancelReason>>>,
    /// Latest accepted version per owner for stale-result suppression.
    latest_versions: Arc<Mutex<HashMap<u64, u64>>>,
    /// Live request ids tracked per owner so newer versions can supersede older work deterministically.
    owner_requests: SharedOwnerRequests,
    /// Configured worker-thread count.
    thread_count: usize,
    /// Owned worker join handles.
    handles: Vec<thread::JoinHandle<()>>,
    /// Number of live requests submitted but not yet terminated.
    pending: Arc<Mutex<u32>>,
    /// Submission sequence used to keep FIFO order inside one priority level.
    next_sequence: AtomicU64,
}

impl PathThreadPool {
    /// Spawn `thread_count` workers (minimum 1).
    pub fn new(thread_count: usize) -> Self {
        let count = thread_count.max(1);
        let (result_tx, result_rx) = mpsc::channel::<AsyncPathEvent>();
        let queue = Arc::new(WorkQueue::default());
        let cancelled = Arc::new(Mutex::new(HashMap::new()));
        let latest_versions = Arc::new(Mutex::new(HashMap::new()));
        let owner_requests = Arc::new(Mutex::new(HashMap::new()));
        let pending = Arc::new(Mutex::new(0));
        let mut handles = Vec::with_capacity(count);
        for _ in 0..count {
            handles.push(Self::spawn_worker(
                Arc::clone(&queue),
                result_tx.clone(),
                Arc::clone(&cancelled),
                Arc::clone(&latest_versions),
                Arc::clone(&owner_requests),
                Arc::clone(&pending),
            ));
        }
        Self {
            queue,
            rx: result_rx,
            result_tx,
            cancelled,
            latest_versions,
            owner_requests,
            thread_count: count,
            handles,
            pending,
            next_sequence: AtomicU64::new(0),
        }
    }

    fn spawn_worker(
        queue: Arc<WorkQueue>,
        tx: mpsc::Sender<AsyncPathEvent>,
        cancelled: Arc<Mutex<HashMap<u64, CancelReason>>>,
        latest_versions: Arc<Mutex<HashMap<u64, u64>>>,
        owner_requests: SharedOwnerRequests,
        pending: Arc<Mutex<u32>>,
    ) -> thread::JoinHandle<()> {
        thread::spawn(move || {
            while let Some(request) = queue.next() {
                if let Some(event) = Self::terminal_state(&request, &cancelled, &latest_versions, 0)
                {
                    Self::finish_request(&tx, &pending, &owner_requests, event);
                    continue;
                }

                if request.is_batch() {
                    if let Some(pairs) = request.batch_pairs.as_deref() {
                        let footprint = request.batch_footprint.unwrap_or_else(|| {
                            FootprintSpec::new(request.unit_size, request.unit_size)
                        });
                        let mut pathfinder =
                            UnitPathfinder::new(ArcGridAdapter::clone_to_rc(&request.grid));
                        let paths = pathfinder
                            .find_paths_for_pairs_spec(pairs, footprint, request.batch_max_steps)
                            .into_iter()
                            .map(|path| {
                                path.map(|waypoints| {
                                    waypoints
                                        .into_iter()
                                        .map(|wp| (wp.x, wp.y))
                                        .collect::<Vec<_>>()
                                })
                            })
                            .collect::<Vec<_>>();

                        if let Some(event) =
                            Self::terminal_state(&request, &cancelled, &latest_versions, 1)
                        {
                            Self::finish_request(&tx, &pending, &owner_requests, event);
                            continue;
                        }

                        let status = if paths.iter().all(|path| path.is_some()) {
                            PathEventStatus::Complete
                        } else {
                            PathEventStatus::Failed
                        };
                        Self::finish_request(
                            &tx,
                            &pending,
                            &owner_requests,
                            AsyncPathEvent::terminal_paths(&request, 1, status, paths),
                        );
                        continue;
                    }

                    let starts = request.batch_starts.as_deref().unwrap_or(&[]);
                    let targets = request.batch_targets.as_deref().unwrap_or(&[]);
                    let footprint = request.batch_footprint.unwrap_or_else(|| {
                        FootprintSpec::new(request.unit_size, request.unit_size)
                    });
                    let mut flow = FlowField::new(ArcGridAdapter::clone_to_rc(&request.grid));
                    flow.calculate_multi_spec(targets, footprint);
                    let paths = starts
                        .iter()
                        .map(|&(x, y)| flow.path_from(x, y, request.batch_max_steps))
                        .collect::<Vec<_>>();

                    if let Some(event) =
                        Self::terminal_state(&request, &cancelled, &latest_versions, 1)
                    {
                        Self::finish_request(&tx, &pending, &owner_requests, event);
                        continue;
                    }

                    let status = if paths.iter().any(|path| path.is_some()) {
                        PathEventStatus::Complete
                    } else {
                        PathEventStatus::Failed
                    };
                    Self::finish_request(
                        &tx,
                        &pending,
                        &owner_requests,
                        AsyncPathEvent::terminal_paths(&request, 1, status, paths),
                    );
                    continue;
                }

                let max_budget = request
                    .grid
                    .get_width()
                    .saturating_mul(request.grid.get_height())
                    .max(1);
                let mut step = 0u32;
                let mut budget = if request.stream_budget == 0 {
                    max_budget
                } else {
                    request.stream_budget.max(1).min(max_budget)
                };

                loop {
                    step = step.saturating_add(1);
                    let (path, reached_goal) = astar::astar(
                        &request.grid,
                        request.start,
                        request.goal,
                        request.unit_size,
                        budget,
                    );

                    if let Some(event) =
                        Self::terminal_state(&request, &cancelled, &latest_versions, step)
                    {
                        Self::finish_request(&tx, &pending, &owner_requests, event);
                        break;
                    }

                    let is_last_step =
                        request.stream_budget == 0 || budget >= max_budget || path.is_none();
                    let event = if reached_goal {
                        AsyncPathEvent::terminal(&request, step, PathEventStatus::Complete, path)
                    } else if is_last_step {
                        AsyncPathEvent::terminal(&request, step, PathEventStatus::Failed, path)
                    } else {
                        AsyncPathEvent::partial(&request, step, path)
                    };

                    let final_event = event.final_event;
                    let _ = tx.send(event);
                    if final_event {
                        Self::remove_live_request(&owner_requests, request.owner_id, request.id);
                        if let Ok(mut pending_count) = pending.lock() {
                            *pending_count = pending_count.saturating_sub(1);
                        }
                        break;
                    }

                    let next_budget = budget.saturating_mul(2).min(max_budget);
                    budget = if next_budget == budget {
                        max_budget
                    } else {
                        next_budget
                    };
                }
            }
        })
    }

    fn finish_request(
        tx: &mpsc::Sender<AsyncPathEvent>,
        pending: &Arc<Mutex<u32>>,
        owner_requests: &SharedOwnerRequests,
        event: AsyncPathEvent,
    ) {
        let owner_id = event.owner_id;
        let request_id = event.id;
        let _ = tx.send(event);
        Self::remove_live_request(owner_requests, owner_id, request_id);
        if let Ok(mut pending_count) = pending.lock() {
            *pending_count = pending_count.saturating_sub(1);
        }
    }

    fn remove_live_request(owner_requests: &SharedOwnerRequests, owner_id: u64, request_id: u64) {
        if let Ok(mut live) = owner_requests.lock() {
            if let Some(entries) = live.get_mut(&owner_id) {
                entries.retain(|(id, _)| *id != request_id);
                if entries.is_empty() {
                    live.remove(&owner_id);
                }
            }
        }
    }

    fn terminal_state(
        request: &AsyncPathRequest,
        cancelled: &Arc<Mutex<HashMap<u64, CancelReason>>>,
        latest_versions: &Arc<Mutex<HashMap<u64, u64>>>,
        step: u32,
    ) -> Option<AsyncPathEvent> {
        {
            let mut cancelled_ids = cancelled.lock().unwrap_or_else(|e| e.into_inner());
            if let Some(reason) = cancelled_ids.remove(&request.id) {
                let status = match reason {
                    CancelReason::Cancelled => PathEventStatus::Cancelled,
                    CancelReason::Superseded => PathEventStatus::Superseded,
                };
                return Some(AsyncPathEvent::terminal(request, step, status, None));
            }
        }

        if request.tracks_version() {
            let latest = latest_versions
                .lock()
                .unwrap_or_else(|e| e.into_inner())
                .get(&request.owner_id)
                .copied()
                .unwrap_or(request.version);
            if latest > request.version {
                return Some(AsyncPathEvent::terminal(
                    request,
                    step,
                    PathEventStatus::Superseded,
                    None,
                ));
            }
        }

        None
    }

    /// Submit a request to the prioritized queue. Returns false when it is stale immediately.
    pub fn submit_query(&self, request: AsyncPathRequest) -> bool {
        if request.tracks_version() {
            let mut latest = self
                .latest_versions
                .lock()
                .unwrap_or_else(|e| e.into_inner());
            let current = latest.get(&request.owner_id).copied().unwrap_or(0);
            if request.version < current {
                let _ = self.result_tx.send(AsyncPathEvent::terminal(
                    &request,
                    0,
                    PathEventStatus::Superseded,
                    None,
                ));
                return false;
            }
            latest.insert(request.owner_id, request.version);
        }

        if let Ok(mut cancelled_ids) = self.cancelled.lock() {
            cancelled_ids.remove(&request.id);
        }

        if request.tracks_version() {
            let mut stale_ids = Vec::new();
            if let Ok(mut live) = self.owner_requests.lock() {
                let entries = live.entry(request.owner_id).or_default();
                entries.retain(|(id, version)| {
                    if *version < request.version {
                        stale_ids.push(*id);
                        false
                    } else {
                        true
                    }
                });
                entries.push((request.id, request.version));
            }
            if !stale_ids.is_empty() {
                if let Ok(mut cancelled_ids) = self.cancelled.lock() {
                    for stale_id in stale_ids {
                        cancelled_ids.insert(stale_id, CancelReason::Superseded);
                    }
                }
            }
        }

        if let Ok(mut pending_count) = self.pending.lock() {
            *pending_count = pending_count.saturating_add(1);
        }

        let sequence = self.next_sequence.fetch_add(1, AtomicOrdering::Relaxed);
        self.queue.push(QueuedRequest {
            priority: request.priority,
            sequence,
            request,
        });
        true
    }

    /// Submit a legacy one-shot request. The id is also used as the owner id.
    pub fn submit(
        &self,
        id: u64,
        grid_snapshot: NavGrid,
        start: (u32, u32),
        goal: (u32, u32),
        unit_size: u32,
    ) {
        let _ = self.submit_query(AsyncPathRequest::legacy(
            id,
            grid_snapshot,
            start,
            goal,
            unit_size,
        ));
    }

    /// Drain all streamed and final events without blocking.
    pub fn poll_events(&self) -> Vec<AsyncPathEvent> {
        let mut results = Vec::new();
        while let Ok(result) = self.rx.try_recv() {
            results.push(result);
        }
        results
    }

    /// Drain only legacy-style final results from the event channel.
    pub fn poll(&self) -> Vec<PathResult> {
        self.poll_events()
            .into_iter()
            .filter(|event| event.final_event)
            .map(|event| (event.id, event.path))
            .collect()
    }

    /// Mark a request id as cancelled. The terminal cancel event is emitted by the worker.
    pub fn cancel(&self, id: u64) {
        if let Ok(mut cancelled_ids) = self.cancelled.lock() {
            cancelled_ids.insert(id, CancelReason::Cancelled);
        }
    }

    /// Return the number of live requests that have not emitted a terminal event.
    pub fn pending_count(&self) -> u32 {
        self.pending.lock().map(|p| *p).unwrap_or(0)
    }

    fn reap_finished_workers(&mut self) {
        let mut idx = 0;
        while idx < self.handles.len() {
            if self.handles[idx].is_finished() {
                let handle = self.handles.swap_remove(idx);
                let _ = handle.join();
            } else {
                idx += 1;
            }
        }
    }

    /// Resize the worker pool. Shrinking retires workers after their current request.
    pub fn set_thread_count(&mut self, count: usize) {
        let target = count.max(1);
        self.reap_finished_workers();
        if target > self.thread_count {
            let additional = target - self.thread_count;
            self.handles.reserve(additional);
            for _ in 0..additional {
                self.handles.push(Self::spawn_worker(
                    Arc::clone(&self.queue),
                    self.result_tx.clone(),
                    Arc::clone(&self.cancelled),
                    Arc::clone(&self.latest_versions),
                    Arc::clone(&self.owner_requests),
                    Arc::clone(&self.pending),
                ));
            }
        } else if target < self.thread_count {
            self.queue.request_shutdown(self.thread_count - target);
        }
        self.thread_count = target;
    }

    /// Return the configured worker thread count.
    pub fn get_thread_count(&self) -> usize {
        self.thread_count
    }
}

struct ArcGridAdapter;

impl ArcGridAdapter {
    fn clone_to_rc(grid: &NavGrid) -> std::rc::Rc<std::cell::RefCell<NavGrid>> {
        std::rc::Rc::new(std::cell::RefCell::new(grid.clone()))
    }
}

impl Drop for PathThreadPool {
    fn drop(&mut self) {
        self.queue.close();
        while let Some(handle) = self.handles.pop() {
            let _ = handle.join();
        }
    }
}
