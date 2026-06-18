//! `src/log/mod.rs` is the module index that exposes structured logging helpers and sink infrastructure.
//! It reexports level control, structured dispatch, and sink types so runtime code uses one stable logging surface.
//! No active sink registry lives here; this file only declares child modules and defines which logging symbols are public.
//! Read this index when wiring diagnostics, because it shows where caller-facing logging ends and backend sinks begin.
//! Changes here reshape the logging boundary, since reexports decide what runtime and Lua-facing code may import.
//! This module keeps facade APIs and sink implementations separated, which makes logging ownership easier to trace.

/// Structured log facade: global level, enabled checks, and dispatch to sink registry.
pub mod facade;
/// Log sink types: rotating file sink, in-memory ring buffer, and sink registry.
pub mod sinks;
pub use facade::{get_level, log_structured, set_level, LogFields};
/// Sink types for routing structured log output to files and in-memory buffers.
pub use sinks::{MemoryEntry, RotatingFileSink, Sink, SinkLevel, SinkRegistry};
