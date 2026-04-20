//! Per-frame depth-sorted draw batcher.
//!
//! This module is part of Lurek2D's `scene` subsystem and provides the implementation
//! details for depth sorter-related operations and data management.
//! Key types exported from this module: `DepthEntry`, `DepthSorter`.
//! Primary functions: `new()`, `add()`, `add_object()`, `sort()`, `sort_radix()`.
//!
//! # Performance
//! Sorting is skipped entirely when the **dirty flag** is clear (no entries added since the
//! last flush).  For 256+ integer-depth entries the sort delegates to a two-pass LSD **radix
//! sort** in O(n).  For 10 000+ entries the sort delegates to **rayon parallel sort**.
//! When `stable = true` a stable comparison sort preserves insertion order for equal depths.
//!
//! All public items are documented. See the parent module for architectural context
//! and the `lurek.*` Lua API for the scripting interface.

/// Minimum entry count to engage the two-pass radix sort path.
const RADIX_THRESHOLD: usize = 256;

/// Minimum entry count to engage the rayon parallel-sort path.
const PARALLEL_SORT_THRESHOLD: usize = 10_000;

/// Depth range offset used when encoding signed floats to unsigned radix keys.
/// Covers the signed range [â’65535, 65535] â†’ [0, 131070] as `u32`.
const DEPTH_OFFSET: f32 = 65_535.0;

/// Entry in the depth-sorted draw queue.
///
/// All fields are `Copy`, allowing the radix-sort index-permutation path to
/// reconstruct the sorted slice without heap allocation beyond the initial `Vec`.
///
/// # Fields
/// - `depth` â€” `f32`. Render depth; lower values are drawn first.
/// - `callback_index` â€” `usize`. Index into the caller-managed callback list.
/// - `is_object` â€” `bool`. `true` when the entry is a table with `:drawSorted()`.
#[derive(Clone, Copy)]
pub struct DepthEntry {
    /// Depth value â€” lower values are drawn first.
    pub depth: f32,
    /// Index into an external callback storage (managed by Lua API layer).
    pub callback_index: usize,
    /// If true, the callback is an object with a `:drawSorted()` method.
    pub is_object: bool,
}

/// Per-frame depth-sorted draw batcher.
///
/// Collects draw callbacks with associated depth values, sorts them once per dirty
/// cycle, and flushes them in ascending depth order.
///
/// # Performance model
/// - **Dirty flag** (`dirty`): set on every `add`/`add_object`; cleared after sort.
///   `sorted_entries()` skips the sort entirely when `dirty == false`.
/// - **Radix path** (`sort_radix`): engaged automatically when
///   `entries.len() >= RADIX_THRESHOLD` and all depths are whole-number values
///   (fract â‰ 0).  Two-pass LSD radix sort over unsigned 32-bit keys.
/// - **Parallel path**: engaged automatically when `entries.len() > PARALLEL_SORT_THRESHOLD`;
///   uses rayon `par_sort_unstable_by`.
/// - **Stable flag** (`stable`): when `true`, equal-depth entries preserve insertion order.
///
/// # Fields
/// - `entries` â€” `Vec<DepthEntry>`. Pending draw entries.
/// - `dirty` â€” `bool`. `true` when entries were added since the last sort.
/// - `stable` â€” `bool`. When `true`, stable comparison sort is used.
pub struct DepthSorter {
    /// Pending draw entries.
    entries: Vec<DepthEntry>,
    /// `true` when entries were added since the last successful sort.
    dirty: bool,
    /// When `true`, sort preserves insertion order for entries with equal depths.
    stable: bool,
}

