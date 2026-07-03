//! Owns the terminal terminal state grid implementation for the terminal subsystem and keeps rules local here.
//! Keeps terminal buffers, widgets, and text-facing presentation state so helpers stay close to invariants this updates.
//! Defines how terminal terminal state grid data is validated, transformed, or stored before systems consume it.
//! Separates terminal terminal state grid behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where terminal code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing terminal terminal state grid defaults, lifecycle handling, validation, or data rules.

use super::*;

impl Terminal {
    /// Set cell at 1-based `(col, row)` to `ch` with `fg` and `bg` colors; invalid payloads are sanitized and out-of-bounds writes are ignored.
    pub fn set(&mut self, col: usize, row: usize, ch: u32, fg: [f32; 4], bg: [f32; 4]) {
        let cell = self.sanitize_cell_payload(ch, fg, bg);
        if let Some(idx) = self.index_1based(col, row) {
            self.grid[idx] = cell;
        } else {
            self.diagnostics.out_of_bounds_writes += 1;
        }
    }

    /// Strictly set cell at 1-based `(col, row)` to `ch` with `fg` and `bg`, returning an error instead of silently sanitizing or ignoring.
    pub fn try_set(
        &mut self,
        col: usize,
        row: usize,
        ch: u32,
        fg: [f32; 4],
        bg: [f32; 4],
    ) -> Result<(), TerminalError> {
        let idx = self
            .index_1based(col, row)
            .ok_or(TerminalError::OutOfBoundsCell { col, row })?;
        if !is_valid_codepoint(ch) {
            return Err(TerminalError::InvalidCodepoint { ch });
        }
        let fg = sanitize_color(fg).ok_or(TerminalError::InvalidColor)?;
        let bg = sanitize_color(bg).ok_or(TerminalError::InvalidColor)?;
        self.grid[idx] = TCell { ch, fg, bg };
        Ok(())
    }

    /// Return the cell at 1-based `(col, row)`; returns a default cell when out of bounds.
    pub fn get(&self, col: usize, row: usize) -> TCell {
        self.index_1based(col, row)
            .map(|idx| self.grid[idx])
            .unwrap_or_default()
    }

    /// Reset all cells to their default state.
    pub fn clear(&mut self) {
        for cell in &mut self.grid {
            *cell = TCell::default();
        }
    }

    /// Return `(cols, rows)` of the current grid.
    pub fn get_dimensions(&self) -> (usize, usize) {
        (self.cols, self.rows)
    }

    /// Override the per-cell pixel dimensions; values below 1.0 are clamped to 1.0.
    pub fn set_cell_size(&mut self, w: f32, h: f32) {
        self.cell_width_override = Some(w.max(1.0));
        self.cell_height_override = Some(h.max(1.0));
    }

    /// Clear the cell size override so the render layer computes size from font metrics.
    pub fn reset_cell_size(&mut self) {
        self.cell_width_override = None;
        self.cell_height_override = None;
    }

    /// Return the overridden cell size as `Some((w, h))`, or `None` when using font metrics.
    pub fn get_cell_size(&self) -> Option<(f32, f32)> {
        match (self.cell_width_override, self.cell_height_override) {
            (Some(w), Some(h)) => Some((w, h)),
            _ => None,
        }
    }

    /// Return the cursor position as 1-based `(col, row)`.
    pub fn get_cursor(&self) -> (usize, usize) {
        (self.cursor_col + 1, self.cursor_row + 1)
    }

    /// Move the cursor to 1-based `(col, row)`, clamped to grid bounds.
    pub fn set_cursor(&mut self, col: usize, row: usize) {
        self.cursor_col = col.saturating_sub(1).min(self.cols.saturating_sub(1));
        self.cursor_row = row.saturating_sub(1).min(self.rows.saturating_sub(1));
    }

    /// Convert 1-based `(col, row)` to a flat grid index; returns `None` for `col`/`row` of 0 or out of bounds.
    fn index_1based(&self, col: usize, row: usize) -> Option<usize> {
        if col == 0 || row == 0 {
            return None;
        }
        let col = col - 1;
        let row = row - 1;
        if col < self.cols && row < self.rows {
            Some(row * self.cols + col)
        } else {
            None
        }
    }

    /// Return the column count. This function is part of the public API.
    pub fn cols(&self) -> usize {
        self.cols
    }

    /// Return the row count. This function is part of the public API.
    pub fn rows(&self) -> usize {
        self.rows
    }

    /// Return the cell at 1-based `(col, row)` as `Some`, or `None` when out of bounds.
    pub fn try_get(&self, col: usize, row: usize) -> Option<TCell> {
        self.index_1based(col, row).map(|idx| self.grid[idx])
    }

