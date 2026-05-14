//! - Structured logging facade with global level control and dispatch to registered sinks.
//! - Rotating file sink and in-memory ring buffer for runtime log capture.
//! - Level-gated emission so disabled messages cost near-zero.

/// Structured log facade: global level, enabled checks, and dispatch to sink registry.
pub mod facade;
/// Log sink types: rotating file sink, in-memory ring buffer, and sink registry.
pub mod sinks;
/// Structured log dispatch and level configuration API.
pub use facade::{enabled_for, get_level, log_structured, set_level, LogFields};
/// Sink types for routing structured log output to files and in-memory buffers.
pub use sinks::{MemoryEntry, RotatingFileSink, Sink, SinkLevel, SinkRegistry};
