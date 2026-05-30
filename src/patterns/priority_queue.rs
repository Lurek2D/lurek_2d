//! Ordered priority queue for gameplay scheduling and selection tasks that need highest-priority work first without losing deterministic order among ties.
//! The file assigns each entry its own identity and insertion sequence so queue mutation remains inspectable even when multiple items share the same score.
//! Push, pop, peek, and targeted removal operate on one consistently sorted store rather than spreading priority semantics across separate containers and side maps.
//! Functionally this delivers stable urgency-based ordering for task systems, AI planners, turn resolution, and any script logic that needs predictable priority arbitration.

/// A single entry in the queue with a stable tie-breaking sequence number.
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
            .items
            .partition_point(|x| x.priority > priority || (x.priority == priority && x.seq < seq));
        self.items.insert(pos, item);
        id
    }
    /// Return a reference to the highest-priority item without removing it.
    pub fn peek(&self) -> Option<&PriorityItem> {
        self.items.first()
    }
    /// Remove and return the highest-priority item's id and priority.
    pub fn pop(&mut self) -> Option<(u64, i64)> {
        if self.items.is_empty() {
            return None;
        }
        let item = self.items.remove(0);
        Some((item.id, item.priority))
    }
    /// Remove the item with `id`; return true when it was found.
    pub fn remove(&mut self, id: u64) -> bool {
        let before = self.items.len();
        self.items.retain(|i| i.id != id);
        self.items.len() < before
    }
    /// Return the number of items in the queue.
    pub fn len(&self) -> usize {
        self.items.len()
    }
    /// Return true when the queue is empty.
    pub fn is_empty(&self) -> bool {
        self.items.is_empty()
    }
    /// Return all items in priority order.
    pub fn items(&self) -> &[PriorityItem] {
        &self.items
    }
    /// Remove all items. This function is part of the public API.
    pub fn clear(&mut self) {
        self.items.clear();
    }
}