    /// Set only the character codepoint at 1-based `(col, row)`.
    pub fn set_char(&mut self, col: usize, row: usize, ch: u32) {
        let (fg, bg) = self
            .try_get(col, row)
            .map(|cell| (cell.fg, cell.bg))
            .unwrap_or((DEFAULT_FG, DEFAULT_BG));
        self.set(col, row, ch, fg, bg);
    }

    /// Set only the foreground color at 1-based `(col, row)`.
    pub fn set_fg(&mut self, col: usize, row: usize, fg: [f32; 4]) {
        if let Some(idx) = self.index_1based(col, row) {
            self.grid[idx].fg = sanitize_color(fg).unwrap_or_else(|| {
                self.diagnostics.invalid_colors += 1;
                DEFAULT_FG
            });
        } else {
            self.diagnostics.out_of_bounds_writes += 1;
        }
    }

    /// Set only the background color at 1-based `(col, row)`.
    pub fn set_bg(&mut self, col: usize, row: usize, bg: [f32; 4]) {
        if let Some(idx) = self.index_1based(col, row) {
            self.grid[idx].bg = sanitize_color(bg).unwrap_or_else(|| {
                self.diagnostics.invalid_colors += 1;
                DEFAULT_BG
            });
        } else {
            self.diagnostics.out_of_bounds_writes += 1;
        }
    }

    /// Write each character of `text` to successive columns starting at 1-based `(col, row)`, preserving existing fg/bg.
    pub fn print(&mut self, col: usize, row: usize, text: &str) {
        let text = self.clip_text_for_limit(text, self.limits.max_line_chars);
        for (offset, ch) in text.chars().enumerate() {
            if let Some(idx) = self.index_1based(col + offset, row) {
                self.grid[idx].ch = ch as u32;
            }
        }
    }

    /// Strictly write `text` into the grid, rejecting out-of-bounds starts and over-limit payloads.
    pub fn try_print(
        &mut self,
        col: usize,
        row: usize,
        text: &str,
    ) -> Result<usize, TerminalError> {
        let len = char_count(text);
        if len > self.limits.max_line_chars {
            return Err(TerminalError::TextTooLong {
                len,
                limit: self.limits.max_line_chars,
            });
        }
        self.index_1based(col, row)
            .ok_or(TerminalError::OutOfBoundsCell { col, row })?;
        self.print(col, row, text);
        Ok(len.min(self.cols.saturating_sub(col.saturating_sub(1))))
    }

    /// Resize the grid to `new_cols`×`new_rows`, preserving the overlapping content region.
    pub fn resize(&mut self, new_cols: usize, new_rows: usize) {
        let new_cols = new_cols.clamp(1, MAX_COLS);
        let new_rows = new_rows.clamp(1, MAX_ROWS);
        let mut new_grid = vec![TCell::default(); new_cols * new_rows];
        let copy_cols = new_cols.min(self.cols);
        let copy_rows = new_rows.min(self.rows);
        for row in 0..copy_rows {
            for col in 0..copy_cols {
                new_grid[row * new_cols + col] = self.grid[row * self.cols + col];
            }
        }
        self.cols = new_cols;
        self.rows = new_rows;
        self.grid = new_grid;
        self.cursor_col = self.cursor_col.min(self.cols.saturating_sub(1));
        self.cursor_row = self.cursor_row.min(self.rows.saturating_sub(1));
        self.ensure_focus_valid();
    }

    /// Apply `fg` and `bg` to every cell in the grid without changing character codepoints.
    pub fn set_default_colors(&mut self, fg: [f32; 4], bg: [f32; 4]) {
        let fg = sanitize_color(fg).unwrap_or_else(|| {
            self.diagnostics.invalid_colors += 1;
            DEFAULT_FG
        });
        let bg = sanitize_color(bg).unwrap_or_else(|| {
            self.diagnostics.invalid_colors += 1;
            DEFAULT_BG
        });
        for cell in &mut self.grid {
            cell.fg = fg;
            cell.bg = bg;
        }
    }

    /// Write `text` with explicit `fg` and optional `bg` starting at 1-based `(col, row)`.
    pub fn print_colored(
        &mut self,
        col: usize,
        row: usize,
        text: &str,
        fg: [f32; 4],
        bg: Option<[f32; 4]>,
    ) {
        let text = self.clip_text_for_limit(text, self.limits.max_line_chars);
        let fg = sanitize_color(fg).unwrap_or_else(|| {
            self.diagnostics.invalid_colors += 1;
            DEFAULT_FG
        });
        let bg = bg.map(|color| {
            sanitize_color(color).unwrap_or_else(|| {
                self.diagnostics.invalid_colors += 1;
                DEFAULT_BG
            })
        });
        for (offset, ch) in text.chars().enumerate() {
            let c = col + offset;
            if let Some(idx) = self.index_1based(c, row) {
                self.grid[idx].ch = ch as u32;
                self.grid[idx].fg = fg;
                if let Some(b) = bg {
                    self.grid[idx].bg = b;
                }
            }
        }
    }
}
