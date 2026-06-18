//! `src/thread/mod.rs` is the module index that exposes channels, workers, pools, and promises for Lua concurrency.
//! It groups message transport and worker orchestration so background Lua execution uses one thread surface.
//! No live thread state lives here; this file only declares child modules and documents the concurrency split by concern.
//! Read this index when wiring background execution, because it shows where message passing ends and worker control begins.
//! Changes here reshape the thread boundary, since module visibility defines which concurrency tools other systems use.
//! This module keeps channels, worker lifecycles, pooling, and one-shot results separated for easier ownership tracing.

/// Typed MPMC channel built on `crossbeam`-style semantics for cross-thread messages.
pub mod channel;
/// Fixed-size thread pool for CPU-bound tasks dispatched from the game thread.
pub mod pool;
/// Single-value async result container shared between a producer thread and consumer.
pub mod promise;
/// Worker-thread harness that owns a secondary Lua VM and processes message payloads.
pub mod worker;
