//! In-engine terminal emulator with ANSI escape-code support
//!
//! - Grid-based cell model, tab completion, and syntax highlighting
//! - Converts terminal state into RenderCommand sequences for display
//! - Widget primitives for composing custom terminal UIs

/// ANSI escape-code parsing and attribute types.
pub mod ansi;
/// Tab-completion provider interface and built-in implementations.
pub mod completion;
/// Syntax-highlighting trait and Lua keyword highlighter.
pub mod highlighter;
/// Render helpers that convert terminal state to `RenderCommand` sequences.
pub mod render;

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
