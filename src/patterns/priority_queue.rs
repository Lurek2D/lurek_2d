//! This file owns the stable priority queue used to order items by urgency while preserving FIFO ties by sequence.
//! `PriorityItem` stores ids, priority, label, and sequence, while `PriorityQueue` owns sorting and head compaction.
//! Push, pop, peek, and removal stay here because tie-breaking and consumed-front cleanup are local queue semantics.
//! The live-slice and compact helpers also belong here since they hide storage details behind stable public ordering.
//! Open it when scheduling order changes; rings, command history, and weighted picks live in sibling modules.

/// A single entry in the queue with a stable tie-breaking sequence number.
///
/// # Fields
/// - `id`: Stable queue entry identifier.
/// - `priority`: Higher values are dequeued first.
/// - `label`: Debug-oriented label string.
/// - `seq`: FIFO tie-breaker for equal priority entries.
#[derive(Debug, Clone)]
pub struct PriorityItem {
    /// Unique item id.
    pub id: u64,
    /// Scheduling priority; higher is dequeued first.
    pub priority: i64,
    /// Debug label.
    pub label: String,
    /// Insertion sequence number for FIFO ordering among equal priorities.
    pub seq: u64,
}
/// Sorted queue of `PriorityItem` entries.
///
/// # Fields
/// - `name`: Debug name for this queue instance.
#[derive(Debug)]
pub struct PriorityQueue {
    /// Debug name.
    pub name: String,
    /// Next item id to assign.
    next_id: u64,
    /// Insertion counter for stable ordering.
    next_seq: u64,
    /// Items stored in descending priority order.
    items: Vec<PriorityItem>,
    /// Index of the first live item within `items`.
    head: usize,
}
/// All methods for `PriorityQueue`.
impl PriorityQueue {
    /// Create an empty priority queue named `name`.
    pub fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            next_id: 1,
            next_seq: 0,
            items: Vec::new(),
            head: 0,
        }
    }
    /// Insert an item with `priority` and `label`; return its id.
    pub fn push(&mut self, priority: i64, label: &str) -> u64 {
        let id = self.next_id;
        self.next_id += 1;
        let seq = self.next_seq;
        self.next_seq += 1;
        let item = PriorityItem {
            id,
            priority,
            label: label.to_string(),
            seq,
        };
        let pos = self
            .active_items()
            .partition_point(|x| x.priority > priority || (x.priority == priority && x.seq < seq));
        self.items.insert(self.head + pos, item);
        id
    }
    /// Return a reference to the highest-priority item without removing it.
    pub fn peek(&self) -> Option<&PriorityItem> {
        self.active_items().first()
    }
    /// Remove and return the highest-priority item's id and priority.
    pub fn pop(&mut self) -> Option<(u64, i64)> {
        let item = self.active_items().first()?.clone();
        self.head += 1;
        self.compact();
        Some((item.id, item.priority))
    }
    /// Remove the item with `id`; return true when it was found.
    pub fn remove(&mut self, id: u64) -> bool {
        let before = self.len();
        if before == 0 {
            return false;
        }
        let mut kept = self.active_items().to_vec();
        kept.retain(|i| i.id != id);
        if kept.len() == before {
            return false;
        }
        self.items = kept;
        self.head = 0;
        true
    }
    /// Return the number of items in the queue.
    pub fn len(&self) -> usize {
        self.items.len().saturating_sub(self.head)
    }
    /// Return true when the queue is empty.
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }
    /// Return all items in priority order.
    pub fn items(&self) -> &[PriorityItem] {
        self.active_items()
    }
    /// Remove all items. This function is part of the public API.
    pub fn clear(&mut self) {
        self.items.clear();
        self.head = 0;
    }

    /// Returns the live queue slice from highest to lowest priority.
    fn active_items(&self) -> &[PriorityItem] {
        &self.items[self.head..]
    }

    /// Compacts consumed front slack after repeated pops.
    fn compact(&mut self) {
        if self.head == 0 {
            return;
        }
        if self.head >= self.items.len() {
            self.items.clear();
            self.head = 0;
            return;
        }
        if self.head * 2 >= self.items.len() {
            self.items.drain(..self.head);
            self.head = 0;
        }
    }
}
