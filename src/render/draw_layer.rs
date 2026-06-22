//! Owns the draw layer model for the render subsystem and keeps its rules local to this file.
//! Centers the implementation around LayerEntry, DrawLayerError, fmt, with helpers kept close to their invariants.
//! Defines how draw layer data is validated, transformed, or stored before neighboring systems use it.
//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on draw layer behavior while Lua registration stays elsewhere.

use std::cmp::Ordering;
use std::fmt;

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

/// Error returned when a draw layer cannot allocate another callback ID.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DrawLayerError {
    /// The monotonic callback ID counter reached `usize::MAX`.
    CallbackIdExhausted,
}

impl fmt::Display for DrawLayerError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::CallbackIdExhausted => write!(f, "draw layer callback id counter exhausted"),
        }
    }
}

impl std::error::Error for DrawLayerError {}

/// Compare two queued layer entries with a total floating-point order and insertion tie-breaker.
pub fn compare_layer_entries(a: &LayerEntry, b: &LayerEntry) -> Ordering {
    a.z_order
        .total_cmp(&b.z_order)
        .then_with(|| a.callback_id.cmp(&b.callback_id))
}

/// Allocate the current callback ID and advance the counter without overflowing.
///
/// `usize::MAX` is reserved as the exhaustion sentinel returned by `DrawLayer::queue`,
/// so successful callback IDs stop at `usize::MAX - 1`.
pub fn allocate_callback_id(next_id: &mut usize) -> Result<usize, DrawLayerError> {
    let id = *next_id;
    if id == usize::MAX {
        return Err(DrawLayerError::CallbackIdExhausted);
    }
    *next_id = next_id
        .checked_add(1)
        .ok_or(DrawLayerError::CallbackIdExhausted)?;
    Ok(id)
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
    ///
    /// Returns `usize::MAX` and skips enqueueing if the callback ID counter is exhausted.
    /// Use `try_queue` when the caller needs structured error handling.
    pub fn queue(&mut self, z_order: f64) -> usize {
        match self.try_queue(z_order) {
            Ok(id) => id,
            Err(err) => {
                log::warn!("DrawLayer::queue skipped callback: {err}");
                usize::MAX
            }
        }
    }
    /// Try to enqueue a callback at `z_order` depth and return its unique callback ID.
    pub fn try_queue(&mut self, z_order: f64) -> Result<usize, DrawLayerError> {
        let id = allocate_callback_id(&mut self.next_id)?;
        self.entries.push(LayerEntry {
            z_order,
            callback_id: id,
        });
        Ok(id)
    }
    /// Sort entries by total `z_order`, drain, and return them; leaves the layer empty.
    pub fn flush(&mut self) -> Vec<LayerEntry> {
        self.entries.sort_by(compare_layer_entries);
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
