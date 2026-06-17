//! High-level logging module that combines facade APIs with sink implementations. `log/mod` is the log module index, declaring `facade`, `sinks` so agents can identify which files own each feature slice before opening implementation code.
//! Re-exports level control and sink types for centralized runtime log configuration. `src/log/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `facade::{get_level, log_structured, set_level, LogFields}`, `sinks::{MemoryEntry, RotatingFileSink, Sink, SinkLevel, SinkRegistry}` centralized for the log subsystem.

/// Structured log facade: global level, enabled checks, and dispatch to sink registry.
pub mod facade;
/// Log sink types: rotating file sink, in-memory ring buffer, and sink registry.
pub mod sinks;
pub use facade::{get_level, log_structured, set_level, LogFields};
/// Sink types for routing structured log output to files and in-memory buffers.
pub use sinks::{MemoryEntry, RotatingFileSink, Sink, SinkLevel, SinkRegistry};