impl DepthSorter {
    /// Create a new empty depth sorter.
    ///
    /// Starts with `dirty = false` (no entries) and `stable = false` (fast unstable sort).
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self {
            entries: Vec::new(),
            dirty: false,
            stable: false,
        }
    }

    /// Enable or disable stable sort mode.
    ///
    /// When `stable = true`, entries with equal depths draw in insertion order.
    /// The default is unstable (faster) sort.
    ///
    /// # Parameters
    /// - `val` â€” `bool`. `true` enables stable sort.
    pub fn set_stable(&mut self, val: bool) {
        self.stable = val;
    }

    /// Whether stable sort mode is currently enabled.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_stable(&self) -> bool {
        self.stable
    }

    /// Add a draw callback at the given depth.
    ///
    /// Sets the dirty flag so the next `sorted_entries()` call will sort.
    ///
    /// # Parameters
    /// - `callback_index` â€” `usize`. Index into the caller's callback list.
    /// - `depth` â€” `f32`. Render depth; lower values are drawn first.
    pub fn add(&mut self, callback_index: usize, depth: f32) {
        self.entries.push(DepthEntry {
            depth,
            callback_index,
            is_object: false,
        });
        self.dirty = true;
    }

    /// Add a table object with a `:drawSorted()` method at the given depth.
    ///
    /// Sets the dirty flag so the next `sorted_entries()` call will sort.
    ///
    /// # Parameters
    /// - `callback_index` â€” `usize`. Index into the caller's object list.
    /// - `depth` â€” `f32`. Render depth; lower values are drawn first.
    pub fn add_object(&mut self, callback_index: usize, depth: f32) {
        self.entries.push(DepthEntry {
            depth,
            callback_index,
            is_object: true,
        });
        self.dirty = true;
    }

    /// Sort entries by depth ascending, choosing the fastest available path.
    ///
    /// Dispatches in this priority order:
    /// 1. Parallel sort when `len > PARALLEL_SORT_THRESHOLD`.
    /// 2. Radix sort when `!stable && len >= RADIX_THRESHOLD` and all depths are integral.
    /// 3. Stable comparison sort when `stable = true`.
    /// 4. Unstable comparison sort (default).
    ///
    /// Clears the dirty flag on completion.
    pub fn sort(&mut self) {
        if self.entries.len() > PARALLEL_SORT_THRESHOLD {
            self.sort_parallel();
        } else if !self.stable
            && self.entries.len() >= RADIX_THRESHOLD
            && Self::are_integral_depths(&self.entries)
        {
            self.sort_radix();
        } else if self.stable {
            self.entries.sort_by(|a, b| {
                a.depth
                    .partial_cmp(&b.depth)
                    .unwrap_or(std::cmp::Ordering::Equal)
            });
            self.dirty = false;
        } else {
            self.entries.sort_unstable_by(|a, b| {
                a.depth
                    .partial_cmp(&b.depth)
                    .unwrap_or(std::cmp::Ordering::Equal)
            });
            self.dirty = false;
        }
    }

    /// Sort using a two-pass LSD radix sort on unsigned 32-bit keys.
    ///
    /// The depth values are shifted by `DEPTH_OFFSET` into the unsigned range
    /// [0, 131070] so that negative depths sort before positive ones.  Only
    /// integer depths (fract â‰ 0) in [â’65535, 65535] are handled; values outside
    /// this range are clamped.
    ///
    /// Call `sort()` rather than this method directly â€” it applies the radix path
    /// only when the heuristics are met.  Returns `true` when the radix path was
    /// taken; `false` when it fell back to comparison sort.
    ///
    /// # Returns
    /// `bool`.
    pub fn sort_radix(&mut self) -> bool {
        if self.entries.len() < RADIX_THRESHOLD || !Self::are_integral_depths(&self.entries) {
            self.entries.sort_unstable_by(|a, b| {
                a.depth
                    .partial_cmp(&b.depth)
                    .unwrap_or(std::cmp::Ordering::Equal)
            });
            self.dirty = false;
            return false;
        }

        let n = self.entries.len();
        // Encode each depth as a u32 key paired with its original index.
        let mut keyed: Vec<(u32, usize)> = self
            .entries
            .iter()
            .enumerate()
            .map(|(i, e)| {
                let shifted = (e.depth + DEPTH_OFFSET).clamp(0.0, 2.0 * DEPTH_OFFSET) as u32;
                (shifted, i)
            })
            .collect();

        // Two independent 8-bit radix passes covering all 16 low bits then all 16 high bits.
        radix_pass_8bit(&mut keyed, 0);
        radix_pass_8bit(&mut keyed, 8);
        radix_pass_8bit(&mut keyed, 16);
        radix_pass_8bit(&mut keyed, 24);

        // Reconstruct in sorted order via the index permutation.  DepthEntry is Copy.
        let old: Vec<DepthEntry> = std::mem::replace(
            &mut self.entries,
            vec![
                DepthEntry {
                    depth: 0.0,
                    callback_index: 0,
                    is_object: false
                };
                n
            ],
        );
        for (new_pos, (_, orig_idx)) in keyed.iter().enumerate() {
            self.entries[new_pos] = old[*orig_idx];
        }

        self.dirty = false;
        true
    }

    /// Sort using rayon parallel unstable sort.
    ///
    /// Invoked automatically by `sort()` when `entries.len() > PARALLEL_SORT_THRESHOLD`.
    /// Requires the `rayon` crate (direct dependency in `Cargo.toml`).
    pub fn sort_parallel(&mut self) {
        use rayon::prelude::*;
        self.entries.par_sort_unstable_by(|a, b| {
            a.depth
                .partial_cmp(&b.depth)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        self.dirty = false;
    }

    /// Return the sorted entries for external processing.
    ///
    /// Skips the sort entirely when `dirty == false` â€” no entries have been added
    /// since the last flush.  This makes per-frame calls on static depth-sorted
    /// layers free (0 ns).
    ///
    /// # Returns
    /// `&[DepthEntry]`.
    pub fn sorted_entries(&mut self) -> &[DepthEntry] {
        if self.dirty {
            self.sort();
        }
        &self.entries
    }

    /// Clear all entries without calling them.
    ///
    /// Preserves the `stable` setting.  Clears the dirty flag.  After this call the
    /// container holds no entries and the next `sorted_entries()` call returns an
    /// empty slice.
    pub fn clear(&mut self) {
        self.entries.clear();
        self.dirty = false;
    }

    /// Number of queued entries.
    ///
    /// This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `usize`.
    pub fn get_count(&self) -> usize {
        self.entries.len()
    }

    // â”€â”€ Private helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    /// Returns `true` when all entry depths have a fractional part smaller than 1e-4.
    ///
    /// Used by `sort()` to decide whether the radix path is safe to apply.
    fn are_integral_depths(entries: &[DepthEntry]) -> bool {
        entries.iter().all(|e| e.depth.fract().abs() < 1e-4)
    }
}

/// One 8-bit radix pass over `(key, orig_idx)` pairs.
///
/// Sorts the slice in-place based on the 8-bit segment of `key` at `shift` bits.
/// Stable relative order within each bucket is preserved.
fn radix_pass_8bit(data: &mut Vec<(u32, usize)>, shift: u32) {
    const BUCKETS: usize = 256;
    let mut counts = [0usize; BUCKETS];
    for &(key, _) in data.iter() {
        let bucket = ((key >> shift) & 0xFF) as usize;
        counts[bucket] += 1;
    }
    let mut offsets = [0usize; BUCKETS];
    let mut total = 0;
    for i in 0..BUCKETS {
        offsets[i] = total;
        total += counts[i];
    }
    let mut output = vec![(0u32, 0usize); data.len()];
    for &(key, idx) in data.iter() {
        let bucket = ((key >> shift) & 0xFF) as usize;
        output[offsets[bucket]] = (key, idx);
        offsets[bucket] += 1;
    }
    *data = output;
}

impl Default for DepthSorter {
    fn default() -> Self {
        Self::new()
    }
}
