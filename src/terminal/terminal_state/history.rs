//! Owns the terminal terminal state history implementation for the terminal subsystem and keeps rules local here.
//! Keeps terminal buffers, widgets, and text-facing presentation state so helpers stay close to invariants this updates.
//! Defines how terminal terminal state history data is validated, transformed, or stored before systems consume it.
//! Separates terminal terminal state history behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where terminal code accepts inputs, reports errors, allocates state, or emits outputs.

use super::*;

impl Terminal {
    /// Set the scrollback line cap; trims oldest lines immediately if the buffer exceeds the new limit.
    pub fn set_scrollback_cap(&mut self, cap: usize) {
        self.scrollback_cap = cap.max(1).min(self.limits.max_scrollback_lines);
        if self.scrollback.len() > self.effective_scrollback_cap() {
            let excess = self.scrollback.len() - self.effective_scrollback_cap();
            self.scrollback.drain(0..excess);
        }
    }

    /// Return the current scrollback line cap.
    pub fn scrollback_cap(&self) -> usize {
        self.scrollback_cap
    }

    /// Append `line` to scrollback, evicting the oldest line when the cap is reached; resets scroll offset to 0.
    pub fn push_scrollback(&mut self, line: &str) {
        let line = self.clip_text_for_limit(line, self.limits.max_line_chars);
        if self.scrollback.len() >= self.effective_scrollback_cap() {
            self.scrollback.remove(0);
        }
        self.scrollback.push(line);
        self.scrollback_offset = 0;
    }

    /// Strictly append `line` to scrollback without truncating or evicting beyond the hard limit.
    pub fn try_push_scrollback(&mut self, line: &str) -> Result<(), TerminalError> {
        let len = char_count(line);
        if len > self.limits.max_line_chars {
            return Err(TerminalError::TextTooLong {
                len,
                limit: self.limits.max_line_chars,
            });
        }
        if self.scrollback.len() >= self.effective_scrollback_cap() {
            return Err(TerminalError::HistoryLimitReached {
                limit: self.effective_scrollback_cap(),
            });
        }
        self.scrollback.push(line.to_owned());
        self.scrollback_offset = 0;
        Ok(())
    }

    /// Return up to `count` lines ending `offset` lines from the bottom; returns empty when buffer is empty or `count` is 0.
    pub fn get_scrollback(&self, offset: usize, count: usize) -> Vec<&str> {
        let len = self.scrollback.len();
        if len == 0 || count == 0 {
            return Vec::new();
        }
        let end = len.saturating_sub(offset);
        let start = end.saturating_sub(count);
        self.scrollback[start..end]
            .iter()
            .map(|s| s.as_str())
            .collect()
    }

    /// Return the current scrollback scroll offset.
    pub fn scrollback_offset(&self) -> usize {
        self.scrollback_offset
    }

    /// Set the scrollback scroll offset, clamped to buffer length.
    pub fn set_scrollback_offset(&mut self, offset: usize) {
        self.scrollback_offset = offset.min(self.scrollback.len());
    }

    /// Return the number of lines in the scrollback buffer.
    pub fn scrollback_len(&self) -> usize {
        self.scrollback.len()
    }

    /// Append a non-empty trimmed `cmd` to the command history and reset the navigation cursor.
    pub fn push_cmd_history(&mut self, cmd: &str) {
        if cmd.trim().is_empty() {
            return;
        }
        let cmd = self.clip_text_for_limit(cmd, self.limits.max_history_entry_chars);
        if self.cmd_history.len() >= self.limits.max_history_entries {
            self.cmd_history.remove(0);
        }
        self.cmd_history.push(cmd);
        self.cmd_cursor = 0;
    }

    /// Strictly append `cmd` to command history.
    pub fn try_push_cmd_history(&mut self, cmd: &str) -> Result<(), TerminalError> {
        if cmd.trim().is_empty() {
            return Ok(());
        }
        let len = char_count(cmd);
        if len > self.limits.max_history_entry_chars {
            self.diagnostics.rejected_history_entries += 1;
            return Err(TerminalError::HistoryEntryTooLong {
                len,
                limit: self.limits.max_history_entry_chars,
            });
        }
        if self.cmd_history.len() >= self.limits.max_history_entries {
            self.diagnostics.rejected_history_entries += 1;
            return Err(TerminalError::HistoryLimitReached {
                limit: self.limits.max_history_entries,
            });
        }
        self.cmd_history.push(cmd.to_owned());
        self.cmd_cursor = 0;
        Ok(())
    }

    /// Navigate to the previous command history entry; returns `None` when history is empty.
    pub fn prev_cmd(&mut self) -> Option<&str> {
        let len = self.cmd_history.len();
        if len == 0 {
            return None;
        }
        if self.cmd_cursor < len {
            self.cmd_cursor += 1;
        }
        let idx = len - self.cmd_cursor;
        Some(&self.cmd_history[idx])
    }

    /// Navigate to the next (more recent) command history entry; returns `None` when at the newest position.
    pub fn next_cmd(&mut self) -> Option<&str> {
        if self.cmd_cursor == 0 {
            return None;
        }
        self.cmd_cursor -= 1;
        if self.cmd_cursor == 0 {
            return None;
        }
        let len = self.cmd_history.len();
        let idx = len - self.cmd_cursor;
        Some(&self.cmd_history[idx])
    }

    /// Return the number of entries in the command history.
    pub fn cmd_history_len(&self) -> usize {
        self.cmd_history.len()
    }

    /// Clear all command history and reset the navigation cursor.
    pub fn clear_cmd_history(&mut self) {
        self.cmd_history.clear();
        self.cmd_cursor = 0;
    }
}
