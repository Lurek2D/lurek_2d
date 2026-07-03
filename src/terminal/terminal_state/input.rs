//! Owns the terminal terminal state input implementation for the terminal subsystem and keeps rules local here.
//! Keeps terminal buffers, widgets, and text-facing presentation state so helpers stay close to invariants this updates.
//! Defines how terminal terminal state input data is validated, transformed, or stored before systems consume it.
//! Separates terminal terminal state input behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where terminal code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing terminal terminal state input defaults, lifecycle handling, validation, or data rules.
//! Keeps failure paths and edge cases near terminal terminal state input state that explains them instead of outward.

use super::*;

impl Terminal {
    fn is_focusable_widget(widget: &Widget) -> bool {
        matches!(
            widget.kind,
            WidgetKind::Button { .. } | WidgetKind::TextBox { .. } | WidgetKind::List { .. }
        )
    }

    /// Returns whether the widget at `index` is visible, enabled, and eligible for focus.
    pub(super) fn is_focusable_widget_index(&self, index: usize) -> bool {
        self.widgets.get(index).is_some_and(|widget| {
            widget.base.visible && widget.base.enabled && Self::is_focusable_widget(widget)
        })
    }

    /// Clears stale focus when the currently focused widget is no longer focusable.
    pub(super) fn ensure_focus_valid(&mut self) {
        if matches!(self.focused, Some(index) if !self.is_focusable_widget_index(index)) {
            self.focused = None;
            self.select_all_textbox = None;
            self.diagnostics.cleared_focus_targets += 1;
        }
    }

    fn focusable_widget_indices(&self) -> Vec<usize> {
        self.widgets
            .iter()
            .enumerate()
            .filter_map(|(index, widget)| {
                if widget.base.visible && widget.base.enabled && Self::is_focusable_widget(widget) {
                    Some(index)
                } else {
                    None
                }
            })
            .collect()
    }

    fn move_focus(&mut self, backwards: bool) -> bool {
        let focusable = self.focusable_widget_indices();
        if focusable.is_empty() {
            self.focused = None;
            return false;
        }
        let next = match self
            .focused
            .and_then(|current| focusable.iter().position(|&value| value == current))
        {
            Some(position) => {
                if backwards {
                    if position > 0 {
                        Some(focusable[position - 1])
                    } else if self.input_policy.wrap_focus {
                        focusable.last().copied()
                    } else {
                        Some(focusable[position])
                    }
                } else if position + 1 < focusable.len() {
                    Some(focusable[position + 1])
                } else if self.input_policy.wrap_focus {
                    focusable.first().copied()
                } else {
                    Some(focusable[position])
                }
            }
            None if backwards => focusable.last().copied(),
            None => focusable.first().copied(),
        };
        if next != self.focused {
            self.focused = next;
            self.select_all_textbox = None;
            true
        } else {
            next.is_some()
        }
    }

    /// Set focus to `index` if valid, or clear focus when `None` or out of range.
    pub fn set_focus(&mut self, index: Option<usize>) {
        self.focused = match index {
            Some(index) if self.is_focusable_widget_index(index) => Some(index),
            _ => None,
        };
        self.select_all_textbox = None;
    }

    /// Return the index of the focused widget, or `None` when nothing is focused.
    pub fn get_focused(&self) -> Option<usize> {
        self.focused
    }

    /// Dispatch a key event to the focused widget; return `true` if consumed.
    pub fn keypressed(&mut self, key: &str) -> bool {
        self.keypressed_with_events(key).0
    }

    /// Dispatch a text-input event to the focused widget; return `true` if consumed.
    pub fn textinput(&mut self, text_input: &str) -> bool {
        self.textinput_with_events(text_input).0
    }

    /// Dispatch a mouse press at 1-based grid `(grid_col, grid_row)` to the topmost hit widget; return `true` if consumed.
    pub fn mousepressed(&mut self, grid_col: usize, grid_row: usize, button: usize) -> bool {
        self.mousepressed_with_events(grid_col, grid_row, button).0
    }

