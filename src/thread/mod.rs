//! Cross-thread messaging via typed MPMC channels for Lua VM isolation.
//!
//! - Fixed-size thread pool for CPU-bound background tasks.
//! - Promise containers for single-value async results.
//! - Worker harness owning secondary Lua VMs for parallel script execution.

/// Typed MPMC channel built on `crossbeam`-style semantics for cross-thread messages.
pub mod channel;
/// Fixed-size thread pool for CPU-bound tasks dispatched from the game thread.
pub mod pool;
/// Single-value async result container shared between a producer thread and consumer.
pub mod promise;
/// Worker-thread harness that owns a secondary Lua VM and processes message payloads.
pub mod worker;
