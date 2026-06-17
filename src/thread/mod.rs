//! This module delivers the high-level concurrency layer for isolated Lua workers in the runtime. `thread/mod` is the thread module index, declaring `channel`, `pool`, `promise`, `worker` so agents can identify which files own each feature slice before opening implementation code.
//! It combines channels, worker execution, pools, and one-shot promises into one coherent flow model. `src/thread/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through no named public items centralized for the thread subsystem.

/// Typed MPMC channel built on `crossbeam`-style semantics for cross-thread messages.
pub mod channel;
/// Fixed-size thread pool for CPU-bound tasks dispatched from the game thread.
pub mod pool;
/// Single-value async result container shared between a producer thread and consumer.
pub mod promise;
/// Worker-thread harness that owns a secondary Lua VM and processes message payloads.
pub mod worker;
