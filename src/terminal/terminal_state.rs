//! This file owns `Terminal`, the main state machine for the character grid, cursor, widgets, and histories.
//! It stores the row-major cell buffer, focus state, clipboard, command history, scrollback, and size overrides.
//! Helper functions draw compact buttons, frames, cursor text, and bounded writes onto composed cell slices.
//! Input handlers route keyboard, text, and mouse events to focused widgets and emit typed terminal events.
//! Text-box editing covers cursor movement, selection replacement, clipboard shortcuts, and word deletes.
//! List handling covers focus, selection, scrolling, and mouse hit resolution for terminal UI controls.
//! Render composition overlays visible widgets on top of the base grid and reuses scratch buffers.
//! Border rendering, panel child maintenance, and widget removal cleanup keep layered layouts consistent.
//! Public grid APIs cover cell reads, writes, resizing, colored printing, default colors, and cursor moves.
//! History APIs manage scrollback limits, command navigation, and durable memory beyond render output.
//! Command builders translate the composed surface into batched render commands without duplicated logic.
//! Open it when terminal interaction or surface semantics change; widgets and exporters depend on it.

use super::cell::{TCell, DEFAULT_BG, DEFAULT_CH, DEFAULT_FG};
use super::text_utils::{byte_index, char_count, truncate_chars};
use super::widget::{BorderStyle, Widget, WidgetKind};
use crate::render::renderer::RenderCommand;
use crate::runtime::resource_keys::FontKey;
use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use std::fmt;

/// Maximum column count accepted by `Terminal::new` and `resize`.
pub(crate) const MAX_COLS: usize = 512;
/// Maximum row count accepted by `Terminal::new` and `resize`.
pub(crate) const MAX_ROWS: usize = 256;

/// Foreground color for unfocused buttons.
const BUTTON_FG: [f32; 4] = [0.90, 0.96, 0.90, 1.0];
/// Background color for inactive terminal buttons.
const BUTTON_BG: [f32; 4] = [0.05, 0.08, 0.05, 1.0];
/// Background color for focused terminal buttons.
const BUTTON_FOCUS_BG: [f32; 4] = [0.11, 0.14, 0.07, 1.0];
/// Background color for text entry widgets.
const TEXTBOX_BG: [f32; 4] = [0.03, 0.05, 0.03, 1.0];
/// Background color for terminal list widgets.
const LIST_BG: [f32; 4] = [0.03, 0.05, 0.03, 1.0];
/// Background color for the selected row inside a terminal list.
const LIST_SELECTED_BG: [f32; 4] = [0.16, 0.18, 0.09, 1.0];
/// Background color for terminal panels and bordered regions.
const PANEL_BG: [f32; 4] = [0.02, 0.03, 0.02, 0.98];
/// Foreground color applied to the focused widget.
const FOCUS_FG: [f32; 4] = [1.0, 0.93, 0.55, 1.0];
/// Foreground color for the selected list item.
const LIST_SELECTED_FG: [f32; 4] = [0.96, 0.98, 0.86, 1.0];
/// Character drawn at the text-box cursor position.
const CURSOR_CHAR: char = '_';

/// Default hard cap for terminal line-like text payloads.
pub const DEFAULT_MAX_LINE_CHARS: usize = 4096;
/// Default hard cap for command history entry length.
pub const DEFAULT_MAX_HISTORY_ENTRY_CHARS: usize = 1024;
/// Default hard cap for widget text payloads.
pub const DEFAULT_MAX_WIDGET_TEXT_CHARS: usize = 1024;
/// Default hard cap for list item text payloads.
pub const DEFAULT_MAX_ITEM_CHARS: usize = 512;
/// Default hard cap for list item count per widget.
pub const DEFAULT_MAX_LIST_ITEMS: usize = 1024;
/// Default hard cap for total widget count per terminal.
pub const DEFAULT_MAX_WIDGETS: usize = 256;
/// Default hard cap for clipboard length.
pub const DEFAULT_MAX_CLIPBOARD_CHARS: usize = 4096;
/// Default hard cap for ANSI/highlight input length.
pub const DEFAULT_MAX_ANSI_CHARS: usize = 4096;
/// Default hard cap for command history entry count.
pub const DEFAULT_MAX_HISTORY_ENTRIES: usize = 256;

/// Validation and retention policy for terminal-owned text, widgets, and clipboard state.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TerminalLimits {
    /// Maximum number of characters accepted by one grid/text payload before truncation or rejection.
    pub max_line_chars: usize,
    /// Maximum number of scrollback lines retained regardless of soft scrollback cap.
    pub max_scrollback_lines: usize,
    /// Maximum number of command history entries retained.
    pub max_history_entries: usize,
    /// Maximum number of characters retained for one command history entry.
    pub max_history_entry_chars: usize,
    /// Maximum number of characters retained in the internal clipboard.
    pub max_clipboard_chars: usize,
    /// Maximum number of widgets attached to one terminal.
    pub max_widgets: usize,
    /// Maximum number of characters retained in widget text/title payloads.
    pub max_widget_text_chars: usize,
    /// Maximum number of list items retained by one list widget.
    pub max_list_items: usize,
    /// Maximum number of characters retained for one list item.
    pub max_item_chars: usize,
    /// Maximum number of characters parsed by ANSI/highlight helper entrypoints.
    pub max_ansi_chars: usize,
}

impl Default for TerminalLimits {
    fn default() -> Self {
        Self {
            max_line_chars: DEFAULT_MAX_LINE_CHARS,
            max_scrollback_lines: 500,
            max_history_entries: DEFAULT_MAX_HISTORY_ENTRIES,
            max_history_entry_chars: DEFAULT_MAX_HISTORY_ENTRY_CHARS,
            max_clipboard_chars: DEFAULT_MAX_CLIPBOARD_CHARS,
            max_widgets: DEFAULT_MAX_WIDGETS,
            max_widget_text_chars: DEFAULT_MAX_WIDGET_TEXT_CHARS,
            max_list_items: DEFAULT_MAX_LIST_ITEMS,
            max_item_chars: DEFAULT_MAX_ITEM_CHARS,
            max_ansi_chars: DEFAULT_MAX_ANSI_CHARS,
        }
    }
}

impl TerminalLimits {
    /// Return a copy with every field clamped to a sensible non-zero minimum.
    fn normalized(self) -> Self {
        Self {
            max_line_chars: self.max_line_chars.max(1),
            max_scrollback_lines: self.max_scrollback_lines.max(1),
            max_history_entries: self.max_history_entries.max(1),
            max_history_entry_chars: self.max_history_entry_chars.max(1),
            max_clipboard_chars: self.max_clipboard_chars.max(1),
            max_widgets: self.max_widgets.max(1),
            max_widget_text_chars: self.max_widget_text_chars.max(1),
            max_list_items: self.max_list_items.max(1),
            max_item_chars: self.max_item_chars.max(1),
            max_ansi_chars: self.max_ansi_chars.max(1),
        }
    }
}

