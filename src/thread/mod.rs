//! This module delivers the high-level concurrency layer for isolated Lua workers in the runtime.
//! It combines channels, worker execution, pools, and one-shot promises into one coherent flow model.
//! It keeps cross-thread scripting safe by enforcing message passing instead of shared VM state.
/// Typed MPMC channel built on `crossbeam`-style semantics for cross-thread messages.
pub mod channel;
/// Fixed-size thread pool for CPU-bound tasks dispatched from the game thread.
pub mod pool;
/// Single-value async result container shared between a producer thread and consumer.
pub mod promise;
/// Worker-thread harness that owns a secondary Lua VM and processes message payloads.
pub mod worker;
