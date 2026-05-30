//! High-level logging module that combines facade APIs with sink implementations.
//! Re-exports level control and sink types for centralized runtime log configuration.
//! Defines the boundary for structured log routing to memory and file backends.

/// Structured log facade: global level, enabled checks, and dispatch to sink registry.
pub mod facade;
/// Log sink types: rotating file sink, in-memory ring buffer, and sink registry.
pub mod sinks;
pub use facade::{get_level, log_structured, set_level, LogFields};
/// Sink types for routing structured log output to files and in-memory buffers.
pub use sinks::{MemoryEntry, RotatingFileSink, Sink, SinkLevel, SinkRegistry};