/// Diagnostic counters collected from permissive terminal operations.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct TerminalDiagnostics {
    /// Count of permissive writes ignored because their coordinates were out of bounds.
    pub out_of_bounds_writes: usize,
    /// Count of permissive reads that fell back to the default cell.
    pub out_of_bounds_reads: usize,
    /// Count of invalid codepoints replaced with a safe fallback.
    pub invalid_codepoints: usize,
    /// Count of invalid color payloads replaced with a safe fallback.
    pub invalid_colors: usize,
    /// Count of text payloads truncated to meet a terminal limit.
    pub clipped_text: usize,
    /// Count of widget attach attempts rejected by widget limits or validation.
    pub rejected_widgets: usize,
    /// Count of invalid panel child operations rejected by graph validation.
    pub rejected_widget_children: usize,
    /// Count of command history entries rejected by strict operations.
    pub rejected_history_entries: usize,
    /// Count of clipboard writes rejected by strict operations.
    pub rejected_clipboard_writes: usize,
    /// Count of times focus was cleared because the target was stale, hidden, disabled, or unfocusable.
    pub cleared_focus_targets: usize,
}

/// Input traversal and clipboard policy for terminal widgets.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TerminalInputPolicy {
    /// When true, Tab and Shift+Tab move focus between focusable widgets.
    pub allow_tab_focus_traversal: bool,
    /// When true, focus traversal wraps around the widget list.
    pub wrap_focus: bool,
    /// When true, Ctrl+C/X/V operate on the internal clipboard buffer.
    pub allow_internal_clipboard: bool,
}

impl Default for TerminalInputPolicy {
    fn default() -> Self {
        Self {
            allow_tab_focus_traversal: true,
            wrap_focus: true,
            allow_internal_clipboard: true,
        }
    }
}

/// Summary of the most recent composition pass used by terminal render helpers.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct TerminalRenderStats {
    /// Number of grid cells composed during the last render helper call.
    pub cells_composed: usize,
    /// Number of visible widgets drawn during the last render helper call.
    pub widgets_drawn: usize,
    /// Number of characters clipped while rendering visible widget text.
    pub clipped_chars: usize,
    /// Number of list rows actually drawn.
    pub list_items_drawn: usize,
    /// Number of list rows skipped because they were outside the visible viewport.
    pub list_items_skipped: usize,
}

/// Error returned by strict terminal operations.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TerminalError {
    /// The requested cell coordinates do not address the current grid.
    OutOfBoundsCell { col: usize, row: usize },
    /// The provided Unicode codepoint is not a valid scalar value.
    InvalidCodepoint { ch: u32 },
    /// One or more RGBA components were NaN or infinite.
    InvalidColor,
    /// The requested widget index does not exist.
    InvalidWidgetIndex { index: usize },
    /// The requested widget kind does not support this operation.
    InvalidWidgetKind { expected: &'static str },
    /// The requested panel index does not refer to a panel widget.
    InvalidPanelIndex { index: usize },
    /// The widget limit would be exceeded by this operation.
    WidgetLimitReached { limit: usize },
    /// The list item limit would be exceeded by this operation.
    ListItemLimitReached { limit: usize },
    /// The text payload exceeds the strict limit for this operation.
    TextTooLong { len: usize, limit: usize },
    /// The clipboard payload exceeds the strict limit for this operation.
    ClipboardTooLong { len: usize, limit: usize },
    /// The command history entry exceeds the strict limit for this operation.
    HistoryEntryTooLong { len: usize, limit: usize },
    /// The command history entry count limit would be exceeded by this operation.
    HistoryLimitReached { limit: usize },
    /// The child widget already belongs to another panel.
    DuplicateParent {
        child_index: usize,
        existing_parent: usize,
    },
    /// Adding the requested child would create a panel cycle.
    PanelCycle {
        panel_index: usize,
        child_index: usize,
    },
}

impl fmt::Display for TerminalError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::OutOfBoundsCell { col, row } => {
                write!(f, "cell ({col}, {row}) is outside the terminal grid")
            }
            Self::InvalidCodepoint { ch } => write!(f, "invalid Unicode scalar value: {ch}"),
            Self::InvalidColor => write!(f, "color components must be finite numbers"),
            Self::InvalidWidgetIndex { index } => write!(f, "widget index {index} does not exist"),
            Self::InvalidWidgetKind { expected } => {
                write!(f, "operation requires widget kind: {expected}")
            }
            Self::InvalidPanelIndex { index } => write!(f, "widget index {index} is not a panel"),
            Self::WidgetLimitReached { limit } => {
                write!(f, "widget limit of {limit} would be exceeded")
            }
            Self::ListItemLimitReached { limit } => {
                write!(f, "list item limit of {limit} would be exceeded")
            }
            Self::TextTooLong { len, limit } => {
                write!(f, "text length {len} exceeds limit {limit}")
            }
            Self::ClipboardTooLong { len, limit } => {
                write!(f, "clipboard length {len} exceeds limit {limit}")
            }
            Self::HistoryEntryTooLong { len, limit } => {
                write!(f, "history entry length {len} exceeds limit {limit}")
            }
            Self::HistoryLimitReached { limit } => {
                write!(f, "history entry limit of {limit} would be exceeded")
            }
            Self::DuplicateParent {
                child_index,
                existing_parent,
            } => write!(
                f,
                "widget {child_index} already belongs to panel {existing_parent}"
            ),
            Self::PanelCycle {
                panel_index,
                child_index,
            } => write!(
                f,
                "adding widget {child_index} to panel {panel_index} would create a cycle"
            ),
        }
    }
}

impl std::error::Error for TerminalError {}

/// Error reported by widget graph validation.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TerminalWidgetValidationError {
    /// A panel references a child index that does not exist.
    MissingChild {
        panel_index: usize,
        child_index: usize,
    },
    /// A widget is referenced by more than one panel.
    DuplicateParent {
        child_index: usize,
        first_parent: usize,
        second_parent: usize,
    },
    /// A panel graph cycle was discovered during validation.
    Cycle {
        panel_index: usize,
        child_index: usize,
    },
    /// Focus currently points at a hidden, disabled, stale, or otherwise unfocusable widget.
    InvalidFocusTarget { index: usize },
}

