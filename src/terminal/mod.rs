//! This module is the terminal index, re-exporting cell, widget, state, completion, ANSI, and render support.
//! It is the navigation point for character-grid storage, styled text parsing, visual composition, and input routing.
//! `terminal_state.rs` owns the mutable grid, cursor, histories, widget focus, and render-cell composition logic.
//! `widget.rs` owns terminal UI parts, while `ansi.rs`, `highlighter.rs`, and `completion.rs` enrich text flows.
//! `cell.rs` and `text_utils.rs` provide the atomic grid unit plus UTF-8-safe helpers reused across terminal code.
//! Change this file when public terminal exports move; change siblings when behavior or rendering semantics change.

/// ANSI escape-code parsing and attribute types.
pub mod ansi;
/// Tab-completion provider interface and built-in implementations.
pub mod completion;
/// Syntax-highlighting trait and Lua keyword highlighter.
pub mod highlighter;
/// Render helpers that convert terminal state to `RenderCommand` sequences.
pub mod render;

/// Shared UTF-8-safe text helpers used across terminal internals.
pub(crate) mod text_utils;

mod cell;
mod terminal_state;
mod widget;

/// Re-export cell type used by consumers building custom terminal UIs.
pub use cell::TCell;
/// Internal event type produced by `Terminal` for engine dispatch.
pub(crate) use terminal_state::TerminalEvent;
/// Re-export the main terminal state machine.
pub use terminal_state::{
    Terminal, TerminalDiagnostics, TerminalError, TerminalInputPolicy, TerminalLimits,
    TerminalRenderStats, TerminalWidgetValidationError,
};
/// Grid size caps shared with render and widget layers.
pub(crate) use terminal_state::{MAX_COLS, MAX_ROWS};
/// Re-export widget primitives for callers composing terminal UIs.
pub use widget::{BorderStyle, Widget, WidgetBase, WidgetKind};