    /// Dispatch a key event to the focused widget; return `(consumed, events)` for the Lua API layer.
    pub(crate) fn keypressed_with_events(&mut self, key: &str) -> (bool, Vec<TerminalEvent>) {
        if self.input_policy.allow_tab_focus_traversal && matches!(key, "tab" | "shift+tab") {
            return (self.move_focus(key == "shift+tab"), Vec::new());
        }
        self.ensure_focus_valid();
        let focused_index = match self.focused {
            Some(index) if index < self.widgets.len() => index,
            _ => return (false, Vec::new()),
        };
        let widget = &mut self.widgets[focused_index];
        if !widget.base.enabled || !widget.base.visible {
            return (false, Vec::new());
        }
        let mut events = Vec::new();
        match &mut widget.kind {
            WidgetKind::TextBox {
                text,
                max_length,
                cursor_pos,
            } => {
                let mut changed = false;
                let mut select_all = self.select_all_textbox == Some(focused_index);
                let consumed = match key {
                    "ctrl+a" => {
                        *cursor_pos = char_count(text);
                        select_all = true;
                        true
                    }
                    "ctrl+c" => {
                        if self.input_policy.allow_internal_clipboard {
                            let (clipboard, dropped) =
                                clip_text_to_limit(text, self.limits.max_clipboard_chars);
                            self.clipboard = clipboard;
                            self.diagnostics.clipped_text += dropped;
                            true
                        } else {
                            false
                        }
                    }
                    "ctrl+x" => {
                        if !self.input_policy.allow_internal_clipboard {
                            false
                        } else {
                            if !text.is_empty() {
                                let (clipboard, dropped) =
                                    clip_text_to_limit(text, self.limits.max_clipboard_chars);
                                self.clipboard = clipboard;
                                self.diagnostics.clipped_text += dropped;
                                text.clear();
                                *cursor_pos = 0;
                                changed = true;
                            }
                            select_all = false;
                            true
                        }
                    }
                    "ctrl+v" => {
                        if !self.input_policy.allow_internal_clipboard {
                            false
                        } else {
                            if select_all {
                                text.clear();
                                *cursor_pos = 0;
                                select_all = false;
                            }
                            if !self.clipboard.is_empty() {
                                let inserted = insert_with_limit(
                                    text,
                                    cursor_pos,
                                    *max_length,
                                    &self.clipboard,
                                );
                                if inserted > 0 {
                                    let dropped =
                                        char_count(&self.clipboard).saturating_sub(inserted);
                                    if dropped > 0 {
                                        self.diagnostics.clipped_text += dropped;
                                    }
                                    changed = true;
                                }
                            }
                            true
                        }
                    }
                    "ctrl+backspace" => {
                        if *cursor_pos > 0 {
                            let start_char = prev_word_boundary(text, *cursor_pos);
                            let start = byte_index(text, start_char);
                            let end = byte_index(text, *cursor_pos);
                            text.replace_range(start..end, "");
                            *cursor_pos = start_char;
                            changed = true;
                        }
                        select_all = false;
                        true
                    }
                    "ctrl+delete" => {
                        let len = char_count(text);
                        if *cursor_pos < len {
                            let end_char = next_word_boundary(text, *cursor_pos);
                            let start = byte_index(text, *cursor_pos);
                            let end = byte_index(text, end_char);
                            text.replace_range(start..end, "");
                            changed = true;
                        }
                        select_all = false;
                        true
                    }
                    "backspace" => {
                        if *cursor_pos > 0 {
                            let end = byte_index(text, *cursor_pos);
                            let start = byte_index(text, *cursor_pos - 1);
                            text.replace_range(start..end, "");
                            *cursor_pos -= 1;
                            changed = true;
                        }
                        select_all = false;
                        true
                    }
                    "delete" => {
                        if *cursor_pos < char_count(text) {
                            let start = byte_index(text, *cursor_pos);
                            let end = byte_index(text, *cursor_pos + 1);
                            text.replace_range(start..end, "");
                            changed = true;
                        }
                        select_all = false;
                        true
                    }
                    "left" => {
                        *cursor_pos = cursor_pos.saturating_sub(1);
                        select_all = false;
                        true
                    }
                    "right" => {
                        *cursor_pos = (*cursor_pos + 1).min(char_count(text));
                        select_all = false;
                        true
                    }
                    "home" => {
                        *cursor_pos = 0;
                        select_all = false;
                        true
                    }
                    "end" => {
                        *cursor_pos = char_count(text);
                        select_all = false;
                        true
                    }
                    _ => false,
                };
                self.select_all_textbox = if select_all {
                    Some(focused_index)
                } else {
                    None
                };
                if changed {
                    events.push(TerminalEvent::TextChanged {
                        index: focused_index,
                    });
                }
                (consumed, events)
            }
            WidgetKind::List {
                items,
                selected,
                scroll_offset,
            } => {
                self.select_all_textbox = None;
                let previous = *selected;
                let visible_rows = widget.base.height.max(1);
                let consumed = match key {
                    "up" => {
                        if let Some(current) = *selected {
                            if current > 0 {
                                *selected = Some(current - 1);
                            }
                        } else if !items.is_empty() {
                            *selected = Some(0);
                        }
                        if let Some(current) = *selected {
                            if current < *scroll_offset {
                                *scroll_offset = current;
                            }
                        }
                        true
                    }
                    "down" => {
                        if let Some(current) = *selected {
                            if current + 1 < items.len() {
                                *selected = Some(current + 1);
                            }
                        } else if !items.is_empty() {
                            *selected = Some(0);
                        }
                        if let Some(current) = *selected {
                            if current >= *scroll_offset + visible_rows {
                                *scroll_offset =
                                    current.saturating_sub(visible_rows.saturating_sub(1));
                            }
                        }
                        true
                    }
                    _ => false,
                };
                if *selected != previous {
                    events.push(TerminalEvent::SelectionChanged {
                        index: focused_index,
                    });
                }
                (consumed, events)
            }
            WidgetKind::Button { .. } => {
                self.select_all_textbox = None;
                if matches!(key, "return" | "space") {
                    events.push(TerminalEvent::ButtonClicked {
                        index: focused_index,
                    });
                    (true, events)
                } else {
                    (false, events)
                }
            }
            _ => (false, events),
        }
    }