impl fmt::Display for TerminalWidgetValidationError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::MissingChild {
                panel_index,
                child_index,
            } => write!(
                f,
                "panel {panel_index} references missing child widget {child_index}"
            ),
            Self::DuplicateParent {
                child_index,
                first_parent,
                second_parent,
            } => write!(
                f,
                "widget {child_index} belongs to multiple panels ({first_parent}, {second_parent})"
            ),
            Self::Cycle {
                panel_index,
                child_index,
            } => write!(
                f,
                "panel cycle detected from panel {panel_index} through child {child_index}"
            ),
            Self::InvalidFocusTarget { index } => {
                write!(
                    f,
                    "focus target {index} is hidden, disabled, stale, or unfocusable"
                )
            }
        }
    }
}

fn is_valid_codepoint(ch: u32) -> bool {
    char::from_u32(ch).is_some()
}

fn sanitize_color(color: [f32; 4]) -> Option<[f32; 4]> {
    if color.iter().all(|value| value.is_finite()) {
        Some(color.map(|value| value.clamp(0.0, 1.0)))
    } else {
        None
    }
}

fn clip_text_to_limit(text: &str, limit: usize) -> (String, usize) {
    let len = char_count(text);
    if len <= limit {
        return (text.to_owned(), 0);
    }
    let clipped = truncate_chars(text, limit);
    (clipped, len - limit)
}

/// Event emitted by `Terminal` input handlers and consumed by the Lua API layer.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum TerminalEvent {
    /// A button widget was activated by keyboard or mouse.
    ButtonClicked { index: usize },
    /// A text-box widget contents changed.
    TextChanged { index: usize },
    /// A list widget selection changed.
    SelectionChanged { index: usize },
}

/// Write a single character cell at `(col, row)` in `cells`; silently ignored when out of bounds.
fn set_render_cell(
    cells: &mut [TCell],
    cols: usize,
    rows: usize,
    col: usize,
    row: usize,
    ch: char,
    fg: [f32; 4],
) {
    if col >= cols || row >= rows {
        return;
    }
    let idx = row * cols + col;
    cells[idx].ch = ch as u32;
    cells[idx].fg = fg;
}

/// Write a single character cell at `(col, row)` including foreground and background; ignored when out of bounds.
#[allow(clippy::too_many_arguments)]
fn set_render_cell_with_bg(
    cells: &mut [TCell],
    dimensions: (usize, usize),
    position: (usize, usize),
    ch: char,
    fg: [f32; 4],
    bg: [f32; 4],
) {
    let (cols, rows) = dimensions;
    let (col, row) = position;
    if col >= cols || row >= rows {
        return;
    }
    let idx = row * cols + col;
    cells[idx].ch = ch as u32;
    cells[idx].fg = fg;
    cells[idx].bg = bg;
}

/// Fill a rectangular region of `cells` with space characters using `fg` and `bg`.
#[allow(clippy::too_many_arguments)]
fn clear_render_rect(
    cells: &mut [TCell],
    cols: usize,
    rows: usize,
    x: usize,
    y: usize,
    width: usize,
    height: usize,
    fg: [f32; 4],
    bg: [f32; 4],
) {
    for row in y..y.saturating_add(height) {
        for col in x..x.saturating_add(width) {
            set_render_cell_with_bg(cells, (cols, rows), (col, row), ' ', fg, bg);
        }
    }
}

/// Draw a shaded one-cell button row with bracket edges and centered text.
#[allow(clippy::too_many_arguments)]
fn draw_compact_button(
    cells: &mut [TCell],
    cols: usize,
    rows: usize,
    x: usize,
    y: usize,
    width: usize,
    text: &str,
    fg: [f32; 4],
    bg: [f32; 4],
) {
    if width == 0 {
        return;
    }
    clear_render_rect(cells, cols, rows, x, y, width, 1, fg, bg);
    if width >= 2 {
        set_render_cell_with_bg(cells, (cols, rows), (x, y), '[', fg, bg);
        set_render_cell_with_bg(cells, (cols, rows), (x + width - 1, y), ']', fg, bg);
    }
    let content_width = width.saturating_sub(2).max(1);
    let text_width = char_count(text).min(content_width);
    let start_col = x + 1 + content_width.saturating_sub(text_width) / 2;
    write_render_text(cells, cols, rows, start_col, y, text, fg, text_width);
}

/// Draw a flat single-line frame around a terminal widget.
#[allow(clippy::too_many_arguments)]
fn draw_shaded_frame(
    cells: &mut [TCell],
    cols: usize,
    rows: usize,
    x: usize,
    y: usize,
    width: usize,
    height: usize,
    bg: [f32; 4],
) {
    if width == 0 || height == 0 {
        return;
    }
    clear_render_rect(cells, cols, rows, x, y, width, height, DEFAULT_FG, bg);
    if width == 1 || height == 1 {
        return;
    }
    for offset in 0..width {
        let top_ch = if offset == 0 {
            '┌'
        } else if offset == width - 1 {
            '┐'
        } else {
            '─'
        };
        let bottom_ch = if offset == 0 {
            '└'
        } else if offset == width - 1 {
            '┘'
        } else {
            '─'
        };
        set_render_cell_with_bg(cells, (cols, rows), (x + offset, y), top_ch, DEFAULT_FG, bg);
        set_render_cell_with_bg(
            cells,
            (cols, rows),
            (x + offset, y + height - 1),
            bottom_ch,
            DEFAULT_FG,
            bg,
        );
    }
    if height > 2 {
        for offset in 1..height - 1 {
            set_render_cell_with_bg(cells, (cols, rows), (x, y + offset), '│', DEFAULT_FG, bg);
            set_render_cell_with_bg(
                cells,
                (cols, rows),
                (x + width - 1, y + offset),
                '│',
                DEFAULT_FG,
                bg,
            );
        }
    }
}

/// Write up to `max_chars` characters of `text` into `cells` starting at `(x, y)` with `fg`.
#[allow(clippy::too_many_arguments)]
fn write_render_text(
    cells: &mut [TCell],
    cols: usize,
    rows: usize,
    x: usize,
    y: usize,
    text: &str,
    fg: [f32; 4],
    max_chars: usize,
) {
    for (offset, ch) in text.chars().take(max_chars).enumerate() {
        set_render_cell(cells, cols, rows, x + offset, y, ch, fg);
    }
}

/// Return `true` when `ch` is treated as a word character for Ctrl+Backspace/Delete editing.
fn is_word_char(ch: char) -> bool {
    ch.is_alphanumeric() || ch == '_'
}

