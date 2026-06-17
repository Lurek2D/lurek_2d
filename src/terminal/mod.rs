//! This module provides the in-engine terminal stack, combining a character grid, ANSI-aware text handling, interactive widgets, and renderer handoff.
//! It supports both console-like workflows and text-heavy in-game interfaces built on a cell-based presentation model. `src/terminal/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `cell::TCell`, `terminal_state::Terminal`, `widget::{BorderStyle, Widget, WidgetBase, WidgetKind}` centralized for the terminal subsystem.

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
/// Re-export the main terminal state machine.
pub use terminal_state::Terminal;
/// Internal event type produced by `Terminal` for engine dispatch.
pub(crate) use terminal_state::TerminalEvent;
/// Grid size caps shared with render and widget layers.
pub(crate) use terminal_state::{MAX_COLS, MAX_ROWS};
/// Re-export widget primitives for callers composing terminal UIs.
pub use widget::{BorderStyle, Widget, WidgetBase, WidgetKind};
