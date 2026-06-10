//! - Stores deferred draw-layer callbacks sorted by depth (Z-order).
//! - Enables gameplay code and UI components to enqueue layered draw commands cheaply.
//! - Postpones immediate GPU commands to allow sorting before final render dispatch.
//! - Centralizes sorting rules to ensure consistent layering of all drawn elements.
//! - Serves as a scheduling buffer between frame-level draw requests and GPU emission.
//! - Provides methods to queue, flush, clear, and inspect pending callbacks.

/// A pending draw-callback slot queued in `DrawLayer`.
///
/// # Fields
/// - `z_order` - Depth key used to order callbacks before flush.
/// - `callback_id` - Opaque callback handle returned to the Lua runtime.
pub struct LayerEntry {
    /// Depth key used to sort entries front-to-back before flush.
    pub z_order: f64,
    /// Opaque callback ID assigned at `queue` time; passed back to the Lua runtime.
    pub callback_id: usize,
}
/// Z-ordered pending-callback queue flushed once per frame by the render loop.
///
/// # Fields
/// - `entries` - Pending callback slots in insertion order until flush.
/// - `next_id` - Monotonic callback ID counter.
pub struct DrawLayer {
    /// Pending entries in insertion order; sorted at flush.
    entries: Vec<LayerEntry>,
    /// Monotonically incrementing counter for callback IDs.
    next_id: usize,
}
impl DrawLayer {
    /// Create an empty `DrawLayer` with ID counter starting at 0.
    pub fn new() -> Self {
        Self {
            entries: Vec::new(),
            next_id: 0,
        }
    }
    /// Enqueue a callback at `z_order` depth and return its unique callback ID.
    pub fn queue(&mut self, z_order: f64) -> usize {
        let id = self.next_id;
        self.next_id += 1;
        self.entries.push(LayerEntry {
            z_order,
            callback_id: id,
        });
        id
    }
    /// Sort entries by `z_order`, drain, and return them; leaves the layer empty.
    pub fn flush(&mut self) -> Vec<LayerEntry> {
        self.entries.sort_by(|a, b| {
            a.z_order
                .partial_cmp(&b.z_order)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        std::mem::take(&mut self.entries)
    }
    /// Discard all pending entries without firing callbacks.
    pub fn clear(&mut self) {
        self.entries.clear();
    }
    /// Return the number of pending entries.
    pub fn get_count(&self) -> usize {
        self.entries.len()
    }
}
/// Delegate `Default` to `DrawLayer::new`.
impl Default for DrawLayer {
    fn default() -> Self {
        Self::new()
    }
}
