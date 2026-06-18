//! This module re-exports devtools support for frame stats, logging, profiling, REPL helpers, timing, and file watching.
//! It is the navigation map for developer instrumentation surfaces rather than the owner of runtime capture state.
//! `frame_stats.rs` owns rolling frame metrics, while `profiler.rs` records hierarchical timing trees across frames.
//! `logger.rs` and `repl.rs` cover diagnostic text capture and command evaluation used by developer workflows.
//! `lua_display.rs`, `time_anchor.rs`, and `watcher.rs` provide value formatting, clocks, and change detection.
//! Change this file when public devtools exports move; change sibling files when the underlying behavior changes.

/// Expose frame-time history collection and aggregate snapshot helpers.
pub mod frame_stats;
/// Expose lightweight log storage and filtering helpers for developer output.
pub mod logger;
/// Expose Lua value formatting helpers for developer-facing text output.
pub mod lua_display;
/// Expose hierarchical profiler zone recording across captured frames.
pub mod profiler;
/// Expose a Lua REPL console with bounded in-memory command history.
pub mod repl;
/// Expose monotonic anchor timestamps for elapsed-time calculations.
pub mod time_anchor;
/// Expose watched-file change tracking for hot-reload related workflows.
pub mod watcher;
/// Re-export frame stats types used by devtools integration points.
pub use frame_stats::{FrameSnapshot, FrameStats};
/// Re-export logger types for message capture and filtering.
pub use logger::{LogEntry, LogLevel, Logger};
/// Re-export profiler types for zone-level timing inspection.
pub use profiler::{ProfileZone, Profiler};
/// Re-export the REPL console type for runtime integration.
pub use repl::ReplConsole;
/// Re-export file watcher type used by hot-reload logic.
pub use watcher::FileWatcher;
