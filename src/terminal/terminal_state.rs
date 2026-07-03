//! Owns the terminal terminal state implementation for the terminal subsystem and keeps related runtime rules local here.
//! Keeps terminal buffers, widgets, and text-facing presentation state so helpers stay close to invariants this updates.
//! Defines how terminal terminal state data is validated, transformed, or stored before neighboring systems consume it.
//! Separates terminal terminal state behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where terminal code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing terminal terminal state defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near terminal terminal state state that explains them instead of spreading outward.
//! Preserves deterministic behavior by keeping terminal terminal state calculations at their owning subsystem boundary.
//! Provides adaptation layer that lets callers reuse terminal terminal state rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on terminal terminal state state, helpers, or rules.

use super::cell::{TCell, DEFAULT_BG, DEFAULT_CH, DEFAULT_FG};
use super::text_utils::{byte_index, char_count, truncate_chars};
use super::widget::{BorderStyle, Widget, WidgetKind};
use crate::render::renderer::RenderCommand;
use crate::runtime::resource_keys::FontKey;
use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use std::fmt;

mod grid;
mod history;
mod input;
mod render;
mod widgets;

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
}

/// `Default` implementation for `Terminal`.
impl Default for Terminal {
    fn default() -> Self {
        Self::new(80, 40)
    }
}