/// Find the previous word boundary before `cursor` for Ctrl+Backspace behavior.
fn prev_word_boundary(text: &str, cursor: usize) -> usize {
    let chars: Vec<char> = text.chars().collect();
    let mut index = cursor.min(chars.len());
    while index > 0 && !is_word_char(chars[index - 1]) {
        index -= 1;
    }
    while index > 0 && is_word_char(chars[index - 1]) {
        index -= 1;
    }
    index
}

/// Find the next word boundary after `cursor` for Ctrl+Delete behavior.
fn next_word_boundary(text: &str, cursor: usize) -> usize {
    let chars: Vec<char> = text.chars().collect();
    let mut index = cursor.min(chars.len());
    while index < chars.len() && !is_word_char(chars[index]) {
        index += 1;
    }
    while index < chars.len() && is_word_char(chars[index]) {
        index += 1;
    }
    index
}

/// Insert `insert_text` at `cursor_pos`, truncating to the remaining capacity when `max_length` is non-zero.
fn insert_with_limit(
    text: &mut String,
    cursor_pos: &mut usize,
    max_length: usize,
    insert_text: &str,
) -> usize {
    let insert_len = char_count(insert_text);
    let existing_len = char_count(text);
    let allowed = if max_length == 0 {
        insert_len
    } else {
        max_length.saturating_sub(existing_len).min(insert_len)
    };
    if allowed == 0 {
        return 0;
    }
    let insert_at = byte_index(text, *cursor_pos);
    if allowed == insert_len {
        text.insert_str(insert_at, insert_text);
    } else {
        let clipped = truncate_chars(insert_text, allowed);
        text.insert_str(insert_at, &clipped);
    }
    *cursor_pos += allowed;
    allowed
}

/// Main terminal state machine: grid, widgets, scrollback, command history, and focus tracking.
#[derive(Debug)]
pub struct Terminal {
    /// Number of columns in the active grid, clamped to `MAX_COLS`.
    cols: usize,
    /// Number of rows in the active grid, clamped to `MAX_ROWS`.
    rows: usize,
    /// Flat row-major cell buffer; length is `cols * rows`.
    grid: Vec<TCell>,
    /// Zero-based column of the cursor (stored internally, exposed via 1-based API).
    cursor_col: usize,
    /// Zero-based row of the cursor (stored internally, exposed via 1-based API).
    cursor_row: usize,
    /// Ordered list of widgets drawn on top of the grid.
    widgets: Vec<Widget>,
    /// Index into `widgets` of the currently focused widget, if any.
    focused: Option<usize>,
    /// Scrollback line history; oldest lines at index 0.
    scrollback: Vec<String>,
    /// Maximum number of lines kept in `scrollback`.
    scrollback_cap: usize,
    /// Current scroll position relative to the end of `scrollback`.
    scrollback_offset: usize,
    /// Command input history for up/down navigation.
    cmd_history: Vec<String>,
    /// Navigation cursor into `cmd_history`; 0 means no active navigation.
    cmd_cursor: usize,
    /// Internal clipboard used by terminal text shortcuts.
    clipboard: String,
    /// Focused textbox index when Ctrl+A "select all" state is active.
    select_all_textbox: Option<usize>,
    /// Hard validation and retention policy for terminal-owned text and widgets.
    limits: TerminalLimits,
    /// Diagnostic counters for permissive operations and sanitizing fallbacks.
    diagnostics: TerminalDiagnostics,
    /// Keyboard traversal and clipboard policy for widget input.
    input_policy: TerminalInputPolicy,
    /// Optional per-terminal cell width override in pixels.
    cell_width_override: Option<f32>,
    /// Optional per-terminal cell height override in pixels.
    cell_height_override: Option<f32>,
    /// Reusable composition buffer that reduces grid buffer clone churn across render paths.
    render_scratch: RefCell<Vec<TCell>>,
    /// Stats captured during the most recent render composition pass.
    render_stats: RefCell<TerminalRenderStats>,
}

impl Clone for Terminal {
    fn clone(&self) -> Self {
        Self {
            cols: self.cols,
            rows: self.rows,
            grid: self.grid.clone(),
            cursor_col: self.cursor_col,
            cursor_row: self.cursor_row,
            widgets: self.widgets.clone(),
            focused: self.focused,
            scrollback: self.scrollback.clone(),
            scrollback_cap: self.scrollback_cap,
            scrollback_offset: self.scrollback_offset,
            cmd_history: self.cmd_history.clone(),
            cmd_cursor: self.cmd_cursor,
            clipboard: self.clipboard.clone(),
            select_all_textbox: self.select_all_textbox,
            limits: self.limits,
            diagnostics: self.diagnostics,
            input_policy: self.input_policy,
            cell_width_override: self.cell_width_override,
            cell_height_override: self.cell_height_override,
            render_scratch: RefCell::new(Vec::new()),
            render_stats: RefCell::new(*self.render_stats.borrow()),
        }
    }
}

impl Terminal {
    /// Create a new `Terminal` with a blank grid of `cols`×`rows` cells, clamped to `MAX_COLS`/`MAX_ROWS`.
    pub fn new(cols: usize, rows: usize) -> Self {
        let cols = cols.clamp(1, MAX_COLS);
        let rows = rows.clamp(1, MAX_ROWS);
        let limits = TerminalLimits::default();
        Self {
            cols,
            rows,
            grid: vec![TCell::default(); cols * rows],
            cursor_col: 0,
            cursor_row: 0,
            widgets: Vec::new(),
            focused: None,
            scrollback: Vec::new(),
            scrollback_cap: limits.max_scrollback_lines,
            scrollback_offset: 0,
            cmd_history: Vec::new(),
            cmd_cursor: 0,
            clipboard: String::new(),
            select_all_textbox: None,
            limits,
            diagnostics: TerminalDiagnostics::default(),
            input_policy: TerminalInputPolicy::default(),
            cell_width_override: None,
            cell_height_override: None,
            render_scratch: RefCell::new(Vec::new()),
            render_stats: RefCell::new(TerminalRenderStats::default()),
        }
    }

    /// Return the active terminal limits.
    pub fn limits(&self) -> TerminalLimits {
        self.limits
    }

