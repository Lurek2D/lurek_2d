//! Defines the concrete interactive controls that sit on top of shared widget state inside the retained UI system.
//! Owns buttons, labels, text inputs, checkboxes, sliders, radios, combos, lists, tabs, and spin-style widgets.
//! Keeps control construction explicit so type identity, defaults, and base widget integration stay unambiguous.
//! Implements text editing helpers that clamp cursor motion, insertion, deletion, and maximum-length constraints.
//! Normalizes selection and numeric-value handling so dynamic option lists do not violate control invariants.
//! Provides the control-layer boundary between generic widget nodes and user-facing interactive primitives.
//! Feeds consistent layout, style, and interaction semantics into the context and renderer without extra adapters.
//! Open this file when editable values, selection rules, or control defaults behave differently than expected.

use crate::ui::widget::{WidgetBase, WidgetType};

fn normalized_range_or(min: f64, max: f64, fallback: (f64, f64)) -> (f64, f64) {
    if !(min.is_finite() && max.is_finite()) {
        return fallback;
    }
    (min.min(max), min.max(max))
}
/// Clickable push button with a text label.
#[derive(Debug, Clone)]
pub struct Button {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Label text rendered inside the button.
    pub text: String,
}
impl Button {
    /// Create a button with the given text.
    pub fn new(text: impl Into<String>) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::Button),
            text: text.into(),
        }
    }
}
/// Non-interactive single-line text display.
#[derive(Debug, Clone)]
pub struct Label {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Text string to render.
    pub text: String,
}
impl Label {
    /// Create a label with the given text.
    pub fn new(text: impl Into<String>) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::Label),
            text: text.into(),
        }
    }
}
/// Single-line editable text field with cursor tracking, selection, and optional max length.
#[derive(Debug, Clone)]
pub struct TextInput {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Current text content.
    pub text: String,
    /// Placeholder text shown when `text` is empty.
    pub placeholder: String,
    /// Maximum character count; 0 = unlimited.
    pub max_length: usize,
    /// Byte offset of the insertion cursor within `text`.
    pub cursor_pos: usize,
    /// Optional byte offset anchoring the active selection range.
    pub selection_anchor: Option<usize>,
    /// Whether this widget currently holds keyboard focus.
    pub focused: bool,
    /// Whether pressing Enter while focused should submit the surrounding dialog default action.
    pub submit_on_enter: bool,
}
impl TextInput {
    /// Create an empty text input with no placeholder and unlimited length.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::TextInput),
            text: String::new(),
            placeholder: String::new(),
            max_length: 0,
            cursor_pos: 0,
            selection_anchor: None,
            focused: false,
            submit_on_enter: true,
        }
    }
    fn byte_index_for_char_limit(text: &str, max_length: usize) -> usize {
        if max_length == 0 {
            return text.len();
        }
        text.char_indices()
            .nth(max_length)
            .map_or(text.len(), |(index, _)| index)
    }
    fn clamp_cursor_to_text(&mut self) {
        self.cursor_pos = self.cursor_pos.min(self.text.len());
        while !self.text.is_char_boundary(self.cursor_pos) {
            self.cursor_pos -= 1;
        }
        if let Some(anchor) = self.selection_anchor {
            let mut anchor = anchor.min(self.text.len());
            while !self.text.is_char_boundary(anchor) {
                anchor -= 1;
            }
            self.selection_anchor = Some(anchor);
        }
    }
    fn enforce_max_length(&mut self) {
        if self.max_length > 0 {
            let limit = Self::byte_index_for_char_limit(&self.text, self.max_length);
            self.text.truncate(limit);
        }
        self.clamp_cursor_to_text();
        if self.selection_anchor == Some(self.cursor_pos) {
            self.selection_anchor = None;
        }
    }
    fn set_cursor_internal(&mut self, next_pos: usize, extend_selection: bool) -> bool {
        self.clamp_cursor_to_text();
        let mut next_pos = next_pos.min(self.text.len());
        while !self.text.is_char_boundary(next_pos) {
            next_pos -= 1;
        }
        let previous_cursor = self.cursor_pos;
        let previous_anchor = self.selection_anchor;
        if extend_selection {
            if previous_anchor.is_none() {
                self.selection_anchor = Some(previous_cursor);
            }
        } else {
            self.selection_anchor = None;
        }
        self.cursor_pos = next_pos;
        if self.selection_anchor == Some(self.cursor_pos) {
            self.selection_anchor = None;
        }
        previous_cursor != self.cursor_pos || previous_anchor != self.selection_anchor
    }
    /// Return the current selection range as byte offsets, or `None` when no text is selected.
    pub fn selection_range(&self) -> Option<(usize, usize)> {
        let anchor = self.selection_anchor?;
        if anchor == self.cursor_pos {
            return None;
        }
        Some((anchor.min(self.cursor_pos), anchor.max(self.cursor_pos)))
    }
    /// Return `true` when a non-empty selection range is active.
    pub fn has_selection(&self) -> bool {
        self.selection_range().is_some()
    }
    /// Return the current cursor position as a character index instead of a byte offset.
    pub fn cursor_char_pos(&self) -> usize {
        self.text[..self.cursor_pos.min(self.text.len())]
            .chars()
            .count()
    }
    /// Clear any active selection without moving the cursor.
    pub fn clear_selection(&mut self) -> bool {
        let had_selection = self.selection_anchor.is_some();
        self.selection_anchor = None;
        had_selection
    }
    /// Select all text in the input.
    pub fn select_all(&mut self) -> bool {
        if self.text.is_empty() {
            return self.clear_selection();
        }
        let changed = self.selection_anchor != Some(0) || self.cursor_pos != self.text.len();
        self.selection_anchor = Some(0);
        self.cursor_pos = self.text.len();
        changed
    }
    /// Delete the active selection range; return `false` when no selection is present.
    pub fn delete_selection(&mut self) -> bool {
        let Some((start, end)) = self.selection_range() else {
            return false;
        };
        self.text.drain(start..end);
        self.cursor_pos = start;
        self.selection_anchor = None;
        true
    }
    /// Replace the text and clamp it to `max_length` when one is configured.
    pub fn set_text(&mut self, text: impl Into<String>) {
        self.text = text.into();
        self.cursor_pos = self.text.len();
        self.selection_anchor = None;
        self.enforce_max_length();
    }
    /// Set the maximum character count, truncating existing text when needed.
    pub fn set_max_length(&mut self, max_length: usize) {
        self.max_length = max_length;
        self.enforce_max_length();
    }
    /// Insert `input` at the cursor position; truncates pasted text to `max_length` when needed.
    pub fn insert_text(&mut self, input: &str) -> bool {
        self.clamp_cursor_to_text();
        let _ = self.delete_selection();
        let allowed_input = if self.max_length == 0 {
            input
        } else {
            let remaining = self.max_length.saturating_sub(self.text.chars().count());
            if remaining == 0 {
                return false;
            }
            let limit = Self::byte_index_for_char_limit(input, remaining);
            &input[..limit]
        };
        if allowed_input.is_empty() {
            return false;
        }
        self.text.insert_str(self.cursor_pos, allowed_input);
        self.cursor_pos += allowed_input.len();
        self.selection_anchor = None;
        true
    }
    /// Delete the character before the cursor; return `false` if already at position 0.
    pub fn backspace(&mut self) -> bool {
        if self.delete_selection() {
            return true;
        }
        if self.cursor_pos > 0 {
            let prev = self.text[..self.cursor_pos]
                .char_indices()
                .next_back()
                .map(|(i, _)| i)
                .unwrap_or(0);
            self.text.drain(prev..self.cursor_pos);
            self.cursor_pos = prev;
            true
        } else {
            false
        }
    }
    /// Delete the character at the cursor; return `false` when already at the end.
    pub fn delete_forward(&mut self) -> bool {
        if self.delete_selection() {
            return true;
        }
        if self.cursor_pos >= self.text.len() {
            return false;
        }
        let next = self.text[self.cursor_pos..]
            .char_indices()
            .nth(1)
            .map(|(offset, _)| self.cursor_pos + offset)
            .unwrap_or(self.text.len());
        self.text.drain(self.cursor_pos..next);
        true
    }
    /// Move the insertion cursor one character left; return `false` when already at the start.
    pub fn move_cursor_left(&mut self) -> bool {
        self.move_cursor_left_with_selection(false)
    }
    /// Move the insertion cursor one character left and optionally extend the selection.
    pub fn move_cursor_left_with_selection(&mut self, extend_selection: bool) -> bool {
        if self.cursor_pos == 0 {
            if !extend_selection {
                return self.clear_selection();
            }
            return false;
        }
        let prev = self.text[..self.cursor_pos]
            .char_indices()
            .next_back()
            .map(|(index, _)| index)
            .unwrap_or(0);
        self.set_cursor_internal(prev, extend_selection)
    }
    /// Move the insertion cursor one character right; return `false` when already at the end.
    pub fn move_cursor_right(&mut self) -> bool {
        self.move_cursor_right_with_selection(false)
    }
    /// Move the insertion cursor one character right and optionally extend the selection.
    pub fn move_cursor_right_with_selection(&mut self, extend_selection: bool) -> bool {
        if self.cursor_pos >= self.text.len() {
            if !extend_selection {
                return self.clear_selection();
            }
            return false;
        }
        let next = self.text[self.cursor_pos..]
            .char_indices()
            .nth(1)
            .map(|(offset, _)| self.cursor_pos + offset)
            .unwrap_or(self.text.len());
        self.set_cursor_internal(next, extend_selection)
    }
    /// Move the insertion cursor to the start; return `false` when already there.
    pub fn move_cursor_home(&mut self) -> bool {
        self.move_cursor_home_with_selection(false)
    }
    /// Move the insertion cursor to the start and optionally extend the selection.
    pub fn move_cursor_home_with_selection(&mut self, extend_selection: bool) -> bool {
        if self.cursor_pos == 0 && (!extend_selection || self.selection_anchor.is_none()) {
            return false;
        }
        self.set_cursor_internal(0, extend_selection)
    }
    /// Move the insertion cursor to the end; return `false` when already there.
    pub fn move_cursor_end(&mut self) -> bool {
        self.move_cursor_end_with_selection(false)
    }
    /// Move the insertion cursor to the end and optionally extend the selection.
    pub fn move_cursor_end_with_selection(&mut self, extend_selection: bool) -> bool {
        if self.cursor_pos == self.text.len()
            && (!extend_selection || self.selection_anchor.is_none())
        {
            return false;
        }
        self.set_cursor_internal(self.text.len(), extend_selection)
    }
    /// Move the insertion cursor to the start of the previous word.
    pub fn move_cursor_word_left(&mut self) -> bool {
        self.clamp_cursor_to_text();
        let prefix = &self.text[..self.cursor_pos];
        let trimmed = prefix.trim_end_matches(char::is_whitespace);
        if trimmed.is_empty() {
            return self.set_cursor_internal(0, false);
        }
        let target = trimmed
            .char_indices()
            .rev()
            .find_map(|(index, ch)| ch.is_whitespace().then_some(index + ch.len_utf8()))
            .unwrap_or(0);
        self.set_cursor_internal(target, false)
    }
    /// Move the insertion cursor to the start of the next word.
    pub fn move_cursor_word_right(&mut self) -> bool {
        self.clamp_cursor_to_text();
        let suffix = &self.text[self.cursor_pos..];
        let mut target = self.text.len();
        let mut seen_non_whitespace = false;
        for (offset, ch) in suffix.char_indices() {
            if ch.is_whitespace() {
                if seen_non_whitespace {
                    target = self.cursor_pos + offset + ch.len_utf8();
                    break;
                }
            } else {
                seen_non_whitespace = true;
            }
        }
        if !seen_non_whitespace {
            target = self.text.len();
        }
        self.set_cursor_internal(target, false)
    }
}
/// Provide a default `TextInput` via `Self::new()`.
impl Default for TextInput {
    fn default() -> Self {
        Self::new()
    }
}
/// Boolean toggle control with a visible label.
#[derive(Debug, Clone)]
pub struct CheckBox {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Label displayed next to the checkbox.
    pub text: String,
    /// Whether the checkbox is currently checked.
    pub checked: bool,
}
impl CheckBox {
    /// Create an unchecked checkbox with the given label.
    pub fn new(text: impl Into<String>) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::CheckBox),
            text: text.into(),
            checked: false,
        }
    }
}
/// Continuous or stepped numeric value slider.
#[derive(Debug, Clone)]
pub struct Slider {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Current clamped value in `[min, max]`.
    pub value: f64,
    /// Minimum allowed value.
    pub min: f64,
    /// Maximum allowed value.
    pub max: f64,
    /// Snap step size; 0.0 = continuous.
    pub step: f64,
}
impl Slider {
    /// Create a slider with the given range; initial value is `min`, step defaults to 0 (continuous).
    pub fn new(min: f64, max: f64) -> Self {
        let (min, max) = normalized_range_or(min, max, (0.0, 1.0));
        let mut slider = Self {
            base: WidgetBase::new(WidgetType::Slider),
            value: min,
            min,
            max,
            step: 0.0,
        };
        let _ = slider.set_value(min);
        slider
    }
    /// Update the allowed range and re-clamp the current value; returns `false` for NaN/Inf.
    pub fn set_range(&mut self, min: f64, max: f64) -> bool {
        if !(min.is_finite() && max.is_finite()) {
            return false;
        }
        self.min = min.min(max);
        self.max = min.max(max);
        let _ = self.set_value(self.value);
        true
    }
    /// Update the snapping step; non-positive values switch back to continuous mode.
    pub fn set_step(&mut self, step: f64) -> bool {
        if !step.is_finite() {
            return false;
        }
        self.step = if step > 0.0 { step } else { 0.0 };
        let _ = self.set_value(self.value);
        true
    }
    /// Clamp `v` to `[min, max]` and snap to the nearest step if step > 0.
    pub fn set_value(&mut self, v: f64) -> bool {
        if !v.is_finite() {
            return false;
        }
        let mut v = v.clamp(self.min, self.max);
        if self.step.is_finite() && self.step > 0.0 {
            v = ((v - self.min) / self.step).round() * self.step + self.min;
            v = v.clamp(self.min, self.max);
        }
        self.value = v;
        true
    }
}
/// Read-only bounded progress indicator.
#[derive(Debug, Clone)]
pub struct ProgressBar {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Current value; should lie in `[min, max]`.
    pub value: f64,
    /// Minimum bound for the progress range.
    pub min: f64,
    /// Maximum bound for the progress range.
    pub max: f64,
}
impl ProgressBar {
    /// Create a progress bar with the given range; initial value is `min`.
    pub fn new(min: f64, max: f64) -> Self {
        let (min, max) = normalized_range_or(min, max, (0.0, 1.0));
        let mut bar = Self {
            base: WidgetBase::new(WidgetType::ProgressBar),
            value: min,
            min,
            max,
        };
        let _ = bar.set_value(min);
        bar
    }
    /// Update the allowed range and re-clamp the current value; returns `false` for NaN/Inf.
    pub fn set_range(&mut self, min: f64, max: f64) -> bool {
        if !(min.is_finite() && max.is_finite()) {
            return false;
        }
        self.min = min.min(max);
        self.max = min.max(max);
        let _ = self.set_value(self.value);
        true
    }
    /// Clamp `v` to `[min, max]`; returns `false` for NaN/Inf.
    pub fn set_value(&mut self, v: f64) -> bool {
        if !v.is_finite() {
            return false;
        }
        self.value = v.clamp(self.min, self.max);
        true
    }
    /// Return the normalised fill fraction in `[0.0, 1.0]`; returns 0.0 when `max == min`.
    pub fn progress(&self) -> f64 {
        let range = self.max - self.min;
        if range <= 0.0 {
            0.0
        } else {
            ((self.value - self.min) / range).clamp(0.0, 1.0)
        }
    }
}
/// Drop-down single-selection list with an open/closed toggle.
#[derive(Debug, Clone)]
pub struct ComboBox {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Ordered item strings shown in the drop-down.
    pub items: Vec<String>,
    /// Index of the currently selected item, or `None` when nothing is selected.
    pub selected_index: Option<usize>,
    /// Whether the drop-down list is currently visible.
    pub open: bool,
    /// Maximum number of items shown at once before the dropdown scrolls.
    pub max_visible_items: usize,
    /// Vertical scroll offset used while the dropdown is open.
    pub scroll_y: f32,
}
impl ComboBox {
    /// Create an empty combo box with no selection.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::ComboBox),
            items: Vec::new(),
            selected_index: None,
            open: false,
            max_visible_items: 8,
            scroll_y: 0.0,
        }
    }
    /// Clamp the dropdown viewport capacity to at least one visible row.
    pub fn set_max_visible_items(&mut self, count: usize) {
        self.max_visible_items = count.max(1);
    }
    /// Append a new item to the drop-down list.
    pub fn add_item(&mut self, text: impl Into<String>) {
        self.items.push(text.into());
    }
    /// Remove the item at `index` from ComboBox; adjusts `selected_index`; return `false` when out of range.
    pub fn remove_item(&mut self, index: usize) -> bool {
        if index < self.items.len() {
            self.items.remove(index);
            if let Some(sel) = self.selected_index {
                if sel >= self.items.len() {
                    self.selected_index = if self.items.is_empty() {
                        None
                    } else {
                        Some(self.items.len() - 1)
                    };
                }
            }
            self.scroll_y = self.scroll_y.max(0.0);
            true
        } else {
            false
        }
    }
    /// Remove all items and reset selection for ComboBox.
    pub fn clear(&mut self) {
        self.items.clear();
        self.selected_index = None;
        self.scroll_y = 0.0;
    }
    /// Return the text of the selected ComboBox item, or `None`.
    pub fn selected_item(&self) -> Option<&str> {
        self.selected_index
            .and_then(|i| self.items.get(i).map(|s| s.as_str()))
    }
}
/// Provide a default `ComboBox` via `Self::new()`.
impl Default for ComboBox {
    fn default() -> Self {
        Self::new()
    }
}
/// Scrollable multi-item list with keyboard-navigable single selection.
#[derive(Debug, Clone)]
pub struct ListBox {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Ordered list items.
    pub items: Vec<String>,
    /// Index of the currently selected item, or `None`.
    pub selected_index: Option<usize>,
    /// Pixel height allocated for each row.
    pub item_height: f32,
    /// Vertical scroll offset used by mouse-wheel routing.
    pub scroll_y: f32,
}
impl ListBox {
    /// Create an empty list box with item_height=24.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::ListBox),
            items: Vec::new(),
            selected_index: None,
            item_height: 24.0,
            scroll_y: 0.0,
        }
    }
    /// Append a new item to the ListBox.
    pub fn add_item(&mut self, text: impl Into<String>) {
        self.items.push(text.into());
    }
    /// Remove the item at `index` from the ListBox; adjusts `selected_index`; return `false` when out of range.
    pub fn remove_item(&mut self, index: usize) -> bool {
        if index < self.items.len() {
            self.items.remove(index);
            if let Some(sel) = self.selected_index {
                if sel >= self.items.len() {
                    self.selected_index = if self.items.is_empty() {
                        None
                    } else {
                        Some(self.items.len() - 1)
                    };
                }
            }
            true
        } else {
            false
        }
    }
    /// Remove all items and reset selection for ListBox.
    pub fn clear(&mut self) {
        self.items.clear();
        self.selected_index = None;
    }
    /// Return the text of the selected ListBox item, or `None`.
    pub fn selected_item(&self) -> Option<&str> {
        self.selected_index
            .and_then(|i| self.items.get(i).map(|s| s.as_str()))
    }
}
/// Provide a default `ListBox` via `Self::new()`.
impl Default for ListBox {
    fn default() -> Self {
        Self::new()
    }
}
/// Horizontal navigation bar with labelled tab buttons.
#[derive(Debug, Clone)]
pub struct TabBar {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Ordered tab label strings.
    pub tabs: Vec<String>,
    /// Index of the currently active tab.
    pub active_tab: usize,
}
impl TabBar {
    /// Create an empty tab bar with active_tab=0.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::TabBar),
            tabs: Vec::new(),
            active_tab: 0,
        }
    }
    /// Append a tab with the given label.
    pub fn add_tab(&mut self, label: impl Into<String>) {
        self.tabs.push(label.into());
    }
    /// Remove the tab at `index`; clamps `active_tab` to the new length; return `false` when out of range.
    pub fn remove_tab(&mut self, index: usize) -> bool {
        if index < self.tabs.len() {
            self.tabs.remove(index);
            if self.active_tab >= self.tabs.len() && !self.tabs.is_empty() {
                self.active_tab = self.tabs.len() - 1;
            }
            true
        } else {
            false
        }
    }
}
/// Provide a default `TabBar` via `Self::new()`.
impl Default for TabBar {
    fn default() -> Self {
        Self::new()
    }
}
/// Mutually exclusive selection option belonging to a named group.
#[derive(Debug, Clone)]
pub struct RadioButton {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Label rendered next to the radio circle.
    pub text: String,
    /// Whether this button is the selected option in its group.
    pub selected: bool,
    /// Group name used to coordinate mutual exclusion.
    pub group: String,
}
impl RadioButton {
    /// Create an unselected radio button with the given label and group.
    pub fn new(text: impl Into<String>, group: impl Into<String>) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::RadioButton),
            text: text.into(),
            selected: false,
            group: group.into(),
        }
    }
}
/// Explicit horizontal or vertical scroll bar for a `ScrollPanel`.
#[derive(Debug, Clone)]
pub struct ScrollBar {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Current scroll position in content pixels.
    pub position: f32,
    /// Total scrollable content size in pixels.
    pub content_size: f32,
    /// Visible viewport size in pixels; thumb length is `view_size / content_size`.
    pub view_size: f32,
    /// `true` for a vertical orientation, `false` for horizontal.
    pub vertical: bool,
}
impl ScrollBar {
    /// Create a scroll bar with content_size=100 and view_size=50.
    pub fn new(vertical: bool) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::ScrollBar),
            position: 0.0,
            content_size: 100.0,
            view_size: 50.0,
            vertical,
        }
    }
}
/// Number field with increment/decrement step buttons.
#[derive(Debug, Clone)]
pub struct SpinBox {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Current clamped value.
    pub value: f64,
    /// Minimum allowed value.
    pub min: f64,
    /// Maximum allowed value.
    pub max: f64,
    /// Amount added or subtracted per button click.
    pub step: f64,
}
impl SpinBox {
    /// Create a spin box clamped to `[min, max]` with step=1.0; initial value is `min`.
    pub fn new(min: f64, max: f64) -> Self {
        let (min, max) = normalized_range_or(min, max, (0.0, 100.0));
        let mut spin_box = Self {
            base: WidgetBase::new(WidgetType::SpinBox),
            value: min,
            min,
            max,
            step: 1.0,
        };
        let _ = spin_box.set_value(min);
        spin_box
    }
    /// Snap `v` to the nearest step and clamp to `[min, max]`.
    pub fn set_value(&mut self, v: f64) -> bool {
        if !v.is_finite() {
            return false;
        }
        let snapped = if self.step.is_finite() && self.step > 0.0 {
            ((v - self.min) / self.step).round() * self.step + self.min
        } else {
            v
        };
        self.value = snapped.clamp(self.min, self.max);
        true
    }
    /// Increase value by one step. This function is part of the public API.
    pub fn increment(&mut self) {
        self.set_value(self.value + self.step);
    }
    /// Decrease value by one step. This function is part of the public API.
    pub fn decrement(&mut self) {
        self.set_value(self.value - self.step);
    }
    /// Update the allowed range and re-clamp the current value.
    pub fn set_range(&mut self, min: f64, max: f64) {
        if min.is_finite() && max.is_finite() {
            self.min = min.min(max);
            self.max = min.max(max);
            let _ = self.set_value(self.value);
        }
    }
    /// Update the step size; invalid or non-positive values are ignored.
    pub fn set_step(&mut self, step: f64) -> bool {
        if !(step.is_finite() && step > 0.0) {
            return false;
        }
        self.step = step.max(1e-9);
        let _ = self.set_value(self.value);
        true
    }
}
/// Animated on/off toggle switch.
#[derive(Debug, Clone)]
pub struct Switch {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Current logical state: `true` = on.
    pub on: bool,
    /// Thumb animation position in `[0.0, 1.0]`; 0.0 = off end, 1.0 = on end.
    pub thumb_t: f32,
}
impl Switch {
    /// Create a switch with the given initial state; sets `thumb_t` accordingly.
    pub fn new(on: bool) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::Switch),
            on,
            thumb_t: if on { 1.0 } else { 0.0 },
        }
    }
    /// Flip the on/off state and snap `thumb_t` to the new position.
    pub fn toggle(&mut self) {
        self.on = !self.on;
        self.thumb_t = if self.on { 1.0 } else { 0.0 };
    }
    /// Set `on` to the given value and snap `thumb_t`.
    pub fn set_on(&mut self, on: bool) {
        self.on = on;
        self.thumb_t = if on { 1.0 } else { 0.0 };
    }
}
