//! Defines the devtools module boundary for profiling, logging, REPL, and file-watch diagnostics. `devtools/mod` is the devtools module index, declaring `frame_stats`, `logger`, `lua_display`, `profiler`, `repl`, and 2 more so agents can identify which files own each feature slice before opening implementation code.
//! Groups developer instrumentation utilities into one cohesive runtime helper surface. `src/devtools/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `frame_stats::{FrameSnapshot, FrameStats}`, `logger::{LogEntry, LogLevel, Logger}`, `profiler::{ProfileZone, Profiler}`, `repl::ReplConsole`, and 1 more centralized for the devtools subsystem.

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