    /// Replace the active terminal limits and immediately sanitize retained state to match.
    pub fn set_limits(&mut self, limits: TerminalLimits) {
        self.limits = limits.normalized();
        self.scrollback_cap = self.scrollback_cap.min(self.limits.max_scrollback_lines);
        while self.widgets.len() > self.limits.max_widgets {
            let removed = self.widgets.len() - 1;
            self.widgets.pop();
            self.adjust_panel_children_after_removal(removed);
        }
        if matches!(self.focused, Some(index) if index >= self.widgets.len()) {
            self.focused = None;
        }
        for widget in &mut self.widgets {
            let clipped = widget.apply_limits(
                self.limits.max_widget_text_chars,
                self.limits.max_list_items,
                self.limits.max_item_chars,
            );
            self.diagnostics.clipped_text += clipped;
        }
        for line in &mut self.scrollback {
            let (clipped, dropped) = clip_text_to_limit(line, self.limits.max_line_chars);
            if dropped > 0 {
                *line = clipped;
                self.diagnostics.clipped_text += dropped;
            }
        }
        if self.scrollback.len() > self.effective_scrollback_cap() {
            let excess = self.scrollback.len() - self.effective_scrollback_cap();
            self.scrollback.drain(0..excess);
        }
        while self.cmd_history.len() > self.limits.max_history_entries {
            self.cmd_history.remove(0);
        }
        for entry in &mut self.cmd_history {
            let (clipped, dropped) = clip_text_to_limit(entry, self.limits.max_history_entry_chars);
            if dropped > 0 {
                *entry = clipped;
                self.diagnostics.clipped_text += dropped;
            }
        }
        let (clipboard, dropped) =
            clip_text_to_limit(&self.clipboard, self.limits.max_clipboard_chars);
        if dropped > 0 {
            self.clipboard = clipboard;
            self.diagnostics.clipped_text += dropped;
        }
        self.cmd_cursor = self.cmd_cursor.min(self.cmd_history.len());
        self.ensure_focus_valid();
    }

    /// Return the current terminal diagnostics snapshot.
    pub fn diagnostics(&self) -> TerminalDiagnostics {
        self.diagnostics
    }

    /// Reset all terminal diagnostics counters to zero.
    pub fn clear_diagnostics(&mut self) {
        self.diagnostics = TerminalDiagnostics::default();
    }

    /// Return the most recent render composition stats.
    pub fn render_stats(&self) -> TerminalRenderStats {
        *self.render_stats.borrow()
    }

    /// Return the active keyboard traversal and clipboard policy.
    pub fn input_policy(&self) -> TerminalInputPolicy {
        self.input_policy
    }

    /// Replace the active keyboard traversal and clipboard policy.
    pub fn set_input_policy(&mut self, policy: TerminalInputPolicy) {
        self.input_policy = policy;
        self.ensure_focus_valid();
    }

    fn effective_scrollback_cap(&self) -> usize {
        self.scrollback_cap.min(self.limits.max_scrollback_lines)
    }

    fn clip_text_for_limit(&mut self, text: &str, limit: usize) -> String {
        let (clipped, dropped) = clip_text_to_limit(text, limit);
        if dropped > 0 {
            self.diagnostics.clipped_text += dropped;
        }
        clipped
    }

    fn sanitize_cell_payload(&mut self, ch: u32, fg: [f32; 4], bg: [f32; 4]) -> TCell {
        let ch = if is_valid_codepoint(ch) {
            ch
        } else {
            self.diagnostics.invalid_codepoints += 1;
            DEFAULT_CH
        };
        let fg = sanitize_color(fg).unwrap_or_else(|| {
            self.diagnostics.invalid_colors += 1;
            DEFAULT_FG
        });
        let bg = sanitize_color(bg).unwrap_or_else(|| {
            self.diagnostics.invalid_colors += 1;
            DEFAULT_BG
        });
        TCell { ch, fg, bg }
    }

    fn is_focusable_widget(widget: &Widget) -> bool {
        matches!(
            widget.kind,
            WidgetKind::Button { .. } | WidgetKind::TextBox { .. } | WidgetKind::List { .. }
        )
    }

    fn is_focusable_widget_index(&self, index: usize) -> bool {
        self.widgets.get(index).is_some_and(|widget| {
            widget.base.visible && widget.base.enabled && Self::is_focusable_widget(widget)
        })
    }