    /// Dispatch text input to the focused `TextBox`; return `(consumed, events)` for the Lua API layer.
    pub(crate) fn textinput_with_events(&mut self, text_input: &str) -> (bool, Vec<TerminalEvent>) {
        let (clipped_input, dropped_before_insert) =
            clip_text_to_limit(text_input, self.limits.max_line_chars);
        if dropped_before_insert > 0 {
            self.diagnostics.clipped_text += dropped_before_insert;
        }
        self.ensure_focus_valid();
        let focused_index = match self.focused {
            Some(index) if index < self.widgets.len() => index,
            _ => return (false, Vec::new()),
        };
        let widget = &mut self.widgets[focused_index];
        if !widget.base.enabled || !widget.base.visible {
            return (false, Vec::new());
        }
        match &mut widget.kind {
            WidgetKind::TextBox {
                text,
                max_length,
                cursor_pos,
            } => {
                if self.select_all_textbox == Some(focused_index) {
                    text.clear();
                    *cursor_pos = 0;
                }
                self.select_all_textbox = None;
                let inserted = insert_with_limit(text, cursor_pos, *max_length, &clipped_input);
                if inserted == 0 {
                    return (false, Vec::new());
                }
                let dropped = char_count(&clipped_input).saturating_sub(inserted);
                if dropped > 0 {
                    self.diagnostics.clipped_text += dropped;
                }
                (
                    true,
                    vec![TerminalEvent::TextChanged {
                        index: focused_index,
                    }],
                )
            }
            _ => (false, Vec::new()),
        }
    }

    /// Dispatch a mouse press to the topmost hit widget; return `(consumed, events)` for the Lua API layer.
    pub(crate) fn mousepressed_with_events(
        &mut self,
        grid_col: usize,
        grid_row: usize,
        _button: usize,
    ) -> (bool, Vec<TerminalEvent>) {
        self.select_all_textbox = None;
        let col = grid_col.saturating_sub(1);
        let row = grid_row.saturating_sub(1);
        for index in (0..self.widgets.len()).rev() {
            let widget = &mut self.widgets[index];
            if !widget.base.visible || !widget.base.enabled || !Self::is_focusable_widget(widget) {
                continue;
            }
            let within_x = col >= widget.base.x && col < widget.base.x + widget.base.width;
            let within_y = row >= widget.base.y && row < widget.base.y + widget.base.height;
            if !within_x || !within_y {
                continue;
            }
            self.focused = Some(index);
            let mut events = Vec::new();
            match &mut widget.kind {
                WidgetKind::Button { .. } => {
                    events.push(TerminalEvent::ButtonClicked { index });
                }
                WidgetKind::TextBox {
                    text, cursor_pos, ..
                } => {
                    let relative_col = col.saturating_sub(widget.base.x);
                    *cursor_pos = relative_col.min(char_count(text));
                }
                WidgetKind::List {
                    items,
                    selected,
                    scroll_offset,
                } => {
                    let relative_row = row.saturating_sub(widget.base.y);
                    let item_index = *scroll_offset + relative_row;
                    if item_index < items.len() && *selected != Some(item_index) {
                        *selected = Some(item_index);
                        events.push(TerminalEvent::SelectionChanged { index });
                    }
                }
                _ => {}
            }
            return (true, events);
        }
        self.focused = None;
        (false, Vec::new())
    }
}
