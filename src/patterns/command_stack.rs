//! Undo/redo command-stack metadata tracker.
//!
//! [`CommandStack`] manages cursor position and entry metadata.  The actual
//! execute/undo Lua callbacks are stored in the API layer.

// ── CommandEntry ──────────────────────────────────────────────────────────

/// Metadata for a single recorded command.
///
/// # Fields
/// - `id` — `u64`.
/// - `name` — `String`.
/// - `has_undo` — `bool`.
#[derive(Debug, Clone)]
pub struct CommandEntry {
    /// Unique monotonic ID.
    pub id: u64,
    /// Human-readable command label.
    pub name: String,
    /// Whether an undo callback was registered.
    pub has_undo: bool,
}

// ── CommandStack ──────────────────────────────────────────────────────────

/// Undo/redo command history with named groups and batch support.
///
/// # Fields
/// - `max_size` — `usize`.
/// - `batch_depth` — `usize`.
#[derive(Debug)]
pub struct CommandStack {
    /// Maximum entries retained (0 = unlimited).
    pub max_size: usize,
    entries: Vec<CommandEntry>,
    /// Cursor: number of entries that have been applied (0 = nothing applied).
    cursor: usize,
    next_id: u64,
    /// Non-zero when inside a batch; commands added during batch are grouped.
    pub batch_depth: usize,
    /// IDs grouped in the current batch.
    batch_buf: Vec<u64>,
}

impl CommandStack {
    /// Creates a new command stack.
    ///
    /// # Parameters
    /// - `max_size` — `usize`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(max_size: usize) -> Self {
        Self {
            max_size,
            entries: Vec::new(),
            cursor: 0,
            next_id: 1,
            batch_depth: 0,
            batch_buf: Vec::new(),
        }
    }

    /// Records a new command entry, discarding any redo history above the cursor.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `has_undo` — `bool`.
    ///
    /// # Returns
    /// `u64` — the new entry ID.
    pub fn push(&mut self, name: &str, has_undo: bool) -> u64 {
        // Discard redo future
        self.entries.truncate(self.cursor);
        let id = self.next_id;
        self.next_id += 1;
        self.entries.push(CommandEntry { id, name: name.to_string(), has_undo });
        self.cursor = self.entries.len();
        // Enforce max size
        if self.max_size > 0 && self.entries.len() > self.max_size {
            let surplus = self.entries.len() - self.max_size;
            self.entries.drain(..surplus);
            self.cursor = self.cursor.saturating_sub(surplus);
        }
        if self.batch_depth > 0 {
            self.batch_buf.push(id);
        }
        id
    }

    /// Returns the entry ID at the undo position (most recently applied command).
    ///
    /// # Returns
    /// `Option<u64>`.
    pub fn peek_undo(&self) -> Option<u64> {
        if self.cursor == 0 { return None; }
        self.entries.get(self.cursor - 1).map(|e| e.id)
    }

    /// Returns the entry ID at the redo position (next command that can be re-applied).
    ///
    /// # Returns
    /// `Option<u64>`.
    pub fn peek_redo(&self) -> Option<u64> {
        self.entries.get(self.cursor).map(|e| e.id)
    }

    /// Moves cursor back one step (undo intent); caller must execute the callback.
    ///
    /// # Returns
    /// `Option<u64>` — ID of the command to undo.
    pub fn step_undo(&mut self) -> Option<u64> {
        if self.cursor == 0 { return None; }
        self.cursor -= 1;
        self.entries.get(self.cursor).map(|e| e.id)
    }

    /// Moves cursor forward one step (redo intent); caller must execute the callback.
    ///
    /// # Returns
    /// `Option<u64>` — ID of the command to redo.
    pub fn step_redo(&mut self) -> Option<u64> {
        if self.cursor >= self.entries.len() { return None; }
        let id = self.entries[self.cursor].id;
        self.cursor += 1;
        Some(id)
    }

    /// Clears all history.
    pub fn clear(&mut self) {
        self.entries.clear();
        self.cursor = 0;
        self.batch_buf.clear();
    }

    /// Number of undoable steps from the current cursor.
    ///
    /// # Returns
    /// `usize`.
    pub fn undo_count(&self) -> usize { self.cursor }

    /// Number of redoable steps from the current cursor.
    ///
    /// # Returns
    /// `usize`.
    pub fn redo_count(&self) -> usize { self.entries.len() - self.cursor }

    /// Lookup entry metadata by ID.
    ///
    /// # Parameters
    /// - `id` — `u64`.
    ///
    /// # Returns
    /// `Option<&CommandEntry>`.
    pub fn get_entry(&self, id: u64) -> Option<&CommandEntry> {
        self.entries.iter().find(|e| e.id == id)
    }

    /// Begins a batch grouping.  Calls must be balanced with [`end_batch`][Self::end_batch].
    pub fn begin_batch(&mut self) {
        self.batch_depth += 1;
    }

    /// Ends a batch grouping and returns the grouped IDs if the outermost batch closes.
    ///
    /// # Returns
    /// `Option<Vec<u64>>`.
    pub fn end_batch(&mut self) -> Option<Vec<u64>> {
        if self.batch_depth == 0 { return None; }
        self.batch_depth -= 1;
        if self.batch_depth == 0 {
            let ids = std::mem::take(&mut self.batch_buf);
            Some(ids)
        } else {
            None
        }
    }
}

// Tests migrated to tests/rust/unit/patterns_tests.rs