    fn ensure_focus_valid(&mut self) {
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

    fn widget_parent_map(&self) -> Result<HashMap<usize, usize>, TerminalWidgetValidationError> {
        let mut parents = HashMap::new();
        for (panel_index, widget) in self.widgets.iter().enumerate() {
            if let WidgetKind::Panel { children } = &widget.kind {
                for &child_index in children {
                    if child_index >= self.widgets.len() {
                        return Err(TerminalWidgetValidationError::MissingChild {
                            panel_index,
                            child_index,
                        });
                    }
                    if let Some(first_parent) = parents.insert(child_index, panel_index) {
                        if first_parent != panel_index {
                            return Err(TerminalWidgetValidationError::DuplicateParent {
                                child_index,
                                first_parent,
                                second_parent: panel_index,
                            });
                        }
                    }
                }
            }
        }
        Ok(parents)
    }

    fn panel_path_exists(
        &self,
        start_index: usize,
        target_index: usize,
        visiting: &mut HashSet<usize>,
    ) -> bool {
        if start_index == target_index {
            return true;
        }
        if !visiting.insert(start_index) {
            return false;
        }
        let result = match self.widgets.get(start_index).map(|widget| &widget.kind) {
            Some(WidgetKind::Panel { children }) => children.iter().copied().any(|child_index| {
                child_index == target_index
                    || (child_index < self.widgets.len()
                        && self.panel_path_exists(child_index, target_index, visiting))
            }),
            _ => false,
        };
        visiting.remove(&start_index);
        result
    }

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

    /// Append `widget` and return its index. When the terminal is at the widget limit, the widget is rejected and the existing length is returned.
    pub fn add_widget(&mut self, widget: Widget) -> usize {
        if self.widgets.len() >= self.limits.max_widgets {
            self.diagnostics.rejected_widgets += 1;
            return self.widgets.len();
        }
        let index = self.widgets.len();
        let mut widget = widget;
        let clipped = widget.apply_limits(
            self.limits.max_widget_text_chars,
            self.limits.max_list_items,
            self.limits.max_item_chars,
        );
        self.diagnostics.clipped_text += clipped;
        self.widgets.push(widget);
        index
    }

    /// Strictly append `widget` and return its index.
    pub fn try_add_widget(&mut self, widget: Widget) -> Result<usize, TerminalError> {
        if self.widgets.len() >= self.limits.max_widgets {
            return Err(TerminalError::WidgetLimitReached {
                limit: self.limits.max_widgets,
            });
        }
        let text_limit = self.limits.max_widget_text_chars;
        let item_limit = self.limits.max_item_chars;
        let max_items = self.limits.max_list_items;
        widget.try_apply_limits(text_limit, max_items, item_limit)?;
        let index = self.widgets.len();
        self.widgets.push(widget);
        Ok(index)
    }

    /// Remove the widget at `index`; adjusts focus and panel child references; returns `false` when index is out of range.
    pub fn remove_widget(&mut self, index: usize) -> bool {
        if index >= self.widgets.len() {
            return false;
        }
        self.widgets.remove(index);
        match self.focused {
            Some(focused) if focused == index => self.focused = None,
            Some(focused) if focused > index => self.focused = Some(focused - 1),
            _ => {}
        }
        self.adjust_panel_children_after_removal(index);
        true
    }

    /// Remove all widgets and clear focus.
    pub fn clear_widgets(&mut self) {
        self.widgets.clear();
        self.focused = None;
    }

    /// Return the number of registered widgets.
    pub fn get_widget_count(&self) -> usize {
        self.widgets.len()
    }

    /// Return a shared reference to the widget at `index`, or `None`.
    pub fn get_widget(&self, index: usize) -> Option<&Widget> {
        self.widgets.get(index)
    }

    /// Return a mutable reference to the widget at `index`, or `None`.
    pub fn get_widget_mut(&mut self, index: usize) -> Option<&mut Widget> {
        self.widgets.get_mut(index)
    }

    /// Permissively set attached widget text using terminal limits; returns whether the widget's change callback should fire.
    pub fn set_widget_text(
        &mut self,
        index: usize,
        new_text: String,
    ) -> Result<bool, TerminalError> {
        let widget = self
            .widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?;
        let before = widget.get_text().ok();
        let changed = widget
            .set_text(new_text)
            .map_err(|_| TerminalError::InvalidWidgetKind {
                expected: "label, button, or text box",
            })?;
        let clipped = widget.apply_limits(
            self.limits.max_widget_text_chars,
            self.limits.max_list_items,
            self.limits.max_item_chars,
        );
        self.diagnostics.clipped_text += clipped;
        Ok(changed || before != widget.get_text().ok())
    }

    /// Strictly set attached widget text using terminal limits.
    pub fn try_set_widget_text(
        &mut self,
        index: usize,
        new_text: String,
    ) -> Result<bool, TerminalError> {
        let limit = self.limits.max_widget_text_chars;
        self.widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?
            .try_set_text_with_limit(new_text, limit)
    }

    /// Permissively append a list item to the widget at `index`.
    pub fn add_widget_item(&mut self, index: usize, item: String) -> Result<(), TerminalError> {
        let widget = self
            .widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?;
        if let Err(err) = widget.try_add_item_with_limits(
            item.clone(),
            self.limits.max_list_items,
            self.limits.max_item_chars,
        ) {
            match err {
                TerminalError::TextTooLong { .. } | TerminalError::ListItemLimitReached { .. } => {
                    self.diagnostics.clipped_text +=
                        char_count(&item).saturating_sub(self.limits.max_item_chars);
                    widget
                        .add_item(item)
                        .map_err(|_| TerminalError::InvalidWidgetKind { expected: "list" })?;
                    widget.apply_limits(
                        self.limits.max_widget_text_chars,
                        self.limits.max_list_items,
                        self.limits.max_item_chars,
                    );
                    Ok(())
                }
                other => Err(other),
            }
        } else {
            Ok(())
        }
    }

    /// Strictly append a list item to the widget at `index`.
    pub fn try_add_widget_item(&mut self, index: usize, item: String) -> Result<(), TerminalError> {
        self.widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?
            .try_add_item_with_limits(item, self.limits.max_list_items, self.limits.max_item_chars)
    }

    /// Permissively set attached widget title using terminal limits.
    pub fn set_widget_title(&mut self, index: usize, title: String) -> Result<(), TerminalError> {
        let widget = self
            .widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?;
        widget
            .set_title(title)
            .map_err(|_| TerminalError::InvalidWidgetKind { expected: "border" })?;
        let clipped = widget.apply_limits(
            self.limits.max_widget_text_chars,
            self.limits.max_list_items,
            self.limits.max_item_chars,
        );
        self.diagnostics.clipped_text += clipped;
        Ok(())
    }

    /// Strictly set attached widget title using terminal limits.
    pub fn try_set_widget_title(
        &mut self,
        index: usize,
        title: String,
    ) -> Result<(), TerminalError> {
        self.widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?
            .try_set_title_with_limit(title, self.limits.max_widget_text_chars)
    }
    /// Strictly attach `child_index` to the panel at `panel_index`.
    pub(crate) fn try_add_panel_child(
        &mut self,
        panel_index: usize,
        child_index: usize,
    ) -> Result<(), TerminalError> {
        if panel_index >= self.widgets.len() {
            return Err(TerminalError::InvalidPanelIndex { index: panel_index });
        }
        if child_index >= self.widgets.len() {
            return Err(TerminalError::InvalidWidgetIndex { index: child_index });
        }
        if panel_index == child_index {
            return Err(TerminalError::PanelCycle {
                panel_index,
                child_index,
            });
        }
        if !matches!(self.widgets[panel_index].kind, WidgetKind::Panel { .. }) {
            return Err(TerminalError::InvalidPanelIndex { index: panel_index });
        }
        if let Ok(parent_map) = self.widget_parent_map() {
            if let Some(existing_parent) = parent_map.get(&child_index).copied() {
                if existing_parent != panel_index {
                    return Err(TerminalError::DuplicateParent {
                        child_index,
                        existing_parent,
                    });
                }
            }
        }
        let mut visiting = HashSet::new();
        if self.panel_path_exists(child_index, panel_index, &mut visiting) {
            return Err(TerminalError::PanelCycle {
                panel_index,
                child_index,
            });
        }
        match &mut self.widgets[panel_index].kind {
            WidgetKind::Panel { children } => {
                if !children.contains(&child_index) {
                    children.push(child_index);
                }
                Ok(())
            }
            _ => Err(TerminalError::InvalidPanelIndex { index: panel_index }),
        }
    }
    /// Remove `child_index` from the Panel widget at `panel_index`; returns `true` when the child was present.
    pub(crate) fn remove_panel_child(&mut self, panel_index: usize, child_index: usize) -> bool {
        if panel_index >= self.widgets.len() {
            return false;
        }
        match &mut self.widgets[panel_index].kind {
            WidgetKind::Panel { children } => {
                let before = children.len();
                children.retain(|&index| index != child_index);
                before != children.len()
            }
            _ => false,
        }
    }
    /// Remove all children from the Panel widget at `panel_index`; returns `false` when index is wrong kind.
    pub(crate) fn clear_panel_children(&mut self, panel_index: usize) -> bool {
        if panel_index >= self.widgets.len() {
            return false;
        }
        match &mut self.widgets[panel_index].kind {
            WidgetKind::Panel { children } => {
                children.clear();
                true
            }
            _ => false,
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
    /// Compose widgets into `cells` on top of the base grid.
    fn compose_widgets_into(&self, cells: &mut [TCell]) -> TerminalRenderStats {
        let mut stats = TerminalRenderStats {
            cells_composed: self.cols * self.rows,
            ..TerminalRenderStats::default()
        };
        for (index, widget) in self.widgets.iter().enumerate() {
            if !widget.base.visible {
                continue;
            }
            stats.widgets_drawn += 1;
            match &widget.kind {
                WidgetKind::Label { text, color } => {
                    write_render_text(
                        cells,
                        self.cols,
                        self.rows,
                        widget.base.x,
                        widget.base.y,
                        text,
                        *color,
                        char_count(text),
                    );
                }
                WidgetKind::Button { text } => {
                    let fg = if self.focused == Some(index) {
                        FOCUS_FG
                    } else {
                        BUTTON_FG
                    };
                    let bg = if self.focused == Some(index) {
                        BUTTON_FOCUS_BG
                    } else {
                        BUTTON_BG
                    };
                    if widget.base.height <= 1 {
                        draw_compact_button(
                            cells,
                            self.cols,
                            self.rows,
                            widget.base.x,
                            widget.base.y,
                            widget.base.width,
                            text,
                            fg,
                            bg,
                        );
                    } else {
                        draw_shaded_frame(
                            cells,
                            self.cols,
                            self.rows,
                            widget.base.x,
                            widget.base.y,
                            widget.base.width,
                            widget.base.height,
                            bg,
                        );
                        let row = widget.base.y + widget.base.height.saturating_sub(1) / 2;
                        let inner_width = widget.base.width.saturating_sub(2).max(1);
                        let text_width = char_count(text).min(inner_width);
                        let start_col =
                            widget.base.x + widget.base.width.saturating_sub(text_width) / 2;
                        write_render_text(
                            cells, self.cols, self.rows, start_col, row, text, fg, text_width,
                        );
                    }
                }
                WidgetKind::TextBox {
                    text, cursor_pos, ..
                } => {
                    clear_render_rect(
                        cells,
                        self.cols,
                        self.rows,
                        widget.base.x,
                        widget.base.y,
                        widget.base.width,
                        widget.base.height,
                        DEFAULT_FG,
                        TEXTBOX_BG,
                    );
                    let display = truncate_chars(text, widget.base.width);
                    stats.clipped_chars += char_count(text).saturating_sub(char_count(&display));
                    write_render_text(
                        cells,
                        self.cols,
                        self.rows,
                        widget.base.x,
                        widget.base.y,
                        &display,
                        DEFAULT_FG,
                        widget.base.width,
                    );
                    if self.focused == Some(index) && widget.base.width > 0 {
                        let cursor_col = widget.base.x + (*cursor_pos).min(widget.base.width - 1);
                        set_render_cell(
                            cells,
                            self.cols,
                            self.rows,
                            cursor_col,
                            widget.base.y,
                            CURSOR_CHAR,
                            FOCUS_FG,
                        );
                    }
                }
                WidgetKind::List {
                    items,
                    selected,
                    scroll_offset,
                } => {
                    clear_render_rect(
                        cells,
                        self.cols,
                        self.rows,
                        widget.base.x,
                        widget.base.y,
                        widget.base.width,
                        widget.base.height,
                        DEFAULT_FG,
                        LIST_BG,
                    );
                    let visible_count = items
                        .len()
                        .saturating_sub(*scroll_offset)
                        .min(widget.base.height);
                    stats.list_items_drawn += visible_count;
                    stats.list_items_skipped += items.len().saturating_sub(visible_count);
                    for row_offset in 0..widget.base.height {
                        let row = widget.base.y + row_offset;
                        let item_index = scroll_offset + row_offset;
                        if item_index >= items.len() {
                            continue;
                        }
                        let is_selected = *selected == Some(item_index);
                        let fg = if is_selected {
                            LIST_SELECTED_FG
                        } else {
                            DEFAULT_FG
                        };
                        if is_selected {
                            clear_render_rect(
                                cells,
                                self.cols,
                                self.rows,
                                widget.base.x,
                                row,
                                widget.base.width,
                                1,
                                fg,
                                LIST_SELECTED_BG,
                            );
                        }
                        let prefix = if is_selected { "> " } else { "  " };
                        let available = widget.base.width.saturating_sub(char_count(prefix));
                        let text = truncate_chars(&items[item_index], available);
                        stats.clipped_chars +=
                            char_count(&items[item_index]).saturating_sub(char_count(&text));
                        write_render_text(
                            cells,
                            self.cols,
                            self.rows,
                            widget.base.x,
                            row,
                            prefix,
                            fg,
                            char_count(prefix),
                        );
                        write_render_text(
                            cells,
                            self.cols,
                            self.rows,
                            widget.base.x + char_count(prefix),
                            row,
                            &text,
                            fg,
                            available,
                        );
                    }
                }
                WidgetKind::Border {
                    style,
                    title,
                    color,
                } => {
                    self.render_border(cells, widget, *style, title, *color);
                }
                WidgetKind::Panel { .. } => {
                    draw_shaded_frame(
                        cells,
                        self.cols,
                        self.rows,
                        widget.base.x,
                        widget.base.y,
                        widget.base.width,
                        widget.base.height,
                        PANEL_BG,
                    );
                }
            }
        }
        stats
    }

    /// Run a closure against a reusable composed cell buffer to reduce grid buffer clone churn.
    pub(crate) fn with_render_cells<R>(&self, f: impl FnOnce(&[TCell]) -> R) -> R {
        let mut scratch = self.render_scratch.borrow_mut();
        scratch.clone_from(&self.grid);
        let stats = self.compose_widgets_into(scratch.as_mut_slice());
        *self.render_stats.borrow_mut() = stats;
        f(&scratch)
    }

    /// Draw a `BorderStyle` frame with optional `title` into `cells` for `widget`.
    fn render_border(
        &self,
        cells: &mut [TCell],
        widget: &Widget,
        style: BorderStyle,
        title: &str,
        color: [f32; 4],
    ) {
        if widget.base.width == 0 || widget.base.height == 0 {
            return;
        }
        let (top_left, top_right, bottom_left, bottom_right, horizontal, vertical) = match style {
            BorderStyle::Single => ('┌', '┐', '└', '┘', '─', '│'),
            BorderStyle::Double => ('╔', '╗', '╚', '╝', '═', '║'),
            BorderStyle::Ascii => ('+', '+', '+', '+', '-', '|'),
        };
        let x = widget.base.x;
        let y = widget.base.y;
        let width = widget.base.width;
        let height = widget.base.height;
        for offset in 0..width {
            let ch = if offset == 0 {
                top_left
            } else if offset == width.saturating_sub(1) {
                top_right
            } else {
                horizontal
            };
            set_render_cell(cells, self.cols, self.rows, x + offset, y, ch, color);
            if height > 1 {
                let ch = if offset == 0 {
                    bottom_left
                } else if offset == width.saturating_sub(1) {
                    bottom_right
                } else {
                    horizontal
                };
                set_render_cell(
                    cells,
                    self.cols,
                    self.rows,
                    x + offset,
                    y + height - 1,
                    ch,
                    color,
                );
            }
        }
        if height > 2 {
            for offset in 1..height - 1 {
                set_render_cell(cells, self.cols, self.rows, x, y + offset, vertical, color);
                if width > 1 {
                    set_render_cell(
                        cells,
                        self.cols,
                        self.rows,
                        x + width - 1,
                        y + offset,
                        vertical,
                        color,
                    );
                }
            }
        }
        if width > 2 && !title.is_empty() {
            let available = width.saturating_sub(2);
            let title = truncate_chars(title, available);
            write_render_text(
                cells,
                self.cols,
                self.rows,
                x + 1,
                y,
                &title,
                color,
                available,
            );
        }
    }
    /// Patch all Panel children lists after a widget at `removed_index` was removed: drop references to it and decrement higher indices.
    fn adjust_panel_children_after_removal(&mut self, removed_index: usize) {
        for widget in &mut self.widgets {
            if let WidgetKind::Panel { children } = &mut widget.kind {
                let mut i = 0;
                while i < children.len() {
                    if children[i] == removed_index {
                        children.remove(i);
                    } else {
                        if children[i] > removed_index {
                            children[i] -= 1;
                        }
                        i += 1;
                    }
                }
            }
        }
    }

    /// Validate the panel child graph and current focus target, returning every discovered problem.
    pub fn validate_widgets(&self) -> Vec<TerminalWidgetValidationError> {
        let mut errors = Vec::new();
        let mut parents = HashMap::new();
        for (panel_index, widget) in self.widgets.iter().enumerate() {
            if let WidgetKind::Panel { children } = &widget.kind {
                for &child_index in children {
                    if child_index >= self.widgets.len() {
                        errors.push(TerminalWidgetValidationError::MissingChild {
                            panel_index,
                            child_index,
                        });
                        continue;
                    }
                    if let Some(first_parent) = parents.insert(child_index, panel_index) {
                        if first_parent != panel_index {
                            errors.push(TerminalWidgetValidationError::DuplicateParent {
                                child_index,
                                first_parent,
                                second_parent: panel_index,
                            });
                        }
                    }
                    let mut visiting = HashSet::new();
                    if self.panel_path_exists(child_index, panel_index, &mut visiting) {
                        errors.push(TerminalWidgetValidationError::Cycle {
                            panel_index,
                            child_index,
                        });
                    }
                }
            }
        }
        if let Some(index) = self.focused {
            if !self.is_focusable_widget_index(index) {
                errors.push(TerminalWidgetValidationError::InvalidFocusTarget { index });
            }
        }
        errors
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
    /// Return the number of registered widgets.
    pub fn widget_count(&self) -> usize {
        self.widgets.len()
    }

    /// Return the first widget whose `base.tag` matches `tag`, or `None`.
    pub fn find_by_tag(&self, tag: &str) -> Option<&Widget> {
        self.widgets.iter().find(|widget| widget.base.tag == tag)
    }

    /// Build a batched `RenderCommand` list for the composited cell grid at pixel origin `(ox, oy)` with `cell_w`/`cell_h` and `font_key`.
    pub fn build_render_commands(
        &self,
        ox: f32,
        oy: f32,
        cell_w: f32,
        cell_h: f32,
        font_key: FontKey,
    ) -> Vec<RenderCommand> {
        self.with_render_cells(|cells| {
            let mut commands = Vec::new();
            for row in 0..self.rows {
                let row_cells = &cells[row * self.cols..(row + 1) * self.cols];
                if row_cells.is_empty() {
                    continue;
                }
                let flush_bg_run = |commands: &mut Vec<RenderCommand>,
                                    run_start: usize,
                                    run_len: usize,
                                    run_color: [f32; 4]| {
                    if run_len > 0 && run_color[3] > 0.0 {
                        commands.push(RenderCommand::SetColor(
                            run_color[0],
                            run_color[1],
                            run_color[2],
                            run_color[3],
                        ));
                        commands.push(RenderCommand::Rectangle {
                            mode: crate::render::renderer::DrawMode::Fill,
                            x: ox + run_start as f32 * cell_w,
                            y: oy + row as f32 * cell_h,
                            w: run_len as f32 * cell_w,
                            h: cell_h,
                        });
                    }
                };
                let mut bg_start = 0usize;
                let mut bg_color = row_cells[0].bg;
                let mut bg_len = 0usize;
                for (col, cell) in row_cells.iter().enumerate() {
                    if col > 0 && cell.bg != bg_color {
                        flush_bg_run(&mut commands, bg_start, bg_len, bg_color);
                        bg_start = col;
                        bg_color = cell.bg;
                        bg_len = 0;
                    }
                    bg_len += 1;
                }
                flush_bg_run(&mut commands, bg_start, bg_len, bg_color);
                let mut run_start = 0usize;
                let mut run_color = row_cells[0].fg;
                let mut run_text = String::new();
                let flush_run = |commands: &mut Vec<RenderCommand>,
                                 run_start: usize,
                                 run_color: [f32; 4],
                                 run_text: &mut String| {
                    if !run_text.trim().is_empty() {
                        commands.push(RenderCommand::SetColor(
                            run_color[0],
                            run_color[1],
                            run_color[2],
                            run_color[3],
                        ));
                        commands.push(RenderCommand::Print {
                            font_key,
                            text: run_text.clone(),
                            x: ox + run_start as f32 * cell_w,
                            y: oy + row as f32 * cell_h,
                            scale: 1.0,
                        });
                    }
                    run_text.clear();
                };
                for (col, cell) in row_cells.iter().enumerate() {
                    if col > 0 && cell.fg != run_color {
                        flush_run(&mut commands, run_start, run_color, &mut run_text);
                        run_start = col;
                        run_color = cell.fg;
                    }
                    run_text.push(char::from_u32(cell.ch).unwrap_or(' '));
                }
                flush_run(&mut commands, run_start, run_color, &mut run_text);
            }
            if !commands.is_empty() {
                commands.push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
            }
            commands
        })
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

/// `Default` implementation for `Terminal`.
impl Default for Terminal {
    fn default() -> Self {
        Self::new(80, 40)
    }
}
